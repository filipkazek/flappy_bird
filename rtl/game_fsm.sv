module game_fsm (
    input  logic clk,
    input  logic rst,

    // sygnały sterujące
    input  logic mouse_left,    // np. start gry / reset
    input  logic collision,     // np. kolizja (na razie podłącz mouse_right)

    // stan wyjściowy do menu_mux
    output logic [1:0] state
);

    // kody stanów
    typedef enum logic [1:0] {
        START    = 2'b00,
        GAME     = 2'b01,
        GAMEOVER = 2'b10
    } state_t;

    state_t current_state, next_state;

    // rejestr stanu
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= START;
        else
            current_state <= next_state;
    end

    // logika przejść
    always_comb begin
        next_state = current_state;
        case (current_state)
            START: begin
                if (mouse_left) next_state = GAME;
            end
            GAME: begin
                if (collision) next_state = GAMEOVER;
            end
            GAMEOVER: begin
                if (mouse_left) next_state = START;
            end
        endcase
    end

    // wyjście (stan jako liczba do muxa)
    assign state = current_state;

endmodule
