

module uart_click_rx #(
    parameter int CLK_FREQ = 65_000_000,
    parameter int BAUD     = 115_200
)(
    input  logic clk,
    input  logic rst,
    input  logic rx_in,          
    output logic click_pulse     
);

    logic [7:0] rx_data;
    logic       rx_valid;

    simple_uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD    (BAUD)
    ) u_rx (
        .clk      (clk),
        .rst      (rst),
        .rx       (rx_in),
        .data_out (rx_data),
        .data_valid(rx_valid)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            click_pulse <= 1'b0;
        end else begin
           
            click_pulse <= (rx_valid && (rx_data == 8'h31));
        end
    end

endmodule
