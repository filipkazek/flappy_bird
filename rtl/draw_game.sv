module draw_game (
    input  logic        clk,
    input  logic        rst,
    input  logic        game_rst,

    input  logic        mouse_left_local,
    input  logic        mouse_left_remote,

    vga_if.in           vin,

    output logic [11:0] rgb,
    output logic        valid,

    output logic        winner_valid,
    output logic [1:0]  winner_code
);
    localparam int SCREEN_W     = 1024;
    localparam int SCREEN_H     = 768;
    localparam int TUBE_WIDTH   = 120;
    localparam int GAP_HEIGHT   = 250;

    localparam int BIRD_WIDTH   = 40;
    localparam int BIRD_HEIGHT  = 50;
    localparam int BIRD1_X      = 180;
    localparam int BIRD2_X      = 260;

    // --- RURY ---
    logic [10:0] tube_x [2:0];
    logic [10:0] gap_y  [2:0];

    tube_render u_tubes (
        .clk     (clk),
        .rst     (rst),
        .game_rst(game_rst),
        .tube_x  (tube_x),
        .gap_y   (gap_y)
    );

    // --- PTAKI ---
    logic [10:0] bird1_y, bird2_y;
    logic        bird1_floorceil, bird2_floorceil;

    bird_jump u_bird1 (
        .clk(clk),
        .rst(rst),
        .game_rst(game_rst),
        .mouse_left_game(mouse_left_local),
        .BIRD_Y(bird1_y),
        .collision(bird1_floorceil)
    );

    bird_jump u_bird2 (
        .clk(clk),
        .rst(rst),
        .game_rst(game_rst),
        .mouse_left_game(mouse_left_remote),
        .BIRD_Y(bird2_y),
        .collision(bird2_floorceil)
    );

    // --- FUNKCJE POMOCNICZE ---
    function automatic int active_tube_idx_for_x(input int bx);
        int idx;
        int best_tx;
        idx     = -1;
        best_tx = 32'h7fffffff;
        for (int i=0; i<3; i++) begin
            if (tube_x[i] < SCREEN_W) begin
                if ((tube_x[i] + TUBE_WIDTH) > bx) begin
                    if (tube_x[i] < best_tx) begin
                        best_tx = tube_x[i];
                        idx     = i;
                    end
                end
            end
        end
        return idx;
    endfunction

    function automatic int tube_trailing_edge(input int i);
        return tube_x[i] + TUBE_WIDTH;
    endfunction

    function automatic bit hits_active_tube(input int bx, input int by);
        int i;
        i = active_tube_idx_for_x(bx);
        if (i == -1) return 0;

        // overlap X
        if ((bx + BIRD_WIDTH - 1) < tube_x[i])             return 0;
        if (bx > (tube_x[i] + TUBE_WIDTH - 1))             return 0;

        // poza szczeliną?
        if (by < gap_y[i])                                  return 1;
        if ((by + BIRD_HEIGHT - 1) > (gap_y[i] + GAP_HEIGHT)) return 1;
        return 0;
    endfunction

    // --- WERDYKT (PENDING) ---
    wire bird1_col_now = bird1_floorceil | hits_active_tube(BIRD1_X, bird1_y);
    wire bird2_col_now = bird2_floorceil | hits_active_tube(BIRD2_X, bird2_y);

    logic        pending;
    logic  [0:0] pending_bird;       // 0 = P1 padł pierwszy; 1 = P2 padł pierwszy
    integer      pending_tube_idx;

    logic        winner_fire;
    logic [1:0]  winner_bits;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pending          <= 1'b0;
            pending_bird     <= '0;
            pending_tube_idx <= -1;
            winner_fire      <= 1'b0;
            winner_bits      <= 2'b00;
        end else begin
            if (game_rst) begin // SYNC reset
                pending          <= 1'b0;
                pending_bird     <= '0;
                pending_tube_idx <= -1;
                winner_fire      <= 1'b0;
                winner_bits      <= 2'b00;
            end else begin
                winner_fire <= 1'b0;

                if (!pending) begin
                    if (bird1_col_now || bird2_col_now) begin
                        if (bird1_col_now && bird2_col_now) begin
                            winner_bits <= 2'b11; winner_fire <= 1'b1; // obaj naraz → DRAW
                        end else if (bird1_col_now) begin
                            if (bird1_floorceil) begin
                                winner_bits <= 2'b10; winner_fire <= 1'b1; // P2 wins (od razu)
                            end else begin
                                pending          <= 1'b1;
                                pending_bird     <= 1'b0; // P1 padł
                                pending_tube_idx <= active_tube_idx_for_x(BIRD1_X);
                            end
                        end else begin
                            if (bird2_floorceil) begin
                                winner_bits <= 2'b01; winner_fire <= 1'b1; // P1 wins (od razu)
                            end else begin
                                pending          <= 1'b1;
                                pending_bird     <= 1'b1; // P2 padł
                                pending_tube_idx <= active_tube_idx_for_x(BIRD2_X);
                            end
                        end
                    end
                end else begin
                    // rozstrzyganie względem zapamiętanej rury
                    if (pending_bird == 1'b0) begin
                        if (hits_active_tube(BIRD2_X, bird2_y) &&
                            (active_tube_idx_for_x(BIRD2_X) == pending_tube_idx)) begin
                            winner_bits <= 2'b11; winner_fire <= 1'b1; pending <= 1'b0; // DRAW
                        end else if (BIRD2_X >= tube_trailing_edge(pending_tube_idx)) begin
                            winner_bits <= 2'b10; winner_fire <= 1'b1; pending <= 1'b0; // P2 wins
                        end
                    end else begin
                        if (hits_active_tube(BIRD1_X, bird1_y) &&
                            (active_tube_idx_for_x(BIRD1_X) == pending_tube_idx)) begin
                            winner_bits <= 2'b11; winner_fire <= 1'b1; pending <= 1'b0; // DRAW
                        end else if (BIRD1_X >= tube_trailing_edge(pending_tube_idx)) begin
                            winner_bits <= 2'b01; winner_fire <= 1'b1; pending <= 1'b0; // P1 wins
                        end
                    end
                end
            end
        end
    end

    assign winner_valid = winner_fire;
    assign winner_code  = winner_bits;

    // --- RYSOWANIE ---
    logic [11:0] rgb_tube;  logic valid_tube;
    logic [11:0] rgb_b1;    logic valid_b1;
    logic [11:0] rgb_b2;    logic valid_b2;

    // rury (gradient + ramka) — bez lokalnego 'int'
    always_comb begin
        rgb_tube   = 12'h000;
        valid_tube = 1'b0;
        for (int i=0; i<3; i++) begin
            if (tube_x[i] < SCREEN_W) begin
                if (vin.hcount >= tube_x[i] && vin.hcount < tube_x[i] + TUBE_WIDTH) begin
                    if (vin.vcount < gap_y[i] || vin.vcount > gap_y[i] + GAP_HEIGHT) begin
                        if ( (vin.hcount - tube_x[i]) < 5 ||
                             (vin.hcount - tube_x[i]) >= (TUBE_WIDTH-5) ) begin
                            rgb_tube = 12'h000; // ramka
                        end else if ( (vin.hcount - tube_x[i]) < 20 ) begin
                            rgb_tube = 12'h0F0;
                        end else if ( (vin.hcount - tube_x[i]) < 40 ) begin
                            rgb_tube = 12'h0C0;
                        end else if ( (vin.hcount - tube_x[i]) < 80 ) begin
                            rgb_tube = 12'h090;
                        end else begin
                            rgb_tube = 12'h0D0;
                        end
                        valid_tube = 1'b1;
                    end
                end
            end
        end
    end

    // ptak 1
    always_comb begin
        if (vin.hcount >= BIRD1_X && vin.hcount < BIRD1_X + BIRD_WIDTH &&
            vin.vcount >= bird1_y  && vin.vcount < bird1_y  + BIRD_HEIGHT) begin
            rgb_b1   = 12'h00F;
            valid_b1 = 1'b1;
        end else begin
            rgb_b1   = 12'h000;
            valid_b1 = 1'b0;
        end
    end

    // ptak 2
    always_comb begin
        if (vin.hcount >= BIRD2_X && vin.hcount < BIRD2_X + BIRD_WIDTH &&
            vin.vcount >= bird2_y  && vin.vcount < bird2_y  + BIRD_HEIGHT) begin
            rgb_b2   = 12'hFF0;
            valid_b2 = 1'b1;
        end else begin
            rgb_b2   = 12'h000;
            valid_b2 = 1'b0;
        end
    end

    // >>> MASKA: zgaś „skutego” ptaka podczas pending <<<
    wire hide_b1 = pending && (pending_bird == 1'b0);
    wire hide_b2 = pending && (pending_bird == 1'b1);
    wire valid_b1_draw = valid_b1 & ~hide_b1;
    wire valid_b2_draw = valid_b2 & ~hide_b2;

    // miks warstw: ptaki nad rurami
    always_comb begin
        if (valid_b1_draw) begin
            rgb = rgb_b1; valid = 1'b1;
        end else if (valid_b2_draw) begin
            rgb = rgb_b2; valid = 1'b1;
        end else if (valid_tube) begin
            rgb = rgb_tube; valid = 1'b1;
        end else begin
            rgb = 12'h000; valid = 1'b0;
        end
    end
endmodule
