/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2 — Flappy Bird
 * Autor: Filip Kazek
 */
module menu_mux (
    input  logic        clk,
    input  logic        rst,      
    input  logic [1:0]  state,
    input  logic [11:0] rgb_bg,     
    rgb_if.in           vin,        
    output logic [11:0] rgb_out     
);
    logic [11:0] rgb_next;

    menu_sel u_menu_sel (
        .state   (state),
        .rgb_bg  (rgb_bg),
        .vin     (vin),
        .rgb_next(rgb_next)
    );

    always_ff @(posedge clk) begin
        if (rst) rgb_out <= rgb_bg;
        else     rgb_out <= rgb_next;
    end
endmodule
