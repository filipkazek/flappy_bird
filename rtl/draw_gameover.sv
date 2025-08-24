module draw_gameover (
    input  logic        clk,
    input  logic        rst,   
    vga_if.in           vin,
    output logic [11:0] rgb,
    output logic        valid
);

    always_ff @(posedge clk) begin
        if (rst) begin
            rgb   <= 12'h000; 
            valid <= 1'b0;    
        end
        else begin
            if (vin.hcount >= 400 && vin.hcount < 600 &&
                vin.vcount >= 300 && vin.vcount < 400) begin
                rgb   <= 12'h00F;  // niebieski
                valid <= 1'b1;     // rysujemy piksel
            end else begin
                rgb   <= 12'h000;  // nie rysujemy
                valid <= 1'b0;
            end
        end
    end

endmodule
