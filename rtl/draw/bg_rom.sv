/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek
 */

module bg_rom (
    input  logic        clk,
    input  logic [16:0] addr,       
    output logic [11:0] rgb_pixel
);

   
    logic [11:0] rom [0:320*240-1];

    initial begin
        $readmemh("data/bg.dat", rom);
    end

    always_ff @(posedge clk) begin
        rgb_pixel <= rom[addr];
    end

endmodule