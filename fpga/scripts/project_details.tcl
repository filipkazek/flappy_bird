# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
    constraints/clk_wiz_0.xdc
    constraints/clk_wiz_0_late.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/vga_pkg.sv
    ../rtl/vga_timing.sv
    ../rtl/draw_bg.sv
    ../rtl/top_vga.sv
    ../rtl/vga_if.sv
    ../rtl/draw_game.sv
    ../rtl/draw_gameover.sv
    ../rtl/draw_start.sv
    ../rtl/game_fsm.sv
    ../rtl/menu_mux.sv
    ../rtl/tube_render.sv
    ../rtl/bird_jump.sv
    ../rtl/image_rom.sv
    ../rtl/start_rom.sv
    ../rtl/gameover_rom.sv
    ../rtl/rgb_if.sv
    ../rtl/uart_click_rx.sv
    rtl/top_vga_basys3.sv
}

# Specify Verilog design files location         -- EDIT
 set verilog_files {
   ../fpga/rtl/clk_wiz_0.v
   ../fpga/rtl/clk_wiz_0_clk_wiz.v
   ../rtl/simple_uart_rx.v
 }

# Specify VHDL design files location            -- EDIT
 set vhdl_files {
../fpga/rtl/MouseCtl.vhd
../fpga/rtl/Ps2Interface.vhd
 }

# Specify files for a memory initialization     -- EDIT
 set mem_files {
    ../rtl/bg.dat
    ../rtl/start.dat
    ../rtl/player1.dat
    ../rtl/player2.dat
    ../rtl/draw.dat
 }
