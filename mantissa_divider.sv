`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2024 03:44:39 PM
// Design Name: 
// Module Name: mantissa_divider
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


module mantissa_divider #(parameter WIDTH = 24) (
    input [WIDTH-1:0] dividend,      // Mantissa of A
    input [WIDTH-1:0] divisor,       // Mantissa of B
    output reg [WIDTH-1:0] quotient, // Quotient result
    output reg [WIDTH-1:0] remainder, // Final remainder
    output reg done,                 // Done signal
    input clk,                       // Clock signal
    input start                      // Start signal
);

    // Internal registers
    reg [2*WIDTH-1:0] temp_dividend; // Extended dividend for precision
    reg [WIDTH-1:0] temp_divisor;    // Temporary divisor
    reg [WIDTH:0] count;             // Counter
    reg busy = 1'b0;

    always @(posedge clk) begin
        if (start && !busy) begin
            // Initialize values
            busy <= 1;
            done <= 0;
            quotient <= 0;
            temp_dividend <= {dividend, {WIDTH{1'b0}}}; // Shift dividend left by WIDTH bits
            temp_divisor <= divisor;
            count <= WIDTH;
        end else if (busy) begin
            if (count > 0) begin
                if (temp_dividend[2*WIDTH-1 -: WIDTH+1] >= {1'b0, temp_divisor}) begin
                    temp_dividend[2*WIDTH-1 -: WIDTH+1] <= temp_dividend[2*WIDTH-1 -: WIDTH+1] - {1'b0, temp_divisor};
                     temp_dividend <= temp_dividend << 1; // Shift left
                    quotient <= (quotient << 1) | 1'b1;
                end else begin
                    quotient <= quotient << 1;
                end
                count <= count - 1;
            end else begin
                busy <= 0;
                done <= 1;
                remainder <= temp_dividend[2*WIDTH-1:WIDTH]; // Assign the remainder
            end
        end else begin
            done <= 0; // Ensure done is reset when not busy
        end
    end
endmodule