`timescale 1ns / 1ps

// module pc #(parameter WIDTH = 8)(
// 	input wire clk,rst,en,
// 	input wire[WIDTH-1:0] d,
// 	output reg[WIDTH-1:0] q
//     );
// 	always @(posedge clk,posedge rst) begin
// 		if(rst) begin
// 			q <= 32'hbfc00000;
// 		end else if(en) begin
// 			/* code */
// 			q <= d;
// 		end
// 	end
// endmodule
// `timescale 1ns / 1ps

module pc #(parameter WIDTH = 8)(
	input clk, reset, enable,clear,
	input [WIDTH-1:0] d,
	input [WIDTH-1:0] newPC,
	output reg [WIDTH-1:0] q,
	output reg inst_reset
	);
	always @(posedge clk) begin
		if(reset) begin
		    inst_reset <= 0;
		end
	    else begin inst_reset<=1;end
	end
	always @(posedge clk) begin
		if(~inst_reset)		q <= 32'hbfc00000;
		else if(clear) 		q <= newPC;
		else if(enable) 	q <= d;
	end
endmodule
