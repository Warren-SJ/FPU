`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 11:31:09 PM
// Design Name: 
// Module Name: FPU_top
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


module FPU_top(
    input [31:0] A,
    input [31:0] B,
    output [31:0] Result,
    input [5:0] Flags,
    input CLK,
    input [1:0] operation,
    output reg done
    );
    
    reg [3:0] one_hot_operation;
    reg add;
    reg subtract;
    reg multiply;
    reg divide;
    reg add_sub;
    // Order is addition subtraction multiplication division. Pull high to enable
    multiplier multiplier(
         .A(A),
         .B(B),
         .C(Result),
         .flags(flags),
         .done(done),
         .resetn(multiply),
         .CLK(CLK),
         .done(done)
    );
    
    IEEE_divider divider(
        .num1(A),
        .num2(B),
        .clk(CLK),
        .rstn(divide),          
        .result(C),     
        .divisionReady(done),     // Signal to indicate division is complete
    );
    
    addsub addsub(
         .A(A),
         .B(B),
         .C(Result),
         .flags(flags),
         .done(done),
         .CLK(CLK),
         .reset_n(add_sub),
         .operation(operation)
        
    );
    
    always @(posedge CLK) begin
        case (operation)
            2'b00:
                operation <= 4'b1000;
            2'b01:
                operation <= 4'b0100;
            2'b10:
                operation <= 4'b0010;
            2'b11:
                operation <= 4'b0001;
         endcase
     end 
     assign add = operation[3];
     assign subtract = operation[2];
     assign multiply = operation[1];
     assign divide = operation[0];
     assign add_sub = add . sub;
     assign operation = add?1'b1:1'b0;
endmodule
