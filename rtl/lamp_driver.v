`timescale 1ns / 1ps
`include "enigma_params.vh"
// lamp_driver.v - drives the lamp board's two CD74HC4067 multiplexers.
//
// `set` (any time, even every clock) latches `letter` and lights its lamp. The lamp stays lit while
// `hold` is high (e.g. the key is still pressed) and in any case for at least MIN_ON_TICKS clocks,
// so even a quick tap is visible. Then all lamps go dark (idle code selects an unused mux channel).
// Outputs are registered so the mux select lines never glitch. `lb4N` is the inverse of `lb[4]`
// and enables the second multiplexer. Letter -> code table: config.yaml -> lamp.codes.
module lamp_driver #(
    parameter MIN_ON_TICKS = `CFG_LAMP_MIN_ON_TICKS
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       set,       // latch `letter` and light it
    input  wire [4:0] letter,    // A=0 .. Z=25 (anything else lights nothing)
    input  wire       hold,      // keep lit while high
    output reg  [4:0] lb,        // o_lb4..o_lb0
    output reg        lb4N       // o_lb4N
);

`include "enigma_tables.vh"

    localparam [4:0] IDLE = `CFG_LAMP_IDLE_CODE;   // selects an unused mux channel = all lamps off

    reg        lit;
    reg [4:0]  code;
    reg [31:0] on_count;

    always @(posedge clk) begin
        if (rst) begin
            lit      <= 1'b0;
            code     <= IDLE;
            on_count <= 32'd0;
            lb       <= IDLE;
            lb4N     <= ~IDLE[4];
        end else begin
            if (set) begin
                lit      <= 1'b1;
                code     <= lamp_encode(letter);
                on_count <= MIN_ON_TICKS;
            end else if (on_count != 32'd0) begin
                on_count <= on_count - 32'd1;
            end else if (!hold) begin
                lit <= 1'b0;
            end
            lb   <= lit ? code : IDLE;
            lb4N <= ~(lit ? code[4] : IDLE[4]);
        end
    end
endmodule
