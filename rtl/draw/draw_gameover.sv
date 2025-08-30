/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek
 */

module draw_gameover (
    input  logic        clk,
    input  logic        rst,               
    input  logic [1:0]  winner_latched,    
    vga_if.in           vin,
    output logic [11:0] rgb,
    output logic        valid
);
    localparam int SW = 1024, SH = 768;
    localparam int P_W = 200;
    localparam int P_H = 34;
    localparam int P_X0 = (SW - P_W) / 2;
    localparam int P_Y0 = (SH - P_H) / 2;

    localparam int DRW  = 201;
    localparam int DRH  = 56;
    localparam int DRX0 = (SW - DRW) / 2;
    localparam int DRY0 = (SH - DRH) / 2;

    wire in_p = (vin.hcount >= P_X0) && (vin.hcount < P_X0 + P_W) &&
                (vin.vcount >= P_Y0) && (vin.vcount < P_Y0 + P_H);

    wire [12:0] addr_p = in_p
                         ? ((vin.vcount - P_Y0) * P_W + (vin.hcount - P_X0))
                         : 13'd0;

    wire in_dr = (vin.hcount >= DRX0) && (vin.hcount < DRX0 + DRW) &&
                 (vin.vcount >= DRY0) && (vin.vcount < DRY0 + DRH);

    wire [13:0] addr_dr = in_dr
                          ? ((vin.vcount - DRY0) * DRW + (vin.hcount - DRX0))
                          : 14'd0;

    logic [11:0] rgb_p1, rgb_p2, rgb_dr;
    gameover_rom u_go_rom (
        .clk     (clk),
        .addr_p1 (addr_p),
        .addr_p2 (addr_p),
        .addr_dr (addr_dr),
        .rgb_p1  (rgb_p1),
        .rgb_p2  (rgb_p2),
        .rgb_draw(rgb_dr)
    );

    logic in_p_d, in_dr_d;
    logic [1:0] winner_d;

    always_ff @(posedge clk) begin
        if (rst) begin
            in_p_d    <= 1'b0;
            in_dr_d   <= 1'b0;
            winner_d  <= 2'b00;
        end else begin
            in_p_d    <= in_p;
            in_dr_d   <= in_dr;
            winner_d  <= winner_latched;
        end
    end

    wire [11:0] rgb_sel =
        (winner_d == 2'b01) ? rgb_p1 :
        (winner_d == 2'b10) ? rgb_p2 :
        (winner_d == 2'b11) ? rgb_dr :
                              12'h000;

    wire        valid_sel =
        (winner_d == 2'b01) ? in_p_d  :
        (winner_d == 2'b10) ? in_p_d  :
        (winner_d == 2'b11) ? in_dr_d :
                              1'b0;

    assign rgb   = rgb_sel;
    assign valid = valid_sel;

endmodule
