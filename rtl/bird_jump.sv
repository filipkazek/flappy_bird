module bird_jump (
    input  logic clk,
    input  logic rst,
    input  logic game_rst,     // reset pozycji przy nowej grze
    input  logic mouse_left,   // kliknięcie uruchamia spadanie
    output logic [10:0] BIRD_Y // pozycja ptaka
);

    // -----------------------------
    // Parametry
    // -----------------------------
    localparam SCREEN_HEIGHT = 768;
    localparam BIRD_HEIGHT   = 100;
    localparam START_Y       = 300;

    localparam integer FALL_DELAY = 1_000_000; // taktów między przesunięciem o 1 piksel

    // -----------------------------
    // Rejestry
    // -----------------------------
    logic fall_active;
    logic [19:0] fall_cnt; // licznik taktów
    logic mouse_left_d;
    logic mouse_left_edge;

    // -----------------------------
    // Detektor zbocza przycisku
    // -----------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            mouse_left_d    <= 0;
            mouse_left_edge <= 0;
        end else begin
            mouse_left_edge <= mouse_left & ~mouse_left_d;
            mouse_left_d    <= mouse_left;
        end
    end

    // -----------------------------
    // Logika ruchu ptaka
    // -----------------------------
    always_ff @(posedge clk) begin
        if (rst || game_rst) begin
            BIRD_Y      <= START_Y;
            fall_active <= 0;
            fall_cnt    <= 0;
        end else begin
            if (mouse_left_edge)
                fall_active <= 1;

            if (fall_active && BIRD_Y + BIRD_HEIGHT < SCREEN_HEIGHT) begin
                if (fall_cnt == FALL_DELAY) begin
                    BIRD_Y   <= BIRD_Y + 1;
                    fall_cnt <= 0;
                end else
                    fall_cnt <= fall_cnt + 1;
            end
        end
    end

endmodule
