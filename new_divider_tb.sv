`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 11:06:20 PM
// Design Name: 
// Module Name: new_divider_tb
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


module IEEE_divider_tb;
    // Testbench signals
    logic [31:0] num1, num2;          // Input operands
    logic clk, rstn;                 // Clock and reset
    logic [31:0] result;             // Division result
    logic [24:0] remainder;          // Remainder output
    logic divisionReady;             // Ready signal

    // Instantiate the DUT (Device Under Test)
    IEEE_divider dut (
        .num1(num1),
        .num2(num2),
        .clk(clk),
        .rstn(rstn),
        .result(result),
        .remainder(remainder),
        .divisionReady(divisionReady)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    // Testbench initialization
    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        num1 = 0;
        num2 = 0;

        // Apply reset
        #10 rstn = 1;

        // Test case 1: 6.0 / 3.0 = 2.0
        num1 = 32'h40C00000; // IEEE 754 for 6.0
        num2 = 32'h40400000; // IEEE 754 for 3.0
        #100;

        // Test case 2: 30.0 / 6.0 = 5.0
        num1 = 32'h41F00000; // IEEE 754 for 30.0
        num2 = 32'h40C00000; // IEEE 754 for 6.0
        #100;

        // Test case 3: 0.5 / 2.0 = 0.25
        num1 = 32'h3F000000; // IEEE 754 for 0.5
        num2 = 32'h40000000; // IEEE 754 for 2.0
        #100;

        // Test case 4: 1.0 / 4.0 = 0.25
        num1 = 32'h3F800000; // IEEE 754 for 1.0
        num2 = 32'h40800000; // IEEE 754 for 4.0
        #100;

        // Test case 5: Edge case - divisor larger than dividend
        num1 = 32'h3F800000; // IEEE 754 for 1.0
        num2 = 32'h40000000; // IEEE 754 for 2.0
        #100;

        // Test case 6: Divide by zero
        num1 = 32'h3F800000; // IEEE 754 for 1.0
        num2 = 32'h00000000; // IEEE 754 for 0.0
        #100;

        // Finish simulation
        $stop;
    end

    // Monitor results
    initial begin
        $monitor($time, " num1=%h, num2=%h, result=%h, remainder=%h, divisionReady=%b",
                 num1, num2, result, remainder, divisionReady);
    end
endmodule

