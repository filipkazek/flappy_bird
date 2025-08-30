
module draw_game #(

    parameter int    BIRD_WIDTH   = 40,
    parameter int    BIRD_HEIGHT  = 50,
    parameter string BIRD1_FILE   = "data/p1.dat",
    parameter string BIRD2_FILE   = "data/p2.dat",
    parameter logic [11:0] TRANSP = 12'h000
)(
    input  logic        clk,
    input  logic        rst,

    vga_if.in           vin,

    input  logic [10:0] tube_x [2:0],
    input  logic [10:0] gap_y  [2:0],
    input  logic [10:0] bird1_y,
    input  logic [10:0] bird2_y,
    input  logic        pending,
    input  logic        pending_bird,

    output logic [11:0] rgb,
    output logic        valid
);
   
    localparam int SCREEN_W   = 1024;
    localparam int TUBE_WIDTH = 120;
    localparam int GAP_HEIGHT = 250;
    localparam int BIRD1_X    = 180;
    localparam int BIRD2_X    = 260;

    logic [11:0] rgb_tube;
    logic        valid_tube;
    logic [10:0] relx;  

    always_comb begin
        rgb_tube   = 12'h000;
        valid_tube = 1'b0;

        if (!vin.hblnk && !vin.vblnk) begin
            for (int i = 0; i < 3; i++) begin
                if (tube_x[i] < SCREEN_W) begin
                    if ( (vin.hcount >= tube_x[i]) &&
                         (vin.hcount < tube_x[i] + TUBE_WIDTH) &&
                         ( (vin.vcount < gap_y[i]) ||
                           (vin.vcount > gap_y[i] + GAP_HEIGHT) ) ) begin

                        relx = vin.hcount - tube_x[i];

                       
                        if ( (relx < 11'd5) || (relx >= (TUBE_WIDTH-5)) ) begin
                            rgb_tube = 12'h000;
                        end else if (relx < 11'd20) begin
                            rgb_tube = 12'h0F0;
                        end else if (relx < 11'd40) begin
                            rgb_tube = 12'h0C0;
                        end else if (relx < 11'd80) begin
                            rgb_tube = 12'h090;
                        end else begin
                            rgb_tube = 12'h0D0;
                        end
                        valid_tube = 1'b1;
                    end
                end
            end
        end
    end


    logic [11:0] rgb_b1;
    logic        valid_b1;
    bird_rom #(
        .SPR_W (BIRD_WIDTH),
        .SPR_H (BIRD_HEIGHT),
        .FILE  (BIRD1_FILE),
        .TRANSP(TRANSP)
    ) u_bird1 (
        .clk  (clk),
        .rst  (rst),
        .vin  (vin),
        .spr_x(BIRD1_X),
        .spr_y(bird1_y),
        .rgb  (rgb_b1),
        .valid(valid_b1)
    );

   
    logic [11:0] rgb_b2;
    logic        valid_b2;
    bird_rom #(
        .SPR_W (BIRD_WIDTH),
        .SPR_H (BIRD_HEIGHT),
        .FILE  (BIRD2_FILE),
        .TRANSP(TRANSP)
    ) u_bird2 (
        .clk  (clk),
        .rst  (rst),
        .vin  (vin),
        .spr_x(BIRD2_X),
        .spr_y(bird2_y),
        .rgb  (rgb_b2),
        .valid(valid_b2)
    );

   
    wire hide_b1       = pending && (pending_bird == 1'b0);
    wire hide_b2       = pending && (pending_bird == 1'b1);
    wire valid_b1_draw = valid_b1 && ~hide_b1;
    wire valid_b2_draw = valid_b2 && ~hide_b2;

  
    always_comb begin
        if (vin.vblnk || vin.hblnk) begin
            rgb   = 12'h000;
            valid = 1'b0;
        end else if (valid_b1_draw) begin
            rgb   = rgb_b1;   
            valid = 1'b1;
        end else if (valid_b2_draw) begin
            rgb   = rgb_b2;   
            valid = 1'b1;
        end else if (valid_tube) begin
            rgb   = rgb_tube; 
            valid = 1'b1;
        end else begin
            rgb   = 12'h000;
            valid = 1'b0;
        end
    end

endmodule
