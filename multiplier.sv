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


module multiplier(
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] C,
    output reg [5:0] flags,
    input CLK
);
    reg a_snan, a_qnan, a_infinity, a_zero, a_subnormal, a_normal;
    reg b_snan, b_qnan, b_infinity, b_zero, b_subnormal, b_normal;
    reg [31:0] Tmp;
    reg [23:0] Mantissa_A, Mantissa_B;
    reg signed [8:0] Exp_A, Exp_B;
    reg [45:0] result_Mantissa;
    reg [23:0] Tmp_Mantissa;
    reg [10:0] Tmp_Exp;
    reg Sign;
	reg [5:0]a_flags;
	reg [5:0] b_flags;
    flags aClass(A, a_flags);
    flags bClass(B, b_flags);
    always @(posedge CLK) begin
        // Reset all flags
        a_snan      <= a_flags[5];
        a_qnan      <= a_flags[4];
        a_infinity  <= a_flags[3];
        a_zero      <= a_flags[2];
        a_subnormal <= a_flags[1];
        a_normal    <= a_flags[0];
        
        b_snan      <= b_flags[5];
        b_qnan      <= b_flags[4];
        b_infinity  <= b_flags[3];
        b_zero      <= b_flags[2];
        b_subnormal <= b_flags[1];
        b_normal    <= b_flags[0];
        
        Sign <= A[31] ^ B[31];

        // Handle special cases first
		  
        if (a_snan || b_snan) begin
            Tmp <= (a_snan ? A : B);
            flags <= 6'b100000;
        end
        else if (a_qnan || b_qnan) begin
            Tmp <= (a_qnan ? A : B);
            flags <= 6'b010000;
        end
        else if (a_infinity || b_infinity) begin
            if (a_zero || b_zero) begin
                // 0 * Infinity results in qNaN
                Tmp <= {Sign, {8{1'b1}}, 1'b1, 22'h02A}; // Representation of qNaN
                flags <= 6'b010000;
            end else begin
                Tmp <= {Sign, {8{1'b1}}, {23{1'b0}}}; // Infinity representation
                flags <= 6'b001000;
            end
        end
        else if (a_zero || b_zero || (a_subnormal && b_subnormal)) begin
            Tmp <= {Sign, {31{1'b0}}}; // Zero representation
            flags <= 6'b000100;
        end
        else begin
            // Handle normal multiplication
            Mantissa_A <= {1'b1, A[22:0]}; // Implicit 1 for normalized values
            Mantissa_B <= {1'b1, B[22:0]};
            Exp_A <= A[30:23] - 127;
            Exp_B <= B[30:23] - 127;
            Tmp_Exp <= Exp_A + Exp_B;
            result_Mantissa <= Mantissa_A * Mantissa_B;

            // Normalize the result
            if (result_Mantissa[45] == 1'b1) begin
                Tmp_Mantissa <= result_Mantissa[44:22];
                Tmp_Exp <= Tmp_Exp + 1;
            end else begin
                Tmp_Mantissa <= result_Mantissa[45:23];
            end

            // Handle the result based on exponent range
            if (Tmp_Exp < -149) begin
                // Too small, underflow to zero
                Tmp <= {Sign, {31{1'b0}}};
                flags <= 6'b000100;
            end
            else if (Tmp_Exp < -126) begin
                // Subnormal case
                Tmp <= {Sign, {8{1'b0}}, result_Mantissa[22:0]};
                flags <= 6'b000010;
            end
            else if (Tmp_Exp > 127) begin
                // Overflow to infinity
                Tmp <= {Sign, {8{1'b1}}, {23{1'b0}}};
                flags <= 6'b001000;
            end
            else begin
                // Normal result
                Tmp_Exp <= Tmp_Exp + 127; // Re-bias the exponent
                Tmp <= {Sign, Tmp_Exp[7:0], Tmp_Mantissa[22:0]};
                flags <= 6'b000001;
            end
        end
        C <= Tmp; // Assign the final result to output
    end
endmodule

