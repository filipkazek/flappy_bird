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
    localparam BIRD_X      = 200;
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
    localparam TUBE_WIDTH = 120;
    localparam GAP_HEIGHT = 400;

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
    // Licznik czystego startu (ok. 1 sekundy)
    // -----------------------------
    localparam integer START_DELAY_FRAMES = 60;  // ~1s przy 60Hz VGA
    logic [7:0] start_cnt;
    logic       start_safe;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            start_cnt <= 0;
            start_safe <= 1;
        end else if (game_rst) begin
            start_cnt <= 0;
            start_safe <= 1;
        end else if (start_safe) begin
            if (start_cnt < START_DELAY_FRAMES) begin
                start_cnt <= start_cnt + 1;
            end else begin
                start_safe <= 0;  // po upływie ~1s zaczynamy rysować rury
            end
        end
    end

    // -----------------------------
    // Logika rysowania
    // -----------------------------
    logic [11:0] rgb_bird, rgb_tube;
    logic        valid_bird, valid_tube;

    // ptak (niebieski)
    always_comb begin
        if (vin.hcount >= BIRD_X && vin.hcount < BIRD_X + BIRD_WIDTH &&
            vin.vcount >= bird_y && vin.vcount < bird_y + BIRD_HEIGHT) begin
            rgb_bird   = 12'h00F;
            valid_bird = 1;
        end else begin
            rgb_bird   = 12'h000;
            valid_bird = 0;
        end
    end

    // rury (gradient + ramka), tylko jeśli nie ma czystego startu
    always_comb begin
        rgb_tube   = 12'h000;
        valid_tube = 0;

        if (!start_safe) begin
            for (int i=0; i<3; i++) begin
                if (tube_x[i] < 1024) begin
                    if (vin.hcount >= tube_x[i] && vin.hcount < tube_x[i] + TUBE_WIDTH) begin
                        if (vin.vcount < gap_y[i] || vin.vcount > gap_y[i] + GAP_HEIGHT) begin
                            int rel_x = vin.hcount - tube_x[i];

                            // ramka 5 px
                            if (rel_x < 5 || rel_x >= TUBE_WIDTH-5) begin
                                rgb_tube = 12'h000; // czarny
                            end
                            // gradient
                            else if (rel_x < 20) begin
                                rgb_tube = 12'h0F0; // jasny zielony
                            end else if (rel_x < 40) begin
                                rgb_tube = 12'h0C0; // średni zielony
                            end else if (rel_x < 80) begin
                                rgb_tube = 12'h090; // ciemniejszy
                            end else begin
                                rgb_tube = 12'h0D0; // znów jaśniejszy
                            end

                            valid_tube = 1;
                        end
                    end
                end
            end
        end
    end

    // -----------------------------
    // Łączenie warstw
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
        if (start_safe)
            collision = bird_col; // na starcie ignorujemy rury
        else
            collision = bird_col | (valid_bird & valid_tube);
    end

endmodule
