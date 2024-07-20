`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/20/2024 09:17:40 AM
// Design Name: 
// Module Name: AddSub
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
    wire [22:0] mantissaA = A[22:0];
    wire [22:0] mantissaB = B[22:0];
    reg [7:0] difference;
    
    // Extract info about exponents
    always @ * begin
        if (expA > expA)
        begin
            difference = expA - expB;
        end
        else if (expB > expA)
        begin
            difference = expB - expA;
        end
        else difference = 8'b0;
    end
    
    // Add or Sub logic
    always @(posedge CLK)
    begin
        if (!RSTn)
        begin
            C = 32'b0;
        end
        
    end
    
endmodule
