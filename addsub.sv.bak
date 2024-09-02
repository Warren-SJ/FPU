`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Warren Jayakumar
// 
// Create Date: 07/20/2024 09:17:40 AM
// Design Name: Adder and Subtracter for Floatinf Point Unit
// Module Name: AddSub
// Project Name: FPU
// Target Devices:  XC7A35T1CPG
// Tool Versions: 
// Description: The adder and subtracter component of the Floating Point Unit.
//              This is capable of handling IEEE single precision inputs with exponents ranging from -128 to 127
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
    input operation, // 0 for addition, 1 for subtraction
    input CLK,
    input RSTn,
    output reg [31:0] C
);

    wire [7:0] expA = A[30:23];
    wire [7:0] expB = B[30:23];
    wire signA  =A[31];
    wire signB = B[31];
    reg [7:0] finalExponent;
    wire [23:0] mantissaA = {1'b1,A[22:0]};
    wire [23:0] mantissaB = {1'b1,B[22:0]};
    reg [7:0] difference;
    reg [23:0] shiftedA;
    reg [23:0] shiftedB;
    reg [24:0] ans;
    reg largeA; // If exponent of A is larger than that of B, this is high
    reg requiredoperation;
    reg [5:0] index;


    // Extract info about operands and operators
    always @ * begin
        if (expA > expB)
            begin
                difference <= expA - expB;
                largeA  <= 1'b1;
            end
        else if (expB > expA)
            begin
                difference <= expB - expA;
                largeA <= 1'b0;
            end
        else begin
            difference <= 8'b0;
            largeA <= 1'b0;
        end
        requiredoperation = signB ^ operation; //required operation is 1 if subtraction and 0 if addition
    end


    // Add or Sub logic
    always @(posedge CLK)
    begin
        if (!RSTn)
            begin
                C <= 32'b0;
            end
        else
            if (largeA)
                begin
                    shiftedB  <= mantissaB  >> difference;
                    shiftedA <= mantissaA;
                    finalExponent <= expA;
                end
            else
                begin
                    shiftedA <= mantissaA >> difference;
                    shiftedB <= mantissaB ;
                    finalExponent <= expB;
                end
        if (!requiredoperation)
            begin
                if (!signA)
                    ans <= shiftedA + shiftedB;
                else
                    ans <= - shiftedA + shiftedB;
            end
        else
            begin
                if (!signA)
                    ans <= shiftedA - shiftedB;
                else
                    ans <= - shiftedA - shiftedB;
            end
        casex (ans)
            24'b1??????????????????????? : index <= 5'd23;
            24'b01?????????????????????? : index <= 5'd22;
            24'b001????????????????????? : index <= 5'd21;
            24'b0001???????????????????? : index <= 5'd20;
            24'b00001??????????????????? : index <= 5'd19;
            24'b000001?????????????????? : index <= 5'd18;
            24'b0000001????????????????? : index <= 5'd17;
            24'b00000001???????????????? : index <= 5'd16;
            24'b000000001??????????????? : index <= 5'd15;
            24'b0000000001?????????????? : index <= 5'd14;
            24'b00000000001????????????? : index <= 5'd13;
            24'b000000000001???????????? : index <= 5'd12;
            24'b0000000000001??????????? : index <= 5'd11;
            24'b00000000000001?????????? : index <= 5'd10;
            24'b000000000000001????????? : index <= 5'd9;
            24'b0000000000000001???????? : index <= 5'd8;
            24'b00000000000000001??????? : index <= 5'd7;
            24'b000000000000000001?????? : index <= 5'd6;
            24'b0000000000000000001????? : index <= 5'd5;
            24'b00000000000000000001???? : index <= 5'd4;
            24'b000000000000000000001??? : index <= 5'd3;
            24'b0000000000000000000001?? : index <= 5'd2;
            24'b00000000000000000000001? : index <= 5'd1;
            24'b000000000000000000000001 : index <= 5'd0;
            default:
            begin
                index <= 5'd0;
            end
        endcase
        ans <= ans >> (24-index);
        C <= {signA ^ signB,finalExponent, ans[22:0]};
    end

endmodule
