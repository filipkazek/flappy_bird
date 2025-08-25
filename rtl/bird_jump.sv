module bird_jump (
    input  logic clk,
    input  logic rst,
    input  logic game_rst,         // reset pozycji przy nowej grze
    input  logic mouse_left_game,  // impuls kliknięcia tylko w stanie GAME
    output logic [10:0] BIRD_Y,    // pozycja ptaka
    output logic collision
);

    // -----------------------------
    // Parametry
    // -----------------------------
    localparam SCREEN_HEIGHT = 768;
    localparam BIRD_HEIGHT   = 50;
    localparam START_Y       = 300;

    // fizyka
    localparam signed GRAVITY       = 1;   // px/tick²
    localparam signed JUMP_VELOCITY = -17;  // px/tick (trochę słabsze przyspieszenie)

    // spowolnienie fizyki
    localparam integer TICK_MAX = 900_000; // co ile cykli clk liczymy fizykę

    // -----------------------------
    // Rejestry
    // -----------------------------
    logic signed [10:0] velocity;
    logic               active;
    logic [31:0]        tick_cnt;
    logic               jump_request; // "zapamiętane kliknięcie"

    // -----------------------------
    // Logika ruchu ptaka
    // -----------------------------
    always_ff @(posedge clk) begin
        if (rst || game_rst) begin
            BIRD_Y        <= START_Y;
            velocity      <= 0;
            active        <= 0;
            collision     <= 0;
            tick_cnt      <= 0;
            jump_request  <= 0;
        end else begin
            // zapamiętanie kliknięcia do obsłużenia przy następnym ticku
            if (mouse_left_game)
                jump_request <= 1;

            // czekanie na start gry
            if (!active) begin
                if (jump_request) begin
                    active       <= 1;
                    velocity     <= JUMP_VELOCITY;
                    jump_request <= 0;  // kliknięcie wykorzystane
                end
            end else begin
                // licznik spowalniający fizykę
                if (tick_cnt >= TICK_MAX) begin
                    tick_cnt <= 0;

                    // obsługa kliknięcia
                    if (jump_request) begin
                        velocity     <= JUMP_VELOCITY;
                        jump_request <= 0;
                    end else begin
                        velocity <= velocity + GRAVITY;
                    end

                    // aktualizacja pozycji
                    BIRD_Y <= BIRD_Y + velocity;

                    // detekcja kolizji
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
