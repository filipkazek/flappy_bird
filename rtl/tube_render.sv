module tube_render #(
    parameter SCREEN_WIDTH  = 1024,
    parameter SCREEN_HEIGHT = 768,
    parameter TUBE_WIDTH    = 120,
    parameter GAP_HEIGHT    = 400,
    parameter TUBE_SPEED    = 2,
    parameter TICK_MAX      = 1_000_000
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        game_rst,
    output logic [10:0] tube_x [2:0],
    output logic [10:0] gap_y [2:0]
);

    logic [31:0] tick_cnt;

    // --- prosty LFSR do losowości ---
    logic [9:0] lfsr;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            lfsr <= 10'h3A5;
        else
            lfsr <= {lfsr[8:0], lfsr[9] ^ lfsr[6]};
    end

    // funkcja: losowe położenie dziury z marginesem 50 px
    function automatic [10:0] rand_gap_y(input [9:0] rnd);
        rand_gap_y = 50 + (rnd % (SCREEN_HEIGHT - GAP_HEIGHT - 100));
    endfunction

    always_ff @(posedge clk) begin
        if (rst || game_rst) begin
            tick_cnt <= 0;

            // ustawienie startowe rur (poza ekranem)
            tube_x[0] <= SCREEN_WIDTH + 25;
            tube_x[1] <= SCREEN_WIDTH + 25 + 350;
            tube_x[2] <= SCREEN_WIDTH + 25 + 700;

            // każda dostaje inny losowy gap_y
            gap_y[0] <= rand_gap_y(lfsr);
            gap_y[1] <= rand_gap_y(lfsr ^ 10'h155);
            gap_y[2] <= rand_gap_y(lfsr ^ 10'h2A3);

        end else begin
            if (tick_cnt >= TICK_MAX) begin
                tick_cnt <= 0;
                for (int i=0; i<3; i++) begin
                    if (tube_x[i] <= TUBE_SPEED) begin
                        tube_x[i] <= SCREEN_WIDTH + TUBE_WIDTH;
                        gap_y[i]  <= rand_gap_y(lfsr);
                    end else begin
                        tube_x[i] <= tube_x[i] - TUBE_SPEED;
                    end
                end
            end else begin
                tick_cnt <= tick_cnt + 1;
            end
        end
    end

endmodule
