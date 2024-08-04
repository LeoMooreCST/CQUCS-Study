`timescale 1ns / 1ps
/**
	@brief: 带有阻塞、刷新的信号控制
-->input:
	@param clk, rst: 时钟信号
	@param en:       阻塞信号(stall)
	@param clear: 	 刷新信号(flush)
	@param d: 		 上一周期的值
-->output:
	@param q: 	     下一周期的值
*/
module flopenrc #(parameter WIDTH = 8)(
	input wire clk,rst,en,clear,
	input wire[WIDTH-1:0] d,
	output reg[WIDTH-1:0] q
    );
	always @(posedge clk) begin
		if(rst) begin
			q <= 0;
		end else if(clear) begin
			q <= 0; //刷新
		end else if(en) begin
			q <= d; //不阻塞
		end
	end
endmodule
