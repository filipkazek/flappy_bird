module draw_start (
    input  logic        clk,
    input  logic        rst,   
    vga_if.in           vin,
    output logic [11:0] rgb,
    output logic        valid
);
    // Rozmiar obrazka
    localparam int IMG_W = 400;
    localparam int IMG_H = 48;

    // Centrowanie dla 1024x768
    localparam int X0 = (1024 - IMG_W) / 2;
    localparam int Y0 = (768  - IMG_H) / 2;

    // Adres do ROM (0..19199), potok 1-takt
    logic [14:0] addr_reg, addr_next;

    // Flaga „w obszarze” (opóźniona o 1 takt)
    logic in_region, in_region_d;

    // Dane z ROM
    logic [11:0] rom_pixel;

    // Relatywne współrzędne
    logic [8:0] rel_x;  // 0..399
    logic [5:0] rel_y;  // 0..47

    // ROM 400x48 (LUT-RAM)
    start_rom u_start_rom (
        .clk      (clk),
        .addr     (addr_reg),
        .rgb_pixel(rom_pixel)
    );

    // Adresowanie i okno
    always_comb begin
        in_region = (!vin.hblnk && !vin.vblnk) &&
                    (vin.hcount >= X0) && (vin.hcount < X0 + IMG_W) &&
                    (vin.vcount >= Y0) && (vin.vcount < Y0 + IMG_H);

        if (in_region) begin
            rel_x     = vin.hcount - X0;        // 0..399
            rel_y     = vin.vcount - Y0;        // 0..47
            addr_next = rel_y * IMG_W + rel_x;  // 0..19199
        end else begin
            rel_x     = '0;
            rel_y     = '0;
            addr_next = '0;
        end
    end

    // Rejestry potokowe (latencja ROM = 1 takt)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            addr_reg    <= '0;
            in_region_d <= 1'b0;
            rgb         <= 12'h000;
            valid       <= 1'b0;
        end else begin
            addr_reg    <= addr_next;
            in_region_d <= in_region;

            if (in_region_d) begin
                rgb   <= rom_pixel;
                valid <= 1'b1;
            end else begin
                rgb   <= 12'h000;
                valid <= 1'b0;
            end
        end
    end
endmodule
