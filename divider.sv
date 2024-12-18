`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2024 05:03:58 PM
// Design Name: 
// Module Name: divider
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


module divider(A, B, C, flags, done, CLK);
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
    reg [23:0] Result_Mantissa;
    reg [23:0] Tmp_Mantissa;
    reg signed [10:0] Tmp_Exp;
    reg Sign;
    reg [5:0] a_flags;
    reg [5:0] b_flags;
    reg [1:0] state = 2'b00;   // Use 2 bits to track states (IDLE, WAIT, DONE)
    reg start = 1'b0;
    reg done_div;
    
    flags aClass(A, a_flags);
    flags bClass(B, b_flags);

    reg [47:0] Quotient;
    reg [23:0] Remainder;
    reg [24:0] Rounded_Mantissa;
    reg [26:0] Extended_Mantissa;
    reg guard, round, sticky;

    // Align the dividend by left-shifting its mantissa
    // Ensure no overflow: mantissa is 23 bits with an implicit '1' bit
    reg [47:0] aligned_dividend;
    reg [24:0] aligned_divisor;
    
    // Instantiate the division module
    mantissa_divider #(24) div_module(.clk(CLK), .start(start), .done(done_div), .dividend(aligned_dividend ), .divisor(aligned_divisor ), .quotient(Quotient), .remainder(Remainder));

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

        Sign = A[31] ^ B[31];

        // Handle special cases first
        
        begin
            // Main state machine logic for handling the division and normalization
            case (state)
                2'b00: begin
                    done = 1'b0;
                    if (a_snan || b_snan) begin
                        Tmp = (a_snan ? A : B);
                        flags = 6'b100000;
                    end
                    else if (a_qnan || b_qnan) begin
                        Tmp = (a_qnan ? A : B);
                        flags = 6'b010000;
                    end
                    else if (a_infinity || b_infinity) begin
                        if (a_infinity && b_infinity) begin
                            Tmp = {Sign, {8{1'b1}}, 1'b1, 22'h02A}; // qNaN (Indeterminate form)
                            flags = 6'b010000;
                        end else if (b_infinity) begin
                            Tmp = {Sign, {31{1'b0}}}; // A finite number divided by infinity is zero
                            flags = 6'b000100;
                        end else begin
                            Tmp = {Sign, {8{1'b1}}, {23{1'b0}}}; // Infinity result
                            flags = 6'b001000;
                        end
                    end
                    else if (a_zero && b_zero) begin
                        Tmp = {Sign, {8{1'b1}}, 1'b1, 22'h02A}; // 0/0 results in qNaN
                        flags = 6'b010000;
                    end
                    else if (a_zero) begin
                        Tmp = {Sign, {31{1'b0}}}; // 0 divided by any finite number results in 0
                        flags = 6'b000100;
                    end
                    else if (b_zero) begin
                        Tmp = {Sign, {8{1'b1}}, {23{1'b0}}}; // Division by zero results in infinity
                        flags = 6'b001000;
                    end
                    // State 0: Normalize the inputs and calculate exponent difference
                    if (a_subnormal) begin
                        Mantissa_A = {1'b0, A[22:0]}; // No implicit 1 for subnormals
                        Exp_A = -126;
                    end else begin
                        Mantissa_A = {1'b1, A[22:0]}; // Implicit 1 for normal values
                        Exp_A = A[30:23] - 127;
                    end
                    if (b_subnormal) begin
                        Mantissa_B = {1'b0, B[22:0]}; // No implicit 1 for subnormals
                        Exp_B = -126;
                    end else begin
                        Mantissa_B = {1'b1, B[22:0]}; // Implicit 1 for normal values
                        Exp_B = B[30:23] - 127;
                    end
                    // Calculate exponent difference
                    Tmp_Exp = Exp_A - Exp_B;
                    aligned_dividend = {24'b0, Mantissa_A} << Tmp_Exp ;
                    aligned_divisor  =  Mantissa_B;
                    start = 1'b1;
                    state = 2'b01; // Move to next state
                end

                2'b01: begin
                    // State 1: Wait for division result from mantissa divider
                    if (done_div) begin
//                        if (Quotient == 0)
//                            // Handle the case where the quotient is zero
//                            Result_Mantissa = Remainder;
//                        else
                            Result_Mantissa = Quotient[46:23];
                        state = 2'b10; // Move to normalization
                        start = 1'b0; 
                    end
                end

                2'b10: begin
                    integer shift_amount = 0; // Initialize shift_amount to 0
                    // Find the position of the first '1' in the mantissa
//                    if (!Result_Mantissa[23]) begin
                    // Find the position of the first '1' in the mantissa
                        for (integer i = 23; i >= 0; i = i - 1) begin
                            if (Result_Mantissa[i]) begin
                                shift_amount = 23 - i; 
                                break; 
                            end
//                        end
                    end
                        
                    // Apply the shift based on the shift_amount
 
                    Result_Mantissa = Result_Mantissa << shift_amount;
                    Tmp_Exp = Tmp_Exp - shift_amount;
                    
//                    if (Quotient == 0) begin
//                    // Construct Extended_Mantissa
//                        Extended_Mantissa = {Result_Mantissa, Remainder[2:0]};
    
//                        // Calculate Guard, Round, and Sticky Bits
//                        guard = Extended_Mantissa[2];
//                        round = Extended_Mantissa[1];
//                        sticky = |Remainder[0] || (Remainder == 0); // Ensure sticky bit is correct
    
//                        // Apply IEEE 754 Rounding
//                        if (guard && (round || sticky || Extended_Mantissa[3])) begin
//                            Extended_Mantissa = Extended_Mantissa + 4;
//                        end
                    
//                        // Extract Final Mantissa
//                        if (Extended_Mantissa[26]) begin
//                            Tmp_Mantissa = Extended_Mantissa[25:3]; // Handle overflow
//                            Tmp_Exp = Tmp_Exp + 1;
//                        end else begin
//                            Tmp_Mantissa = Extended_Mantissa[26:4];
//                        end
//                    end else begin
                        Tmp_Mantissa = Result_Mantissa[22:0];
//                    end

                    // Handle result based on exponent range
                    if (Tmp_Exp < -149) begin
                        Tmp = {Sign, {31{1'b0}}}; // Underflow to zero
                        flags = 6'b000100;
                    end
                    else if (Tmp_Exp < -126) begin
                        Tmp = {Sign, {8{1'b0}}, Tmp_Mantissa[22:0]}; // Subnormal result
                        flags = 6'b000010;
                    end
                    else if (Tmp_Exp > 127) begin
                        Tmp = {Sign, {8{1'b1}}, {23{1'b0}}}; // Overflow to infinity
                        flags = 6'b001000;
                    end
                    else begin
                        Tmp = {Sign, Tmp_Exp[7:0] + 127, Tmp_Mantissa[22:0]}; // Normal result
                        flags = 6'b000001;
                    end

                    state = 2'b11; // Move to done state
                end

                2'b11: begin
                    // State 3: Done, assign the result and set the done signal
                    C = Tmp;
                    done = 1'b1;
                    state = 2'b00; // Reset to initial state for next operation
                end
            endcase
        end
    end
endmodule
