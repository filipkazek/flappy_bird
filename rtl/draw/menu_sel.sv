/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2 — Flappy Bird
 * Autor: Filip Kazek
 */
module menu_sel (
    input  logic        [1:0] state,
    input  logic        [11:0] rgb_bg,
    rgb_if.in                  vin,
    output logic       [11:0]  rgb_next
);
    always_comb begin
        // domyślnie samo tło
        rgb_next = rgb_bg;

         case (state)
            2'b00: begin
                if (vin.valid_start)    rgb_next = vin.rgb_start;
                else                    rgb_next = rgb_bg;
            end

            2'b01: begin
                if (vin.valid_game)     rgb_next = vin.rgb_game;
                else                    rgb_next = rgb_bg;
            end

            2'b10: begin
                if (vin.valid_gameover) rgb_next = vin.rgb_gameover;
                else                    rgb_next = rgb_bg;
            end

            default: begin
                rgb_next = rgb_bg;
            end
        endcase
    end
endmodule
