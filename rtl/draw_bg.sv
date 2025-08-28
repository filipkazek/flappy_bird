module draw_bg (
    input  logic clk,
    input  logic rst,
    vga_if.in  vin,
    vga_if.out vout
);

    import vga_pkg::*;

    // sygnał z ROM
    logic [11:0] rgb_pixel;
    logic [16:0] rom_addr;

    // instancja ROM z grafiką
    image_rom #(
        .WIDTH(320),
        .HEIGHT(240)
    ) u_rom (
        .clk(clk),
        .addr(rom_addr),
        .rgb_pixel(rgb_pixel)
    );

    // skalowanie nearest-neighbor
    // hcount: 0..1023 → 0..319
    // vcount: 0..767 → 0..239
    logic [8:0] scaled_x;  // 9-bit do 320
    logic [7:0] scaled_y;  // 8-bit do 240

    always_comb begin
        scaled_x = vin.hcount * 320 / 1024;
        scaled_y = vin.vcount * 240 / 768;
        rom_addr = scaled_y * 320 + scaled_x;
    end

    // pipeline na 1 takt żeby zgadzało się z ROM
    always_ff @(posedge clk) begin
        if (rst) begin
            vout.vcount <= 0;
            vout.vsync  <= 0;
            vout.vblnk  <= 0;
            vout.hcount <= 0;
            vout.hsync  <= 0;
            vout.hblnk  <= 0;
        end else begin
            vout.vcount <= vin.vcount;
            vout.vsync  <= vin.vsync;
            vout.vblnk  <= vin.vblnk;
            vout.hcount <= vin.hcount;
            vout.hsync  <= vin.hsync;
            vout.hblnk  <= vin.hblnk;

            if (vin.vblnk || vin.hblnk)
                vout.rgb <= 12'h000;  // czarne w blankingu
            else
                vout.rgb <= rgb_pixel;
        end
    end

endmodule
