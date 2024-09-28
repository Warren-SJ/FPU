module BinaryToBCD(
    input [11:0] binary,     // 12-bit binary input
    output reg [3:0] hundreds, // BCD hundreds digit
    output reg [3:0] tens,     // BCD tens digit
    output reg [3:0] ones      // BCD ones digit
);

integer i;

always @(binary) begin
    // Initialize BCD digits
    hundreds = 4'd0;
    tens = 4'd0;
    ones = 4'd0;
    
    // Double Dabble Algorithm
    for (i = 11; i >= 0; i = i - 1) begin
        // Shift BCD digits left by 1
        if (hundreds >= 5)
            hundreds = hundreds + 3;
        if (tens >= 5)
            tens = tens + 3;
        if (ones >= 5)
            ones = ones + 3;
        
        hundreds = hundreds << 1;
        hundreds[0] = tens[3];
        tens = tens << 1;
        tens[0] = ones[3];
        ones = ones << 1;
        ones[0] = binary[i];
    end
end

endmodule
