module menu_mux (
    input  logic        clk,
    input  logic        rst,
    input  logic [1:0]  state,        // od FSM
    input  logic [11:0] rgb_bg,
    rgb_if.in           vin,
    output logic [11:0] rgb_out
);

    logic [11:0] rgb_next;

    // combinational logic – wybór co idzie dalej
    always_comb begin
        case (state)
            2'b00: rgb_next = vin.valid_start    ? vin.rgb_start    : rgb_bg;
            2'b01: rgb_next = vin.valid_game     ? vin.rgb_game     : rgb_bg;
            2'b10: rgb_next = vin.valid_gameover ? vin.rgb_gameover : rgb_bg;
            default: rgb_next = rgb_bg;
        endcase
    end

    // registered output – żeby nie mieszały się kolory
    always_ff @(posedge clk) begin
        if (rst)
            rgb_out <= 12'h000; // czarny przy resecie
        else
            rgb_out <= rgb_next;
    end

endmodule
