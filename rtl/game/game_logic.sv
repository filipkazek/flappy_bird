/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek
 */
module game_logic (
    input  logic        clk,
    input  logic        rst,         
    input  logic        game_rst,    
    input  logic        mouse_left_local,
    input  logic        mouse_left_remote,

    output logic [10:0] tube_x [2:0],
    output logic [10:0] gap_y  [2:0],
    output logic [10:0] bird1_y,
    output logic [10:0] bird2_y,

    output logic        pending,        
    output logic        pending_bird,   

  
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

 
    tube_render #(
        .SCREEN_WIDTH (SCREEN_W),
        .SCREEN_HEIGHT(SCREEN_H),
        .TUBE_WIDTH   (TUBE_WIDTH),
        .GAP_HEIGHT   (GAP_HEIGHT)
    ) u_tubes (
        .clk(clk),
        .rst(rst),
        .game_rst(game_rst),
        .tube_x(tube_x),
        .gap_y(gap_y)
    );

    logic bird1_floorceil, bird2_floorceil;

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

    function automatic int active_tube_idx_for_x(input int bx);
        int idx;
        logic [11:0] best_tx;  
        idx     = -1;
        best_tx = 12'hFFF;
        for (int i=0; i<3; i++) begin
            if ((tube_x[i] + TUBE_WIDTH) > bx) begin
                if (tube_x[i] < best_tx) begin
                    best_tx = tube_x[i];
                    idx     = i;
                end
            end
        end
        return idx; 
    endfunction

    function automatic bit hits_active_tube(input int bx, input int by);
        int i;
        i = active_tube_idx_for_x(bx);
        if (i == -1) return 1'b0;

        if ((bx + BIRD_WIDTH - 1) < tube_x[i])              return 1'b0;
        if (bx > (tube_x[i] + TUBE_WIDTH - 1))              return 1'b0;


        if (by < gap_y[i])                                   return 1'b1; 
        if ((by + BIRD_HEIGHT - 1) > (gap_y[i] + GAP_HEIGHT))return 1'b1; 
        return 1'b0; 
    endfunction

 
    wire bird1_col_now = bird1_floorceil | hits_active_tube(BIRD1_X, bird1_y);
    wire bird2_col_now = bird2_floorceil | hits_active_tube(BIRD2_X, bird2_y);

   
    logic       winner_fire;
    logic [1:0] winner_bits;
    integer     pending_tube_idx;

    always_ff @(posedge clk) begin
        if (rst) begin
            pending          <= 1'b0;
            pending_bird     <= 1'b0;
            pending_tube_idx <= -1;
            winner_fire      <= 1'b0;
            winner_bits      <= 2'b00;
        end else begin
            if (game_rst) begin
                pending          <= 1'b0;
                pending_bird     <= 1'b0;
                pending_tube_idx <= -1;
                winner_fire      <= 1'b0;
                winner_bits      <= 2'b00;
            end else begin
                winner_fire <= 1'b0; 

                if (!pending) begin
                    if (bird1_col_now || bird2_col_now) begin
                        if (bird1_col_now && bird2_col_now) begin        
                            winner_bits <= 2'b11; 
                            winner_fire <= 1'b1;
                        end else if (bird1_col_now) begin
                          
                            if (bird1_floorceil) begin
                                winner_bits <= 2'b10; 
                                winner_fire <= 1'b1;
                            end else begin
                                pending          <= 1'b1;
                                pending_bird     <= 1'b0; 
                                pending_tube_idx <= active_tube_idx_for_x(BIRD1_X);
                            end
                        end else begin
                            if (bird2_floorceil) begin
                                winner_bits <= 2'b01; 
                                winner_fire <= 1'b1;
                            end else begin
                                pending          <= 1'b1;
                                pending_bird     <= 1'b1; 
                                pending_tube_idx <= active_tube_idx_for_x(BIRD2_X);
                            end
                        end
                    end
                end else begin
                    if (pending_bird == 1'b0) begin
                        if (hits_active_tube(BIRD2_X, bird2_y) &&
                            (active_tube_idx_for_x(BIRD2_X) == pending_tube_idx)) begin
                            winner_bits <= 2'b11; 
                            winner_fire <= 1'b1; 
                            pending     <= 1'b0;
                        end else if (BIRD2_X >= tube_x[pending_tube_idx] + TUBE_WIDTH) begin
                            winner_bits <= 2'b10; 
                            winner_fire <= 1'b1; 
                            pending     <= 1'b0;
                        end
                    end else begin
                        if (hits_active_tube(BIRD1_X, bird1_y) &&
                            (active_tube_idx_for_x(BIRD1_X) == pending_tube_idx)) begin
                            winner_bits <= 2'b11; 
                            winner_fire <= 1'b1; 
                            pending     <= 1'b0;
                        end else if (BIRD1_X >= tube_x[pending_tube_idx] + TUBE_WIDTH) begin
                            winner_bits <= 2'b01; 
                            winner_fire <= 1'b1; 
                            pending     <= 1'b0;
                        end
                    end
                end
            end
        end
    end

    assign winner_valid = winner_fire;
    assign winner_code  = winner_bits;

endmodule
