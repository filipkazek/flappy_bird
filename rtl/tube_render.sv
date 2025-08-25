module tube_render #(
    parameter SCREEN_WIDTH  = 1024,
    parameter SCREEN_HEIGHT = 768,
    parameter TUBE_WIDTH    = 60,
    parameter GAP_HEIGHT    = 600,
    parameter TUBE_SPEED    = 2,        // px na tick
    parameter TICK_MAX      = 1_200_000 // spowolnienie przesuwu
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        game_rst,
    output logic [10:0] tube_x [2:0], // pozycje X rur
    output logic [10:0] gap_y [2:0]   // górna krawędź dziury
);

    logic [31:0] tick_cnt;

    always_ff @(posedge clk) begin
        if (rst || game_rst) begin
            tick_cnt <= 0;

            // równomiernie rozmieszczone 3 rury
            tube_x[0] <= SCREEN_WIDTH + 200;
            tube_x[1] <= SCREEN_WIDTH + 200 + 350;
            tube_x[2] <= SCREEN_WIDTH + 200 + 700;

            gap_y[0] <= (SCREEN_HEIGHT/2) - (GAP_HEIGHT/2);
            gap_y[1] <= (SCREEN_HEIGHT/2) - (GAP_HEIGHT/2);
            gap_y[2] <= (SCREEN_HEIGHT/2) - (GAP_HEIGHT/2);

        end else begin
            if (tick_cnt >= TICK_MAX) begin
                tick_cnt <= 0;
                for (int i=0; i<3; i++) begin
                    if (tube_x[i] <= TUBE_SPEED) begin
                        tube_x[i] <= SCREEN_WIDTH + TUBE_WIDTH; 
                        gap_y[i]  <= (SCREEN_HEIGHT/2) - (GAP_HEIGHT/2);
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
