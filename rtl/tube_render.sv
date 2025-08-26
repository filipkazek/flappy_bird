module tube_render #(
    parameter SCREEN_WIDTH  = 1024,
    parameter SCREEN_HEIGHT = 768,
    parameter TUBE_WIDTH    = 120,
    parameter GAP_HEIGHT    = 400,
    parameter TUBE_SPEED    = 2,        
    parameter TICK_MAX      = 1_200_000,
    parameter TUBE_SPACING  = 380
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        game_rst,
    output logic [10:0] tube_x [2:0],
    output logic [10:0] gap_y [2:0]   
);

    logic [31:0] tick_cnt;

    // LFSR 10-bit do pseudo-losowości
    logic [9:0] lfsr;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) 
            lfsr <= 10'h3A5;
        else 
            lfsr <= {lfsr[8:0], lfsr[9] ^ lfsr[6]};
    end

    // funkcja: losowanie Y z marginesami
    function automatic [10:0] rand_gap_y(input [9:0] rnd);
        rand_gap_y = 100 + (rnd % (SCREEN_HEIGHT - 200 - GAP_HEIGHT));
    endfunction

    // --- logika rur ---
    always_ff @(posedge clk) begin
        if (rst || game_rst) begin
            tick_cnt <= 0;

            // startowe pozycje: zawsze poza ekranem
            tube_x[0] <= SCREEN_WIDTH + 200;
            tube_x[1] <= SCREEN_WIDTH + 200 + (TUBE_SPACING + TUBE_WIDTH);
            tube_x[2] <= SCREEN_WIDTH + 200 + 2*(TUBE_SPACING + TUBE_WIDTH);

            // każda z losową szczeliną
            gap_y[0] <= rand_gap_y(lfsr);
            gap_y[1] <= rand_gap_y(lfsr);
            gap_y[2] <= rand_gap_y(lfsr);

        end else begin
            if (tick_cnt >= TICK_MAX) begin
                tick_cnt <= 0;

                for (int i=0; i<3; i++) begin
                    // przesuwaj rurę
                    if (tube_x[i] > 0) begin
                        tube_x[i] <= tube_x[i] - TUBE_SPEED;
                    end else begin
                        // jeśli rura wyszła całkowicie z lewej -> wraca za prawą
                        tube_x[i] <= SCREEN_WIDTH + TUBE_WIDTH + TUBE_SPACING;
                        gap_y[i]  <= rand_gap_y(lfsr);
                    end
                end

            end else begin
                tick_cnt <= tick_cnt + 1;
            end
        end
    end

endmodule
