module draw_gameover (
    input  logic        clk,
    input  logic        rst,
    input  logic [1:0]  winner_latched, 
    vga_if.in           vin,
    output logic [11:0] rgb,
    output logic        valid
);
    localparam int SW = 1024, SH = 768;
    localparam int P1W=200, P1H=34,  P1X0=(SW-P1W)/2, P1Y0=(SH-P1H)/2;
    localparam int P2W=200, P2H=34,  P2X0=(SW-P2W)/2, P2Y0=(SH-P2H)/2;
    localparam int DRW=201, DRH=56,  DRX0=(SW-DRW)/2, DRY0=(SH-DRH)/2;

    
    logic in_p1, in_p2, in_dr;
    logic [12:0] addr_p1, addr_p2; 
    logic [13:0] addr_dr;          

    
    always_comb begin
    
        in_p1   = (vin.hcount >= P1X0 && vin.hcount < P1X0+P1W &&
                   vin.vcount >= P1Y0 && vin.vcount < P1Y0+P1H);
        addr_p1 = in_p1
                  ? ( (vin.vcount - P1Y0) * P1W + (vin.hcount - P1X0) )
                  : '0;

        
        in_p2   = (vin.hcount >= P2X0 && vin.hcount < P2X0+P2W &&
                   vin.vcount >= P2Y0 && vin.vcount < P2Y0+P2H);
        addr_p2 = in_p2
                  ? ( (vin.vcount - P2Y0) * P2W + (vin.hcount - P2X0) )
                  : '0;

        
        in_dr   = (vin.hcount >= DRX0 && vin.hcount < DRX0+DRW &&
                   vin.vcount >= DRY0 && vin.vcount < DRY0+DRH);
        addr_dr = in_dr
                  ? ( (vin.vcount - DRY0) * DRW + (vin.hcount - DRX0) )
                  : '0;
    end

   
    logic [11:0] rgb_p1, rgb_p2, rgb_dr;
    gameover_rom u_go_rom (
        .clk(clk),
        .addr_p1(addr_p1),
        .addr_p2(addr_p2),
        .addr_dr(addr_dr),
        .rgb_p1(rgb_p1),
        .rgb_p2(rgb_p2),
        .rgb_draw(rgb_dr)
    );

  
    logic in_p1_d, in_p2_d, in_dr_d;
    logic [1:0] winner_d;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            in_p1_d  <= 1'b0;
            in_p2_d  <= 1'b0;
            in_dr_d  <= 1'b0;
            winner_d <= 2'b00;
        end else begin
            in_p1_d  <= in_p1;
            in_p2_d  <= in_p2;
            in_dr_d  <= in_dr;
            winner_d <= winner_latched;
        end
    end

   
    always_comb begin
        unique case (winner_d)
            2'b01: begin rgb = rgb_p1; valid = in_p1_d; end
            2'b10: begin rgb = rgb_p2; valid = in_p2_d; end
            2'b11: begin rgb = rgb_dr; valid = in_dr_d; end
            default: begin rgb = 12'h000; valid = 1'b0; end
        endcase
    end
endmodule
