/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg (
        input  logic clk,
        input  logic rst,
        input logic left,
        vga_if.in vin,
        vga_if.out vout
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;


    /**
     * Internal logic
     */


    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            vout.vcount <= '0;
            vout.vsync  <= '0;
            vout.vblnk <= '0;
            vout.hcount <= '0;
            vout.hsync <= '0;
            vout.hblnk  <= '0;
            vout.rgb    <= '0;
        end else begin
            vout.vcount <= vin.vcount;
            vout.vsync <= vin.vsync;
            vout.vblnk <= vin.vblnk;
            vout.hcount <= vin.hcount;
            vout.hsync <= vin.hsync;
            vout.hblnk <= vin.hblnk;
            vout.rgb   <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        
        if (vin.vblnk || vin.hblnk) begin             // Blanking region:
            rgb_nxt = 12'h0_0_0;                    // - make it it black.
        end else if (left) begin                              // Active region:
            rgb_nxt = 12'hF_0_0;                // - fill with gray.
            end else begin
                rgb_nxt = 12'h0_F_F;                // - fill with white.
        end
    end


endmodule
