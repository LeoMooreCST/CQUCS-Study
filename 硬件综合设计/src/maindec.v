`timescale 1ns / 1ps
`include "defines.vh"
/**
	@brief: 译码器
-->input:
	@param instrD: 		32位指令(D阶段)
	@param op: 			6位操作码(指令高6位)
	@param funct: 		6位功能码(指令低6位)
	@param rtBranch: 	5位用于区分branch分支跳转指令
-->output:
	@param memtoreg: 	写回寄存器数据来源
	@param memwrite: 	是否需要访存(读写使能信号)
	@param branch: 		是否分支跳转指令
	@param regwrite: 	是否需要回写寄存器
	@param jump: 		是否为跳转指令
	@param jtoreg: 		跳转指令是否需要将地址保留至寄存器
	@param jgetreg: 	跳转指令的跳转地址是否来源于寄存器
	@param isbreak: 	断点信号
	@param syscall: 	系统调用信号
	@param eret: 		例外处理返回，刷新流水线，选取新的PC进行执行
	@param cp0ren: 		cp0寄存器读使能信号
	@param cp0wen: 		cp0寄存器写使能信号
	@param reserve: 	保留(未实现)指令,缺省值
**/
module maindec(
	input wire[31:0] instrD,
	input wire[5:0]  op,
	input wire[5:0]  funct,
	input wire[4:0]  rtBranch,
	output wire memtoreg,memwrite,branch,alusrc,
	output wire regdst,regwrite,jump,jtoreg,jgetreg,
	output wire isbreak,syscall,eret,cp0ren,cp0wen,reserve
    );
	reg[19:0] controls;
	assign {regwrite,regdst,alusrc,branch,  memwrite,memtoreg,jump,jtoreg,
			jgetreg,isbreak,syscall,eret,   cp0ren,cp0wen,reserve} = controls[19:5];
	always @(*) begin
		case (op)
			//逻辑运算指令
			`EXE_LUI: 	controls = 20'b1010_0000_0000_0000_0000; //lui
			`EXE_ORI: 	controls = 20'b1010_0000_0000_0000_0000; //ori
			`EXE_ANDI: 	controls = 20'b1010_0000_0000_0000_0000; //andi
			`EXE_XORI: 	controls = 20'b1010_0000_0000_0000_0000; //xori
			//访存指令
			`EXE_SB: 	controls = 20'b0010_1000_0000_0000_0000; //sb
			`EXE_LB: 	controls = 20'b1010_1100_0000_0000_0000; //lb
			`EXE_LBU: 	controls = 20'b1010_1100_0000_0000_0000; //lbu
			`EXE_SH: 	controls = 20'b0010_1000_0000_0000_0000; //sh
			`EXE_LH: 	controls = 20'b1010_1100_0000_0000_0000; //lh
			`EXE_LHU: 	controls = 20'b1010_1100_0000_0000_0000; //lhu
			`EXE_SW: 	controls = 20'b0010_1000_0000_0000_0000; //sw
            `EXE_LW: 	controls = 20'b1010_1100_0000_0000_0000; //lw
			//算术运算指令
			`EXE_ADDI: 	controls = 20'b1010_0000_0000_0000_0000; //addi
			`EXE_ADDIU: controls = 20'b1010_0000_0000_0000_0000; //addiu
			`EXE_SLTI: 	controls = 20'b1010_0000_0000_0000_0000; //slti
			`EXE_SLTIU: controls = 20'b1010_0000_0000_0000_0000; //sltiu
			//分支跳转指令
			`EXE_J: 	controls = 20'b0000_0010_0000_0000_0000; //j
			`EXE_JAL: 	controls = 20'b1100_0011_0000_0000_0000; //jal
			`EXE_BEQ: 	controls = 20'b0001_0000_0000_0000_0000; //beq
			`EXE_BGTZ: 	controls = 20'b0001_0000_0000_0000_0000; //bgtz
			`EXE_BLEZ: 	controls = 20'b0001_0000_0000_0000_0000; //blez
			`EXE_BNE: 	controls = 20'b0001_0000_0000_0000_0000; //bne
			`EXE_REGIMM_INST: begin
				case(rtBranch)
					`EXE_BLTZ: 	 controls = 20'b0001_0000_0000_0000_0000; //bltz
					`EXE_BLTZAL: controls = 20'b1101_0001_0000_0000_0000; //bltzal
					`EXE_BGEZ: 	 controls = 20'b0001_0000_0000_0000_0000; //bgez
					`EXE_BGEZAL: controls = 20'b1101_0001_0000_0000_0000; //bgezal
					default: 	 controls = 20'b0000_0000_0000_0010_0000;
				endcase
			end
			`EXE_NOP:
				case(funct)
					//逻辑运算指令
					`EXE_OR: 	controls = 20'b1100_0000_0000_0000_0000; //or
			    	`EXE_AND: 	controls = 20'b1100_0000_0000_0000_0000; //and
			    	`EXE_XOR: 	controls = 20'b1100_0000_0000_0000_0000; //xor
			        `EXE_NOR: 	controls = 20'b1100_0000_0000_0000_0000; //nor
			        //移位指令
					`EXE_SLL: 	controls = 20'b1100_0000_0000_0000_0000; //sll
					`EXE_SLLV: 	controls = 20'b1100_0000_0000_0000_0000; //sllv
					`EXE_SRL: 	controls = 20'b1100_0000_0000_0000_0000; //srl
					`EXE_SRLV: 	controls = 20'b1100_0000_0000_0000_0000; //srlv
					`EXE_SRA: 	controls = 20'b1100_0000_0000_0000_0000; //sra
					`EXE_SRAV: 	controls = 20'b1100_0000_0000_0000_0000; //srav
					//算术运算指令
					`EXE_ADDU: 	controls = 20'b1100_0000_0000_0000_0000; //addu
					`EXE_SUB: 	controls = 20'b1100_0000_0000_0000_0000; //sb
					`EXE_SUBU: 	controls = 20'b1100_0000_0000_0000_0000; //sbu
					`EXE_ADD: 	controls = 20'b1100_0000_0000_0000_0000; //add
					`EXE_SLT: 	controls = 20'b1100_0000_0000_0000_0000; //slt
					`EXE_SLTU: 	controls = 20'b1100_0000_0000_0000_0000; //sltu
					`EXE_MULT: 	controls = 20'b0000_0000_0000_0000_0000; //mult
					`EXE_MULTU: controls = 20'b0000_0000_0000_0000_0000; //multu
					`EXE_DIV: 	controls = 20'b0000_0000_0000_0000_0000; //div
					`EXE_DIVU: 	controls = 20'b0000_0000_0000_0000_0000; //divu
					//HI_LO指令
					`EXE_MFHI: 	controls = 20'b1100_0000_0000_0000_0000; //mfhi
					`EXE_MFLO: 	controls = 20'b1100_0000_0000_0000_0000; //mflo
					`EXE_MTHI: 	controls = 20'b0000_0000_0000_0000_0000; //mthi
					`EXE_MTLO: 	controls = 20'b0000_0000_0000_0000_0000; //mtlo
					//j指令
					`EXE_JALR: 	controls = 20'b1100_0011_1000_0000_0000; //jalr
					`EXE_JR: 	controls = 20'b0000_0010_1000_0000_0000; //jr
					//break和syscall
					`EXE_BREAK: controls = 20'b0000_0000_0100_0000_0000; //break
					`EXE_SYSCALL: controls = 20'b0000_0000_0010_0000_0000; //syscall
					default: 	controls = 20'b0000_0000_0000_0010_0000;
				endcase
			`EXE_SPECIAL3_INST: begin
				if(instrD == `EXE_ERET)
					controls = 20'b0000_0000_0001_0000_0000; //eret
				else if(instrD[25:21] == 5'b00100 & instrD[10:3] == 8'b0000_0000)
					controls = 20'b0000_0000_0000_0100_0000; //mtc0
				else if(instrD[25:21] == 5'b00000 & instrD[10:3] == 8'b0000_0000)
					controls = 20'b1000_0000_0000_1000_0000; //mfc0
				else
					controls = 20'b0000_0000_0000_0010_0000; //reserve
			end
			default: controls = 20'b0000_0000_0000_0010_0000;
		endcase
	end
endmodule
