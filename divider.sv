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
    reg [47:0] Result_Mantissa;
    reg [23:0] Tmp_Mantissa;
    reg signed [10:0] Tmp_Exp;
    reg Sign;
    reg [5:0] a_flags;
    reg [5:0] b_flags;
    reg [1:0] state;   // Use 2 bits to track states (IDLE, WAIT, DONE)
    wire logic start;
    reg busy;
    reg done_div;
    reg valid;

    flags aClass(A, a_flags);
    flags bClass(B, b_flags);

    reg [47:0] Quotient;

    // Instantiate the division module
    mantissa_divider #(23) div_module(.clk(CLK), .start(start), .busy(busy), .done(done_div), .valid(valid), .a(Mantissa_A), .b(Mantissa_B), .val(Quotient));

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
        else begin
            // Main state machine logic for handling the division and normalization
            case (state)
                2'b00: begin
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
                    state = 2'b01; // Move to next state
                end

                2'b01: begin
                    // State 1: Wait for division result from mantissa divider
                    if (done_div) begin
                        Result_Mantissa = Quotient;
                        state = 2'b10; // Move to normalization
                    end
                end

                2'b10: begin
                    // State 2: Normalize the result
                    if (Result_Mantissa[23]) begin
                        Tmp_Mantissa = Result_Mantissa[22:0];
                    end else begin
                        Tmp_Mantissa = Result_Mantissa[22:0];
                        while (!Tmp_Mantissa[23] && Tmp_Exp > -126) begin
                            Tmp_Mantissa = Tmp_Mantissa << 1;
                            Tmp_Exp = Tmp_Exp - 1;
                        end
                    end

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
