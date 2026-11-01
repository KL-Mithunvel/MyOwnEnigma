`timescale 1ns / 1ps
// plugboard.v - Steckerbrett: swaps one letter through up to 10 plugged pairs.
//
// Pair i is active when en[i] = 1 and connects letter a[5i+4:5i] with letter b[5i+4:5i].
// `swapped` is the letter that `c` is connected to (c itself when unplugged). The pairs are
// compared directly (priority chain), which is far smaller in an FPGA than building a 26-entry map.
// `error` flags an invalid configuration (letter >= 26, a pair with itself, or a letter used in more
// than one pair). With an invalid configuration `swapped` is deterministic (first matching pair wins)
// but not meaningful. Pure combinational logic.
//
// Implemented with functions and continuous assigns (not `always @*`) so the outputs are defined
// from time 0 in simulation even when the inputs never change.
module plugboard (
    input  wire [9:0]  en,
    input  wire [49:0] a,
    input  wire [49:0] b,
    input  wire [4:0]  c,
    output wire [4:0]  swapped,
    output wire        error
);
    function [4:0] swap;
        input [9:0]  f_en;
        input [49:0] f_a;
        input [49:0] f_b;
        input [4:0]  f_c;
        integer   i;
        reg [4:0] la;
        reg [4:0] lb;
        reg       hit;
        begin
            swap = f_c;
            hit  = 1'b0;
            for (i = 0; i < 10; i = i + 1) begin
                la = f_a[i*5 +: 5];
                lb = f_b[i*5 +: 5];
                if (f_en[i] && !hit) begin
                    if (f_c == la) begin
                        swap = lb;
                        hit  = 1'b1;
                    end else if (f_c == lb) begin
                        swap = la;
                        hit  = 1'b1;
                    end
                end
            end
        end
    endfunction

    function invalid;
        input [9:0]  f_en;
        input [49:0] f_a;
        input [49:0] f_b;
        integer    i;
        reg [25:0] used;
        reg [4:0]  la;
        reg [4:0]  lb;
        begin
            invalid = 1'b0;
            used    = 26'd0;
            for (i = 0; i < 10; i = i + 1) begin
                la = f_a[i*5 +: 5];
                lb = f_b[i*5 +: 5];
                if (f_en[i]) begin
                    if (la >= 5'd26 || lb >= 5'd26 || la == lb) begin
                        invalid = 1'b1;
                    end else begin
                        if (used[la] || used[lb]) invalid = 1'b1;
                        used[la] = 1'b1;
                        used[lb] = 1'b1;
                    end
                end
            end
        end
    endfunction

    assign swapped = swap(en, a, b, c);
    assign error   = invalid(en, a, b);
endmodule
