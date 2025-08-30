module draw_bg (
    input  logic clk,
    input  logic rst,
    vga_if.in  vin,
    vga_if.out vout,
    output logic [11:0] rgb_bg
);
    // ROM 320x240
    logic [11:0] rgb_pixel;
    logic [16:0] rom_addr;
    bg_rom u_rom (
        .clk (clk),
        .addr(rom_addr),
        .rgb_pixel(rgb_pixel)
    );

    // Skalowanie 5/16 = 0.3125 bez mnożników:
    // scaled_x = (h>>2) + (h>>4);  scaled_y = (v>>2) + (v>>4)
    logic [9:0] scx;  // 0..~319
    logic [8:0] scy;  // 0..~239

    always_ff @(posedge clk) begin
        if (rst) begin
            // pipeline timing (1 takt) – align z ROM
            vout.vcount <= '0;  vout.vsync <= '0;  vout.vblnk <= '0;
            vout.hcount <= '0;  vout.hsync <= '0;  vout.hblnk <= '0;
            rgb_bg    <= 12'h000;
            scx         <= '0;
            scy         <= '0;
            rom_addr    <= '0;
        end else begin
            // 1) przepisz timing (opóźnij o 1 takt)
            vout.vcount <= vin.vcount;
            vout.vsync  <= vin.vsync;
            vout.vblnk  <= vin.vblnk;
            vout.hcount <= vin.hcount;
            vout.hsync  <= vin.hsync;
            vout.hblnk  <= vin.hblnk;

            // 2) skalowanie bez DSP (shifty + add)
            scx <= (vin.hcount >> 2) + (vin.hcount >> 4);
            scy <= (vin.vcount >> 2) + (vin.vcount >> 4);

            // 3) addr = y*320 + x = y*(256+64) + x (też tylko shifty)
            rom_addr <= (scy << 8) + (scy << 6) + scx;

            // 4) kolor – ROM ma 1 takt latencji; timing już jest opóźniony
            rgb_bg <= (vin.vblnk || vin.hblnk) ? 12'h000 : rgb_pixel;
        end
    end
endmodule
