module IEEE_divider (
    input logic [31:0] num1, num2,   // IEEE 754 inputs
    input logic clk, rstn,          // Clock and reset signals
    output logic [31:0] result,     // IEEE 754 result
    output logic [24:0] remainder,  // Remainder from division
    output logic divisionReady,     // Signal to indicate division is complete
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

    assign reg1 = {1'b1, num1[22:0]}; // Append implicit leading 1 for mantissa
    assign reg2 = {1'b1, num2[22:0]};

    subtractor_8bit subtractor (
        .reg1(num1[30:23]),          // Exponent of num1
        .reg2(num2[30:23]),          // Exponent of num2
        .result(reg3),               // Exponent difference
        .cout()                      // Carry out (not used)
    );

    always_ff @(posedge clk or negedge rstn) begin : divider
        if (!rstn) begin
            result <= 32'b0;
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
            if (num2 == 32'b0) begin
                divByZero <= 1'b1;
                result <= 32'h7FC00000; // Return NaN for IEEE 754
            end else if (num1[30:23] == 8'hFF || num2[30:23] == 8'hFF) begin
                invalid <= 1'b1;
                result <= 32'h7FC00000; // Return NaN for invalid operation
            end else begin
                // Normal operation
                result[31] <= num1[31] ^ num2[31]; // Sign of the result

                if (normalize) begin
                    result[30:23] <= reg3 + 8'd127 - 1'b1; // Adjust exponent for normalization
                    result[22:0] <= quotient[23:1];        // Assign normalized quotient
                end else begin
                    result[30:23] <= reg3 + 8'd127;        // Exponent without normalization
                    result[22:0] <= quotient[23:1];
                end

                // Check for underflow and overflow
                if (reg3 + 8'd127 < 8'd1) begin
                    underflow <= 1'b1;
                    result <= 32'b0; // Set result to zero for underflow
                end else if (reg3 + 8'd127 > 8'd254) begin
                    overflow <= 1'b1;
                    result <= {result[31], 8'hFF, 23'b0}; // Set result to infinity for overflow
                end
            end
        end
    end

    divider_24bit_A #( // Mantissa division module
        .N(24)
    ) dut (
        .num1(reg1), 
        .num2(reg2),
        .clk(clk), 
        .rstn(rstn),
        .quotient(quotient),
        .remainder(remainder),
        .normalize(normalize),
        .divisionReady(divisionReady)
    );

endmodule

