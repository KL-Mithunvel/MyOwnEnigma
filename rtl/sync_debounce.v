`timescale 1ns / 1ps
`include "enigma_params.vh"
// sync_debounce.v - 2-flop synchroniser plus debounce for a switch or push button.
// `level` follows `in` only after `in` has been stable for TICKS clocks; `rise` is a one-clock
// pulse on each 0 -> 1 transition of `level`. Power-up state is 0 (FPGA register initial values).
module sync_debounce #(
    parameter TICKS = `CFG_BTN_DEBOUNCE_TICKS
) (
    input  wire clk,
    input  wire in,
    output reg  level = 1'b0,
    output wire rise
);
    reg        s1 = 1'b0;
    reg        s2 = 1'b0;
    reg        prev = 1'b0;
    reg [31:0] count = 32'd0;

    always @(posedge clk) begin
        s1   <= in;
        s2   <= s1;
        prev <= level;
        if (s2 == level) begin
            count <= 32'd0;
        end else if (count == TICKS - 1) begin
            level <= s2;
            count <= 32'd0;
        end else begin
            count <= count + 32'd1;
        end
    end

    assign rise = level & ~prev;
endmodule
