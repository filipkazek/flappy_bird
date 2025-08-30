/**
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Flappy Bird - UEC2 Final Project
 *
 *  Filip Kazek
 */
module draw_game    (
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

    localparam int SCREEN_W     = 1024;
    localparam int TUBE_WIDTH   = 120;
    localparam int GAP_HEIGHT   = 250;

    localparam int BIRD_WIDTH   = 40;
    localparam int BIRD_HEIGHT  = 50;
    localparam int BIRD1_X      = 180;
    localparam int BIRD2_X      = 260;

    logic [11:0] rgb_tube;  
    logic        valid_tube;

    always_comb begin
        rgb_tube   = 12'h000;
        valid_tube = 1'b0;

        for (int i=0; i<3; i++) begin
            if (tube_x[i] < SCREEN_W) begin
                if (vin.hcount >= tube_x[i] && vin.hcount < tube_x[i] + TUBE_WIDTH) begin
                    if (vin.vcount < gap_y[i] || vin.vcount > gap_y[i] + GAP_HEIGHT) begin
                        int rel_x;
                        rel_x = vin.hcount - tube_x[i];

                        if (rel_x < 5 || rel_x >= TUBE_WIDTH-5)      rgb_tube = 12'h000; 
                        else if (rel_x < 20)                         rgb_tube = 12'h0F0;
                        else if (rel_x < 40)                         rgb_tube = 12'h0C0;
                        else if (rel_x < 80)                         rgb_tube = 12'h090;
                        else                                          rgb_tube = 12'h0D0;

                        valid_tube = 1'b1;
                    end
                end
            end
        end
    end

    logic [11:0] rgb_b1;    logic valid_b1;
    logic [11:0] rgb_b2;    logic valid_b2;


    always_comb begin
        if (vin.hcount >= BIRD1_X && vin.hcount < BIRD1_X + BIRD_WIDTH &&
            vin.vcount >= bird1_y  && vin.vcount < bird1_y  + BIRD_HEIGHT) begin
            rgb_b1   = 12'h00F;
            valid_b1 = 1'b1;
        end else begin
            rgb_b1   = 12'h000;
            valid_b1 = 1'b0;
        end
    end

    always_comb begin
        if (vin.hcount >= BIRD2_X && vin.hcount < BIRD2_X + BIRD_WIDTH &&
            vin.vcount >= bird2_y  && vin.vcount < bird2_y  + BIRD_HEIGHT) begin
            rgb_b2   = 12'hFF0;
            valid_b2 = 1'b1;
        end else begin
            rgb_b2   = 12'h000;
            valid_b2 = 1'b0;
        end
    end

    wire hide_b1       = pending && (pending_bird == 1'b0);
    wire hide_b2       = pending && (pending_bird == 1'b1);
    wire valid_b1_draw = valid_b1 & ~hide_b1;
    wire valid_b2_draw = valid_b2 & ~hide_b2;

    always_comb begin
        if (valid_b1_draw) begin
            rgb = rgb_b1; valid = 1'b1;
        end else if (valid_b2_draw) begin
            rgb = rgb_b2; valid = 1'b1;
        end else if (valid_tube) begin
            rgb = rgb_tube; valid = 1'b1;
        end else begin
            rgb = 12'h000; valid = 1'b0;
        end
    end

endmodule
