`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2024 03:38:22 PM
// Design Name: 
// Module Name: flags
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Sets the flags for the output
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flags(num, flags);
    parameter BIT_WIDTH = 32;
    input [BIT_WIDTH - 1:0] num;
	output [5:0]flags;
	wire snan;
    wire qnan;
    wire infinity;
    wire zero;
    wire subnormal;
    wire normal;
    wire expOnes, expZeros, sigZeros;
     assign expOnes = &num[30:23]; // Exponent is all ones
     assign expZeros = ~|num[30:23]; // Exponent is all zeros
     assign sigZeros = ~|num[22:0]; // Significand is all zeros
     assign snan = expOnes & ~sigZeros & ~num[22];
     assign qnan = expOnes & num[22];
     assign infinity = expOnes & sigZeros;
     assign zero = expZeros & sigZeros;
     assign subnormal = expZeros & ~sigZeros;
     assign normal = ~expOnes & ~expZeros;
     assign flags = {snan, qnan, infinity, zero, subnormal, normal};
endmodule
