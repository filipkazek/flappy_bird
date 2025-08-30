/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek
 */
interface vga_if();
    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;
modport in (input vcount, vsync, vblnk, hcount, hsync, hblnk);
modport out (output vcount, vsync, vblnk, hcount, hsync, hblnk);
endinterface