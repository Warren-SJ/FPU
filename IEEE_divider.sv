module divider_top (
    input logic [31:0] A, B,   // IEEE 754 inputs
    input logic clk, resetn,          // Clock and reset signals
    output logic [31:0] C,     // IEEE 754 result
    output logic [24:0] remainder,  // Remainder from division
    output logic done,     // Signal to indicate division is complete
    output logic divByZero,         // Flag: Division by zero
    output logic underflow,         // Flag: Underflow
    output logic overflow,          // Flag: Overflow
    output logic invalid            // Flag: Invalid operation (e.g., NaN)
);
    // Internal signals
    logic normalize;
    logic [24:0] quotient;
    logic [23:0] reg1, reg2;
    logic [7:0] reg3;

    assign reg1 = {1'b1, A[22:0]}; // Append implicit leading 1 for mantissa
    assign reg2 = {1'b1, B[22:0]};

    subtractor_8bit subtractor (
        .reg1(A[30:23]),          // Exponent of num1
        .reg2(B[30:23]),          // Exponent of num2
        .result(reg3),               // Exponent difference
        .cout()                      // Carry out (not used)
    );

    always_ff @(posedge clk or negedge resetn) begin : divider
        if (!resetn) begin
            C <= 32'b0;
            divByZero <= 1'b0;
            underflow <= 1'b0;
            overflow <= 1'b0;
            invalid <= 1'b0;
        end else begin
            // Reset flags
            divByZero <= 1'b0;
            underflow <= 1'b0;
            overflow <= 1'b0;
            invalid <= 1'b0;

            // Handle special cases
            if (B == 32'b0) begin
                divByZero <= 1'b1;
                C <= 32'h7FC00000; // Return NaN for IEEE 754
            end else if (A[30:23] == 8'hFF || B[30:23] == 8'hFF) begin
                invalid <= 1'b1;
                C <= 32'h7FC00000; // Return NaN for invalid operation
            end else begin
                // Normal operation
                C[31] <= A[31] ^ B[31]; // Sign of the result

                if (normalize) begin
                    C[30:23] <= reg3 + 8'd127 - 1'b1; // Adjust exponent for normalization
                    C[22:0] <= quotient[23:1];        // Assign normalized quotient
                end else begin
                    C[30:23] <= reg3 + 8'd127;        // Exponent without normalization
                    C[22:0] <= quotient[23:1];
                end

                // Check for underflow and overflow
                if (reg3 + 8'd127 < 8'd1) begin
                    underflow <= 1'b1;
                    C <= 32'b0; // Set result to zero for underflow
                end else if (reg3 + 8'd127 > 8'd254) begin
                    overflow <= 1'b1;
                    C <= {C[31], 8'hFF, 23'b0}; // Set result to infinity for overflow
                end
            end
        end
    end

    divider #( // Mantissa division module
        .N(24)
    ) dut (
        .A(reg1), 
        .B(reg2),
        .clk(clk), 
        .resetn(resetn),
        .C(quotient),
        .normalize(normalize),
        .done(done)
    );

endmodule

