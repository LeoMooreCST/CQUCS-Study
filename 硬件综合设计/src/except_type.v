
`timescale 1ns / 1ps
module except_type(
	input rst,
	input [31:0] pcM,
	input [6:0] exceptionM,
	input wire[31:0] status_o,cause_o,aluoutM,
	output wire [31:0] excepttype_i,bad_addr
    );
	/*	exception input:
	exceptionM[6:0] = {adelM,adesM,syscallD,isbreakD,reserveD,eretD,overflowE}
	ExcCode:
	0x00 Int
	0x04 AdEL
	0x05 AdES
	0x08 Sys
	0x09 Bp
	0x0A RI
	0x0C Ov
	*/
	// exception type
	assign excepttype_i = (rst)? 32'h0000_0000:
	                      ((cause_o[15:8] & status_o[15:8]) != 8'h00 && status_o[1] == 1'b0 && status_o[0] == 1'b1)? 32'h0000_0001: // interrupt
						  (pcM[1:0]!=2'b00)? 32'h0000_0004: // AdEL
						  (exceptionM[0])? 32'h0000_000c: // overflow
						  (exceptionM[1])? 32'h0000_000e: // eret
						  (exceptionM[2])? 32'h0000_000a: // reserve
						  (exceptionM[3])? 32'h0000_0009: // isbreak
						  (exceptionM[4])? 32'h0000_0008: // syscall
						  (exceptionM[5])? 32'h0000_0005: // adesM
						  (exceptionM[6])? 32'h0000_0004: // adelM
						  32'h0;
	// bad address
	assign bad_addr = (rst)? 32'h0:
					  ((cause_o[15:8] & status_o[15:8]) != 8'h00 && status_o[1] == 1'b0 && status_o[0] == 1'b1)? 32'h0:
					  (pcM[1:0]!=2'b00)? pcM:
					  (exceptionM[0])? 32'h0:
					  (exceptionM[1])? 32'h0:
					  (exceptionM[2])? 32'h0:
					  (exceptionM[3])? 32'h0:
					  (exceptionM[4])? 32'h0:
					  (exceptionM[5])? aluoutM:
					  (exceptionM[6])? aluoutM:
					  32'h0;
endmodule
