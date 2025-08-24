/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

module top_vga (
        input logic clk100MHz,
        input  logic clk,
        input  logic rst,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,
        inout logic ps2_clk,
        inout logic ps2_data
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

    wire mouse_left_event = left & new_event;

    draw_bg u_draw_bg (
        .clk,
        .rst,
        .vin(u_timing_draw_if),
        .vout(u_draw_out_if)
    );

    wire logic [1:0] state;
    rgb_if u_modules_mux_if();
    wire logic game_rst;
    menu_mux u_menu_mux
    (
        .clk,
        .state(state),
        .rgb_bg(u_draw_out_if.rgb),
        .vin(u_modules_mux_if),
        .rgb_out(rgb_out)
    );

    game_fsm u_game_fsm
    (
        .clk,
        .rst,
        .mouse_left(mouse_left_event),
        .collision(right),
        .state(state),
        .game_rst(game_rst)
    );

    draw_start u_draw_start
    (
        .clk,
        .rst,
        .vin(u_timing_draw_if),
        .rgb(u_modules_mux_if.rgb_start),
        .valid(u_modules_mux_if.valid_start)
    );

        draw_game u_draw_game
    (
        .clk,
        .rst,
        .vin(u_timing_draw_if),
        .rgb(u_modules_mux_if.rgb_game),
        .valid(u_modules_mux_if.valid_game),
        .mouse_left(mouse_left_event),
        .game_rst(game_rst)
    );
        
        draw_gameover u_draw_gameover
    (
        .clk,
        .rst,
        .vin(u_timing_draw_if),
        .rgb(u_modules_mux_if.rgb_gameover),
        .valid(u_modules_mux_if.valid_gameover)
    );


endmodule