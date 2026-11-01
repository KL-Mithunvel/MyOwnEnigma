`timescale 1ns / 1ps
// plugboard.v - Steckerbrett: up to 10 letter pairs -> 26-entry swap map.
//
// Pair i is active when en[i] = 1 and connects letter a[5i+4:5i] with letter b[5i+4:5i].
// map[5k+4:5k] is the letter that letter k is swapped with (k itself when unplugged).
// An invalid pair (letter >= 26, a pair with itself, or a letter already used) is ignored
// and raises `error`. Pure combinational logic.
//
// Implemented as a function driven by a continuous assignment (rather than `always @*`) so the
// outputs are defined from time 0 in simulation even when the inputs never change.
module plugboard (
    input  wire [9:0]   en,
    input  wire [49:0]  a,
    input  wire [49:0]  b,
    output wire [129:0] map,
    output wire         error
);
    // Returns {error, map[129:0]}
    function [130:0] build;
        input [9:0]  f_en;
        input [49:0] f_a;
        input [49:0] f_b;
        integer    i;
        integer    k;
        reg [25:0]  used;
        reg [129:0] m;
        reg         err;
        reg [4:0]   la;
        reg [4:0]   lb;
        reg [4:0]   kk;
        begin
            used = 26'd0;
            err  = 1'b0;
            for (k = 0; k < 26; k = k + 1) begin
                kk = k;
                m[k*5 +: 5] = kk;
            end
            for (i = 0; i < 10; i = i + 1) begin
                if (f_en[i]) begin
                    la = f_a[i*5 +: 5];
                    lb = f_b[i*5 +: 5];
                    if (la >= 5'd26 || lb >= 5'd26 || la == lb) begin
                        err = 1'b1;
                    end else if (used[la] || used[lb]) begin
                        err = 1'b1;
                    end else begin
                        used[la] = 1'b1;
                        used[lb] = 1'b1;
                        m[la*5 +: 5] = lb;
                        m[lb*5 +: 5] = la;
                    end
                end
            end
            build = {err, m};
        end
    endfunction

    assign {error, map} = build(en, a, b);
endmodule
