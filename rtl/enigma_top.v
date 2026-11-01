`timescale 1ns / 1ps
`include "enigma_params.vh"
// enigma_top.v - Arty S7-50 top level of the FPGA Enigma. Needs only the keyboard and lamp board.
//
// Controls (all 3.3 V board I/O; sw[3] is deliberately unused - it sits in the 1.35 V DDR bank):
//   sw[1:0]  machine preset 0..3 (rotors, rings, reflector, plugboard) - see config.yaml -> presets.
//            Change presets between letters.
//   sw[2]    SETUP mode. While on, typed letters shift into the start window (the last three typed
//            letters = left, middle, right) and are echoed on the lamp board; nothing is encrypted.
//            Switching it off loads that window into the rotors and returns to normal operation.
//   btn[0]   reload the typed start window into the rotors (start a new message).
//   btn[1..3] hold to display the LEFT / MIDDLE / RIGHT rotor window letter on the lamp board.
//            Hold all three together for the LAMP SELF-TEST: the lamps sweep A..Z (no keyboard needed).
//   Keyboard: each press encrypts a letter, steps the rotors, and lights the lamp while held.
// Status: led[0] key held, led[1] setup mode, led[2] plug error, led[3] heartbeat (bitstream alive).
//         RGB0 shows the preset colour; RGB1: green = ready, blue = setup, red = plug error.
// Parameters default to the values generated from config.yaml; testbenches override them.
module enigma_top #(
    parameter SCAN_TICKS         = `CFG_SCAN_TICKS,
    parameter NUM_COLS           = `CFG_NUM_COLS,
    parameter DEBOUNCE_FRAMES    = `CFG_DEBOUNCE_FRAMES,
    parameter LAMP_MIN_ON_TICKS  = `CFG_LAMP_MIN_ON_TICKS,
    parameter BTN_DEBOUNCE_TICKS = `CFG_BTN_DEBOUNCE_TICKS,
    parameter HEARTBEAT_TICKS    = `CFG_HEARTBEAT_TICKS,
    parameter LAMP_TEST_TICKS    = `CFG_LAMP_TEST_TICKS
) (
    input  wire       CLK100MHZ,
    input  wire [2:0] sw,
    input  wire [3:0] btn,
    output wire [3:0] led,
    output wire       led0_r, led0_g, led0_b,
    output wire       led1_r, led1_g, led1_b,
    // keyboard: mux select out (ck_io4 = 4067 enable, active low), rows in
    output wire       ck_io0, ck_io1, ck_io2, ck_io3, ck_io4,
    input  wire       ck_io5, ck_io6, ck_io7, ck_io8,
    // lamp board: 5-bit mux code plus inverse of the MSB
    output wire       o_lb0, o_lb1, o_lb2, o_lb3, o_lb4, o_lb4N
);

`include "enigma_tables.vh"
`include "enigma_presets.vh"
`include "enigma_util.vh"

    wire clk = CLK100MHZ;

    // ---- power-on reset: 15 clocks ---------------------------------------------------
    reg [3:0] por = 4'd0;
    wire      rst = ~&por;
    always @(posedge clk) if (!(&por)) por <= por + 4'd1;

    // ---- switches and buttons ------------------------------------------------------
    wire sw0, sw1, sw_setup;
    wire b_reload, b_left, b_mid, b_right;
    sync_debounce #(.TICKS(BTN_DEBOUNCE_TICKS)) u_sw0   (.clk(clk), .in(sw[0]),  .level(sw0),      .rise());
    sync_debounce #(.TICKS(BTN_DEBOUNCE_TICKS)) u_sw1   (.clk(clk), .in(sw[1]),  .level(sw1),      .rise());
    sync_debounce #(.TICKS(BTN_DEBOUNCE_TICKS)) u_sw2   (.clk(clk), .in(sw[2]),  .level(sw_setup), .rise());
    wire reload_rise;
    sync_debounce #(.TICKS(BTN_DEBOUNCE_TICKS)) u_btn0  (.clk(clk), .in(btn[0]), .level(b_reload), .rise(reload_rise));
    sync_debounce #(.TICKS(BTN_DEBOUNCE_TICKS)) u_btn1  (.clk(clk), .in(btn[1]), .level(b_left),   .rise());
    sync_debounce #(.TICKS(BTN_DEBOUNCE_TICKS)) u_btn2  (.clk(clk), .in(btn[2]), .level(b_mid),    .rise());
    sync_debounce #(.TICKS(BTN_DEBOUNCE_TICKS)) u_btn3  (.clk(clk), .in(btn[3]), .level(b_right),  .rise());

    wire [1:0] preset_idx = {sw1, sw0};
    wire       setup_mode = sw_setup;
    reg        setup_prev = 1'b0;
    always @(posedge clk) setup_prev <= setup_mode;
    wire       setup_done = setup_prev & ~setup_mode;     // falling edge of sw[2]

    // ---- machine preset -----------------------------------------------------------------
    wire [8:0]  rotor_sel;
    wire [14:0] ring_set;
    wire        reflector_sel;
    wire [9:0]  plug_en;
    wire [49:0] plug_a, plug_b;
    assign {rotor_sel, ring_set, reflector_sel, plug_en, plug_a, plug_b} = preset_cfg(preset_idx);

    // ---- keyboard --------------------------------------------------------------------------
    wire [3:0] col_sel;
    wire       key_valid, key_down;
    wire [4:0] key_code;
    key_scanner #(.SCAN_TICKS(SCAN_TICKS), .NUM_COLS(NUM_COLS), .DEBOUNCE_FRAMES(DEBOUNCE_FRAMES)) u_keys (
        .clk(clk), .rst(rst), .rows_in({ck_io5, ck_io6, ck_io7, ck_io8}), .col_sel(col_sel),
        .key_valid(key_valid), .key_down(key_down), .key_code(key_code)
    );
    assign {ck_io3, ck_io2, ck_io1, ck_io0} = col_sel;
    // The CD74HC4067 enable (EN, active low) is assumed to be ck_io4: the early keyboard experiment drove it low.
    // Driving it low keeps the mux enabled whether or not the board also has a pull-down on EN.
    assign ck_io4 = 1'b0;

    // ---- setup window (typed start positions) ---------------------------------------
    reg [14:0] setup_pos = 15'd0;                         // {left, middle, right}
    always @(posedge clk)
        if (rst)                              setup_pos <= 15'd0;
        else if (key_valid && setup_mode)     setup_pos <= {setup_pos[9:0], key_code};

    // ---- cipher core -------------------------------------------------------------------
    wire        core_busy, core_done, plug_error;
    wire [4:0]  core_letter;
    wire [14:0] pos_out;
    enigma_core u_core (
        .clk(clk), .rst(rst),
        .load(setup_done | reload_rise), .start_pos(setup_pos),
        .rotor_sel(rotor_sel), .ring_set(ring_set), .reflector_sel(reflector_sel),
        .plug_en(plug_en), .plug_a(plug_a), .plug_b(plug_b),
        .key_valid(key_valid & ~setup_mode & ~core_busy), .key_code(key_code),
        .busy(core_busy), .done(core_done), .lamp_code(core_letter),
        .pos_out(pos_out), .plug_error(plug_error)
    );

    // ---- lamp board: cipher output, setup echo, or rotor window display ----------------
    wire       show_win   = b_left | b_mid | b_right;
    wire [4:0] win_letter = b_left ? pos_out[14:10] : (b_mid ? pos_out[9:5] : pos_out[4:0]);

    // Lamp self-test: all three window buttons held -> sweep A..Z, one letter per LAMP_TEST_TICKS.
    wire       lamp_test = b_left & b_mid & b_right;
    localparam LT_W = clog2(LAMP_TEST_TICKS);
    reg [LT_W-1:0] lt_count  = {LT_W{1'b0}};
    reg [4:0]      lt_letter = 5'd0;
    always @(posedge clk) begin
        if (!lamp_test) begin
            lt_count  <= {LT_W{1'b0}};
            lt_letter <= 5'd0;
        end else if (lt_count == LAMP_TEST_TICKS - 1) begin
            lt_count  <= {LT_W{1'b0}};
            lt_letter <= (lt_letter == 5'd25) ? 5'd0 : lt_letter + 5'd1;
        end else begin
            lt_count <= lt_count + 1'b1;
        end
    end

    wire       echo       = key_valid & setup_mode;
    wire       lamp_set   = show_win | echo | core_done;
    wire [4:0] lamp_letter = lamp_test ? lt_letter : (show_win ? win_letter : (echo ? key_code : core_letter));
    wire [4:0] lb;
    wire       lb4N;
    lamp_driver #(.MIN_ON_TICKS(LAMP_MIN_ON_TICKS)) u_lamps (
        .clk(clk), .rst(rst), .set(lamp_set), .letter(lamp_letter), .hold(show_win | key_down),
        .lb(lb), .lb4N(lb4N)
    );
    assign {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} = lb;
    assign o_lb4N = lb4N;

    // ---- status ---------------------------------------------------------------------------
    localparam HB_W = clog2(HEARTBEAT_TICKS);
    reg [HB_W-1:0] hb_count = {HB_W{1'b0}};
    reg        heartbeat = 1'b0;
    always @(posedge clk) begin
        if (hb_count == HEARTBEAT_TICKS - 1) begin
            hb_count  <= {HB_W{1'b0}};
            heartbeat <= ~heartbeat;
        end else begin
            hb_count <= hb_count + 1'b1;
        end
    end

    assign led = {heartbeat, plug_error, setup_mode, key_down};
    assign {led0_r, led0_g, led0_b} = {preset_idx == 2'd0 || preset_idx == 2'd3,
                                       preset_idx == 2'd1 || preset_idx == 2'd3,
                                       preset_idx == 2'd2 || preset_idx == 2'd3};
    assign led1_r = plug_error;
    assign led1_g = ~setup_mode & ~plug_error;
    assign led1_b = setup_mode;
endmodule
