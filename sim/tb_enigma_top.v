`timescale 1ns / 1ps
// tb_enigma_top.v - full-system test of enigma_top.
// A behavioural keyboard (diode matrix) and lamp-board decoder surround the DUT. For every vector in
// sim/build/sys_vectors.txt (made by tools/gen_vectors.py from the Python golden model) the testbench:
//   1. selects the preset on sw[1:0], enters SETUP mode (sw[2]) and types the three start letters
//      (checking the echo on the lamp board), leaves setup mode;
//   2. types the message and checks every lamp against the model's ciphertext;
//   3. holds btn[1..3] and checks the lamp board shows the left/middle/right window letters;
//   4. presses btn[0] (reload) and checks the first letter encrypts the same as before.
// The expected lamp decoding (A-M -> 0..12, N-Z -> 16..28) is written independently of the tables.
module tb_enigma_top;
    localparam SCAN  = 40;
    localparam COLS  = 9;
    localparam DEB   = 3;
    localparam FRAME = SCAN * COLS;
    localparam MIN_ON = 200;
    localparam BTN_DEB = 20;

    reg clk = 1'b0;
    always #5 clk = ~clk;

    reg [2:0] sw = 3'b000;
    reg [3:0] btn = 4'b0000;
    wire [3:0] led;
    wire led0_r, led0_g, led0_b, led1_r, led1_g, led1_b;
    wire ck_io0, ck_io1, ck_io2, ck_io3;
    wire ck_io5, ck_io6, ck_io7, ck_io8;
    wire o_lb0, o_lb1, o_lb2, o_lb3, o_lb4, o_lb4N;

    // ---- keyboard model -------------------------------------------------------------
    reg [4:0] pressed = 5'd31;
`include "enigma_tables.vh"   // key_pattern()
    wire [7:0] pat = key_pattern(pressed);
    wire [3:0] col_sel = {ck_io3, ck_io2, ck_io1, ck_io0};
    wire [3:0] rows = (pressed != 5'd31 && col_sel == pat[7:4]) ? pat[3:0] : 4'd0;
    assign {ck_io5, ck_io6, ck_io7, ck_io8} = rows;

    enigma_top #(
        .SCAN_TICKS(SCAN), .NUM_COLS(COLS), .DEBOUNCE_FRAMES(DEB),
        .LAMP_MIN_ON_TICKS(MIN_ON), .BTN_DEBOUNCE_TICKS(BTN_DEB), .HEARTBEAT_TICKS(100)
    ) dut (
        .CLK100MHZ(clk), .sw(sw), .btn(btn), .led(led),
        .led0_r(led0_r), .led0_g(led0_g), .led0_b(led0_b),
        .led1_r(led1_r), .led1_g(led1_g), .led1_b(led1_b),
        .ck_io0(ck_io0), .ck_io1(ck_io1), .ck_io2(ck_io2), .ck_io3(ck_io3),
        .ck_io5(ck_io5), .ck_io6(ck_io6), .ck_io7(ck_io7), .ck_io8(ck_io8),
        .o_lb0(o_lb0), .o_lb1(o_lb1), .o_lb2(o_lb2), .o_lb3(o_lb3), .o_lb4(o_lb4), .o_lb4N(o_lb4N)
    );

    // ---- lamp board decoder: which letter is lit (31 = none) ------------------------------
    wire [4:0] lamp_code = {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0};
    function [4:0] lit_letter;
        input [4:0] code;
        begin
            if (code <= 5'd12)                     lit_letter = code;
            else if (code >= 5'd16 && code <= 5'd28) lit_letter = code - 5'd3;
            else                                     lit_letter = 5'd31;
        end
    endfunction

    integer errors = 0;
    integer checks = 0;

    task check;
        input [255:0] what;
        input integer got;
        input integer expected;
        begin
            checks = checks + 1;
            if (got !== expected) begin
                errors = errors + 1;
                if (errors <= 25) $display("  MISMATCH %0s: got %0d expected %0d (t=%0t)", what, got, expected, $time);
            end
        end
    endtask

    task frames;
        input integer n;
        begin repeat (n * FRAME) @(posedge clk); end
    endtask

    // Press a key, read the lamp while it is held, release, and confirm the lamp goes dark.
    task type_key;
        input [4:0] letter;
        output [4:0] lamp_seen;
        begin
            pressed = letter;
            frames(DEB + 3);
            lamp_seen = lit_letter(lamp_code);
            check("lamp inverse bit", o_lb4N, o_lb4 ? 0 : 1);
            pressed = 5'd31;
            frames(2);
            repeat (MIN_ON + 20) @(posedge clk);
            check("lamp dark after release", lit_letter(lamp_code), 31);
        end
    endtask

    task hold_button;
        input integer which;          // 1 = left, 2 = middle, 3 = right
        output [4:0] lamp_seen;
        begin
            btn[which] = 1'b1;
            repeat (BTN_DEB + 60) @(posedge clk);
            lamp_seen = lit_letter(lamp_code);
            btn[which] = 1'b0;
            repeat (BTN_DEB + MIN_ON + 40) @(posedge clk);
        end
    endtask

    task press_reload;
        begin
            btn[0] = 1'b1;
            repeat (BTN_DEB + 40) @(posedge clk);
            btn[0] = 1'b0;
            repeat (BTN_DEB + 40) @(posedge clk);
        end
    endtask

    // ---- vector file -------------------------------------------------------------------
    integer fd, rc, preset, sl, sm, sr, len, fl, fm, fr, i, vec_count;
    integer pt [0:127];
    integer ct [0:127];
    reg [4:0] seen;
    reg [8*200-1:0] vec_path;

    initial begin
        if (!$value$plusargs("SYSVEC=%s", vec_path)) vec_path = "sim/build/sys_vectors.txt";
        if ($test$plusargs("VCD")) begin
            $dumpfile("sim/build/tb_enigma_top.vcd");
            $dumpvars(0, tb_enigma_top);
        end

        repeat (40) @(posedge clk);
        // Power-up sanity: lamps dark, heartbeat running, ready LED on.
        check("power-up lamps dark", lit_letter(lamp_code), 31);
        check("ready (green) LED", led1_g, 1);
        check("no plug error", led[2], 0);

        vec_count = 0;
        fd = $fopen(vec_path, "r");
        if (fd == 0) begin
            $display("  cannot open %0s", vec_path);
            errors = errors + 1;
        end else begin
            rc = $fscanf(fd, "%d", preset);
            while (rc == 1) begin
                rc = $fscanf(fd, "%d %d %d %d", sl, sm, sr, len);
                for (i = 0; i < len; i = i + 1) rc = $fscanf(fd, "%d", pt[i]);
                for (i = 0; i < len; i = i + 1) rc = $fscanf(fd, "%d", ct[i]);
                rc = $fscanf(fd, "%d %d %d", fl, fm, fr);

                // 1. preset + setup mode: type the start window, check the echo
                sw[1:0] = preset[1:0];
                repeat (BTN_DEB + 40) @(posedge clk);
                sw[2] = 1'b1;
                repeat (BTN_DEB + 40) @(posedge clk);
                check("setup LED", led[1], 1);
                type_key(sl[4:0], seen); check("echo left", seen, sl);
                type_key(sm[4:0], seen); check("echo middle", seen, sm);
                type_key(sr[4:0], seen); check("echo right", seen, sr);
                sw[2] = 1'b0;
                repeat (BTN_DEB + 80) @(posedge clk);
                check("setup LED off", led[1], 0);

                // window display right after setup shows the typed start letters
                hold_button(1, seen); check("start window left", seen, sl);
                hold_button(2, seen); check("start window middle", seen, sm);
                hold_button(3, seen); check("start window right", seen, sr);

                // 2. the message
                for (i = 0; i < len; i = i + 1) begin
                    type_key(pt[i][4:0], seen);
                    check("cipher letter", seen, ct[i]);
                end

                // 3. window display shows the final rotor positions
                hold_button(1, seen); check("final window left", seen, fl);
                hold_button(2, seen); check("final window middle", seen, fm);
                hold_button(3, seen); check("final window right", seen, fr);

                // 4. reload returns to the typed start window: first letter encrypts identically
                press_reload;
                type_key(pt[0][4:0], seen);
                check("reload repeats first letter", seen, ct[0]);

                vec_count = vec_count + 1;
                rc = $fscanf(fd, "%d", preset);
            end
            $fclose(fd);
            $display("  %0d system vectors", vec_count);
        end

        $display("tb_enigma_top: %0d checks, %0d errors", checks, errors);
        if (errors == 0 && vec_count > 0) $display("PASS"); else $display("FAIL");
        $finish;
    end

    initial begin
        #2_000_000_000;
        $display("FAIL: testbench timeout");
        $finish;
    end
endmodule
