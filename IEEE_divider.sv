module IEEE_divider (
    input logic [31:0] num1, num2,
    input logic clk, rstn,
    output logic [31:0] result,
    output logic [24:0] remainder,
    output logic divisionReady
);
    logic normalize;
	logic [24:0] quotient;
    logic [23:0] reg1, reg2;
    logic [7:0] reg3;

assign reg1 = {1'b1, num1[22:0]};
assign reg2 = {1'b1, num2[22:0]};

subtractor_8bit subtractor (
    .reg1(num1[30:23]),
    .reg2(num2[30:23]),
    .result(reg3),
    .cout(cout)
);

always_ff @( posedge clk or negedge rstn ) begin : divider

    if (!rstn) begin
      result <= 32'b0;
    end

    else begin

        result[31] <= num1[31] ^ num2[31];
        if (normalize) begin
            result[30:23] <= reg3 + 8'd127 - 1'b1;
				result[22:0] <= quotient[23:1];
		  end
        else begin
            result[30:23] <= reg3 + 8'd127;
			result[22:0] <= quotient[23:1];
				
        end
    
    end

end

// divider_24bit#(
//     .N(48)
// )  dut(
//     .num1(reg1), 
//     .num2(reg2), //divisor
//     .clk(clk),
//     .rstn(rstn),
//     .remainder(remainder), 
//     .quotient(result_dup),
//     .normalize(normalize)
// );
divider_24bit_A #(
    .N(24)
) dut (
    .num1(reg1), 
    .num2(reg2), //divisor
    .clk(clk), 
    .rstn(rstn),
  	.quotient(quotient),
    .remainder(remainder),
    .normalize(normalize),
    .divisionReady(divisionReady)
);

//just a edit

endmodule
