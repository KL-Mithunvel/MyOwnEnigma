`timescale 1ns / 1ps
`include "enigma_params.vh"
// key_scanner.v - scans the diode-matrix keyboard through the CD74HC4067 mux and reports
// debounced key presses.
//
// The FPGA drives `col_sel` (the mux channel) and reads `rows_in` back. Each column stays selected
// for SCAN_TICKS clocks so the analog mux can settle, then rows are sampled once. One pass over all
// NUM_COLS columns is a "frame". A key becomes a press only after it is seen alone in
// DEBOUNCE_FRAMES consecutive frames:
//   * more than one key (or an unknown row pattern) in a frame -> frame ignored (no ghost letters)
//   * no key in a frame                                        -> release
// Outputs: `key_valid` is a one-clock pulse per press, `key_down` stays high while it is held,
// `key_code` holds the letter (A=0 .. Z=25). Key table: config.yaml -> keyboard.keys.
module key_scanner #(
    parameter SCAN_TICKS      = `CFG_SCAN_TICKS,
    parameter NUM_COLS        = `CFG_NUM_COLS,
    parameter DEBOUNCE_FRAMES = `CFG_DEBOUNCE_FRAMES
) (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] rows_in,     // {ck_io5, ck_io6, ck_io7, ck_io8}, asynchronous
    output reg  [3:0] col_sel,     // ck_io3..ck_io0
    output reg        key_valid,   // one-clock pulse on a debounced press
    output reg        key_down,    // high while that key is held
    output reg  [4:0] key_code
);

`include "enigma_tables.vh"
`include "enigma_util.vh"

    // Two-flop synchroniser for the asynchronous row inputs.
    reg [3:0] rows_s1, rows_s2;
    always @(posedge clk) begin
        rows_s1 <= rows_in;
        rows_s2 <= rows_s1;
    end

    localparam TICK_W = clog2(SCAN_TICKS) + 1;
    reg [TICK_W-1:0] tick;
    reg [3:0]  col;
    reg        frame_found;     // a valid key has been seen in this frame
    reg        frame_multi;     // ambiguous: two keys, or an unknown row pattern
    reg [4:0]  frame_code;
    reg [4:0]  cand;            // candidate key being debounced (31 = none)
    reg [7:0]  stable;          // consecutive frames the candidate has been seen

    // Next-state temporaries (blocking, evaluated only at the sample instant).
    reg        n_found;
    reg        n_multi;
    reg [4:0]  n_code;
    reg [7:0]  n_stable;
    reg        changed;

    wire [4:0] decoded = key_decode({col_sel, rows_s2});
    wire       sample  = (tick == SCAN_TICKS - 1);

    always @(posedge clk) begin
        key_valid <= 1'b0;
        if (rst) begin
            tick        <= {TICK_W{1'b0}};
            col         <= 4'd0;
            col_sel     <= 4'd0;
            frame_found <= 1'b0;
            frame_multi <= 1'b0;
            frame_code  <= 5'd31;
            cand        <= 5'd31;
            stable      <= 8'd0;
            key_down    <= 1'b0;
            key_code    <= 5'd31;
        end else if (!sample) begin
            tick <= tick + 1'b1;
        end else begin
            tick <= {TICK_W{1'b0}};

            // Fold this column's sample into the frame.
            n_found = frame_found;
            n_multi = frame_multi;
            n_code  = frame_code;
            if (rows_s2 != 4'd0) begin
                if (decoded == 5'd31)        n_multi = 1'b1;         // unknown pattern
                else if (!n_found) begin     n_found = 1'b1; n_code = decoded; end
                else if (n_code != decoded)  n_multi = 1'b1;         // second, different key
            end

            if (col != NUM_COLS - 1) begin
                // Mid-frame: advance to the next column.
                col         <= col + 4'd1;
                col_sel     <= col + 4'd1;
                frame_found <= n_found;
                frame_multi <= n_multi;
                frame_code  <= n_code;
            end else begin
                // End of frame: start the next one and decide.
                col         <= 4'd0;
                col_sel     <= 4'd0;
                frame_found <= 1'b0;
                frame_multi <= 1'b0;
                frame_code  <= 5'd31;
                if (!n_multi) begin
                    if (n_found) begin
                        changed  = !(stable != 8'd0 && n_code == cand);
                        n_stable = changed ? 8'd1 : ((stable < DEBOUNCE_FRAMES) ? stable + 8'd1 : stable);
                        cand     <= n_code;
                        stable   <= n_stable;
                        if (changed) key_down <= 1'b0;
                        if (n_stable == DEBOUNCE_FRAMES && (changed || stable < DEBOUNCE_FRAMES)) begin
                            key_down  <= 1'b1;
                            key_valid <= 1'b1;
                            key_code  <= n_code;
                        end
                    end else begin
                        cand     <= 5'd31;
                        stable   <= 8'd0;
                        key_down <= 1'b0;
                    end
                end
            end
        end
    end
endmodule
