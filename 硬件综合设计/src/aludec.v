`timescale 1ns / 1ps
`include "defines.vh"
/**
	@brief: alu译码器
-->input:
	@param funct: 6位功能码
	@param op:    6位操作码
-->output:
	@param alucontrol: D阶段每条指令的唯一标识信号
*/
module aludec(
	input wire[5:0] funct,
	input wire[5:0] op,
	input wire[4:0] rtBranch,
	output reg[7:0] alucontrol
    );
	//....
	always @(*) begin
		case (op)
			//逻辑运算指令
			`EXE_LUI:  	alucontrol = `EXE_LUI_OP; //lui
			`EXE_ORI:  	alucontrol = `EXE_ORI_OP; //ori
			`EXE_ANDI: 	alucontrol = `EXE_ANDI_OP; //andi
			`EXE_XORI: 	alucontrol = `EXE_XORI_OP; //xori
			//访存指令
			`EXE_SB:   	alucontrol = `EXE_SB_OP; //sb
			`EXE_LB:   	alucontrol = `EXE_LB_OP; //lb
			`EXE_LBU:  	alucontrol = `EXE_LBU_OP; //lbu
			`EXE_SH:   	alucontrol = `EXE_SH_OP; //sh
			`EXE_LH:   	alucontrol = `EXE_LH_OP; //lh
			`EXE_LHU:  	alucontrol = `EXE_LHU_OP; //lhu
			`EXE_SW:   	alucontrol = `EXE_SW_OP; //sw
            `EXE_LW:   	alucontrol = `EXE_LW_OP; //lw
			//算术运算指令
			`EXE_ADDI: 	alucontrol = `EXE_ADDI_OP; //addi
			`EXE_ADDIU: alucontrol = `EXE_ADDIU_OP; //addiu
			`EXE_SLTI: 	alucontrol = `EXE_SLTI_OP; //slti
			`EXE_SLTIU: alucontrol = `EXE_SLTIU_OP; //sltiu
			//分支跳转指令
			`EXE_BEQ: 	alucontrol = `EXE_BEQ_OP;  //beq
			`EXE_BGTZ: 	alucontrol = `EXE_BGTZ_OP; //bgtz
			`EXE_BLEZ: 	alucontrol = `EXE_BLEZ_OP; //blez
			`EXE_BNE: 	alucontrol = `EXE_BNE_OP;  //bne
			`EXE_JAL: 	alucontrol = `EXE_JAL_OP;  //jal
			`EXE_REGIMM_INST: begin
				case(rtBranch)
					`EXE_BLTZ: 	 alucontrol = `EXE_BLTZ_OP; //bltz
					`EXE_BLTZAL: alucontrol = `EXE_BLTZAL_OP; //bltzal
					`EXE_BGEZ:   alucontrol = `EXE_BGEZ_OP; //bgez
					`EXE_BGEZAL: alucontrol = `EXE_BGEZAL_OP; //bgezal
					default: alucontrol = `EXE_NOP_OP;
				endcase
			end
			`EXE_NOP:
				case(funct)
					//逻辑运算指令
					`EXE_OR: 	alucontrol = `EXE_OR_OP; //OR
			    	`EXE_AND: 	alucontrol = `EXE_AND_OP; //AND
			    	`EXE_XOR: 	alucontrol = `EXE_XOR_OP; //XOR
			     	`EXE_NOR: 	alucontrol = `EXE_NOR_OP; //NOR
					//移位指令
					`EXE_SLL: 	alucontrol = `EXE_SLL_OP; //sll
					`EXE_SLLV: 	alucontrol = `EXE_SLLV_OP; //sllv
					`EXE_SRL: 	alucontrol = `EXE_SRL_OP; //srl
					`EXE_SRLV: 	alucontrol = `EXE_SRLV_OP; //srlv
					`EXE_SRA: 	alucontrol = `EXE_SRA_OP; //sra
					`EXE_SRAV: 	alucontrol = `EXE_SRAV_OP; //srav
					//算术运算指令
					`EXE_ADDU: 	alucontrol = `EXE_ADDU_OP; //addu
					`EXE_SUB: 	alucontrol = `EXE_SUB_OP;  //sub
					`EXE_SUBU: 	alucontrol = `EXE_SUBU_OP; //sunbu
					`EXE_ADD: 	alucontrol = `EXE_ADD_OP;  //add
					`EXE_SLT: 	alucontrol = `EXE_SLT_OP;  //slt
					`EXE_SLTU: 	alucontrol = `EXE_SLTU_OP; //sltu
					`EXE_MULT: 	alucontrol = `EXE_MULT_OP; //mult
					`EXE_MULTU: alucontrol = `EXE_MULTU_OP; //multu
					`EXE_DIV: 	alucontrol = `EXE_DIV_OP; //div
					`EXE_DIVU: 	alucontrol = `EXE_DIVU_OP; //divu
					//HI,LO
					`EXE_MFHI: 	alucontrol = `EXE_MFHI_OP; //mfhi
					`EXE_MFLO: 	alucontrol = `EXE_MFLO_OP; //mflo
					`EXE_MTHI: 	alucontrol = `EXE_MTHI_OP; //mthi
					`EXE_MTLO: 	alucontrol = `EXE_MTLO_OP; //mtlo
					//J
					`EXE_JALR: 	alucontrol = `EXE_JALR_OP; //jalr
					default: 	alucontrol = `EXE_NOP_OP;
				endcase
			default: alucontrol = `EXE_NOP_OP;
		endcase
	
	end
endmodule
