`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2024 08:02:02 AM
// Design Name: 
// Module Name: divider_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divider_tb;
	reg [31:0] A;           // Input A (32-bit)
    reg [31:0] B;           // Input B (32-bit)
    reg [31:0] C;
    reg CLK;  
    reg [5:0] flags;
    reg done;
	 divider uut (
    .A(A),
    .B(B),
    .C(C),
    .flags(flags),
    .CLK(CLK),
    .done(done)
);


    // Clock generation (50MHz clock for testing purposes)

    // Test sequence
   initial begin
        // Initialize clock
        CLK = 0;
        forever #5 CLK = ~CLK; // Clock with period of 10 time units
    end
    initial begin

        // Test Case 1: Infinity * Non zero number
        #10
        // Case 1: Infinity * Infinity
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b01111111100000000000000000000000; // +Infinity
        #40;
        $display("Test Case 1: Infinity * Infinity");
        $display("C = %b, flags = %b", C, flags);

        // Case 2: Infinity * Zero (should return qNaN)
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b00000000000000000000000000000000; // +Zero
        #40;
        $display("Test Case 2: Infinity * Zero (should be qNaN)");
        $display("C = %b, flags = %b", C, flags);

        // Case 3: Zero * Zero (should return zero)
        A = 32'b00000000000000000000000000000000; // +Zero
        B = 32'b00000000000000000000000000000000; // +Zero
        #40;
        $display("Test Case 3: Zero * Zero");
        $display("C = %b, flags = %b", C, flags);

        // Case 4: sNaN * Normal (should return sNaN)
        A = 32'b01111111110000000000000000000001; // sNaN
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #40;
        $display("Test Case 4: sNaN * Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 5: qNaN * Normal (should return qNaN)
        A = 32'b01111111110000000000000000000000; // qNaN
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #40;
        $display("Test Case 5: qNaN * Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 6: Subnormal * Normal (should return subnormal)
        A = 32'b00000000000000000000000000000001; // Smallest subnormal number
        B = 32'b01000000010000000000000000000000; // Normal number (3.0)
        #40;
        $display("Test Case 6: Subnormal * Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 7: Normal * Normal (should return normal)
        A = 32'b01000001111100000000000000000000; // Normal number (30.0)
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #40;
        $display("Test Case 7: Normal * Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 8: Infinity * Normal (should return infinity)
        A = 32'b01111111100000000000000000000000; // +Infinity
        B = 32'b01000000110000000000000000000000; // Normal number (6.0)
        #40;
        $display("Test Case 8: Infinity * Normal");
        $display("C = %b, flags = %b", C, flags);

        // Case 9: Subnormal * Subnormal (should return zero here)
        A = 32'b00000000000000000000000000000001; // Smallest subnormal number
        B = 32'b00000000000000000000000000000010; // Subnormal number
        #40;
        $display("Test Case 9: Subnormal * Subnormal");
        $display("C = %b, flags = %b", C, flags);
        // End simulation
        #40
        $stop;
    end

endmodule
