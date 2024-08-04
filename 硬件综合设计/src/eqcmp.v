`timescale 1ns / 1ps
`include "defines.vh"
// module eqcmp(
// 	input wire [31:0] a,b,
// 	input wire [7:0]alucontrolD,
// 	output reg y
//     );
// 	always @(*) begin
// 		case(alucontrolD)
// 			`EXE_BEQ_OP: y = (a == b)?1:0;   //a==b
// 			`EXE_BNE_OP: y = (a != b)?1:0;   //a!=b
// 			`EXE_BGTZ_OP: y = ((a[31]==0) && (a != 32'b0))?1:0;  //a>0
// 			`EXE_BGEZ_OP: y = (a[31] == 0)?1:0;   //a>=0
// 			`EXE_BGEZAL_OP: y = (a[31] == 0)?1:0; //a>=0
// 			`EXE_BLTZ_OP: y = ((a[31] == 1) && (a != 32'b10000000_00000000_00000000_00000000))?1:0; //a<0
// 			`EXE_BLEZ_OP: y = (a[31] == 1)?1:0;   //a<=0
// 			`EXE_BLTZAL_OP: y = ((a[31] == 1) && (a != 32'b10000000_00000000_00000000_00000000))?1:0; //a<0
// 			default: y = 0;
// 		endcase
// 	end
// endmodule

module eqcmp(
	input wire [31:0] a,b,
	input wire [7:0] alucontrolD,
	output reg y
    );
	
	always@ (*) begin
		case (alucontrolD)
			`EXE_BEQ_OP: y = (a == b) ? 1:0;
			`EXE_BGTZ_OP: y = ((a[31] == 0) && (a != 32'b0)) ? 1:0;
			`EXE_BLEZ_OP: y = ((a[31] == 1) || (a == 32'b0)) ? 1:0;
			`EXE_BNE_OP: y = (a != b) ? 1:0; 
			`EXE_BLTZ_OP: y = (a[31] == 1) ? 1:0;
			`EXE_BLTZAL_OP: y = (a[31] == 1) ? 1:0;
			`EXE_BGEZ_OP: y = (a[31] == 0) ? 1:0;
			`EXE_BGEZAL_OP: y = (a[31] == 0) ? 1:0;
		default: y = 0;
		endcase
	end
	
endmodule
