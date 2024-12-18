`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 10:59:31 PM
// Design Name: 
// Module Name: subtractor_8bit
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


module subtractor_8bit (
    input logic [7:0] reg1,    // First 8-bit input
    input logic [7:0] reg2,    // Second 8-bit input
    output logic [7:0] result, // Result of the subtraction
    output logic cout          // Borrow out flag
);

    logic [8:0] extended_result; // Intermediate 9-bit result to handle borrow

    always_comb begin
        extended_result = {1'b0, reg1} - {1'b0, reg2}; // Perform subtraction
        result = extended_result[7:0];                // Assign the 8-bit result
        cout = extended_result[8];                    // Borrow out is the MSB of extended_result
    end

endmodule

