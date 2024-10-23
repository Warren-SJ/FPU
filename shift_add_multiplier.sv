`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2024 07:39:06 AM
// Design Name: 
// Module Name: shift_add_multiplier
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


module shift_and_add_multiplier (
    input [23:0] Mantissa_A,
    input [23:0] Mantissa_B,
    output reg [47:0] Result_Mantissa
);
    integer i;
    
    always @(*) begin
        Result_Mantissa = 48'b0; // Reset result
        for (i = 0; i < 24; i = i + 1) begin
            if (Mantissa_B[i] == 1'b1) begin
                Result_Mantissa = Result_Mantissa + (Mantissa_A << i);
            end
        end
    end
endmodule
