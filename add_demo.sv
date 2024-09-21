`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Warren Jayakumar
// 
// Create Date: 09/04/2024 11:37:07 AM
// Design Name: 
// Module Name: add_demo
// Project Name: FPU
// Target Devices: Altera Cyclone IV EP4CE115F29C7N 
// Tool Versions: 
// Description: A demo of the addition and subtraction capabilities
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module add_demo(
    input CLK,
    input RSTn,
    output [17:0] LEDR // Output connected to LEDs on DE2-115 board
);

    reg [31:0] A;
    reg [31:0] B;
    reg operation;
    wire [31:0] C;

    // Instantiate the AddSub module
    addsub uut (
        .A(A),
        .B(B),
        .operation(operation),
        .CLK(CLK),
        .RSTn(RSTn),
        .C(C)
    );

	always @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
            A <= 32'h0;
            B <= 32'h0;
            operation <= 1'b0;
        end
        else begin
            A <= 32'h40600000; // 3.5 in IEEE 754 single-precision format
            B <= 32'h3FA00000; // 1.25 in IEEE 754 single-precision format
            operation <= 1'b0; // 0 for addition, 1 for subtraction
        end
    end
    // Assign the most significant 18 bits of C to the LEDs
    assign LEDR = C[31:14];

endmodule

