/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek
 */

module draw_start (
    input  logic        clk,
    input  logic        rst,    
    vga_if.in           vin,
    output logic [11:0] rgb,
    output logic        valid
);
    localparam int IMG_W = 400;
    localparam int IMG_H = 48;

    localparam int X0 = (1024 - IMG_W) / 2;
    localparam int Y0 = (768  - IMG_H) / 2; 

    wire in_region_next =
        (!vin.hblnk && !vin.vblnk) &&
        (vin.hcount >= X0) && (vin.hcount < X0 + IMG_W) &&
        (vin.vcount >= Y0) && (vin.vcount < Y0 + IMG_H);

    wire [14:0] addr_next = in_region_next
        ? ( (((vin.vcount - Y0) << 8)
           + ((vin.vcount - Y0) << 7)
           + ((vin.vcount - Y0) << 4))
           +  (vin.hcount - X0) )
        : 15'd0;

    logic [14:0] addr_reg;
    logic [11:0] rom_pixel;
    start_rom u_start_rom (
        .clk      (clk),
        .addr     (addr_reg),
        .rgb_pixel(rom_pixel)
    );

   
    logic valid_reg;  

    always_ff @(posedge clk) begin
        if (rst) begin
            addr_reg  <= 15'd0;
            valid_reg <= 1'b0;
            rgb       <= 12'h000;
            valid     <= 1'b0;
        end else begin
            addr_reg  <= addr_next;        
            valid_reg <= in_region_next;  

            rgb   <= valid_reg ? rom_pixel : 12'h000;
            valid <= valid_reg;
        end
    end
endmodule
