module draw_game (
    input  logic        clk,
    input  logic        rst,
    input  logic        game_rst,     // reset pozycji ptaka przy nowej grze
    input  logic        mouse_left,
    vga_if.in           vin,
    output logic [11:0] rgb,
    output logic        valid
);

    // -----------------------------
    // Parametry klocka
    // -----------------------------
    localparam BIRD_X      = 400;
    localparam BIRD_WIDTH  = 200;
    localparam BIRD_HEIGHT = 100;

    // -----------------------------
    // Pozycja ptaka z modułu bird_jump
    // -----------------------------
    logic [10:0] bird_y;

    bird_jump u_bird (
        .clk(clk),
        .rst(rst),
        .game_rst(game_rst),
        .mouse_left(mouse_left),
        .BIRD_Y(bird_y)
    );

    // -----------------------------
    // Rysowanie ptaka
    // -----------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            rgb   <= 12'h000;
            valid <= 1'b0;
        end else begin
            if (vin.hcount >= BIRD_X && vin.hcount < BIRD_X + BIRD_WIDTH &&
                vin.vcount >= bird_y && vin.vcount < bird_y + BIRD_HEIGHT) begin
                rgb   <= 12'h0F0;  // zielony ptak
                valid <= 1'b1;
            end else begin
                rgb   <= 12'h000;
                valid <= 1'b0;
            end
        end
    end

endmodule
