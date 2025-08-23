/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Vga timing controller.
 */

 module vga_timing (
    input  logic clk,
    input  logic rst,
    vga_if.out vout
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;


/**
 * Local variables and signals
 */
    logic [10:0] vcount_nxt;
    logic [10:0] hcount_nxt;
    logic vsync_nxt;
    logic vblnk_nxt;
    logic hsync_nxt;
    logic hblnk_nxt;
    
/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    if (rst) begin
        vout.hcount <= 0;
        vout.vcount <= 0;
        vout.hblnk <= 0;
        vout.hsync <= 0;
        vout.vblnk <= 0;
        vout.vsync <= 0;
    end else begin
        vout.hcount <= hcount_nxt;
        vout.vcount <= vcount_nxt;
        vout.hsync  <= hsync_nxt;
        vout.hblnk  <= hblnk_nxt;
        vout.vsync  <= vsync_nxt;
        vout.vblnk  <= vblnk_nxt;
    end
end

always_comb begin
    if (vout.hcount == HOR_TOTAL_TIME - 1) begin
        hcount_nxt = 0;
        hblnk_nxt = 0;
        if (vout.vcount == VER_TOTAL_TIME - 1) begin
            vcount_nxt = 0;
        end else begin
            vcount_nxt = vout.vcount + 1;
        end 
    end else begin
        hcount_nxt = vout.hcount + 1;
        vcount_nxt = vout.vcount;
     
    end
    vblnk_nxt = (vout.vcount >= VER_PIXELS ) && (vout.vcount < VER_TOTAL_TIME);
    hblnk_nxt = (vout.hcount >= HOR_PIXELS -1 ) && (vout.hcount < HOR_TOTAL_TIME);

    hsync_nxt = (vout.hcount >= HOR_SYNC_START-1) && (vout.hcount <= HOR_SYNC_START + HOR_SYNC_TIME -1) ;
    vsync_nxt = (vout.vcount >= VER_SYNC_START -1) && (vout.vcount <= VER_SYNC_START + VER_SYNC_TIME -1);
    
end  


endmodule