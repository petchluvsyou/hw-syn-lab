`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2024 06:42:14 PM
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments// 
//////////////////////////////////////////////////////////////////////////////////


module uart(
    input clk,
    input [7:0] data_transmit,
    output tx,
    output [7:0] data_received,
    input rx,
    input dte, //data transmit enable
    output wire received
    );
    
    reg en;
    wire sent;
    reg [7:0] data;
    wire baud;
    reg last_record;
    
    uart_rx uart_rx(baud, rx, received, data_received);
    uart_tx uart_tx(baud, data_transmit, en, sent, tx);
    baudrate_gen baudrate_gen(clk, baud);
    
    always @(posedge baud) begin
        en = 0;
        if(~last_record & dte) en = 1; 
        last_record = dte;
    end
    
endmodule
