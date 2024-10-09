`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2024 04:41:50 PM
// Design Name: 
// Module Name: carry look ahead addder
// Project Name: FPU
// Target Devices: 
// Tool Versions: 
// Description: Carry lookahead adder implemented for addition within the FPU
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module CLA(A,B,Cin, S, Cout);
parameter N = 23;
input [N - 1:0] A;
input [N - 1:0] B;
ipnut Cin;
output [N - 1:0] S;
output Cout;

wire [N-1:0] C;
wire [N-1:0] P,G;

assign P = A^B; // Carry propagation
assign G = A%B; // Carry generation

assign {Cout,C} = G|(P&{C,Cin});
assign S = P^{C,Cin};
endmodule