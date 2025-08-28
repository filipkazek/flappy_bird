

module simple_uart_rx #(
    parameter integer CLK_FREQ = 65_000_000, 
    parameter integer BAUD     = 115_200
)(
    input  wire       clk,
    input  wire       rst,        
    input  wire       rx,        
    output reg  [7:0] data_out,   
    output reg        data_valid  
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;

    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end

    localparam [2:0]
        S_IDLE   = 3'd0,
        S_START  = 3'd1,
        S_DATA   = 3'd2,
        S_STOP   = 3'd3,
        S_CLEAN  = 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_cnt;    
    reg [2:0]  bit_idx;     
    reg [7:0]  shreg;       

    always @(posedge clk) begin
        if (rst) begin
            state      <= S_IDLE;
            clk_cnt    <= 16'd0;
            bit_idx    <= 3'd0;
            shreg      <= 8'd0;
            data_out   <= 8'd0;
            data_valid <= 1'b0;
        end else begin
            data_valid <= 1'b0; 

            case (state)
                S_IDLE: begin
                   
                    if (rx_sync2 == 1'b0) begin
                        state   <= S_START;
                        clk_cnt <= 16'd0;
                    end
                end

                S_START: begin
                   
                    if (clk_cnt == (CLKS_PER_BIT/2)) begin
                        if (rx_sync2 == 1'b0) begin
                            
                            clk_cnt <= 16'd0;
                            bit_idx <= 3'd0;
                            state   <= S_DATA;
                        end else begin
                            
                            state <= S_IDLE;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                S_DATA: begin
                  
                    if (clk_cnt == CLKS_PER_BIT-1) begin
                        clk_cnt        <= 16'd0;
                        shreg[bit_idx] <= rx_sync2;  

                        if (bit_idx == 3'd7) begin
                            state   <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                S_STOP: begin
                    
                    if (clk_cnt == CLKS_PER_BIT-1) begin
                        data_out   <= shreg;
                        data_valid <= 1'b1;   
                        clk_cnt    <= 16'd0;
                        state      <= S_CLEAN;
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                S_CLEAN: begin
                   
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
