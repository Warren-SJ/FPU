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


module flags(
    input [31:0] num,
    output snan,
    output qnan,
    output infinity,
    output zero,
    output subnormal,
    output normal
    );
    wire expOnes, expZeros, sigZeros;
     assign expOnes = &num[30:23];
     assign expZeros = ~|num[30:23];
     assign sigZeros = ~|num[22:0];
     
     assign snan = expOnes & ~sigZeros & ~num[22];
     assign qnan = expOnes & num[22];
     assign infinity = expOnes & sigZeros;
     assign zero = expZeros & sigZeros;
     assign subnormal = expZeros & ~sigZeros;
     assign normal = ~expOnes & ~expZeros;
     
endmodule
