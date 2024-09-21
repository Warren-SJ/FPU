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
    reg operation;          // Operation: 0 for addition, 1 for subtraction
    reg CLK;                // Clock signal
    reg RSTn;               // Reset signal (active low)
    wire [31:0] C;          // Output result (32-bit)

    // Instantiate the addsub module
    addsub uut (
        .A(A),
        .B(B),
        .operation(operation),
        .CLK(CLK),
        .RSTn(RSTn),
        .C(C)
    );

    // Clock generation (50MHz clock for testing purposes)
    always begin
        #10 CLK = ~CLK; // 50 MHz clock (20ns period)
    end

    // Test sequence
    initial begin
        // Initialize signals
        CLK = 0;
        RSTn = 0;
        A = 32'b0;
        B = 32'b0;
        operation = 0;

        // Apply reset
        #5 RSTn = 0;
        #15 RSTn = 1; // Release reset after a short delay

        // Test Case 1: Add 3.5 + 1.25
        // 3.5 (in float) = 0x40600000, 1.25 (in float) = 0x3FA00000
        A = 32'h40600000; // 3.5 in IEEE 754
        B = 32'h3FA00000; // 1.25 in IEEE 754
        operation = 0; // Addition
        #50;

        // Test Case 2: Subtract 3.5 - 1.25
        A = 32'h40600000; // 3.5
        B = 32'h3FA00000; // 1.25
        operation = 1; // Subtraction
        #50;

        // Test Case 3: Add 5.0 + 2.75
        A = 32'h40A00000; // 5.0 in IEEE 754
        B = 32'h40300000; // 2.75 in IEEE 754
        operation = 0; // Addition
        #50;

        // Test Case 4: Subtract 5.0 - 2.75
        A = 32'h40A00000; // 5.0
        B = 32'h40300000; // 2.75
        operation = 1; // Subtraction
        #50;

        // End simulation
        $stop;
    end

endmodule
