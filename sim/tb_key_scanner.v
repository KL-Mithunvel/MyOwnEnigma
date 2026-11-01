`timescale 1ns / 1ps
// tb_key_scanner.v - verifies key_scanner against a behavioural model of the diode-matrix keyboard.
// Covers: all 26 keys, hold (single event), release, short tap rejection, two-key rollover handling,
// unknown row pattern, and direct key-to-key change. Prints PASS/FAIL on the last line.
module tb_key_scanner;
    localparam SCAN  = 40;
    localparam COLS  = 9;
    localparam DEB   = 3;
    localparam FRAME = SCAN * COLS;

    reg clk = 1'b0;
    always #5 clk = ~clk;
    reg rst = 1'b1;

    // Keyboard model: up to two pressed keys plus an optional stray row signal.
    reg [4:0] keyA = 5'd31;
    reg [4:0] keyB = 5'd31;
    reg       junk_en = 1'b0;
    reg [3:0] junk_col = 4'd0;
    reg [3:0] junk_rows = 4'd0;

    wire [3:0] col_sel;
    wire       key_valid, key_down;
    wire [4:0] key_code;

`include "enigma_tables.vh"   // key_pattern(): letter -> {column, rows}

    wire [7:0] patA = key_pattern(keyA);
    wire [7:0] patB = key_pattern(keyB);
    wire [3:0] rows = ((keyA != 5'd31 && col_sel == patA[7:4]) ? patA[3:0] : 4'd0)
                    | ((keyB != 5'd31 && col_sel == patB[7:4]) ? patB[3:0] : 4'd0)
                    | ((junk_en && col_sel == junk_col)        ? junk_rows   : 4'd0);

    key_scanner #(.SCAN_TICKS(SCAN), .NUM_COLS(COLS), .DEBOUNCE_FRAMES(DEB)) dut (
        .clk(clk), .rst(rst), .rows_in(rows), .col_sel(col_sel),
        .key_valid(key_valid), .key_down(key_down), .key_code(key_code)
    );

    integer errors = 0;
    integer checks = 0;
    integer pulses = 0;
    reg [4:0] last_code = 5'd31;
    always @(posedge clk) if (key_valid) begin pulses <= pulses + 1; last_code <= key_code; end

    task check;
        input [255:0] what;
        input integer got;
        input integer expected;
        begin
            checks = checks + 1;
            if (got !== expected) begin
                errors = errors + 1;
                if (errors <= 20) $display("  MISMATCH %0s: got %0d expected %0d (t=%0t)", what, got, expected, $time);
            end
        end
    endtask

    task frames;
        input integer n;
        begin repeat (n * FRAME) @(posedge clk); end
    endtask

    integer k, base_count;

    initial begin
        if ($test$plusargs("VCD")) begin
            $dumpfile("sim/build/tb_key_scanner.vcd");
            $dumpvars(0, tb_key_scanner);
        end
        repeat (5) @(posedge clk);
        rst = 1'b0;
        frames(2);
        check("idle: no pulses", pulses, 0);
        check("idle: key_down", key_down, 0);

        // 1. Every key: exactly one event with the right code, held, then released.
        for (k = 0; k < 26; k = k + 1) begin
            base_count = pulses;
            keyA = k;
            frames(DEB + 3);
            check("press pulses", pulses - base_count, 1);
            check("press code", last_code, k);
            check("press key_down", key_down, 1);
            frames(5);                       // keep holding: still only one event
            check("hold: no repeat", pulses - base_count, 1);
            keyA = 5'd31;
            frames(3);
            check("release key_down", key_down, 0);
            check("release: no extra pulse", pulses - base_count, 1);
        end

        // 2. Short tap (about one and a half frames) is rejected as bounce/noise.
        base_count = pulses;
        keyA = 5'd5;
        repeat (FRAME + FRAME / 2) @(posedge clk);
        keyA = 5'd31;
        frames(DEB + 2);
        check("short tap rejected", pulses - base_count, 0);

        // 3. Two different keys at once: ambiguous, ignored. Releasing one turns the other into a press.
        base_count = pulses;
        keyA = 5'd0;  keyB = 5'd11;          // A and L together
        frames(DEB + 4);
        check("two keys ignored", pulses - base_count, 0);
        keyB = 5'd31;
        frames(DEB + 3);
        check("remaining key fires", pulses - base_count, 1);
        check("remaining key code", last_code, 0);
        keyA = 5'd31;
        frames(3);

        // 4. Stray signal on a column/row combination that is not a key: no event.
        base_count = pulses;
        junk_en = 1'b1; junk_col = 4'd8; junk_rows = 4'b0001;
        frames(DEB + 4);
        check("unknown pattern ignored", pulses - base_count, 0);
        junk_en = 1'b0;
        frames(2);

        // 5. Direct key-to-key change while held produces a second event.
        base_count = pulses;
        keyA = 5'd3;
        frames(DEB + 3);
        keyA = 5'd22;
        frames(DEB + 3);
        check("key change events", pulses - base_count, 2);
        check("key change code", last_code, 22);
        keyA = 5'd31;
        frames(3);

        // 6. Reset in the middle of a press clears the state.
        keyA = 5'd9;
        frames(DEB + 3);
        rst = 1'b1; repeat (3) @(posedge clk); rst = 1'b0;
        check("reset clears key_down", key_down, 0);
        keyA = 5'd31;
        frames(2);

        $display("tb_key_scanner: %0d checks, %0d errors", checks, errors);
        if (errors == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end

    initial begin
        #100_000_000;
        $display("FAIL: testbench timeout");
        $finish;
    end
endmodule
