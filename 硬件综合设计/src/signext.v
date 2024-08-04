`timescale 1ns / 1ps

/**
 * @brief 符号扩展
 * 
 * @param a: 初始输入16位
 * @param y: 扩展后的32位
 */

module signext(
	input wire[15:0] a,
	input wire[1:0] type1,
	output wire[31:0] y
	);
	//andi,xori,lui,ori指令的a[29:28]的两位对应的是11,其余均为00
	assign y = (type1 == 2'b11)? {{16{1'b0}},a} : {{16{a[15]}},a};
endmodule
