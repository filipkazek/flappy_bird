/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

 module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 25;     // 40 MHz


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

    wire [10:0] vcount, hcount;
    wire        vsync,  hsync;
    wire        vblnk,  hblnk;


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #(1.25*CLK_PERIOD) rst = 1'b1;
        rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end


    /**
     * Dut placement
     */

    vga_timing dut(
        .clk(clk),
        .rst(rst),
        .vcount(vcount),
        .vsync(vsync),
        .vblnk(vblnk),
        .hcount(hcount),
        .hsync(hsync),
        .hblnk(hblnk)
    );

    /**
     * Tasks and functions
     */

    // Here you can declare tasks with immediate assertions (assert).


    /**
     * Assertions
     */

    property p_hsync;
        @(posedge clk) disable iff(rst)
        (hcount == HOR_SYNC_START +1 ) |-> (hsync==1);
    endproperty
    assert property (p_hsync) else $error("hsync assertion failed");

    property p_vsync;
        @(posedge clk) disable iff(rst)
        (vcount == VER_SYNC_START +1 ) |-> (vsync==1);
    endproperty
    assert property (p_vsync) else $error("vsync assertion failed");

    property p_hblnk;
        @(posedge clk) disable iff(rst)
        (hcount == HOR_TOTAL_TIME +1) |-> (hblnk==1);
    endproperty
    assert property (p_hblnk) else $error("hblnk assertion failed");

    property p_vblnk;
        @(posedge clk) disable iff(rst)
        (vcount == VER_TOTAL_TIME + 1) |-> (vblnk==1);
    endproperty
    assert property (p_vblnk) else $error("vblnk assertion failed");
    
    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);

        wait (vsync == 1'b0);
        @(negedge vsync);
        @(negedge vsync);

        $finish;
    end

endmodule
