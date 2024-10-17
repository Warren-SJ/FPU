`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Warren Jayakumar
// 
// Create Date: 07/20/2024 09:17:40 AM
// Design Name: Adder and Subtracter for FloatinG Point Unit
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


module addsub(A, B, C, flags, done, CLK, operation);
    parameter BIT_WIDTH = 32;
    input [BIT_WIDTH - 1:0] A;
    input [BIT_WIDTH - 1:0] B;
    output reg [BIT_WIDTH - 1:0] C;
    output reg [5:0] flags;
    output reg done;
    input CLK;
    input operation;
    reg a_snan, a_qnan, a_infinity, a_zero, a_subnormal, a_normal;
    reg b_snan, b_qnan, b_infinity, b_zero, b_subnormal, b_normal;
    reg [BIT_WIDTH-1:0] Tmp;
    reg [23:0] Mantissa_A, Mantissa_B;
    reg [7:0] Exp_A, Exp_B;
    reg Sign;
	reg [5:0]a_flags;
	reg [5:0] b_flags;
	reg [8:0] shiftAmount;
	reg [4:0] subnormalShift;
	reg [24:0] result_Mantissa;
	reg [22:0] Tmp_Mantissa;
	reg signed [9:0] Tmp_Exp;
    flags aClass(A, a_flags);
    flags bClass(B, b_flags);
    integer shift_count;

    // Extract info about operands and operators
    always @(posedge CLK) begin
        a_snan      = a_flags[5];
        a_qnan      = a_flags[4];
        a_infinity  = a_flags[3];
        a_zero      = a_flags[2];
        a_subnormal = a_flags[1];
        a_normal    = a_flags[0];
        
        b_snan      = b_flags[5];
        b_qnan      = b_flags[4];
        b_infinity  = b_flags[3];
        b_zero      = b_flags[2];
        b_subnormal = b_flags[1];
        b_normal    = b_flags[0];
        
        Exp_A = A[30:23];
        Exp_B = B[30:23];
        if (a_subnormal)
            Mantissa_A = {1'b0, A[22:0]};
        else
            Mantissa_A  = {1'b1, A[22:0]};
        if (b_subnormal)
            Mantissa_B = {1'b0, B[22:0]};
        else
            Mantissa_B  = {1'b1, B[22:0]};
        done = 1'b0;
        
        if (a_snan | b_snan) begin
            Tmp = (a_snan ? A : B);
            flags = 6'b100000;
        end
        else if (a_qnan | b_qnan) begin
            Tmp = (a_qnan ? A : B);
            flags = 6'b010000;
        end
        else if (a_zero & b_zero)
        begin
            Tmp = A;
            flags = 6'b000100;
        end
         else if (a_infinity && b_infinity)
         begin
         if (operation == 1'b0) begin
            Tmp = {A[BIT_WIDTH - 1], {8{1'b1}}, 1'b1, 22'h02A};
            flags = 6'b010000;
            end else begin
                Tmp = A;
                flags = 6'b001000;
            end
          end
          else if (a_infinity)
          begin
            Tmp = A;
            flags = 6'b001000;
          end
          else if (b_infinity)
          begin
            Tmp = B;
            flags = 6'b001000;
          end else begin
          shift_count = 0;
          if (Exp_A > Exp_B) begin
            Sign = A[BIT_WIDTH - 1];
            shiftAmount = Exp_A - Exp_B;
            Mantissa_B = Mantissa_B >> shiftAmount;
            Tmp_Exp = Exp_A;
        end else begin
            Sign = B[BIT_WIDTH - 1];
            shiftAmount = Exp_B - Exp_A;
            Mantissa_A = Mantissa_A >> shiftAmount;
            Tmp_Exp = Exp_B;
        end
        // Perform addition or subtraction
        if (operation == 1'b1) begin
            // Addition
            result_Mantissa = Mantissa_A + Mantissa_B;
        end else begin
            // Subtraction
            if (Mantissa_A >= Mantissa_B) begin
                result_Mantissa = Mantissa_A - Mantissa_B;
            end else begin
                result_Mantissa = Mantissa_B - Mantissa_A;
                Sign = ~Sign;  // Change sign if B > A
            end
        end
            if (result_Mantissa[24]) begin
                Tmp_Mantissa = result_Mantissa[23:1];
                Tmp_Exp = Tmp_Exp + 1;
            end else begin
                while (!result_Mantissa[23] && Tmp_Exp > -126  && shift_count < 23) begin
                    result_Mantissa = result_Mantissa << 1;
                    Tmp_Exp = Tmp_Exp - 1;
                    shift_count = shift_count + 1;
                end
                Tmp_Mantissa = result_Mantissa[22:0];
            end
            if (Tmp_Exp > 255) //Infinity Output
                begin
                Tmp = {Sign, 8'b11111111, 22'b0}; 
                flags = 6'b001000;
                end
            else if (Tmp_Exp < -22) //Zero Output
                begin
                Tmp = {Sign, {31{1'b0}}};
                flags = 6'b000100; 
                end
            else if (Tmp_Exp < 1) // Subnormal Output
                begin
                subnormalShift = -126 - Tmp_Exp;
                Tmp_Mantissa = Tmp_Mantissa >> subnormalShift;
                Tmp = {Sign, 8'b0000000, Tmp_Mantissa[22:0]};
                flags = 6'b000010;
                end
            else begin
                Tmp = {Sign, Tmp_Exp[7:0], Tmp_Mantissa[22:0]};
                flags = 6'b000001;
            end
          end
          C = Tmp;
          done = 1'b1;
          end
endmodule
