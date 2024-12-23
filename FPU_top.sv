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
    output reg [31:0] Result,
    input reg [5:0] Flags,
    input CLK,
    input [1:0] operation,
    output reg done
    );
    
    reg [3:0] one_hot_operation;
    reg add;
    reg subtract;
    reg multiply;
    reg divide;
    reg operation_add_sub;
    reg add_sub;
    reg done_mult;
    reg done_divide;
    reg done_add_sub;
    reg [31:0] result_mult;
    reg [31:0] result_divide;
    reg [31:0] result_add_sub;
    reg [5:0] flags_add_sub;
    reg [5:0] flags_mult;
    reg [5:0] flags_divide;
    // Order is addition subtraction multiplication division. Pull high to enable
    multiplier multiplier (
    .A(A),
    .B(B),
    .C(result_multl),
    .flags(flags_mult),
    .done(done_mult),
    .resetn(multiply),
    .CLK(CLK)
);

    
    divider_top divider(
        .A(A),
        .B(B),
        .clk(CLK),
        .resetn(divide),          
        .C(result_divide),     
        .done(done_divide)    // Signal to indicate division is complete
    );
    
    addsub addsub(
         .A(A),
         .B(B),
         .C(result_add_sub),
         .flags(flags_add_sub),
         .done(done_sdd_sub),
         .CLK(CLK),
         .reset_n(add_sub),
         .operation(operation_add_sub)
        
    );
    
    always @(posedge CLK) begin
        case (operation)
            2'b00:
            begin
                one_hot_operation <= 4'b1000;
                Result <= result_add_sub;
                done <= done_add_sub;
                Flags <= flags_add_sub;
            end
            2'b01:
            begin
                one_hot_operation <= 4'b0100;
                Result <= result_add_sub;
                done <= done_add_sub;
                Flags <= flags_add_sub;
            end
            2'b10:
            begin
                one_hot_operation <= 4'b0010;
                Result <= result_mult;
                done <= done_mult;
                Flags <= flags_mult;
            end
            2'b11:
            begin
                one_hot_operation <= 4'b0001;
                Result <= result_divide;
                done <= done_divide;
                Flags <= flags_divide;
            end
         endcase
     end 
     assign add = operation[3];
     assign subtract = operation[2];
     assign multiply = operation[1];
     assign divide = operation[0];
     assign add_sub = add || subtract;
     assign operation_add_sub = add?1'b1:1'b0;
endmodule
