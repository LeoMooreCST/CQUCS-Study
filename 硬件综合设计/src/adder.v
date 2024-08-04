`timescale 1ns / 1ps
/**
 * @brief 加法器
 * 
 * @param a: 加数1
 * @param b: 加数2
 * @param y: 结果
 */
module adder(
	input wire[31:0] a,b,
	output wire[31:0] y
    );
	assign y = a + b;
endmodule
