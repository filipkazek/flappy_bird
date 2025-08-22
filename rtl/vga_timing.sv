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
        output logic [10:0] vcount,
        output logic vsync,
        output logic vblnk,
        output logic [10:0] hcount,
        output logic hsync,
        output logic hblnk
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
            hcount <= 0;
            vcount <= 0;
            hblnk <= 0;
            hsync <= 0;
            vblnk <= 0;
            vsync <= 0;
        end else begin
            hcount <= hcount_nxt;
            vcount <= vcount_nxt;
            hsync  <= hsync_nxt;
            hblnk  <= hblnk_nxt;
            vsync  <= vsync_nxt;
            vblnk  <= vblnk_nxt;
        end
    end

    always_comb begin
        if (hcount == HOR_TOTAL_TIME - 1) begin
            hcount_nxt = 0;
            hblnk_nxt = 0;
            if (vcount == VER_TOTAL_TIME - 1) begin
                vcount_nxt = 0;
            end else begin
                vcount_nxt = vcount + 1;
            end 
        end else begin
            hcount_nxt = hcount + 1;
            vcount_nxt = vcount;
         
        end
        vblnk_nxt = (vcount >= VER_PIXELS ) && (vcount < VER_TOTAL_TIME);
        hblnk_nxt = (hcount >= HOR_PIXELS -1 ) && (hcount < HOR_TOTAL_TIME);

        hsync_nxt = (hcount >= HOR_SYNC_START-1) && (hcount <= HOR_SYNC_START + HOR_SYNC_TIME -1) ;
        vsync_nxt = (vcount >= VER_SYNC_START -1) && (vcount <= VER_SYNC_START + VER_SYNC_TIME -1);
        
    end  


endmodule
