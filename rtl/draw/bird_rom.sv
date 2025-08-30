module bird_rom #(
    parameter int    SPR_W = 40,
    parameter int    SPR_H = 50,
    parameter string FILE  = "data/bird.dat",   
    parameter logic [11:0] TRANSP = 12'h000     
)(
    input  logic        clk,
    input  logic        rst,
    vga_if.in           vin,                    
    input  logic [10:0] spr_x,                 
    input  logic [10:0] spr_y,
    output logic [11:0] rgb,                   
    output logic        valid                  
);
    localparam int DEPTH = SPR_W * SPR_H;

  
    (* ram_style = "block" *)
    logic [11:0] rom [0:DEPTH-1];
    initial $readmemh(FILE, rom);

    logic [$clog2(DEPTH)-1:0] addr_reg, addr_next;
    logic in_region, in_region_d;
    logic [11:0] rom_pixel;

    always_comb begin
        in_region = !vin.hblnk && !vin.vblnk &&
                    (vin.hcount >= spr_x) && (vin.hcount < spr_x + SPR_W) &&
                    (vin.vcount >= spr_y) && (vin.vcount < spr_y + SPR_H);

        if (in_region) begin
            logic [5:0] rel_y;  
            logic [5:0] rel_x;  
            rel_x     = vin.hcount - spr_x;
            rel_y     = vin.vcount - spr_y;
            addr_next = ((rel_y << 5) + (rel_y << 3)) + rel_x; 
        end else begin
            addr_next = '0;
        end
    end

  
    always_ff @(posedge clk) begin
        if (rst) begin
            addr_reg    <= '0;
            in_region_d <= 1'b0;
            rgb         <= 12'h000;
            valid       <= 1'b0;
        end else begin
            addr_reg    <= addr_next;
            in_region_d <= in_region;

            rom_pixel   <= rom[addr_reg]; 

            if (in_region_d && (rom_pixel != TRANSP)) begin
                rgb   <= rom_pixel;
                valid <= 1'b1;
            end else begin
                rgb   <= 12'h000;
                valid <= 1'b0;
            end
        end
    end
endmodule
