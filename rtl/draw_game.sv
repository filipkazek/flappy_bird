module draw_game (
    input  logic        clk,
    input  logic        rst,
    input  logic        game_rst,
    input  logic        mouse_left,
    vga_if.in           vin,
    output logic [11:0] rgb,
    output logic        valid,
    output logic        collision
);

    // -----------------------------
    // Parametry ptaka
    // -----------------------------
    localparam BIRD_X      = 400;
    localparam BIRD_WIDTH  = 40;
    localparam BIRD_HEIGHT = 50;

    // -----------------------------
    // Pozycja ptaka
    // -----------------------------
    logic [10:0] bird_y;
    logic        bird_col;

    bird_jump u_bird (
        .clk(clk),
        .rst(rst),
        .game_rst(game_rst),
        .mouse_left_game(mouse_left),
        .BIRD_Y(bird_y),
        .collision(bird_col)
    );

    // -----------------------------
    // Pozycje rur
    // -----------------------------
    logic [10:0] tube_x [2:0];
    logic [10:0] gap_y  [2:0];

    tube_render u_tubes (
        .clk(clk),
        .rst(rst),
        .game_rst(game_rst),
        .tube_x(tube_x),
        .gap_y(gap_y)
    );

    // -----------------------------
    // Logika rysowania
    // -----------------------------
    logic [11:0] rgb_bird, rgb_tube;
    logic        valid_bird, valid_tube;

    // ptak (debug – niebieski)
    always_comb begin
        if (vin.hcount >= BIRD_X && vin.hcount < BIRD_X + BIRD_WIDTH &&
            vin.vcount >= bird_y && vin.vcount < bird_y + BIRD_HEIGHT) begin
            rgb_bird   = 12'h00F; // niebieski ptak
            valid_bird = 1;
        end else begin
            rgb_bird   = 12'h000;
            valid_bird = 0;
        end
    end

    // rury (debug – czerwone)
    always_comb begin
        rgb_tube   = 12'h000;
        valid_tube = 0;

        for (int i=0; i<3; i++) begin
            if (tube_x[i] < 1024) begin // <-- poprawka: nie rysuj poza ekranem
                if (vin.hcount >= tube_x[i] && vin.hcount < tube_x[i] + 60) begin
                    if (vin.vcount < gap_y[i] || vin.vcount > gap_y[i] + 600) begin
                        rgb_tube   = 12'hF00; // czerwone rury
                        valid_tube = 1;
                    end
                end
            end
        end
    end

    // -----------------------------
    // Łączenie warstw (ptak nad rurami)
    // -----------------------------
    always_comb begin
        if (valid_bird) begin
            rgb   = rgb_bird;
            valid = 1;
        end else if (valid_tube) begin
            rgb   = rgb_tube;
            valid = 1;
        end else begin
            valid = 0;
            rgb   = 12'h000;
        end
    end

    // -----------------------------
    // Kolizje
    // -----------------------------
    always_comb begin
        collision = bird_col | (valid_bird & valid_tube);
    end

endmodule
