`timescale 1ns / 1ps
`include "enigma_params.vh"
// enigma_core.v - Enigma I / M3 cipher engine: 3 rotors (I-V), reflector B/C, ring settings,
// double-stepping and a 10-pair plugboard.
//
// Operation: pulse `key_valid` with a letter code (0..25) while `busy` is low. The core steps
// the rotors, then pushes the letter through one stage per clock:
//   PLUG_IN -> R fwd -> M fwd -> L fwd -> REFLECTOR -> L inv -> M inv -> R inv -> PLUG_OUT
// and finally pulses `done` for one clock with the result on `lamp_code` (held until the next
// letter). 10 clocks after the key, so 100 ns at 100 MHz.
//
// Configuration inputs are read live: change rotor/ring/reflector/plug settings only while
// idle (between letters). `load` (idle only) copies `start_pos` into the rotor positions.
// Bus packing is {left, middle, right}, most significant first. Letters: A=0 .. Z=25.
// Spec and formulas: docs/ENIGMA_SPEC.md. Golden model: tools/enigma_ref.py.
module enigma_core (
    input  wire        clk,
    input  wire        rst,           // synchronous, active high: positions -> AAA

    input  wire        load,          // pulse: load start_pos into the rotor positions (idle only)
    input  wire [14:0] start_pos,     // {left, middle, right} window letters

    input  wire [8:0]  rotor_sel,     // {left, middle, right}: I=0 II=1 III=2 IV=3 V=4
    input  wire [14:0] ring_set,      // {left, middle, right} ring settings, A=0
    input  wire        reflector_sel, // 0 = UKW-B, 1 = UKW-C

    input  wire [9:0]  plug_en,       // plugboard pairs, see plugboard.v
    input  wire [49:0] plug_a,
    input  wire [49:0] plug_b,

    input  wire        key_valid,     // pulse: encrypt key_code (ignored while busy)
    input  wire [4:0]  key_code,      // 0..25; larger values are ignored

    output wire        busy,          // high while a letter is in flight
    output reg         done,          // one-clock pulse: lamp_code is valid
    output reg  [4:0]  lamp_code,     // encrypted letter, held until the next letter
    output wire [14:0] pos_out,       // current window letters {left, middle, right}
    output wire        plug_error     // invalid plugboard configuration
);

`include "enigma_tables.vh"
`include "enigma_math.vh"

    // ---- state encoding -------------------------------------------------------
    localparam [3:0] S_IDLE     = 4'd0;
    localparam [3:0] S_PLUG_IN  = 4'd1;
    localparam [3:0] S_R_FWD    = 4'd2;
    localparam [3:0] S_M_FWD    = 4'd3;
    localparam [3:0] S_L_FWD    = 4'd4;
    localparam [3:0] S_REFLECT  = 4'd5;
    localparam [3:0] S_L_INV    = 4'd6;
    localparam [3:0] S_M_INV    = 4'd7;
    localparam [3:0] S_R_INV    = 4'd8;
    localparam [3:0] S_PLUG_OUT = 4'd9;

    reg [3:0] state;
    reg [4:0] sig;                   // the letter travelling through the machine
    reg [4:0] pos_l, pos_m, pos_r;   // rotor window positions

    assign busy    = (state != S_IDLE);
    assign pos_out = {pos_l, pos_m, pos_r};

    // ---- unpack configuration ------------------------------------------------
    wire [2:0] rsel_l = rotor_sel[8:6];
    wire [2:0] rsel_m = rotor_sel[5:3];
    wire [2:0] rsel_r = rotor_sel[2:0];
    wire [4:0] ring_l = ring_set[14:10];
    wire [4:0] ring_m = ring_set[9:5];
    wire [4:0] ring_r = ring_set[4:0];

    // ---- plugboard ----------------------------------------------------------------
    wire [129:0] plug_map;
    plugboard u_plugboard (
        .en(plug_en), .a(plug_a), .b(plug_b), .map(plug_map), .error(plug_error)
    );

    // ---- stepping decision (double-step included) -----------------------------
    wire mid_at_notch   = (pos_m == rotor_notch(rsel_m));
    wire right_at_notch = (pos_r == rotor_notch(rsel_r));

    wire key_ok = key_valid && (key_code < 5'd26);

    always @(posedge clk) begin
        done <= 1'b0;
        if (rst) begin
            state <= S_IDLE;
            sig   <= 5'd0;
            pos_l <= 5'd0;
            pos_m <= 5'd0;
            pos_r <= 5'd0;
            lamp_code <= 5'd0;
        end else begin
            case (state)
                S_IDLE: begin
                    if (load) begin
                        pos_l <= start_pos[14:10];
                        pos_m <= start_pos[9:5];
                        pos_r <= start_pos[4:0];
                    end else if (key_ok) begin
                        // Step first, then encrypt (the rotors move before the current flows).
                        if (mid_at_notch)                  pos_l <= add26(pos_l, 5'd1);
                        if (mid_at_notch || right_at_notch) pos_m <= add26(pos_m, 5'd1);
                        pos_r <= add26(pos_r, 5'd1);
                        sig   <= key_code;
                        state <= S_PLUG_IN;
                    end
                end
                S_PLUG_IN: begin
                    sig   <= plug_map[sig*5 +: 5];
                    state <= S_R_FWD;
                end
                S_R_FWD: begin
                    sig   <= rotor_pass(rsel_r, pos_r, ring_r, 1'b1, sig);
                    state <= S_M_FWD;
                end
                S_M_FWD: begin
                    sig   <= rotor_pass(rsel_m, pos_m, ring_m, 1'b1, sig);
                    state <= S_L_FWD;
                end
                S_L_FWD: begin
                    sig   <= rotor_pass(rsel_l, pos_l, ring_l, 1'b1, sig);
                    state <= S_REFLECT;
                end
                S_REFLECT: begin
                    sig   <= reflect(reflector_sel, sig);
                    state <= S_L_INV;
                end
                S_L_INV: begin
                    sig   <= rotor_pass(rsel_l, pos_l, ring_l, 1'b0, sig);
                    state <= S_M_INV;
                end
                S_M_INV: begin
                    sig   <= rotor_pass(rsel_m, pos_m, ring_m, 1'b0, sig);
                    state <= S_R_INV;
                end
                S_R_INV: begin
                    sig   <= rotor_pass(rsel_r, pos_r, ring_r, 1'b0, sig);
                    state <= S_PLUG_OUT;
                end
                S_PLUG_OUT: begin
                    lamp_code <= plug_map[sig*5 +: 5];
                    done      <= 1'b1;
                    state     <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
