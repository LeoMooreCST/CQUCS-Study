`timescale 1ns / 1ps
`include "defines.vh"
/**
	@brief ALU
	@param a: 操作数1
	@param b: 操作数2
	@param alucontrol: 每条指令的唯一标识
	@param sa: sll,srl,sra
	@param y: 运算结果
	@param overflow: 溢出标志
	@param zero: 零标志
*/
module alu(
	input wire clk,rst,
	input wire flushM,
	input wire[31:0] a,b,
	input wire[7:0] alucontrol,
	input wire[4:0] sa,
	input wire[63:0]hilo_o,
	output wire[63:0]hilo_i,
	output wire hiloen,
	output wire stall_div,
	output reg[31:0] y,
	output reg overflow,
	output wire zero
    );
    reg hilo_en;
	reg [63:0]hilo;
	always @(*) begin
		y = 32'h00000000;  //赋初值,防止生成latch
        hilo = 0;
		case (alucontrol)
			//逻辑运算指令
			`EXE_LUI_OP: y = {b[15:0],16'b0};
			`EXE_ORI_OP: y = a | b;
			`EXE_OR_OP:  y = a|b; 
            `EXE_ANDI_OP: y = a & b;
            `EXE_AND_OP: y = a & b;
            `EXE_XORI_OP: y = a ^ b;
            `EXE_XOR_OP:  y = a ^ b;
            `EXE_NOR_OP:  y =~(a | b);
			//访存指令
            `EXE_SB_OP: y = a + b;
            `EXE_LB_OP: y = a + b;
            `EXE_LBU_OP: y = a + b;
            `EXE_SH_OP: y = a + b;
            `EXE_LH_OP: y = a + b;
            `EXE_LHU_OP: y = a + b;
            `EXE_SW_OP: y = a + b;
            `EXE_LW_OP: y = a + b;
			//移位指令
			`EXE_SLL_OP: y = (b << sa);      
			`EXE_SLLV_OP: y = (b << a[4:0]);
			`EXE_SRL_OP: y = (b >> sa);
			`EXE_SRLV_OP: y = (b >> a[4:0]);
			`EXE_SRA_OP: y = $signed(b) >>> sa;
			`EXE_SRAV_OP: y = $signed(b) >>> a[4:0];
			//算术运算指令
			`EXE_ADDU_OP: y = a + b;
			`EXE_SUB_OP: y = a - b;
			`EXE_SUBU_OP: y = a - b;
			`EXE_ADDI_OP: y = a + b;
			`EXE_ADDIU_OP: y = a + b;
			`EXE_ADD_OP: y = a + b;
			`EXE_SLT_OP: y = ($signed(a) < $signed(b))? 1:0; 
			`EXE_SLTU_OP: y = (a < b)? 32'b1 : 32'b0; 
			`EXE_SLTI_OP: y = ($signed(a) < $signed(b))? 1:0; //ti
			`EXE_SLTIU_OP: y = (a < b)? 32'b1: 32'b0; //tiu
			//`EXE_MULT_OP: hilo = $signed(a) * $signed(b); //mult
			//`EXE_MULTU_OP: hilo = {32'b0, a} * {32'b0, b};  //multu
			//hilo
			`EXE_MFHI_OP: y = hilo_o[63:32];  //mfhi
			`EXE_MFLO_OP: y = hilo_o[31:0];  //mflo
			`EXE_MTHI_OP: hilo[63:32] = a;   //mthi
			`EXE_MTLO_OP: hilo[31:0] = a;   //mtlo
			default : begin y = 32'b0; hilo = 0; end
		endcase	
	end

	/********************************溢出**********************************************/
	always @(*) begin
		case (alucontrol)
			`EXE_SUB_OP: overflow = (~y[31] & a[31] & ~b[31]) | (y[31] & ~a[31] & b[31]);
			`EXE_ADD_OP: overflow = (~y[31] & a[31] & b[31]) | (y[31] & ~a[31] & ~b[31]);
			`EXE_ADDI_OP: overflow = (~y[31] & a[31] & b[31]) | (y[31] & ~a[31] & ~b[31]);
			default : overflow = 1'b0;
		endcase
	end
	/********************************hilo寄存器*************************************/
	always @(*)begin
        case(alucontrol)
        	`EXE_MTHI_OP: hilo_en=1'b1;
            `EXE_MTLO_OP: hilo_en=1'b1;
            //`EXE_MULT_OP: hilo_en=1'b1;
            //`EXE_MULTU_OP: hilo_en=1'b1;
            default: hilo_en=1'b0;
        endcase
    end
	/********************************除法器控制信号*************************************/
	wire start_i, annul_i, signed_div_i, ready_o;   //开始信号、除数是否为零、是否为有符号除法
	wire [63:0]hilo_div;
	assign start_i = ((alucontrol == `EXE_DIV_OP)|(alucontrol == `EXE_DIVU_OP)) & ~ready_o;
	assign annul_i = (b==0)? 1'b1 : 1'b0;
	assign signed_div_i = (alucontrol == `EXE_DIV_OP)? 1'b1 : 1'b0;
	div div(
		.clk(clk),
		.rst(rst),
		.signed_div_i(signed_div_i),
		.opdata1_i(a),
		.opdata2_i(b),
		.start_i(start_i),
		.annul_i(annul_i),
		.result_o(hilo_div),
		.ready_o(ready_o)
	);
	/*******************************乘法器控制信号*************************************/
	wire [63:0]mul_y;
	wire stall_mul, ready_mul, issign;
	wire valid, mult_res_ready, mult_res_valid;
	assign valid = (alucontrol==`EXE_MULT_OP)||(alucontrol==`EXE_MULTU_OP);
	assign mult_res_ready = 1'b1;
	assign issign = (alucontrol==`EXE_MULT_OP);
	mul_2 mul_2( 
		clk,rst,
        a,b,
        valid, issign,
        mul_y,
        flushM,flushM,
        stall_mul, mult_res_ready,
        mult_res_valid,ready_mul);
	
	/*******************************hilo寄存器使能、暂停信号控制*************************************/
	assign stall_div = (((alucontrol == `EXE_DIV_OP) |(alucontrol == `EXE_DIVU_OP))  & ~ready_o | 
						((alucontrol == `EXE_MULT_OP)|(alucontrol == `EXE_MULTU_OP)) & ~ready_mul)  
						& ~flushM;
	//使能
    wire hiloen1,hiloen2;
    assign hiloen1 = ready_mul;
    assign hiloen2 = ready_o; 
    assign hiloen  = hiloen1 | hiloen2 | hilo_en;
    assign hilo_i  = (alucontrol==`EXE_MULT_OP || alucontrol ==`EXE_MULTU_OP)? mul_y : 
	                 ((alucontrol==`EXE_DIV_OP  || alucontrol==`EXE_DIVU_OP)) & ready_o? hilo_div:hilo;
   
	assign zero = (y == 32'b0);
	
endmodule

 
