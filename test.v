`timescale 1ns / 1ps
 
//and
//module test(
//    input [3:0] btn,
//    output [3:0] led
//   );
//    wire at_1;
//    assign at_1 = btn[0] & btn[1];
//    assign led = {3'b00, at_1};  
//endmodule


//clock
//test for keys and led
//module keyboard(
//    input CLK100MHZ,
//    input ck_io5,
//    input ck_io6,
//    input ck_io7,
//    input ck_io8,
//    input [3:0] sw ,
//    output ck_io0,
//    output ck_io1,
//    output ck_io2,
//    output ck_io3,
//    output ck_io4,
//    output o_lb0,
//    output o_lb1,
//    output o_lb2,
//    output o_lb3,
//    output o_lb4,
//    output o_lb4N,
//    output reg [3:0] led
//    );
//    assign ck_io0= sw[0];
//    assign ck_io1= sw[1];
//    assign ck_io2= sw[2];
//    assign ck_io3= sw[3];
//    assign o_lb0= sw[0];
//    assign o_lb1= sw[1];
//    assign o_lb2= sw[2];
//    assign o_lb3= sw[3];
//    assign ck_io4 = 1'b0;
//    assign ck_io4N = 1'b1;
//always @(posedge CLK100MHZ) begin
//    led <={ck_io5,ck_io6,ck_io7,ck_io8};

//end
//endmodule


//clock devider 
//module clk5(
//    input CLK100MHZ, 
//    output [3:0] led
//    );
//    reg [31:0] counter = 0;
//    reg CLK5MHZ;
//    always @(posedge CLK100MHZ) begin
//        counter <= counter + 1;
//        if (counter == 20000000) begin // 100MHz / 5Hz = 20,000,000
//            counter <= 0;
//            CLK5MHZ <= ~CLK5MHZ;
//        end
//    end
//    assign led ={3'b00,CLK5MHZ};
    
//endmodule


//adder 
//module test (
//input [3:0] btn

//    output [3:0] led    
//    );
//    wire sum;
//    wire count;
//    assign Sum = btn[0] ^ btn[1] ^ btn[2];
//    assign Cout = (btn[0] & btn[1]) | (btn[2] & (btn[0] ^ btn[1]));
//    assign led ={2'b00,Sum,Cout};
//endmodule

//4-bit mux counter 
//module test (
//    input CLK100MHZ,       
//    input [3:0] btn ,            
//    output reg [3:0] led
//    );

//    reg [31:0] debounce_counter = 0; 
//    reg [3:0] counter = 0;           
//    reg [1:0] sel = 0;              

//    // Debounce logic for button press
//    always @(posedge CLK100MHZ) begin
//        if (btn[0] == 1 && debounce_counter == 0) begin
//            counter <= counter + 1;    // Increment counter on button press
//            debounce_counter <= 1000000; // Debounce time (10ms assuming 100MHz)
//        end else if (debounce_counter > 0) begin
//            debounce_counter <= debounce_counter - 1;
//        end
//    end

//    // MUX logic: selects one of the 4 bits of the counter to display on LEDs
//    always @(posedge CLK100MHZ) begin
//        case (sel)
//            2'b00: led[0] <= 4'b0001 << counter[0]; // Display the LSB of the counter
//            2'b01: led[1] <= 4'b0001 << counter[1]; // Display the 2nd bit of the counter
//            2'b10: led[2] <= 4'b0001 << counter[2]; // Display the 3rd bit of the counter
//            2'b11: led[3] <= 4'b0001 << counter[3]; // Display the MSB of the counter
//        endcase

//        // Increment the select line to change which bit is shown on LEDs
//        sel <= sel + 1;
//    end
//endmodule

//Mux-0to9
//module keyboardriver(
//    input CLK100MHZ,
//    input wire ck_io5,
//    output reg [3:0] led);
//always @(posedge CLK100MHZ) begin
////if (ck_io5) begin
//    assign led [0] =ck_io5;
////end
////else if (CLK100MHZ) begin

////end
//end
//endmodule

// hi mitun this is shivani
// shivani is the best
// queen slayyyyyyyyyy
// bow down to qweennnnnn
//ysenwofnf



//module counter_0_to_9 (
//    input wire CLK100MHZ, // 100 MHz clock input
//    input ck_io5,
//    input ck_io6,
//    input ck_io7,
//    input ck_io8,
//    output wire ck_io0,   // Output pin ck_io0
//    output wire ck_io1,   // Output pin ck_io1
//    output wire ck_io2,   // Output pin ck_io2
//    output wire ck_io3,    // Output pin ck_io3
//     output reg [3:0] led
     
//);

//    localparam integer DIVISOR = 1_000_000; // 100 MHz to 1 Hz
//    reg [26:0] clk_div; // 27-bit counter to divide 100 MHz to 1 Hz
//    reg [3:0] count;    // 4-bit output count

//    always @(posedge CLK100MHZ) begin
//        // Clock Divider Logic
//        if (clk_div == DIVISOR - 1) begin
//            clk_div <= 0;
//            // Increment the count from 0 to 9
//            if (count == 9) begin
//                count <= 0;
//            end else begin
//                count <= count + 1;
//            end
//        end else begin
//            clk_div <= clk_div + 1;
//        end
//    end

//    // Assign the count bits to the respective pins
//    assign ck_io0 = count[0];
//    assign ck_io1 = count[1];
//    assign ck_io2 = count[2];
//    assign ck_io3 = count[3];
//always @(posedge CLK100MHZ) begin
//    led <={ck_io5,ck_io6,ck_io7,ck_io8};
//    end
//endmodule

//the above code has the functioning of keybourd with outputs 



//test -2 with saved op
module counter_with_input_check (
    input wire CLK100MHZ,   // 100 MHz clock input
    input wire ck_io5,      // Digital input
    input wire ck_io6,      // Digital input
    input wire ck_io7,      // Digital input
    input wire ck_io8,      // Digital input
    output wire ck_io0,     // Output pin for count[0]
    output wire ck_io1,     // Output pin for count[1]
    output wire ck_io2,     // Output pin for count[2]
    output wire ck_io3,     // Output pin for count[3]
    output reg o_lb0, o_lb1, o_lb2, o_lb3, o_lb4,o_lb4N, // 5-bit output for patterns
    output reg [3:0] led, 
    output reg led0_r, led0_g, led0_b, led1_r , led1_g, led1_b
);

    localparam integer DIVISOR = 100_000_0; // 100 MHz to 1 Hz
    reg [26:0] clk_div;       // Clock divider register
    reg [3:0] count;          // 4-bit counter register

    // Internal variables for each letter of the alphabet
    reg input_A, input_B, input_C, input_D, input_E, input_F, input_G;
    reg input_H, input_I, input_J, input_K, input_L, input_M, input_N;
    reg input_O, input_P, input_Q, input_R, input_S, input_T, input_U;
    reg input_V, input_W, input_X, input_Y, input_Z;

    // Clock Divider and Counter
    always @(posedge CLK100MHZ) begin
        if (clk_div == DIVISOR - 1) begin
            clk_div <= 0;
            // Increment the count from 0 to 9
            if (count == 9) begin
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // Assign the count bits to the output pins
    assign ck_io0 = count[0];
    assign ck_io1 = count[1];
    assign ck_io2 = count[2];
    assign ck_io3 = count[3];

    // Check for any high signal on the digital inputs (ck_io5, ck_io6, ck_io7, ck_io8)
    always @(posedge CLK100MHZ) begin
        // Reset all alphabet flags to low
        input_A <= 0; input_B <= 0; input_C <= 0; input_D <= 0; input_E <= 0;
        input_F <= 0; input_G <= 0; input_H <= 0; input_I <= 0; input_J <= 0;
        input_K <= 0; input_L <= 0; input_M <= 0; input_N <= 0; input_O <= 0;
        input_P <= 0; input_Q <= 0; input_R <= 0; input_S <= 0; input_T <= 0;
        input_U <= 0; input_V <= 0; input_W <= 0; input_X <= 0; input_Y <= 0; input_Z <= 0;

        if (ck_io5 || ck_io6 || ck_io7 || ck_io8) begin
        //ck_io0 ck_io1   ck_io2  ck_io3    
            case ({ck_io3, ck_io2, ck_io1, ck_io0, ck_io5, ck_io6, ck_io7, ck_io8})
                8'b00010100: input_A <= 1; //b00010100
                8'b01010010: input_B <= 1;
                8'b00110010: input_C <= 1;
                8'b00110100: input_D <= 1;
                8'b00101000: input_E <= 1;
                8'b01000100: input_F <= 1;
                8'b01010100: input_G <= 1;
                8'b01100100: input_H <= 1;
                8'b01111000: input_I <= 1;
                8'b01110100: input_J <= 1;
                8'b10000100: input_K <= 1;
                8'b10000010: input_L <= 1;
                8'b01110010: input_M <= 1;
                8'b01100010: input_N <= 1;
                8'b10001000: input_O <= 1;
                8'b00000010: input_P <= 1;
                8'b00001000: input_Q <= 1;
                8'b00111000: input_R <= 1;
                8'b00100100: input_S <= 1;
                8'b01001000: input_T <= 1; //b01001000
                8'b01101000: input_U <= 1;
                8'b01000010: input_V <= 1;
                8'b00011000: input_W <= 1;
                8'b00100010: input_X <= 1;
                8'b00010010: input_Y <= 1;
                8'b01011000: input_Z <= 1;
                default: ; // No match
            endcase
        end

        // Set the output pattern based on which input is active
        case (1'b1) // Only one input variable will be high at a time
            input_A: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00000;
            input_B: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00001;
            input_C: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00010;
            input_D: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00011;
            input_E: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00100;
            input_F: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00101;
            input_G: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00110;
            input_H: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00111;
            input_I: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01000;
            input_J: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01001;
            input_K: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01010;
            input_L: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01011;
            input_M: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01100;
            input_N: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10000;
            input_O: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10001;
            input_P: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10010;
            input_Q: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10011;
            input_R: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10100;
            input_S: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10101;
            input_T: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10110;
            input_U: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10111;
            input_V: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11000;
            input_W: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11001;
            input_X: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11010;
            input_Y: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11011;
            input_Z: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11100;
            default: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11111; // Default pattern
        endcase
    end

always @(posedge CLK100MHZ) begin
    led <={ck_io5,ck_io6,ck_io7,ck_io8};
    o_lb4N<=~o_lb4;
    end
always @(posedge CLK100MHZ) begin
        led0_r <= input_B;  // Light up LED when input_A is high
        led1_r <= input_C;
        led1_b <= input_D;
        led0_b <= input_E;
        led0_g <= input_F;
        led1_g <= input_G;
    end
endmodule
