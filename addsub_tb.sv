`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Warren Jayakumar
// 
// Create Date: 09/21/2024 06:42:37 PM
// Design Name: Testbench for adder and subtracter
// Module Name: addsub_tb
// Project Name: FPU
// Target Devices:  Altera Cyclone IV EP4CE115F29C7N
// Tool Versions: 
// Description: This is the testbench for the adder and subtracter module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module addsub_tb;
	reg [31:0] A;           // Input A (32-bit)
    reg [31:0] B;           // Input B (32-bit)
    reg [31:0] C;
    reg CLK;  
    reg [5:0] flags;
    reg done;
    reg operation;
	addsub uut (
    .A(A),
    .B(B),
    .C(C),
    .flags(flags),
    .CLK(CLK),
    .done(done),
    .operation(operation)
);


    // Clock generation (50MHz clock for testing purposes)

    // Test sequence
   initial begin
        // Initialize clock
        CLK = 0;
        forever #5 CLK = ~CLK; // Clock with period of 10 time units
    end
    initial begin

        #10
        operation = 1'b1;
        // Case 1: Infinity + Infinity
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b01111111100000000000000000000000; // +Infinity

        #50;
        $display("Test Case 1: Infinity + Infinity");
        $display("C = %b, flags = %b", C, flags);

        // Case 2: Infinity + Zero (should return qNaN)
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b00000000000000000000000000000000; // +Zero
        #50;
        $display("Test Case 2: Infinity + Zero (should be infinity)");
        $display("C = %b, flags = %b", C, flags);

        // Case 3: Zero + Zero (should return zero)
        A = 32'b00000000000000000000000000000000; // +Zero
        B = 32'b00000000000000000000000000000000; // +Zero
        #50;
        $display("Test Case 3: Zero + Zero");
        $display("C = %b, flags = %b", C, flags);

        // Case 4: sNaN + Normal (should return sNaN)
        A = 32'b01111111110000000000000000000001; // sNaN
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #50;
        $display("Test Case 4: sNaN + Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 5: qNaN + Normal (should return qNaN)
        A = 32'b01111111110000000000000000000000; // qNaN
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #50;
        $display("Test Case 5: qNaN + Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 6: Subnormal + Normal (should return subnormal)
        A = 32'b00000000000000000000000000000001; // Smallest subnormal number
        B = 32'b01000000010000000000000000000000; // Normal number (3.0)
        #50;
        $display("Test Case 6: Subnormal + Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 7: Normal + Normal (should return normal)
        A = 32'b01000000101000000000000000000000; // Normal number (5.0)
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #50;
        $display("Test Case 7: Normal + Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 8: Infinity + Normal (should return infinity)
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #50;
        $display("Test Case 8: Infinity + Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 9: Subnormal + Subnormal
        A = 32'b00000000000000000000000000000001; // Smallest subnormal number
        B = 32'b00000000000000000000000000000010; // Subnormal number
        #50;
        $display("Test Case 9: Subnormal + Subnormal");
        $display("C = %b, flags = %b", C, flags);
       
       #50;
        operation = 1'b0;
        // Case 1: Infinity - Infinity
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b01111111100000000000000000000000; // +Infinity

        #50;
        $display("Test Case 1: Infinity - Infinity");
        $display("C = %b, flags = %b", C, flags);

        // Case 2: Infinity * Zero (should return qNaN)
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b00000000000000000000000000000000; // +Zero
        #50;
        $display("Test Case 2: Infinity + Zero (should be infinity)");
        $display("C = %b, flags = %b", C, flags);

        // Case 3: Zero * Zero (should return zero)
        A = 32'b00000000000000000000000000000000; // +Zero
        B = 32'b00000000000000000000000000000000; // +Zero
        #50;
        $display("Test Case 3: Zero - Zero");
        $display("C = %b, flags = %b", C, flags);

        // Case 4: sNaN * Normal (should return sNaN)
        A = 32'b01111111110000000000000000000001; // sNaN
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #50;
        $display("Test Case 4: sNaN - Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 5: qNaN - Normal (should return qNaN)
        A = 32'b01111111110000000000000000000000; // qNaN
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #50;
        $display("Test Case 5: qNaN - Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 6: Subnormal - Normal (should return subnormal)
        A = 32'b00000000000000000000000000000001; // Smallest subnormal number
        B = 32'b01000000010000000000000000000000; // Normal number (3.0)
        #50;
        $display("Test Case 6: Subnormal - Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 7: Normal - Normal 
        A = 32'b01000000101000000000000000000000; // Normal number (5.0)
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #50;
        $display("Test Case 7: Normal - Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 8: Infinity - Normal (should return infinity)
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #50;
        $display("Test Case 8: Infinity - Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 9: Subnormal - Subnormal (should return subnormal)
        A = 32'b00000000000000000000000000000001; // Smallest subnormal number
        B = 32'b00000000000000000000000000000010; // Subnormal number
        #10;
        $display("Test Case 9: Subnormal - Subnormal");
        $display("C = %b, flags = %b", C, flags);
        
        #40
        $stop;
    end
endmodule
