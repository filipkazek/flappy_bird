module menu_mux (
    input  logic [1:0]  state = 2'b00,        // od FSM
    input  logic [11:0] rgb_bg,
    //input  logic [11:0] rgb_start, rgb_game, rgb_gameover,
   // input  logic        valid_start, valid_game, valid_gameover,
    rgb_if.in vin,
    output logic [11:0] rgb_out
);

    always_comb begin
        case (state)
            2'b00: rgb_out = vin.valid_start   ? vin.rgb_start   : rgb_bg;
            2'b01: rgb_out = vin.valid_game    ? vin.rgb_game    : rgb_bg;
            2'b10: rgb_out = vin.valid_gameover? vin.rgb_gameover: rgb_bg;
            default: rgb_out = rgb_bg;
        endcase
    end

endmodule