module start_rom(
    input  logic        clk,
    input  logic [14:0] addr,       // 0 .. 19199
    output logic [11:0] rgb_pixel   // RGB444
);
    // Stałe
    localparam int WIDTH  = 400;
    localparam int HEIGHT = 48;
    localparam int DEPTH  = WIDTH * HEIGHT; // 19200

    // Wymuś BRAM (opcjonalnie)
    (* ram_style = "block" *) logic [11:0] rom [0:DEPTH-1];

    initial begin
        // Upewnij się, że plik jest widoczny dla Vivado:
        // Add Sources -> Memory Initialization File -> start.dat
        $readmemh("start.dat", rom);
    end

    // Synchroniczny odczyt (1-taktowa latencja)
    always_ff @(posedge clk) begin
        rgb_pixel <= rom[addr];
    end
endmodule
