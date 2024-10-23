`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2024 04:41:50 PM
// Design Name: 
// Module Name: multiplier
// Project Name: FPU
// Target Devices: 
// Tool Versions: 
// Description: 32 bit IEE754 multiplier. This module takes in 2 32 bit numbers in IEEE754 format as inputs
// and outputs the result of the multiplication and relevant flags
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module multiplier(A, B, C, flags, done, CLK);
    parameter BIT_WIDTH = 32;
    input [BIT_WIDTH - 1:0] A;
    input [BIT_WIDTH - 1:0] B;
    output reg [BIT_WIDTH - 1:0] C;
    output reg [5:0] flags;
    output reg done;
    input CLK;
    
    reg a_snan, a_qnan, a_infinity, a_zero, a_subnormal, a_normal;
    reg b_snan, b_qnan, b_infinity, b_zero, b_subnormal, b_normal;
    reg [BIT_WIDTH-1:0] Tmp;
    reg [23:0] Mantissa_A, Mantissa_B;
    reg signed [8:0] Exp_A, Exp_B;
    reg [47:0] Result_Mantissa;
    reg [23:0] Tmp_Mantissa;
    reg signed [10:0] Tmp_Exp;
    reg Sign;
    reg [5:0] a_flags;
    reg [5:0] b_flags;

    flags aClass(A, a_flags);
    flags bClass(B, b_flags);
    
    shift_and_add_multiplier mantissa_multiplier (
        .Mantissa_A(Mantissa_A),
        .Mantissa_B(Mantissa_B),
        .Result_Mantissa(Result_Mantissa)
    );
    
    always @(posedge CLK) begin
        // Reset all flags
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
        
        done = 1'b0;
        
        Sign = A[31] ^ B[31]; // Result sign is the XOR of A and B sign bits

        
        // Handle special cases first
        if (a_snan || b_snan) begin
            Tmp = (a_snan ? A : B);
            flags = 6'b100000;
        end
        else if (a_qnan || b_qnan) begin
            Tmp = (a_qnan ? A : B);
            flags = 6'b010000;
        end
        else if (a_infinity || b_infinity) begin
            if (a_zero || b_zero) begin
                // 0 * Infinity results in qNaN
                Tmp = {Sign, {8{1'b1}}, 1'b1, 22'h02A}; // qNaN
                flags = 6'b010000;
            end else begin
                Tmp = {Sign, {8{1'b1}}, {23{1'b0}}}; // Infinity
                flags = 6'b001000;
            end
        end
        else if (a_zero || b_zero) begin
            Tmp = {Sign, {31{1'b0}}}; // Zero
            flags = 6'b000100;
        end
        else begin

            // Extract mantissas and exponents from A and B
            if (a_subnormal) begin
                Mantissa_A = {1'b0, A[22:0]}; // No implicit 1 for subnormals
                Exp_A = -126;
                while (Mantissa_A[23] == 1'b0 && Exp_A > -149) begin
                    Mantissa_A = Mantissa_A << 1;
                    Exp_A = Exp_A - 1;
                 end
            end else begin
                Mantissa_A = {1'b1, A[22:0]}; // Implicit 1 for normal numbers
                Exp_A = A[30:23] - 127;
            end

            if (b_subnormal) begin
                Mantissa_B = {1'b0, B[22:0]}; // No implicit 1 for subnormals
                Exp_B = -126;
                while (Mantissa_B[23] == 1'b0 && Exp_B > -149) begin
                    Mantissa_B = Mantissa_B << 1;
                    Exp_B = Exp_B - 1;
                 end
            end else begin
                Mantissa_B = {1'b1, B[22:0]}; // Implicit 1 for normal numbers
                Exp_B = B[30:23] - 127;
            end

            // Add exponents
            Tmp_Exp = Exp_A + Exp_B;

            // Normalize the result (shift mantissa if needed)
            if (Result_Mantissa[47]) begin
                // If the result's MSB is 1, shift right
                Tmp_Mantissa = Result_Mantissa[46:24];
                Tmp_Exp = Tmp_Exp + 1;
            end else begin
                Tmp_Mantissa = Result_Mantissa[45:23];
            end

            // Handle the result based on the exponent
            if (Tmp_Exp < -149) begin
                // Underflow to zero
                Tmp = {Sign, {31{1'b0}}};
                flags = 6'b000100;
            end
            else if (Tmp_Exp < -126) begin
                // Subnormal result
                Tmp = {Sign, {8{1'b0}}, Tmp_Mantissa[22:0]};
                flags = 6'b000010;
            end
            else if (Tmp_Exp > 127) begin
                // Overflow to infinity
                Tmp = {Sign, {8{1'b1}}, {23{1'b0}}};
                flags = 6'b001000;
            end
            else begin
                // Normal result
                Tmp_Exp = Tmp_Exp + 127; // Re-bias the exponent
                Tmp = {Sign, Tmp_Exp[7:0], Tmp_Mantissa[22:0]};
                flags = 6'b000001;
            end
        end
        
        C = Tmp; // Assign the final result
        done = 1'b1;
    end
endmodule


