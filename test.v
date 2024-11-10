`timescale 1ns / 1ps
 `define A 0
 `define B 1
 `define C 2
 `define D 3
 `define E 4
 `define F 5
 `define G 6
 `define H 7
 `define I 8
 `define J 9
 `define K 10
 `define L 11
 `define M 12
 `define N 13
 `define O 14
 `define P 15
 `define Q 16
 `define R 17
 `define S 18
 `define T 19
 `define U 20
 `define V 21
 `define W 22
 `define X 23
 `define Y 24
 `define Z 25
  
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
//    endmodule

//the above code has the functioning of keybourd with outputs 



//test -2 with saved op

//module counter_with_input_check (
//    input wire CLK100MHZ,   // 100 MHz clock input
//    input wire ck_io5,      // Digital input
//    input wire ck_io6,      // Digital input
//    input wire ck_io7,      // Digital input
//    input wire ck_io8,      // Digital input
//    output wire ck_io0,     // Output pin for count[0]
//    output wire ck_io1,     // Output pin for count[1]
//    output wire ck_io2,     // Output pin for count[2]
//    output wire ck_io3,     // Output pin for count[3]
//    output reg o_lb0, o_lb1, o_lb2, o_lb3, o_lb4,o_lb4N, // 5-bit output for patterns
//    output reg [3:0] led, 
//    output reg led0_r, led0_g, led0_b, led1_r , led1_g, led1_b
//);

//    localparam integer DIVISOR = 100_000_0; // 100 MHz to 1 Hz
//    reg [26:0] clk_div;       // Clock divider register
//    reg [3:0] count;          // 4-bit counter register

//    // Internal variables for each letter of the alphabet
//    reg input_A, input_B, input_C, input_D, input_E, input_F, input_G;
//    reg input_H, input_I, input_J, input_K, input_L, input_M, input_N;
//    reg input_O, input_P, input_Q, input_R, input_S, input_T, input_U;
//    reg input_V, input_W, input_X, input_Y, input_Z;

//    // Clock Divider and Counter
//    always @(posedge CLK100MHZ) begin
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

//    // Assign the count bits to the output pins
//    assign ck_io0 = count[0];
//    assign ck_io1 = count[1];
//    assign ck_io2 = count[2];
//    assign ck_io3 = count[3];

//    // Check for any high signal on the digital inputs (ck_io5, ck_io6, ck_io7, ck_io8)
//    always @(posedge CLK100MHZ) begin
//        // Reset all alphabet flags to low
//        input_A <= 0; input_B <= 0; input_C <= 0; input_D <= 0; input_E <= 0;
//        input_F <= 0; input_G <= 0; input_H <= 0; input_I <= 0; input_J <= 0;
//        input_K <= 0; input_L <= 0; input_M <= 0; input_N <= 0; input_O <= 0;
//        input_P <= 0; input_Q <= 0; input_R <= 0; input_S <= 0; input_T <= 0;
//        input_U <= 0; input_V <= 0; input_W <= 0; input_X <= 0; input_Y <= 0; input_Z <= 0;

//        if (ck_io5 || ck_io6 || ck_io7 || ck_io8) begin
//        //ck_io0 ck_io1   ck_io2  ck_io3    
//            case ({ck_io3, ck_io2, ck_io1, ck_io0, ck_io5, ck_io6, ck_io7, ck_io8})
//                8'b00010100: input_A <= 1; //b00010100
//                8'b01010010: input_B <= 1;
//                8'b00110010: input_C <= 1;
//                8'b00110100: input_D <= 1;
//                8'b00101000: input_E <= 1;
//                8'b01000100: input_F <= 1;
//                8'b01010100: input_G <= 1;
//                8'b01100100: input_H <= 1;
//                8'b01111000: input_I <= 1;
//                8'b01110100: input_J <= 1;
//                8'b10000100: input_K <= 1;
//                8'b10000010: input_L <= 1;
//                8'b01110010: input_M <= 1;
//                8'b01100010: input_N <= 1;
//                8'b10001000: input_O <= 1;
//                8'b00000010: input_P <= 1;
//                8'b00001000: input_Q <= 1;
//                8'b00111000: input_R <= 1;
//                8'b00100100: input_S <= 1;
//                8'b01001000: input_T <= 1; //b01001000
//                8'b01101000: input_U <= 1;
//                8'b01000010: input_V <= 1;
//                8'b00011000: input_W <= 1;
//                8'b00100010: input_X <= 1;
//                8'b00010010: input_Y <= 1;
//                8'b01011000: input_Z <= 1;
//                default: ; // No match
//            endcase
//        end

//        // Set the output pattern based on which input is active
//        case (1'b1) // Only one input variable will be high at a time
//            input_A: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00000;
//            input_B: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00001;
//            input_C: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00010;
//            input_D: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00011;
//            input_E: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00100;
//            input_F: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00101;
//            input_G: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00110;
//            input_H: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00111;
//            input_I: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01000;
//            input_J: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01001;
//            input_K: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01010;
//            input_L: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01011;
//            input_M: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01100;
//            input_N: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10000;
//            input_O: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10001;
//            input_P: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10010;
//            input_Q: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10011;
//            input_R: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10100;
//            input_S: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10101;
//            input_T: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10110;
//            input_U: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10111;
//            input_V: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11000;
//            input_W: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11001;
//            input_X: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11010;
//            input_Y: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11011;
//            input_Z: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11100;
//            default: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11111; // Default pattern
//        endcase
//    end

//always @(posedge CLK100MHZ) begin
//    led <={ck_io5,ck_io6,ck_io7,ck_io8};
//    o_lb4N<=~o_lb4;
//    end

//endmodule


//the above code has keys and light up with proper maping (a->a)


// hi mitun this is shivani
// shivani is the best
// queen slayyyyyyyyyy
// bow down to qweennnnnn
//ysenwofnf

//test-3 for encription 

module counter_with_input_check (
    input wire CLK100MHZ,   // 100 MHz clock input
    input wire ck_io5,      // Digital input
    input wire ck_io6,      // Digital input
    input wire ck_io7,      // Digital input
    input wire ck_io8,      // Digital input
    input [3:0] sw ,
    output wire ck_io0,     // Output pin for count[0]
    output wire ck_io1,     // Output pin for count[1]
    output wire ck_io2,     // Output pin for count[2]
    output wire ck_io3,     // Output pin for count[3]
    output reg o_lb0, o_lb1, o_lb2, o_lb3, o_lb4,o_lb4N, // 5-bit output for patterns
//    output reg [3:0] led,
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
    reg output_A, output_B, output_C, output_D, output_E, output_F, output_G;
    reg output_H, output_I, output_J, output_K, output_L, output_M, output_N;
    reg output_O, output_P, output_Q, output_R, output_S, output_T, output_U;
    reg output_V, output_W, output_X, output_Y, output_Z;
    reg [2:0] rotor_left, rotor_mid ,rotor_right;
   
    reg pass1 [25:0];
    reg pass2 [25:0];
    reg pass3 [25:0];
    reg pass4 [25:0];
    reg pass5 [25:0];
    reg pass6 [25:0];
    reg pass7 [25:0];
   
    initial begin
        rotor_left=1;
        rotor_mid=2;
        rotor_right=3;
    end
//    always @(posedge CLK100MHZ) begin
////        led = {rotor_left, rotor_mid};
////        {led0_r, led0_g, led0_b} = {rotor_right, 1'b0};    //red+green=pink
       
//    end
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
                8'b00010100: input_A <= 1;
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
                8'b01001000: input_T <= 1;
                8'b01101000: input_U <= 1;
                8'b01000010: input_V <= 1;
                8'b00011000: input_W <= 1;
                8'b00100010: input_X <= 1;
                8'b00010010: input_Y <= 1;
                8'b01011000: input_Z <= 1;
                default: ; // No match
            endcase
        end
        // PASS 1 - ROTOR RIGHT - ONLY ROTOR 3 IMPLEMENTED

//        if (rotor_right == 1) begin
//              pass1 = rotor_I_LtoR(input)
//        end
//        if (rotor_right == 2) begin
//              pass1 = rotor_II_LtoR(input)
//        end
//        if (rotor_right == 3) begin
//              pass1 = rotor_III_LtoR(input)
//        end


end
    always @(posedge CLK100MHZ) begin
        if (sw[0]) begin
        //aaa
        
        pass1[`B] <= input_A; pass1[`D] <= input_B; pass1[`F] <= input_C; pass1[`H] <= input_D; pass1[`J] <= input_E;
        pass1[`L] <= input_F; pass1[`C] <= input_G; pass1[`P] <= input_H; pass1[`R] <= input_I; pass1[`T] <= input_J;
        pass1[`X] <= input_K; pass1[`V] <= input_L; pass1[`Z] <= input_M; pass1[`N] <= input_N; pass1[`Y]<= input_O;
        pass1[`E] <= input_P; pass1[`I] <= input_Q; pass1[`W] <= input_R; pass1[`G] <= input_S; pass1[`A] <= input_T;
        pass1[`K] <= input_U; pass1[`M] <= input_V; pass1[`U] <= input_W; pass1[`S] <= input_X; pass1[`Q] <= input_Y; pass1[`O] <= input_Z;
       
        // PASS 2 - ROTOR MID - ONLY ROTOR 2 IMPLEMENTE
        pass2[`A] <= pass1[`A]; pass2[`J] <= pass1[`B]; pass2[`D] <= pass1[`C]; pass2[`K] <= pass1[`D]; pass2[`S] <= pass1[`E];
        pass2[`I] <= pass1[`F]; pass2[`R] <= pass1[`G]; pass2[`U] <= pass1[`H]; pass2[`X] <= pass1[`I]; pass2[`B] <= pass1[`J];
        pass2[`L] <= pass1[`K]; pass2[`H] <= pass1[`L]; pass2[`W] <= pass1[`M]; pass2[`T] <= pass1[`N]; pass2[`M] <= pass1[`O];
        pass2[`C] <= pass1[`P]; pass2[`Q] <= pass1[`Q]; pass2[`G] <= pass1[`R]; pass2[`Z] <= pass1[`S]; pass2[`N] <= pass1[`T];
        pass2[`P] <= pass1[`U]; pass2[`Y] <= pass1[`V]; pass2[`F] <= pass1[`W]; pass2[`V] <= pass1[`X]; pass2[`O] <= pass1[`Y]; pass2[`E] <= pass1[`Z];

       
        // PASS 3 - ROTOR LEFT - ONLY ROTOR 1 IMPLEMENTED
        pass3[`E] <= pass2[`A]; pass3[`K] <= pass2[`B]; pass3[`M] <= pass2[`C]; pass3[`F] <= pass2[`D]; pass3[`L] <= pass2[`E];
        pass3[`G] <= pass2[`F]; pass3[`D] <= pass2[`G]; pass3[`Q] <= pass2[`H]; pass3[`V] <= pass2[`I]; pass3[`Z] <= pass2[`J];
        pass3[`N] <= pass2[`K]; pass3[`T] <= pass2[`L]; pass3[`O] <= pass2[`M]; pass3[`W] <= pass2[`N]; pass3[`Y] <= pass2[`O];
        pass3[`H] <= pass2[`P]; pass3[`X] <= pass2[`Q]; pass3[`U] <= pass2[`R]; pass3[`S] <= pass2[`S]; pass3[`P] <= pass2[`T];
        pass3[`A] <= pass2[`U]; pass3[`I] <= pass2[`V]; pass3[`B] <= pass2[`W]; pass3[`R] <= pass2[`X]; pass3[`C] <= pass2[`Y]; pass3[`J] <= pass2[`Z];
       
        // PASS 4 - REFLECTOR C
        pass4[`A] <= pass3[`A]; pass4[`B] <= pass3[`B]; pass4[`C] <= pass3[`C]; pass4[`D] <= pass3[`D]; pass4[`E] <= pass3[`E];
        pass4[`F] <= pass3[`F]; pass4[`G] <= pass3[`G]; pass4[`H] <= pass3[`H]; pass4[`I] <= pass3[`I]; pass4[`J] <= pass3[`J];
        pass4[`K] <= pass3[`K]; pass4[`L] <= pass3[`L]; pass4[`M] <= pass3[`M]; pass4[`N] <= pass3[`N]; pass4[`O] <= pass3[`O];
        pass4[`P] <= pass3[`P]; pass4[`Q] <= pass3[`Q]; pass4[`R] <= pass3[`R]; pass4[`S] <= pass3[`S]; pass4[`T] <= pass3[`T];
        pass4[`U] <= pass3[`U]; pass4[`V] <= pass3[`V]; pass4[`W] <= pass3[`W]; pass4[`X] <= pass3[`X]; pass4[`Y] <= pass3[`Y]; pass4[`Z] <= pass3[`Z];

        // PASS 5 - ROTOR LEFT REVERESE
        pass5[`Y] <= pass4[`A]; pass5[`R] <= pass4[`B]; pass5[`U] <= pass4[`C]; pass5[`H] <= pass4[`D]; pass5[`Q] <= pass4[`E];
        pass5[`S] <= pass4[`F]; pass5[`L] <= pass4[`G]; pass5[`D] <= pass4[`H]; pass5[`P] <= pass4[`I]; pass5[`X] <= pass4[`J];
        pass5[`N] <= pass4[`K]; pass5[`G] <= pass4[`L]; pass5[`O] <= pass4[`M]; pass5[`K] <= pass4[`N]; pass5[`M] <= pass4[`O];
        pass5[`I] <= pass4[`P]; pass5[`E] <= pass4[`Q]; pass5[`B] <= pass4[`R]; pass5[`F] <= pass4[`S]; pass5[`Z] <= pass4[`T];
        pass5[`C] <= pass4[`U]; pass5[`W] <= pass4[`V]; pass5[`V] <= pass4[`W]; pass5[`J] <= pass4[`X]; pass5[`A] <= pass4[`Y]; pass5[`T] <= pass4[`Z];


        // PASS 6 - ROTOR MID REVERESE
        pass6[`U] <= pass5[`A]; pass6[`W] <= pass5[`B]; pass6[`Y] <= pass5[`C]; pass6[`G] <= pass5[`D]; pass6[`A] <= pass5[`E];
        pass6[`D] <= pass5[`F]; pass6[`F] <= pass5[`G]; pass6[`P] <= pass5[`H]; pass6[`V] <= pass5[`I]; pass6[`Z] <= pass5[`J];
        pass6[`B] <= pass5[`K]; pass6[`E] <= pass5[`L]; pass6[`C] <= pass5[`M]; pass6[`K] <= pass5[`N]; pass6[`M] <= pass5[`O];
        pass6[`T] <= pass5[`P]; pass6[`H] <= pass5[`Q]; pass6[`X] <= pass5[`R]; pass6[`S] <= pass5[`S]; pass6[`L] <= pass5[`T];
        pass6[`R] <= pass5[`U]; pass6[`I] <= pass5[`V]; pass6[`N] <= pass5[`W]; pass6[`Q] <= pass5[`X]; pass6[`O] <= pass5[`Y]; pass6[`J] <= pass5[`Z];


        // PASS 7 - ROTOR RIGHT REVERESE
        pass7[`A] <= pass6[`A]; pass7[`J] <= pass6[`B]; pass7[`P] <= pass6[`C]; pass7[`C] <= pass6[`D]; pass7[`Z] <= pass6[`E];
        pass7[`W] <= pass6[`F]; pass7[`R] <= pass6[`G]; pass7[`L] <= pass6[`H]; pass7[`F] <= pass6[`I]; pass7[`B] <= pass6[`J];
        pass7[`D] <= pass6[`K]; pass7[`K] <= pass6[`L]; pass7[`O] <= pass6[`M]; pass7[`T] <= pass6[`N]; pass7[`Y] <= pass6[`O];
        pass7[`U] <= pass6[`P]; pass7[`Q] <= pass6[`Q]; pass7[`G] <= pass6[`R]; pass7[`E] <= pass6[`S]; pass7[`N] <= pass6[`T];
        pass7[`H] <= pass6[`U]; pass7[`X] <= pass6[`V]; pass7[`M] <= pass6[`W]; pass7[`I] <= pass6[`X]; pass7[`V] <= pass6[`Y]; pass7[`S] <= pass6[`Z];

//output_A = pass3[`A];
//output_B = pass3[`B];
//output_C = pass3[`C];
//output_D = pass3[`D];
//output_E = pass3[`E];
//output_F = pass3[`F];
//output_G = pass3[`G];
//output_H = pass3[`H];
//output_I = pass3[`I];
//output_J = pass3[`J];
//output_K = pass3[`K];
//output_L = pass3[`L];
//output_M = pass3[`M];
//output_N = pass3[`N];
//output_O = pass3[`O];
//output_P = pass3[`P];
//output_Q = pass3[`Q];
//output_R = pass3[`R];
//output_S = pass3[`S];
//output_T = pass3[`T];
//output_U = pass3[`U];
//output_V = pass3[`V];
//output_W = pass3[`W];
//output_X = pass3[`X];
//output_Y = pass3[`Y];
//output_Z = pass3[`Z];
        output_A = pass7[`B];
        output_B = pass7[`D];
        output_C = pass7[`F];
        output_D = pass7[`H];
        output_E = pass7[`J];
        output_F = pass7[`L];
        output_G = pass7[`C];
        output_H = pass7[`P];
        output_I = pass7[`R];
        output_J = pass7[`T];
        output_K = pass7[`X];
        output_L = pass7[`V];
        output_M = pass7[`Z];
        output_N = pass7[`N];
        output_O = pass7[`Y];
        output_P = pass7[`E];
        output_Q = pass7[`I];
        output_R = pass7[`W];
        output_S = pass7[`G];
        output_T = pass7[`A];
        output_U = pass7[`K];
        output_V = pass7[`M];
        output_W = pass7[`U];
        output_X = pass7[`S];
        output_Y = pass7[`Q];
        output_Z = pass7[`O];
        end
        else if (sw[1]) begin
            //bbb
            pass1[`D] <= input_A; pass1[`F] <= input_B; pass1[`H] <= input_C; pass1[`J] <= input_D; pass1[`L] <= input_E;
            pass1[`C] <= input_F; pass1[`P] <= input_G; pass1[`R] <= input_H; pass1[`T] <= input_I; pass1[`X] <= input_J;
            pass1[`V] <= input_K; pass1[`Z] <= input_L; pass1[`N] <= input_M; pass1[`Y] <= input_N; pass1[`E]<= input_O;
            pass1[`I] <= input_P; pass1[`W] <= input_Q; pass1[`G] <= input_R; pass1[`A] <= input_S; pass1[`K] <= input_T;
            pass1[`M] <= input_U; pass1[`U] <= input_V; pass1[`S] <= input_W; pass1[`Q] <= input_X; pass1[`O] <= input_Y; pass1[`B] <= input_Z;
           
            // PASS 2 - ROTOR MID - ONLY ROTOR 2 IMPLEMENTE
            pass2[`A] <= pass1[`A]; pass2[`J] <= pass1[`B]; pass2[`D] <= pass1[`C]; pass2[`K] <= pass1[`D]; pass2[`S] <= pass1[`E];
            pass2[`I] <= pass1[`F]; pass2[`R] <= pass1[`G]; pass2[`U] <= pass1[`H]; pass2[`X] <= pass1[`I]; pass2[`B] <= pass1[`J];
            pass2[`L] <= pass1[`K]; pass2[`H] <= pass1[`L]; pass2[`W] <= pass1[`M]; pass2[`T] <= pass1[`N]; pass2[`M] <= pass1[`O];
            pass2[`C] <= pass1[`P]; pass2[`Q] <= pass1[`Q]; pass2[`G] <= pass1[`R]; pass2[`Z] <= pass1[`S]; pass2[`N] <= pass1[`T];
            pass2[`P] <= pass1[`U]; pass2[`Y] <= pass1[`V]; pass2[`F] <= pass1[`W]; pass2[`V] <= pass1[`X]; pass2[`O] <= pass1[`Y]; pass2[`E] <= pass1[`Z];
   
           
            // PASS 3 - ROTOR LEFT - ONLY ROTOR 1 IMPLEMENTED
            pass3[`E] <= pass2[`A]; pass3[`K] <= pass2[`B]; pass3[`M] <= pass2[`C]; pass3[`F] <= pass2[`D]; pass3[`L] <= pass2[`E];
            pass3[`G] <= pass2[`F]; pass3[`D] <= pass2[`G]; pass3[`Q] <= pass2[`H]; pass3[`V] <= pass2[`I]; pass3[`Z] <= pass2[`J];
            pass3[`N] <= pass2[`K]; pass3[`T] <= pass2[`L]; pass3[`O] <= pass2[`M]; pass3[`W] <= pass2[`N]; pass3[`Y] <= pass2[`O];
            pass3[`H] <= pass2[`P]; pass3[`X] <= pass2[`Q]; pass3[`Q] <= pass2[`R]; pass3[`Q] <= pass2[`S]; pass3[`P] <= pass2[`T];
            pass3[`A] <= pass2[`U]; pass3[`I] <= pass2[`V]; pass3[`B] <= pass2[`W]; pass3[`R] <= pass2[`X]; pass3[`C] <= pass2[`Y]; pass3[`J] <= pass2[`Z];
           
            // PASS 4 - REFLECTOR C
            pass4[`T] <= pass3[`A]; pass4[`A] <= pass3[`B]; pass4[`B] <= pass3[`C]; pass4[`C] <= pass3[`D]; pass4[`D] <= pass3[`E];
            pass4[`E] <= pass3[`F]; pass4[`F] <= pass3[`G]; pass4[`G] <= pass3[`H]; pass4[`D] <= pass3[`I]; pass4[`I] <= pass3[`J];
            pass4[`J] <= pass3[`K]; pass4[`K] <= pass3[`L]; pass4[`G] <= pass3[`M]; pass4[`M] <= pass3[`N]; pass4[`K] <= pass3[`O];
            pass4[`M] <= pass3[`P]; pass4[`I] <= pass3[`Q]; pass4[`E] <= pass3[`R]; pass4[`B] <= pass3[`S]; pass4[`F] <= pass3[`T];
            pass4[`T] <= pass3[`U]; pass4[`C] <= pass3[`V]; pass4[`V] <= pass3[`W]; pass4[`V] <= pass3[`X]; pass4[`J] <= pass3[`Y]; pass4[`A] <= pass3[`Z];
   
            // PASS 5 - ROTOR LEFT REVERESE
            pass5[`Z] <= pass4[`A]; pass5[`S] <= pass4[`B]; pass5[`V] <= pass4[`C]; pass5[`E] <= pass4[`D]; pass5[`R] <= pass4[`E];
            pass5[`F] <= pass4[`F]; pass5[`G] <= pass4[`G]; pass5[`H] <= pass4[`H]; pass5[`I] <= pass4[`I]; pass5[`J] <= pass4[`J];
            pass5[`K] <= pass4[`K]; pass5[`L] <= pass4[`L]; pass5[`M] <= pass4[`M]; pass5[`N] <= pass4[`N]; pass5[`O] <= pass4[`O];
            pass5[`P] <= pass4[`P]; pass5[`Q] <= pass4[`Q]; pass5[`R] <= pass4[`R]; pass5[`S] <= pass4[`S]; pass5[`T] <= pass4[`T];
            pass5[`U] <= pass4[`U]; pass5[`V] <= pass4[`V]; pass5[`W] <= pass4[`W]; pass5[`X] <= pass4[`X]; pass5[`Y] <= pass4[`Y]; pass5[`Z] <= pass4[`Z];
   
   
            // PASS 6 - ROTOR MID REVERESE
            pass6[`U] <= pass5[`A]; pass6[`W] <= pass5[`B]; pass6[`Y] <= pass5[`C]; pass6[`G] <= pass5[`D]; pass6[`A] <= pass5[`E];
            pass6[`D] <= pass5[`F]; pass6[`F] <= pass5[`G]; pass6[`P] <= pass5[`H]; pass6[`V] <= pass5[`I]; pass6[`Z] <= pass5[`J];
            pass6[`B] <= pass5[`K]; pass6[`E] <= pass5[`L]; pass6[`C] <= pass5[`M]; pass6[`K] <= pass5[`N]; pass6[`M] <= pass5[`O];
            pass6[`T] <= pass5[`P]; pass6[`H] <= pass5[`Q]; pass6[`X] <= pass5[`R]; pass6[`S] <= pass5[`S]; pass6[`L] <= pass5[`T];
            pass6[`R] <= pass5[`U]; pass6[`I] <= pass5[`V]; pass6[`N] <= pass5[`W]; pass6[`Q] <= pass5[`X]; pass6[`O] <= pass5[`Y]; pass6[`J] <= pass5[`Z];
   
   
            // PASS 7 - ROTOR RIGHT REVERESE
            pass7[`A] <= pass6[`A]; pass7[`J] <= pass6[`B]; pass7[`P] <= pass6[`C]; pass7[`C] <= pass6[`D]; pass7[`Z] <= pass6[`E];
            pass7[`W] <= pass6[`F]; pass7[`R] <= pass6[`G]; pass7[`L] <= pass6[`H]; pass7[`F] <= pass6[`I]; pass7[`B] <= pass6[`J];
            pass7[`D] <= pass6[`K]; pass7[`K] <= pass6[`L]; pass7[`O] <= pass6[`M]; pass7[`T] <= pass6[`N]; pass7[`Y] <= pass6[`O];
            pass7[`U] <= pass6[`P]; pass7[`Q] <= pass6[`Q]; pass7[`G] <= pass6[`R]; pass7[`E] <= pass6[`S]; pass7[`N] <= pass6[`T];
            pass7[`H] <= pass6[`U]; pass7[`X] <= pass6[`V]; pass7[`M] <= pass6[`W]; pass7[`I] <= pass6[`X]; pass7[`V] <= pass6[`Y]; pass7[`S] <= pass6[`Z];
   
   
            output_A = pass7[`D];
            output_B = pass7[`F];
            output_C = pass7[`H];
            output_D = pass7[`J];
            output_E = pass7[`L];
            output_F = pass7[`C];
            output_G = pass7[`P];
            output_H = pass7[`R];
            output_I = pass7[`T];
            output_J = pass7[`X];
            output_K = pass7[`V];
            output_L = pass7[`Z];
            output_M = pass7[`N];
            output_N = pass7[`Y];
            output_O = pass7[`E];
            output_P = pass7[`I];
            output_Q = pass7[`W];
            output_R = pass7[`G];
            output_S = pass7[`A];
            output_T = pass7[`K];
            output_U= pass7[`M];
            output_V = pass7[`U];
            output_W = pass7[`S];
            output_X = pass7[`Q];
            output_Y = pass7[`O];
            output_Z = pass7[`B];
   
   
        end
        else if (sw[2]) begin
            //ccc
        pass1[`F] <= input_A; pass1[`H] <= input_B; pass1[`J] <= input_C; pass1[`L] <= input_D; pass1[`C] <= input_E;
        pass1[`P] <= input_F; pass1[`R] <= input_G; pass1[`T] <= input_H; pass1[`X] <= input_I; pass1[`V] <= input_J;
        pass1[`Z] <= input_K; pass1[`N] <= input_L; pass1[`Y] <= input_M; pass1[`E] <= input_N; pass1[`I]<= input_O;
        pass1[`W] <= input_P; pass1[`G] <= input_Q; pass1[`A] <= input_R; pass1[`K] <= input_S; pass1[`M] <= input_T;
        pass1[`U] <= input_U; pass1[`S] <= input_V; pass1[`Q] <= input_W; pass1[`O] <= input_X; pass1[`B] <= input_Y; pass1[`D] <= input_Z;
       
        // PASS 2 - ROTOR MID - ONLY ROTOR 2 IMPLEMENTE
        pass2[`A] <= pass1[`A]; pass2[`J] <= pass1[`B]; pass2[`D] <= pass1[`C]; pass2[`K] <= pass1[`D]; pass2[`S] <= pass1[`E];
        pass2[`I] <= pass1[`F]; pass2[`R] <= pass1[`G]; pass2[`U] <= pass1[`H]; pass2[`X] <= pass1[`I]; pass2[`B] <= pass1[`J];
        pass2[`L] <= pass1[`K]; pass2[`H] <= pass1[`L]; pass2[`W] <= pass1[`M]; pass2[`T] <= pass1[`N]; pass2[`M] <= pass1[`O];
        pass2[`C] <= pass1[`P]; pass2[`Q] <= pass1[`Q]; pass2[`G] <= pass1[`R]; pass2[`Z] <= pass1[`S]; pass2[`N] <= pass1[`T];
        pass2[`P] <= pass1[`U]; pass2[`Y] <= pass1[`V]; pass2[`F] <= pass1[`W]; pass2[`V] <= pass1[`X]; pass2[`O] <= pass1[`Y]; pass2[`E] <= pass1[`Z];

       
        // PASS 3 - ROTOR LEFT - ONLY ROTOR 1 IMPLEMENTED
        pass3[`E] <= pass2[`A]; pass3[`K] <= pass2[`B]; pass3[`M] <= pass2[`C]; pass3[`F] <= pass2[`D]; pass3[`L] <= pass2[`E];
        pass3[`G] <= pass2[`F]; pass3[`D] <= pass2[`G]; pass3[`Q] <= pass2[`H]; pass3[`V] <= pass2[`I]; pass3[`Z] <= pass2[`J];
        pass3[`N] <= pass2[`K]; pass3[`T] <= pass2[`L]; pass3[`O] <= pass2[`M]; pass3[`W] <= pass2[`N]; pass3[`Y] <= pass2[`O];
        pass3[`H] <= pass2[`P]; pass3[`X] <= pass2[`Q]; pass3[`U] <= pass2[`R]; pass3[`S] <= pass2[`S]; pass3[`P] <= pass2[`T];
        pass3[`A] <= pass2[`U]; pass3[`I] <= pass2[`V]; pass3[`B] <= pass2[`W]; pass3[`R] <= pass2[`X]; pass3[`C] <= pass2[`Y]; pass3[`J] <= pass2[`Z];
       
        // PASS 4 - REFLECTOR C
        pass4[`A] <= pass3[`A]; pass4[`T] <= pass3[`B]; pass4[`A] <= pass3[`C]; pass4[`B] <= pass3[`D]; pass4[`C] <= pass3[`E];
        pass4[`D] <= pass3[`F]; pass4[`E] <= pass3[`G]; pass4[`F] <= pass3[`H]; pass4[`G] <= pass3[`I]; pass4[`D] <= pass3[`J];
        pass4[`I] <= pass3[`K]; pass4[`J] <= pass3[`L]; pass4[`K] <= pass3[`M]; pass4[`G] <= pass3[`N]; pass4[`M] <= pass3[`O];
        pass4[`K] <= pass3[`P]; pass4[`M] <= pass3[`Q]; pass4[`I] <= pass3[`R]; pass4[`E] <= pass3[`S]; pass4[`B] <= pass3[`T];
        pass4[`F] <= pass3[`U]; pass4[`T] <= pass3[`V]; pass4[`C] <= pass3[`W]; pass4[`V] <= pass3[`X]; pass4[`V] <= pass3[`Y]; pass4[`J] <= pass3[`Z];

        // PASS 5 - ROTOR LEFT REVERESE
        pass5[`Y] <= pass4[`A]; pass5[`R] <= pass4[`B]; pass5[`C] <= pass4[`C]; pass5[`D] <= pass4[`D]; pass5[`E] <= pass4[`E];
        pass5[`F] <= pass4[`F]; pass5[`G] <= pass4[`G]; pass5[`H] <= pass4[`H]; pass5[`I] <= pass4[`I]; pass5[`J] <= pass4[`J];
        pass5[`K] <= pass4[`K]; pass5[`L] <= pass4[`L]; pass5[`M] <= pass4[`M]; pass5[`N] <= pass4[`N]; pass5[`O] <= pass4[`O];
        pass5[`P] <= pass4[`P]; pass5[`Q] <= pass4[`Q]; pass5[`R] <= pass4[`R]; pass5[`S] <= pass4[`S]; pass5[`T] <= pass4[`T];
        pass5[`U] <= pass4[`U]; pass5[`V] <= pass4[`V]; pass5[`W] <= pass4[`W]; pass5[`X] <= pass4[`X]; pass5[`Y] <= pass4[`Y]; pass5[`Z] <= pass4[`Z];


        // PASS 6 - ROTOR MID REVERESE
        pass6[`U] <= pass5[`A]; pass6[`W] <= pass5[`B]; pass6[`Y] <= pass5[`C]; pass6[`G] <= pass5[`D]; pass6[`A] <= pass5[`E];
        pass6[`D] <= pass5[`F]; pass6[`F] <= pass5[`G]; pass6[`P] <= pass5[`H]; pass6[`V] <= pass5[`I]; pass6[`Z] <= pass5[`J];
        pass6[`B] <= pass5[`K]; pass6[`E] <= pass5[`L]; pass6[`C] <= pass5[`M]; pass6[`K] <= pass5[`N]; pass6[`M] <= pass5[`O];
        pass6[`T] <= pass5[`P]; pass6[`H] <= pass5[`Q]; pass6[`X] <= pass5[`R]; pass6[`S] <= pass5[`S]; pass6[`L] <= pass5[`T];
        pass6[`R] <= pass5[`U]; pass6[`I] <= pass5[`V]; pass6[`N] <= pass5[`W]; pass6[`J] <= pass5[`X]; pass6[`O] <= pass5[`Y]; pass6[`J] <= pass5[`Z];


        // PASS 7 - ROTOR RIGHT REVERESE
        pass7[`A] <= pass6[`A]; pass7[`J] <= pass6[`B]; pass7[`P] <= pass6[`C]; pass7[`C] <= pass6[`D]; pass7[`Z] <= pass6[`E];
        pass7[`W] <= pass6[`F]; pass7[`R] <= pass6[`G]; pass7[`L] <= pass6[`H]; pass7[`F] <= pass6[`I]; pass7[`B] <= pass6[`J];
        pass7[`D] <= pass6[`K]; pass7[`K] <= pass6[`L]; pass7[`O] <= pass6[`M]; pass7[`T] <= pass6[`N]; pass7[`Y] <= pass6[`O];
        pass7[`U] <= pass6[`P]; pass7[`Q] <= pass6[`Q]; pass7[`G] <= pass6[`R]; pass7[`E] <= pass6[`S]; pass7[`N] <= pass6[`T];
        pass7[`H] <= pass6[`U]; pass7[`X] <= pass6[`V]; pass7[`M] <= pass6[`W]; pass7[`I] <= pass6[`X]; pass7[`V] <= pass6[`Y]; pass7[`S] <= pass6[`Z];


        output_A = pass7[`F];
        output_B = pass7[`H];
        output_C = pass7[`J];
        output_D = pass7[`L];
        output_E = pass7[`C];
        output_F = pass7[`P];
        output_G = pass7[`R];
        output_H = pass7[`T];
        output_I = pass7[`X];
        output_J = pass7[`V];
        output_K = pass7[`Z];
        output_L = pass7[`N];
        output_M = pass7[`Y];
        output_N = pass7[`E];
        output_O = pass7[`I];
        output_P = pass7[`W];
        output_Q = pass7[`G];
        output_R = pass7[`A];
        output_S = pass7[`K];
        output_T = pass7[`M];
        output_U = pass7[`U];
        output_V = pass7[`S];
        output_W = pass7[`Q];
        output_X = pass7[`O];
        output_Y = pass7[`B];
        output_Z = pass7[`D];
        end
        else begin
        //defalt  
        output_A = input_A;
        output_B = input_B;
        output_C = input_C;
        output_D = input_D;
        output_E = input_E;
        output_F = input_F;
        output_G = input_G;
        output_H = input_H;
        output_I = input_I;
        output_J = input_J;
        output_K = input_K;
        output_L = input_L;
        output_M = input_M;
        output_N = input_N;
        output_O = input_O;
        output_P = input_P;
        output_Q = input_Q;
        output_R = input_R;
        output_S = input_S;
        output_T = input_T;
        output_U = input_U;
        output_V = input_V;
        output_W = input_W;
        output_X = input_X;
        output_Y = input_Y;
        output_Z = input_Z;  
        end
    end


always @(posedge CLK100MHZ) begin
       
        // Set the output pattern based on which input is active
        case (1'b1) // Only one input variable will be high at a time
            output_A: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00000;
            output_B: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00001;
            output_C: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00010;
            output_D: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00011;
            output_E: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00100;
            output_F: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00101;
            output_G: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00110;
            output_H: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b00111;
            output_I: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01000;
            output_J: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01001;
            output_K: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01010;
            output_L: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01011;
            output_M: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b01100;
            output_N: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10000;
            output_O: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10001;
            output_P: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10010;
            output_Q: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10011;
            output_R: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10100;
            output_S: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10101;
            output_T: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10110;
            output_U: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b10111;
            output_V: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11000;
            output_W: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11001;
            output_X: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11010;
            output_Y: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11011;
            output_Z: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11100;
            default: {o_lb4, o_lb3, o_lb2, o_lb1, o_lb0} <= 5'b11111; // Default pattern
        endcase
    end

always @(posedge CLK100MHZ) begin
    o_lb4N<=~o_lb4;
    end

endmodule

