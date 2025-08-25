/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background (DEBUG version – flat gray).
 */

module draw_bg (
        input  logic clk,
        input  logic rst,
        vga_if.in vin,
        vga_if.out vout
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    logic [11:0] rgb_nxt;

    always_ff @(posedge clk) begin
        if (rst) begin
            vout.vcount <= '0;
            vout.vsync  <= '0;
            vout.vblnk  <= '0;
            vout.hcount <= '0;
            vout.hsync  <= '0;
            vout.hblnk  <= '0;
            vout.rgb    <= '0;
        end else begin
            vout.vcount <= vin.vcount;
            vout.vsync  <= vin.vsync;
            vout.vblnk  <= vin.vblnk;
            vout.hcount <= vin.hcount;
            vout.hsync  <= vin.hsync;
            vout.hblnk  <= vin.hblnk;
            vout.rgb    <= rgb_nxt;
        end
    end

    always_comb begin
        if (vin.vblnk || vin.hblnk) begin
            rgb_nxt = 12'h000;      // black during blanking
        end else begin
            rgb_nxt = 12'h777;      // flat gray everywhere
        end
    end

endmodule
