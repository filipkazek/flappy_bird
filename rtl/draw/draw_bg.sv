/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek
 */
module draw_bg (
    input  logic clk,
    input  logic rst,
    vga_if.in  vin,
    vga_if.out vout,
    output logic [11:0] rgb_bg
);

    logic [11:0] rgb_pixel;
    logic [16:0] rom_addr;
    bg_rom u_rom (
        .clk (clk),
        .addr(rom_addr),
        .rgb_pixel(rgb_pixel)
    );


    logic [9:0] scx;  
    logic [8:0] scy;  

    always_ff @(posedge clk) begin
        if (rst) begin
          
            vout.vcount <= '0;  vout.vsync <= '0;  vout.vblnk <= '0;
            vout.hcount <= '0;  vout.hsync <= '0;  vout.hblnk <= '0;
            rgb_bg    <= 12'h000;
            scx         <= '0;
            scy         <= '0;
            rom_addr    <= '0;
        end else begin
          
            vout.vcount <= vin.vcount;
            vout.vsync  <= vin.vsync;
            vout.vblnk  <= vin.vblnk;
            vout.hcount <= vin.hcount;
            vout.hsync  <= vin.hsync;
            vout.hblnk  <= vin.hblnk;

         
            scx <= (vin.hcount >> 2) + (vin.hcount >> 4);
            scy <= (vin.vcount >> 2) + (vin.vcount >> 4);

           
            rom_addr <= (scy << 8) + (scy << 6) + scx;

            
            rgb_bg <= (vin.vblnk || vin.hblnk) ? 12'h000 : rgb_pixel;
        end
    end
endmodule
