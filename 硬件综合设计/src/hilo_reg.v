`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/12 11:26:03
// Design Name: 
// Module Name: hilo_reg
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


module hilo_reg(
	input  wire clk,rst,we,flushE,
	input  wire [31:0] hi_i,lo_i,
	output wire [31:0] hi_o,lo_o
    );
	
	reg [31:0] hi, lo;
	always @(posedge clk) begin //...
		if(rst) begin
			hi <= 0;
			lo <= 0;
		end else if (we & ~flushE) begin
			hi <= hi_i;
			lo <= lo_i;
		end
	end

	assign hi_o = hi;
	assign lo_o = lo;
endmodule
