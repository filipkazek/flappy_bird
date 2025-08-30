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
    inout  logic ps2_data,
    input  logic JB0           
);
    timeunit 1ns;
    timeprecision 1ps;

    wire logic [11:0] rgb_out;
    wire logic [11:0] rgb_bg_mux;
   
    vga_if u_timing_draw_if();
    vga_if u_draw_out_if();

    assign vs      = u_draw_out_if.vsync;
    assign hs      = u_draw_out_if.hsync;
    assign {r,g,b} = rgb_out;

    vga_timing u_vga_timing (
        .clk (clk),
        .rst (rst),
        .vout(u_timing_draw_if)
    );

    draw_bg u_draw_bg (
        .clk (clk),
        .rst (rst),
        .vin (u_timing_draw_if),
        .vout(u_draw_out_if),
        .rgb_bg(rgb_bg_mux)
    );

  
    wire logic left;
    wire logic right;

    MouseCtl u_mouse_ctl (
        .clk      (clk100MHz),
        .rst      (rst),
        .ps2_clk  (ps2_clk),
        .ps2_data (ps2_data),
        .left     (left),
        .right    (right),
        .new_event(),
        .xpos(), .ypos(), .zpos(),
        .middle(), .value(), .setx(), .sety(), .setmax_x(), .setmax_y()
    );

 
    wire logic mouse_left_level_sync;
    wire logic mouse_left_event; 
    mouse_sync u_sync_mouse_left (
        .clk        (clk),
        .rst        (rst),
        .in_async   (left),
        .level_sync (mouse_left_level_sync),
        .rise_pulse (mouse_left_event)
    );
    wire logic remote_click_pulse_raw;

    uart_click_rx #(
        .CLK_FREQ(65_000_000),
        .BAUD    (115_200)
    ) u_remote (
        .clk        (clk),
        .rst        (rst),
        .rx_in      (JB0),
        .click_pulse(remote_click_pulse_raw)
    );

    wire logic remote_click_level_sync;
    wire logic remote_click_event;
    mouse_sync u_sync_remote_click (
        .clk        (clk),
        .rst        (rst),
        .in_async   (remote_click_pulse_raw),
        .level_sync (remote_click_level_sync),
        .rise_pulse (remote_click_event)
    );

    wire logic [1:0] state;
    rgb_if u_modules_mux_if();
    wire logic game_rst;
    wire logic mouse_left_game_local;
    wire logic mouse_left_game_remote;

    menu_mux u_menu_mux (
        .clk    (clk),
        .rst    (rst),
        .state  (state),
        .rgb_bg (rgb_bg_mux),
        .vin    (u_modules_mux_if),
        .rgb_out(rgb_out)
    );


    wire logic        winner_valid;
    wire logic [1:0]  winner_code;
    wire logic [1:0]  winner_latched;

    game_fsm u_game_fsm (
        .clk                      (clk),
        .rst                      (rst),
        .mouse_left_remote        (remote_click_event),
        .mouse_left_local         (mouse_left_event),
        .state                    (state),
        .game_rst                 (game_rst),
        .mouse_left_game_local    (mouse_left_game_local),
        .mouse_left_game_remote   (mouse_left_game_remote),
        .winner_code              (winner_code),
        .winner_valid             (winner_valid),
        .winner_latched           (winner_latched)
    );


    wire logic [10:0] tube_x [2:0];
    wire logic [10:0] gap_y  [2:0];
    wire logic [10:0] bird1_y;
    wire logic [10:0] bird2_y;
    wire logic        pending;
    wire logic        pending_bird;

    game_logic u_game_logic (
        .clk               (clk),
        .rst               (rst),
        .game_rst          (game_rst),
        .mouse_left_local  (mouse_left_game_local),
        .mouse_left_remote (mouse_left_game_remote),
        .tube_x            (tube_x),
        .gap_y             (gap_y),
        .bird1_y           (bird1_y),
        .bird2_y           (bird2_y),
        .pending           (pending),
        .pending_bird      (pending_bird),
        .winner_valid      (winner_valid),
        .winner_code       (winner_code)
    );

  
    draw_start u_draw_start (
        .clk  (clk),
        .rst  (rst),
        .vin  (u_timing_draw_if),
        .rgb  (u_modules_mux_if.rgb_start),
        .valid(u_modules_mux_if.valid_start)
    );

  
    draw_game u_draw_game (
        .vin          (u_timing_draw_if),
        .tube_x       (tube_x),
        .gap_y        (gap_y),
        .bird1_y      (bird1_y),
        .bird2_y      (bird2_y),
        .pending      (pending),
        .pending_bird (pending_bird),
        .rgb          (u_modules_mux_if.rgb_game),
        .valid        (u_modules_mux_if.valid_game)
    );

    draw_gameover u_draw_gameover (
        .clk           (clk),
        .rst           (rst),
        .vin           (u_timing_draw_if),
        .rgb           (u_modules_mux_if.rgb_gameover),
        .valid         (u_modules_mux_if.valid_gameover),
        .winner_latched(winner_latched)
    );
endmodule
