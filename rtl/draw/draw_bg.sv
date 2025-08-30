/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek
 */

module draw_bg (
    input  logic   clk,
    input  logic   rst,
    vga_if.in      vin,
    vga_if.out     vout,
    output logic [11:0] rgb_bg
);

    logic [11:0] rgb_pixel;
    logic [16:0] rom_addr;

    bg_rom u_rom (
        .clk       (clk),
        .addr      (rom_addr),
        .rgb_pixel (rgb_pixel)
    );

   
    logic [8:0] scaled_x;  
    logic [7:0] scaled_y;  

    assign  scaled_x = vin.hcount * 320 / 1024;
    assign  scaled_y = vin.vcount * 240 / 768;
    assign  rom_addr = scaled_y * 320 + scaled_x;
   
    always_ff @(posedge clk) begin
        if (rst) begin
            vout.vcount <= '0;
            vout.vsync  <= 1'b0;
            vout.vblnk  <= 1'b0;
            vout.hcount <= '0;
            vout.hsync  <= 1'b0;
            vout.hblnk  <= 1'b0;
            rgb_bg    <= 12'h000;
        end else begin
            vout.vcount <= vin.vcount;
            vout.vsync  <= vin.vsync;
            vout.vblnk  <= vin.vblnk;
            vout.hcount <= vin.hcount;
            vout.hsync  <= vin.hsync;
            vout.hblnk  <= vin.hblnk;

            if (vin.vblnk || vin.hblnk)
                rgb_bg <= 12'h000;   
            else
                rgb_bg <= rgb_pixel; 
        end
    end

endmodule
