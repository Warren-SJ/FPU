module divider #(
    N = 24
)(
    input logic [N-1:0] A, 
    input logic [N-1:0] B, //divisor
    input logic clk, resetn,
  	output logic [N:0] C,
    output logic normalize,
    output logic done
);
    logic [2*N:0] aq, d;
    logic [N:0] M;
    logic [$clog2(N)-1:0] c_bits;
    logic [N-1:0] subt;
    logic overflow;
    logic [N:0] remainder;
    enum logic [1:0] {START, SUB, FINAL} state;
    
    
    always_ff @( posedge clk or negedge resetn ) begin : divisor

        if (!resetn) begin

            c_bits <= 0;
            aq <= {1'b0, A, 24'b0};
            d <= {1'b0, B, 24'b0};
            {overflow, subt} <= A - B;
            C <= 0; 
            normalize <= 0; 
            state <= START;
            done <= 0;
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
                        C[N+1-c_bits] <= 1; 

                    end

                    else begin
                        aq <= (aq << 1) + d;
                        C[N+1-c_bits] <= 0; 
                    end

                    if (c_bits == N+1) begin
                        state <= FINAL;


                    end
                
                end

                FINAL: begin
                    done <= 1;
                    remainder <= aq[2*N:N];
                    if (C[0] == 1) begin
                        C <= C + 1'b1;
                    end
                end 
            endcase

        end        
    end
endmodule
