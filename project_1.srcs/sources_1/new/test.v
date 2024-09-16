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
//module test(
//    input CLK100MHZ,
//    output [3:0] led
//    );
//    assign led ={3'b00,CLK100MHZ};
//endmodule


//clock devider 
//module test(
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
//    input [3:0] btn,      
//    output [3:0] led    
//    );
//    wire sum;
//    wire count;
//    assign Sum = btn[0] ^ btn[1] ^ btn[2];
//    assign Cout = (btn[0] & btn[1]) | (btn[2] & (btn[0] ^ btn[1]));
//    assign led ={2'b00,Sum,Cout};
//endmodule

//4-bit mux counter 
module test (
    input CLK100MHZ,       
    input [3:0] btn ,            
    output reg [3:0] led
    );

    reg [31:0] debounce_counter = 0; 
    reg [3:0] counter = 0;           
    reg [1:0] sel = 0;              

    // Debounce logic for button press
    always @(posedge CLK100MHZ) begin
        if (btn[0] == 1 && debounce_counter == 0) begin
            counter <= counter + 1;    // Increment counter on button press
            debounce_counter <= 1000000; // Debounce time (10ms assuming 100MHz)
        end else if (debounce_counter > 0) begin
            debounce_counter <= debounce_counter - 1;
        end
    end

    // MUX logic: selects one of the 4 bits of the counter to display on LEDs
    always @(posedge CLK100MHZ) begin
        case (sel)
            2'b00: led[0] <= 4'b0001 << counter[0]; // Display the LSB of the counter
            2'b01: led[1] <= 4'b0001 << counter[1]; // Display the 2nd bit of the counter
            2'b10: led[2] <= 4'b0001 << counter[2]; // Display the 3rd bit of the counter
            2'b11: led[3] <= 4'b0001 << counter[3]; // Display the MSB of the counter
        endcase

        // Increment the select line to change which bit is shown on LEDs
        sel <= sel + 1;
    end
endmodule
