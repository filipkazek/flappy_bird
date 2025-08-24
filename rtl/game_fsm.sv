module game_fsm
(
    input  wire  clk,        // posedge active clock
    input  wire  rst,        // high-level active synchronous reset
    input  wire  mouse_left, // left mouse click
    input  wire  collision,  // collision signal
    output logic [1:0] state // encoded FSM state for outside world
);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam STATE_BITS = 2; // number of bits used for state register

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
enum logic [STATE_BITS-1 :0] {
    START    = 2'b00, 
    GAME     = 2'b01,
    GAMEOVER = 2'b10
} current_state;

//------------------------------------------------------------------------------
// edge detector for mouse_left
//------------------------------------------------------------------------------
logic mouse_left_d;
logic mouse_left_pulse;

always_ff @(posedge clk) begin
    if (rst)
        mouse_left_d <= 1'b0;
    else
        mouse_left_d <= mouse_left;
end

assign mouse_left_pulse = mouse_left & ~mouse_left_d; // tylko zbocze narastające

//------------------------------------------------------------------------------
// FSM sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin : seq_blk
    if (rst) begin
        current_state <= START;
        state <= START;
    end
    else begin
        case (current_state)
            START: begin
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
            end
        endcase
    end
end

endmodule
