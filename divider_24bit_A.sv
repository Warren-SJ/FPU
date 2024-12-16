// // non restoring

// module divider_24bit_A #(
//     N = 24
// )(
//     input logic [N-1:0] num1, 
//     input logic [N-1:0] num2, //divisor
//     input logic clk, rstn,
//   	output logic [N:0] quotient,
//     output logic normalize,
//     output logic divisionReady
// );
//     logic [2*N:0] aq, d;
//     logic [N:0] M;
//     logic [$clog2(N)-1:0] c_bits;
//     logic [N-1:0] subt;
//     logic overflow;
//     enum logic [1:0] {START, SUB, FINAL} state;
    
    
//     always_ff @( posedge clk or negedge rstn ) begin : divisor

//         if (!rstn) begin

//             c_bits <= 0;
//             aq <= {1'b0, num1, 24'b0};
//             d <= {1'b0, num2, 24'b0};
//             {overflow, subt} <= num1 - num2;
//             quotient <= 0; 
//             normalize <= 0; 
//             state <= START;
//             divisionReady <= 1;
//         end

//         else begin
            
//             case (state)
//                 START: begin
//                     if (overflow) begin
//                         state <= SUB;  
//                         normalize <= 1;

//                     end

//                     if (!overflow) begin
//                         aq <= aq >> 1;  // can be a edit
//                         state <= SUB;
//                         normalize <= 0;
//                     end
                    
//                 end  

//                 SUB: begin
//                     c_bits <= c_bits + 1;
//                     if (aq[2*N] == 0) begin
//                         aq <= (aq << 1) - d;
//                         quotient[N-c_bits] <= 1; 

//                     end

//                     else begin
//                         aq <= (aq << 1) + d;
//                         quotient[N-c_bits] <= 0; 
//                     end

//                     if (c_bits == N) begin
//                         state <= FINAL;
//                         divisionReady <= 1;

//                     end
                
//                 end

//                 // FINAL: begin
//                 //   if (quotient[N-1] == 1) begin
                    
//                 //    end

//                 //   else begin
                       
//                 //     end
//                 // end 
//             endcase

//         end        
//     end
// endmodule
// non restoring

module divider_24bit_A #(
    N = 24
)(
    input logic [N-1:0] num1, 
    input logic [N-1:0] num2, //divisor
    input logic clk, rstn,
  	output logic [N:0] quotient,
    output logic [N:0] remainder,
    output logic normalize,
    output logic divisionReady
);
    logic [2*N:0] aq, d;
    logic [N:0] M;
    logic [$clog2(N)-1:0] c_bits;
    logic [N-1:0] subt;
    logic overflow;
    enum logic [1:0] {START, SUB, FINAL} state;
    
    
    always_ff @( posedge clk or negedge rstn ) begin : divisor

        if (!rstn) begin

            c_bits <= 0;
            aq <= {1'b0, num1, 24'b0};
            d <= {1'b0, num2, 24'b0};
            {overflow, subt} <= num1 - num2;
            quotient <= 0; 
            normalize <= 0; 
            state <= START;
            divisionReady <= 0;
        end

        else begin
            
            case (state)
                START: begin
                    if (overflow) begin
                        state <= SUB;  
                        normalize <= 1;

                    end

                    if (!overflow) begin
                        aq <= aq >> 1;  // can be a edit
                        state <= SUB;
                        normalize <= 0;
                    end
                    
                end  

                SUB: begin
                    c_bits <= c_bits + 1;
                    if (aq[2*N] == 0) begin
                        aq <= (aq << 1) - d;
                        quotient[N+1-c_bits] <= 1; 

                    end

                    else begin
                        aq <= (aq << 1) + d;
                        quotient[N+1-c_bits] <= 0; 
                    end

                    if (c_bits == N+1) begin
                        state <= FINAL;


                    end
                
                end

                FINAL: begin
                    divisionReady <= 1;
                    remainder <= aq[2*N:N];
                    if (quotient[0] == 1) begin
                        quotient <= quotient + 1'b1;
                    end
                end 
            endcase

        end        
    end
endmodule
