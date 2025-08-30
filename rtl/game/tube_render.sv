module tube_render #(
    parameter int SCREEN_WIDTH  = 1024,
    parameter int SCREEN_HEIGHT = 768,
    parameter int TUBE_WIDTH    = 120,
    parameter int GAP_HEIGHT    = 250,
    parameter int TUBE_SPEED    = 2,
    parameter int TICK_MAX      = 650_000,
    parameter int MARGIN        = 30,       
    parameter logic [15:0] SEED = 16'hACE1  
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        game_rst,
    output logic [10:0] tube_x [2:0],
    output logic [10:0] gap_y  [2:0]
);


    logic [31:0] tick_cnt;
    logic [15:0] lfsr;

    function automatic logic [15:0] lfsr_step (input logic [15:0] s);
        lfsr_step = { s[14:0], s[15]^s[13]^s[12]^s[10] };
    endfunction
    function automatic logic [10:0] rand_gap_y(input logic [15:0] rnd);
        int range;
        range = SCREEN_HEIGHT - GAP_HEIGHT - (MARGIN<<1);
        rand_gap_y = MARGIN + (rnd % range);
    endfunction
    always_ff @(posedge clk) begin
        if (rst) begin
            tick_cnt <= 32'd0;

            tube_x[0] <= SCREEN_WIDTH + 25;
            tube_x[1] <= SCREEN_WIDTH + 25 + 350;
            tube_x[2] <= SCREEN_WIDTH + 25 + 700;
            lfsr     <= (SEED==16'd0) ? 16'h1 : SEED;
            gap_y[0] <= rand_gap_y(lfsr[15:0]);
            gap_y[1] <= rand_gap_y({lfsr[7:0],  lfsr[15:8]});
            gap_y[2] <= rand_gap_y({lfsr[11:0], lfsr[15:12]});

        end else begin
            if (game_rst) begin
                tick_cnt <= 32'd0;

                tube_x[0] <= SCREEN_WIDTH + 25;
                tube_x[1] <= SCREEN_WIDTH + 25 + 350;
                tube_x[2] <= SCREEN_WIDTH + 25 + 700;

                lfsr     <= (SEED==16'd0) ? 16'h1 : SEED;
                gap_y[0] <= rand_gap_y(lfsr[15:0]);
                gap_y[1] <= rand_gap_y({lfsr[7:0],  lfsr[15:8]});
                gap_y[2] <= rand_gap_y({lfsr[11:0], lfsr[15:12]});

            end else begin
                if (tick_cnt >= TICK_MAX) begin
                    tick_cnt <= 32'd0;

                    lfsr <= lfsr_step(lfsr);

                    for (int i=0; i<3; i++) begin
                        if (tube_x[i] <= TUBE_SPEED) begin
                            tube_x[i] <= SCREEN_WIDTH + TUBE_WIDTH;

                            case (i)
                                0: gap_y[i] <= rand_gap_y(lfsr);
                                1: gap_y[i] <= rand_gap_y({lfsr[7:0],  lfsr[15:8]});
                                default: gap_y[i] <= rand_gap_y({lfsr[11:0], lfsr[15:12]});
                            endcase
                        end else begin
                            tube_x[i] <= tube_x[i] - TUBE_SPEED;
                        end
                    end
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
        end
    end

endmodule
