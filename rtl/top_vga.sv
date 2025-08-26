module top_vga (
        input  logic clk100MHz,
        input  logic clk,
        input  logic rst,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,
        inout  logic ps2_clk,
        inout  logic ps2_data
    );

    timeunit 1ns;
    timeprecision 1ps;

    wire logic [11:0] rgb_out;

    assign vs = u_draw_out_if.vsync;
    assign hs = u_draw_out_if.hsync;
    assign {r,g,b} = rgb_out;

    vga_if u_timing_draw_if();
    vga_if u_draw_out_if();

    vga_timing u_vga_timing (
        .clk,
        .rst,
        .vout(u_timing_draw_if)
    );

 
    wire logic left;
    wire logic right;
    wire logic collision;
    wire logic new_event;

    MouseCtl u_mouse_ctl (
        .clk(clk100MHz),
        .rst(rst),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .left(left),
        .right(right),
        .new_event(new_event)
    );

  
    logic left_meta, left_sync, left_d;

    always_ff @(posedge clk) begin
        if (rst) begin
            left_meta <= 0;
            left_sync <= 0;
            left_d    <= 0;
        end else begin
            left_meta <= left;       
            left_sync <= left_meta;  
            left_d    <= left_sync;  
        end
    end

    wire mouse_left_event = left_sync & ~left_d; 

  
    draw_bg u_draw_bg (
        .clk,
        .rst,
        .vin(u_timing_draw_if),
        .vout(u_draw_out_if)
    );

    wire logic [1:0] state;
    rgb_if u_modules_mux_if();
    wire logic game_rst;
    wire logic mouse_left_game;

    menu_mux u_menu_mux (
        .clk,
        .state(state),
        .rgb_bg(u_draw_out_if.rgb),
        .vin(u_modules_mux_if),
        .rgb_out(rgb_out)
    );

    game_fsm u_game_fsm (
        .clk,
        .rst,
        .mouse_left(mouse_left_event),
        .collision(collision),
        .state(state),
        .game_rst(game_rst),
        .mouse_left_game(mouse_left_game)
    );


    draw_start u_draw_start (
        .clk,
        .rst,
        .vin(u_timing_draw_if),
        .rgb(u_modules_mux_if.rgb_start),
        .valid(u_modules_mux_if.valid_start)
    );

    draw_game u_draw_game (
        .clk,
        .rst,
        .vin(u_timing_draw_if),
        .rgb(u_modules_mux_if.rgb_game),
        .valid(u_modules_mux_if.valid_game),
        .mouse_left(mouse_left_game),
        .game_rst(game_rst),
        .collision(collision)
    );

    draw_gameover u_draw_gameover (
        .clk,
        .rst,
        .vin(u_timing_draw_if),
        .rgb(u_modules_mux_if.rgb_gameover),
        .valid(u_modules_mux_if.valid_gameover)
    );

endmodule
