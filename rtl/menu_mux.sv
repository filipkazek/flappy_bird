module menu_mux (
    input  logic        clk,
    input  logic        rst,
    input  logic [1:0]  state,
    input  logic [11:0] rgb_bg,
    rgb_if.in           vin,
    output logic [11:0] rgb_out
);

    logic [11:0] rgb_next;

    always_comb begin
        rgb_next = rgb_bg;
        case (state)
            2'b00: if (vin.valid_start)    rgb_next = vin.rgb_start; 
            2'b01: if (vin.valid_game)     rgb_next = vin.rgb_game; 
            2'b10: if (vin.valid_gameover) rgb_next = vin.rgb_gameover;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) rgb_out <= rgb_bg;
        else     rgb_out <= rgb_next;
    end

endmodule
