module image_rom #(
    parameter WIDTH  = 320,
    parameter HEIGHT = 240
)(
    input  logic        clk,
    input  logic [16:0] addr,       
    output logic [11:0] rgb_pixel
);

   
    logic [11:0] rom [0:WIDTH*HEIGHT-1];

    initial begin
        $readmemh("bg.dat", rom);
    end

    always_ff @(posedge clk) begin
        rgb_pixel <= rom[addr];
    end

endmodule