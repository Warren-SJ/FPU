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
// Description: 32 bit IEE754 multiplier
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
    output [31:0] C,
    output qnan, snan, infinity, zero, subnormal, normal,
	 input CLK
    );
	 
	 wire a_snan, a_qnan, a_infinity, a_zero, a_subnormal, a_normal;
	 wire b_snan, b_qnan, b_infinity, b_zero, b_subnormal, b_normal;
	 reg [31:0]Tmp;
	 
	 flags aClass(A, a_snan, a_qnan, a_infinity, a_zero, a_subnormal, a_normal);
	 flags bClass(B, b_snan, b_qnan, b_infinity, b_zero, b_subnormal, b_normal);
	 
	 always @(posedge CLK)
	 begin
		reg Sign <= A[31] ^ B[31];
		reg Tmp[31:0] <= {1'b0, {8{1'b1}}, 1'b0, {22{1'b1}}};
		if ((a_snan | b_snan) == 1'b1) // If one input is an s_nan, we set the output to the s_nan
			begin
				Tmp = a_snan == 1'b1? a:b;
				snan <= 1;
			end
		else if ((a_qnan | b_qnan) == 1'b1) // If one input is a q_nan, we set the output to the s_nan
			begin
				Tmp = a_qnan == 1'b1? a:b;
				qnan <= 1;
			end
		end
		else if((a_infinity | b_infinity) == 1'b1)
			begin
				if ((a_zero | b_zero) == 1'b1)
					begin
						Tmp <= {Sign, {5{1'b1}}, 1'b1, 22'h02A}; // 0 times infinity returns *
						qnan <= 1;
					end
				else
					begin
						Tmp <= {Sign, {5{1'b1}}, {26{1'b0}}};
						infinity <= 1;
					end
			end
		else if((a_zero | b_zero) == 1'b1)
		begin
			Tmp <= {Sign, {31{1'b0}}};
			zero <= 1;
		end
	 end
endmodule
