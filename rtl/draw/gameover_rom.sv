/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek, Mikołaj Twaróg
 */
module gameover_rom (
    input  logic        clk,
    
    input  logic [12:0] addr_p1,   
    input  logic [12:0] addr_p2,  
    input  logic [13:0] addr_dr,  
    output logic [11:0] rgb_p1,
    output logic [11:0] rgb_p2,
    output logic [11:0] rgb_draw
);
    localparam int DEPTH_P1 = 200*34;   
    localparam int DEPTH_P2 = 200*34;   
    localparam int DEPTH_DR = 201*56;   

    
    (* rom_style = "distributed" *) logic [11:0] rom_p1 [0:DEPTH_P1-1];
    (* rom_style = "distributed" *) logic [11:0] rom_p2 [0:DEPTH_P2-1];
    (* rom_style = "distributed" *) logic [11:0] rom_dr [0:DEPTH_DR-1];

    initial begin
        $readmemh("data/player1.dat", rom_p1);
        $readmemh("data/player2.dat", rom_p2);
        $readmemh("data/draw.dat",    rom_dr);
    end

    always_ff @(posedge clk) begin
        rgb_p1   <= rom_p1[addr_p1];
        rgb_p2   <= rom_p2[addr_p2];
        rgb_draw <= rom_dr[addr_dr];
    end
endmodule
