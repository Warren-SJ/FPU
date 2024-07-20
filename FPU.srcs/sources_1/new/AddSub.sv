`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Warren Jayakumar
// 
// Create Date: 07/20/2024 09:17:40 AM
// Design Name: Adder and Subtracter for Floatinf Point Unit
// Module Name: AddSub
// Project Name: FPU
// Target Devices:  XC7A35T1CPG
// Tool Versions: 
// Description: The adder and subtracter component of the Floating Point Unit.
//              This is capable of handling IEEE single precision inputs with exponents ranging from -128 to 127
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AddSub(
    input [31:0] A,
    input [31:0] B,
    input operation,
    input CLK,
    input RSTn,
    output reg [31:0] C
    );
    
    wire [7:0] expA = A[30:23];
    wire [7:0] expB = B[30:23];
    wire [23:0] mantissaA = {1'b1,A[22:0]};
    wire [23:0] mantissaB = {1'b1,B[22:0]};
    reg [7:0] difference;
    reg [280:0] shiftedA;
    reg [280:0] shiftedB;
    reg [280:0] ans; 
    reg bitShiftA; // If exponent of A is larger than that of B, this is high
    
    // Extract info about exponents
    always @ * begin
        if (expA > expB)
        begin
            difference <= expA - expB;
            bitShiftA  <= 1'b1;
        end
        else if (expB > expA)
        begin
            difference <= expB - expA;
            bitShiftA <= 1'b0;
        end
        else begin
            difference <= 8'b0;
            bitShiftA <= 1'b0;
        end
    end
    
    // Add or Sub logic
    always @(posedge CLK)
    begin
        if (!RSTn)
        begin
            C <= 32'b0;
        end
        else
            if (bitShiftA)
            begin
                shiftedA  = mantissaA  << difference;
                shiftedB = mantissaB;
                ans = shiftedA + mantissaB;
            end
            else
            begin
                shiftedB = mantissaB << difference;
                shiftedA = mantissaA ;
                ans = shiftedB + mantissaA;
            end
    end
    
endmodule
