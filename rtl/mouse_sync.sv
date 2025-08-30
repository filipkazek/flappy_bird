
module mouse_sync (
    input  logic clk,
    input  logic rst,       
    input  logic in_async,   
    output logic level_sync, 
    output logic rise_pulse  
);
    logic ff1, ff2, ff2_d;

    always_ff @(posedge clk) begin
        if (rst) begin
            ff1    <= 1'b0;
            ff2    <= 1'b0;
            ff2_d  <= 1'b0;
        end else begin
            ff1    <= in_async; // 1. przerzutnik
            ff2    <= ff1;      // 2. przerzutnik (zsynchronizowany poziom)
            ff2_d  <= ff2;      // opóźnienie do detekcji zbocza
        end
    end

    assign level_sync = ff2;
    assign rise_pulse = ff2 & ~ff2_d; // detekcja rising edge
endmodule
