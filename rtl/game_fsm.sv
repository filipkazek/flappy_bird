module game_fsm
(
    input  logic clk,            
    input  logic rst,             
    input  logic mouse_left,      
    input  logic collision,       
    output logic [1:0] state,     
    output logic game_rst,        
    output logic mouse_left_game  
);

  
    enum logic [1:0] {
        START    = 2'b00,
        GAME     = 2'b01,
        GAMEOVER = 2'b10
    } current_state, next_state;

   
    always_ff @(posedge clk) begin
        if (rst)
            current_state <= START;
        else
            current_state <= next_state;
    end

  
    always_comb begin
        next_state      = current_state;
        game_rst        = 1'b0;
        mouse_left_game = 1'b0;
        state           = current_state;

        case (current_state)
            START: begin
                if (mouse_left) begin
                    next_state      = GAME;
                    mouse_left_game = 1'b1;
                game_rst        = 1'b1;  // <<< wymuszamy reset tub na starcie
            end
         end

            GAME: begin
                if (collision) begin
                    next_state = GAMEOVER;
                end else if (mouse_left) begin
                    mouse_left_game = 1'b1;
                end
            end

            GAMEOVER: begin
                if (mouse_left) begin
                    next_state = START;
                    game_rst   = 1'b1; 
                end
            end

            default: begin
                next_state = START;
            end
        endcase
    end

endmodule
