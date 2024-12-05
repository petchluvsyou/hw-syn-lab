`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 06:39:34 PM
// Design Name: 
// Module Name: system
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module system(
    input clk,
    input [7:0] sw,
    output [6:0] seg,
    output [3:0] an,
    output dp,
    input btnU, btnC,
    output wire hsync,
    output wire vsync,
    output wire [11:0] rgb,
    inout jb0,
    inout jb1,
    input RsRx,
    output RsTx
    );
    wire Tx, Rx;
    assign Tx = jb0;
    assign Rx = jb1;
    
    ////////////////////////////////////////
    // Clock
    wire targetClk;
    wire [18:0] tclk;
    
    assign tclk[0]=clk;
    
    genvar c;
    generate for(c=0;c<18;c=c+1) begin
        clockDiv fDiv(tclk[c+1],tclk[c]);
    end endgenerate
    
    clockDiv fdivTarget(targetClk,tclk[18]);
    
    ////////////////////////////////////////
    // 7-Segment Display
    
    wire [3:0] num3,num2,num1,num0; // left to right
    
    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    
    quadSevenSeg q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,targetClk);
    
    ////////////////////////////////////////
    wire [7:0] data_in;
    wire received;
    assign {num3, num2} = data_in;
    assign {num1, num0} = sw;
    
    uart uart(clk,sw,Tx,data_in,Rx,btnU,received);
    
    ////////////////////////////////////////
    
    vga vga(clk, btnC, received, vsync, hsync, rgb[11:8], rgb[7:4], rgb[3:0], data_in);
    
endmodule
