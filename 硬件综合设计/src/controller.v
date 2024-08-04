`timescale 1ns / 1ps
/**
	@brief: maindec、aludec和暂停信号
-->input:
	@param 
	@param 
	@param 
	@param 
-->output:
	@param 
*/
module controller(
	input wire clk,rst,
	/***Decode Stage***/
	input wire[31:0] instrD,
	input wire[5:0] opD,functD,
	input wire[4:0]rtBranch,
	input wire stallD,
	output wire pcsrcD,branchD,equalD,jumpD,jtoregD,jgetregD,
	output wire isbreakD,syscallD, eretD,cp0renM,cp0wenM,reserveD,
	/***Execute Stage***/
	input wire flushE,stallE,
	output wire memtoregE,alusrcE,regdstE,regwriteE,	
	output wire[7:0] alucontrolD,alucontrolE,
	/***Memory Stage***/
	input wire flushM,
	output wire memtoregM,memwriteM,regwriteM,
	output wire [7:0]alucontrolM,
	/***Write Back Stage***/
	input wire flushW,
	output wire memtoregW,regwriteW,
	/***stall***/
	input wire longest_stall
    );
	//D阶段
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD,cp0renD,cp0wenD;
	//E阶段
	wire memwriteE,cp0renE,cp0wenE;
	assign pcsrcD = branchD & equalD;
	maindec md(
		.instrD(instrD),
		.op(opD),
		.funct(functD),
		.rtBranch(rtBranch),
		.memtoreg(memtoregD),
		.memwrite(memwriteD),
		.branch(branchD),
		.alusrc(alusrcD),
		.regdst(regdstD),
		.regwrite(regwriteD),
		.jump(jumpD),
		.jtoreg(jtoregD),
		.jgetreg(jgetregD),
		.isbreak(isbreakD),
		.syscall(syscallD),
		.eret(eretD),
		.cp0ren(cp0renD),
		.cp0wen(cp0wenD),
		.reserve(reserveD)
		);
	aludec ad(
		.funct(functD),
		.op(opD),
		.rtBranch(rtBranch),
		.alucontrol(alucontrolD)
	);
	
	flopenrc #(32) regE(
		clk,rst,~stallE, (flushE & ~longest_stall), 
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,cp0renD,cp0wenD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,cp0renE,cp0wenE}
	);
	flopenrc #(32) regM(
		clk,rst,~longest_stall,flushM,
		{memtoregE,memwriteE,regwriteE,alucontrolE,cp0renE,cp0wenE},
		{memtoregM,memwriteM,regwriteM,alucontrolM,cp0renM,cp0wenM}
	);
	flopenrc #(8) regW(
		clk,rst,~longest_stall,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
	);
endmodule
