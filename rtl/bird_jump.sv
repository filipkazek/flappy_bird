module bird_jump (
    input  logic clk,
    input  logic rst,
    input  logic game_rst,         
    input  logic mouse_left_game,  
    output logic [10:0] BIRD_Y,   
    output logic collision
);

   
    localparam SCREEN_HEIGHT = 768;
    localparam BIRD_HEIGHT   = 50;
    localparam START_Y       = 300;

    localparam signed GRAVITY       = 1;    
    localparam signed JUMP_VELOCITY = -15;   

   
    localparam integer TICK_MAX = 800_000; 

   
    logic signed [10:0] velocity;
    logic               active;
    logic [31:0]        tick_cnt;
    logic               jump_request; 


    always_ff @(posedge clk) begin
        if (rst || game_rst) begin
            BIRD_Y        <= START_Y;
            velocity      <= 0;
            active        <= 0;
            collision     <= 0;
            tick_cnt      <= 0;
            jump_request  <= 0;
        end else begin
            
            if (mouse_left_game)
                jump_request <= 1;

            
            if (!active) begin
                if (jump_request) begin
                    active       <= 1;
                    velocity     <= JUMP_VELOCITY;
                    jump_request <= 0;  
                end
            end else begin
                
                if (tick_cnt >= TICK_MAX) begin
                    tick_cnt <= 0;

                    if (jump_request) begin
                        velocity     <= JUMP_VELOCITY;
                        jump_request <= 0; 
                    end else begin
                        velocity <= velocity + GRAVITY;
                    end

                    
                    BIRD_Y <= BIRD_Y + velocity;

                    
                    if (BIRD_Y <= 0) begin
                        BIRD_Y    <= 0;
                        collision <= 1;
                    end else if (BIRD_Y + BIRD_HEIGHT >= SCREEN_HEIGHT) begin
                        BIRD_Y    <= SCREEN_HEIGHT - BIRD_HEIGHT;
                        collision <= 1;
                    end else begin
                        collision <= 0;
                    end
                end else begin
                    tick_cnt <= tick_cnt + 1;
                end
            end
        end
    end

endmodule
