`timescale 1ns / 1ps
// tb_lamp_driver.v - verifies lamp_driver. Expected lamp codes are written out independently here
// (A-M -> 0..12 on mux 1, N-Z -> 16..28 on mux 2, 31 = all off), NOT taken from the generated table,
// so an error in config.yaml's lamp table would be caught. Prints PASS/FAIL on the last line.
module tb_lamp_driver;
    localparam MIN_ON = 50;

    reg clk = 1'b0;
    always #5 clk = ~clk;
    reg rst = 1'b1;
    reg set = 1'b0;
    reg [4:0] letter = 5'd0;
    reg hold = 1'b0;
    wire [4:0] lb;
    wire lb4N;

    lamp_driver #(.MIN_ON_TICKS(MIN_ON)) dut (
        .clk(clk), .rst(rst), .set(set), .letter(letter), .hold(hold), .lb(lb), .lb4N(lb4N)
    );

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
                if (errors <= 20) $display("  MISMATCH %0s: got %0d expected %0d (t=%0t)", what, got, expected, $time);
            end
        end
    endtask

    task pulse_set;
        input [4:0] l;
        begin
            @(negedge clk); letter = l; set = 1'b1;
            @(negedge clk); set = 1'b0;
        end
    endtask

    function [4:0] expected_code;
        input integer idx;
        begin
            if (idx < 13)      expected_code = idx;
            else if (idx < 26) expected_code = 16 + (idx - 13);
            else               expected_code = 31;
        end
    endfunction

    integer k;

    initial begin
        if ($test$plusargs("VCD")) begin
            $dumpfile("sim/build/tb_lamp_driver.vcd");
            $dumpvars(0, tb_lamp_driver);
        end
        repeat (3) @(posedge clk);
        rst = 1'b0;
        repeat (3) @(posedge clk);
        check("idle lb", lb, 31);
        check("idle lb4N", lb4N, 0);

        // Every letter lights the right channel while held; lb4N is the inverse of lb[4].
        for (k = 0; k < 26; k = k + 1) begin
            hold = 1'b1;
            pulse_set(k);
            repeat (4) @(posedge clk);
            check("letter code", lb, expected_code(k));
            check("lb4N inverse", lb4N, (expected_code(k) >= 16) ? 0 : 1);
            repeat (MIN_ON * 2) @(posedge clk);          // still held, well past min on-time
            check("stays lit while held", lb, expected_code(k));
            hold = 1'b0;
            repeat (6) @(posedge clk);
            check("dark after release", lb, 31);
            check("dark lb4N", lb4N, 0);
        end

        // Minimum on-time: a quick tap (hold never raised) stays lit for MIN_ON clocks.
        hold = 1'b0;
        pulse_set(5'd4);                                 // E
        repeat (MIN_ON / 2) @(posedge clk);
        check("min on-time: still lit", lb, 4);
        repeat (MIN_ON) @(posedge clk);
        check("min on-time: expired", lb, 31);

        // A new letter replaces the old one immediately.
        hold = 1'b1;
        pulse_set(5'd0);
        pulse_set(5'd25);
        repeat (4) @(posedge clk);
        check("replacement letter", lb, 28);
        hold = 1'b0;
        repeat (MIN_ON + 10) @(posedge clk);

        // Invalid letter lights nothing.
        pulse_set(5'd30);
        repeat (4) @(posedge clk);
        check("invalid letter", lb, 31);

        // Continuous `set` (used for window display) keeps the lamp lit.
        hold = 1'b0;
        @(negedge clk); letter = 5'd7; set = 1'b1;
        repeat (MIN_ON * 3) @(posedge clk);
        check("continuous set stays lit", lb, 7);
        @(negedge clk); set = 1'b0;
        repeat (MIN_ON + 10) @(posedge clk);
        check("dark after continuous set", lb, 31);

        $display("tb_lamp_driver: %0d checks, %0d errors", checks, errors);
        if (errors == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end

    initial begin
        #50_000_000;
        $display("FAIL: testbench timeout");
        $finish;
    end
endmodule
