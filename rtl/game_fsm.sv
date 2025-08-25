module game_fsm
(
    input  logic clk,             // posedge active clock
    input  logic rst,             // synchroniczny reset
    input  logic mouse_left,      // impuls lewego kliku (zsynchronizowany do clk)
    input  logic collision,       // kolizja z rurą/ziemią
    output logic [1:0] state,     // aktualny stan FSM
    output logic game_rst,        // 1-cyklowy impuls resetu gry
    output logic mouse_left_game  // 1-cyklowy impuls kliknięcia w stanie GAME
);

    // -----------------------------
    // Stany
    // -----------------------------
    enum logic [1:0] {
        START    = 2'b00,
        GAME     = 2'b01,
        GAMEOVER = 2'b10
    } current_state, next_state;

    // -----------------------------
    // Rejestr stanu
    // -----------------------------
    always_ff @(posedge clk) begin
        if (rst)
            current_state <= START;
        else
            current_state <= next_state;
    end

    // -----------------------------
    // Logika przejść
    // -----------------------------
    always_comb begin
        next_state      = current_state;
        game_rst        = 1'b0;
        mouse_left_game = 1'b0;
        state           = current_state;

        case (current_state)
            START: begin
                if (mouse_left) begin
                    // start gry + aktywacja ptaka
                    next_state      = GAME;
                    mouse_left_game = 1'b1;
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
                    game_rst   = 1'b1; // impuls tylko w cyklu powrotu
                end
            end

            default: begin
                next_state = START;
            end
        endcase
    end

endmodule
