module start_rom(
    input  logic        clk,
    input  logic [14:0] addr,      
    output logic [11:0] rgb_pixel   
);
   
    localparam int WIDTH  = 400;
    localparam int HEIGHT = 48;
    localparam int DEPTH  = WIDTH * HEIGHT; 

  
    (* rom_style = "distributed" *) logic [11:0] rom [0:DEPTH-1];

    initial begin
        
        $readmemh("start.dat", rom);
    end

   
    always_ff @(posedge clk) begin
        rgb_pixel <= rom[addr];
    end
endmodule