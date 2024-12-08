`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 07:20:03 PM
// Design Name: 
// Module Name: vga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: VGA controller with grid-based ASCII rendering
// 
// Dependencies: 
// ASCII ROM, VGA sync module
// 
// Revision:
// Revision 0.02 - Fixed grid indexing, timing, and initialization
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module vga(
    input wire clk,
    input wire reset,
    input wire en,
    output wire vsync,
    output wire hsync,
    output reg [3:0] red, green, blue,
    input wire [7:0] data
);

    parameter WIDTH = 640, HEIGHT = 480;

    // Each row: 640/8 = 80 chars/row
    // # of rows: 480/16 = 30 rows

    wire [9:0] x, y;
    wire video_on;

    // Instantiate VGA sync module
    vga_sync vga_sync_unit (
        .clk(clk), .reset(reset), 
        .hsync(hsync), .vsync(vsync), .video_on(video_on),
        .x(x), .y(y)
    );

    // Grid to store characters
    reg [7:0] grid[0:79][0:29];

    // Internal signals for grid indexing
    wire [9:0] char_x = x/8;
    wire [9:0] char_y = y/16;

    reg last_en;

    integer i = 20, j = 8;

    // Initialize grid and variables on reset
    initial begin
        for (i = 0; i < 80; i = i + 1) begin
            for (j = 0; j < 30; j = j + 1) begin
                grid[i][j] <= 8'b00000000;
            end
        end
        grid[36][4]<=8'h54;
        grid[37][4]<=8'h45;
        grid[38][4]<=8'h4C;
        grid[39][4]<=8'h45;
        grid[40][4]<=8'h54;
        grid[41][4]<=8'h59;
        grid[42][4]<=8'h50;
        grid[43][4]<=8'h45;
        i <= 20;
        j <= 8;
        last_en <= 0;
        
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 80; i = i + 1) begin
                for (j = 0; j < 30; j = j + 1) begin
                    grid[i][j] <= 8'b00000000;
                end
            end
            grid[36][4]<=8'h54;
            grid[37][4]<=8'h45;
            grid[38][4]<=8'h4C;
            grid[39][4]<=8'h45;
            grid[40][4]<=8'h54;
            grid[41][4]<=8'h59;
            grid[42][4]<=8'h50;
            grid[43][4]<=8'h45;
            i <= 20;
            j <= 8;
            last_en <= 1;
        end
        else if (en & ~last_en) begin
            // Write data to grid when enabled
            if(data!=8'b00001010) grid[i][j] <= data;
            else begin grid[i][j]<=8'b00000000; j=j+1; i=19; end
            if (i >= 59) begin
                i = 20;
                if (j >= 24) begin
                    j = 8;
                end else begin
                    j = j + 1;
                end
            end else begin
                i = i + 1;
                if (j >= 24) begin
                    j = 8;
                end
            end
        end
        last_en <= en;  
    end

    // Signals for character and bitmap rendering
    reg [6:0] current_char;
    wire [7:0] bitmap;
    wire [3:0] row = y[3:0];
    wire [2:0] col = x[2:0];

    // Instantiate ASCII ROM
    ascii_rom ascii_rom_unit(
        .clk(clk),
        .rom_addr({current_char, row}),
        .data(bitmap)
    );

    reg pixel_on;

    // Render characters and manage video signals
    always @(posedge clk) begin
        if (video_on) begin
            current_char <= grid[char_x][char_y];
            pixel_on <= bitmap[3'b111 - col];

            red <= (pixel_on) ? 4'hF : 
                (!(char_x <= 59 && char_x >= 20 && char_y <= 24 && char_y >= 8) ? 4'h6 : 4'h2);
            green <= (pixel_on) ? 4'hF : 4'h2;
            blue <= (pixel_on) ? 4'hF : 
                (!(char_x <= 59 && char_x >= 20 && char_y <= 24 && char_y >= 8) ? 4'h6 : 4'h2);
        end else begin
            // Background color when video is off
            red <= 4'hF;
            green <= 4'h0;
            blue <= 4'h0;
        end
    end

endmodule
