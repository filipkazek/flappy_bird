module game_fsm
(
    input  logic clk,
    input  logic rst,

   
    input  logic mouse_left_local,
    input  logic mouse_left_remote,

   
    input  logic        winner_valid,   
    input  logic [1:0]  winner_code,    

    
    output logic [1:0]  state,     
    output logic        game_rst,        
    output logic        mouse_left_game_local,
    output logic        mouse_left_game_remote,

   
    output logic [1:0]  winner_latched
);

    typedef enum logic [1:0] {
        START    = 2'b00,
        GAME     = 2'b01,
        GAMEOVER = 2'b10
    } state_t;

    state_t current_state, next_state;
    logic [1:0] winner_next;

    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state  <= START;
            winner_latched <= 2'b00;
        end else begin
            current_state  <= next_state;
            winner_latched <= winner_next;
        end
    end

   
    always_comb begin
       
        next_state             = current_state;
        game_rst               = 1'b0;
        mouse_left_game_local  = 1'b0;
        mouse_left_game_remote = 1'b0;
        state                  = current_state;
        winner_next            = winner_latched;

        unique case (current_state)

        START: begin
            winner_next = 2'b00;
            if (mouse_left_local || mouse_left_remote) begin
                next_state = GAME;
                game_rst   = 1'b1;  
            end
        end

        GAME: begin
            
            mouse_left_game_local  = mouse_left_local;
            mouse_left_game_remote = mouse_left_remote;

           
            if (winner_valid) begin
                next_state  = GAMEOVER;
                winner_next = winner_code;
            end
        end

        GAMEOVER: begin
           
            if (mouse_left_local || mouse_left_remote) begin
                next_state  = START;
                game_rst    = 1'b1;
                winner_next = 2'b00;
            end
        end

        endcase
    end

endmodule
