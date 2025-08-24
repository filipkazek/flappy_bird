module game_fsm
(
    input  wire  clk,         // posedge active clock
    input  wire  rst,         // high-level active synchronous reset
    input  wire  mouse_left,  // left mouse click
    input  wire  collision,   // collision signal
    output logic [1:0] state, // encoded FSM state for outside world
    output logic       game_rst // synchronous reset for game logic
);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam STATE_BITS = 2; // liczba bitów do reprezentacji stanu

//------------------------------------------------------------------------------
// lokalne zmienne
//------------------------------------------------------------------------------
enum logic [STATE_BITS-1:0] {
    START    = 2'b00,
    GAME     = 2'b01,
    GAMEOVER = 2'b10
} current_state;

//------------------------------------------------------------------------------
// detektor zbocza dla mouse_left
//------------------------------------------------------------------------------
logic mouse_left_d;        // poprzedni stan przycisku
logic mouse_left_pulse;    // pojedynczy impuls

always_ff @(posedge clk) begin
    if (rst)
        mouse_left_d <= 1'b0;
    else
        mouse_left_d <= mouse_left;
end

assign mouse_left_pulse = mouse_left & ~mouse_left_d;

//------------------------------------------------------------------------------
// FSM sekwencyjny z synchronicznym resetem
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        current_state <= START;
        state <= START;
        game_rst <= 1'b0;
    end
    else begin
        case (current_state)
            START: begin
                game_rst <= 1'b0; // reset gry w stanie START
                if (mouse_left_pulse) begin
                    current_state <= GAME;
                    state <= GAME;
                end
                else begin
                    current_state <= START;
                    state <= START;
                end
            end

            GAME: begin
                game_rst <= 1'b0; // reset gry nieaktywny w trakcie gry
                if (collision) begin
                    current_state <= GAMEOVER;
                    state <= GAMEOVER;
                end
                else begin
                    current_state <= GAME;
                    state <= GAME;
                end
            end

            GAMEOVER: begin
                game_rst <= 1'b1; // aktywujemy reset gry
                if (mouse_left_pulse) begin
                    current_state <= START;
                    state <= START;
                end
                else begin
                    current_state <= GAMEOVER;
                    state <= GAMEOVER;
                end
            end

            default: begin
                current_state <= START;
                state <= START;
                game_rst <= 1'b0;
            end
        endcase
    end
end

endmodule
