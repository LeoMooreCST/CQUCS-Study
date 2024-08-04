`timescale 1ns / 1ps
module mips(
	input wire clk,rst,
	//inst
	output wire inst_en,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//data
	output wire data_en,
	//output wire memwriteM,
	output wire [3:0] memenM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	//stall
	input inst_stall,
	input data_stall,
    output longest_stall,
	//debug
    output wire [31:0] debug_wb_pc,
    output wire [3 :0] debug_wb_rf_wen,
    output wire [4 :0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
    );
	//D阶段
	wire [5:0] opD,functD;
	wire [7:0]alucontrolD;
	wire [31:0] instrD;
	wire [4:0]rtBranch;
	wire pcsrcD,equalD,jumpD,jtoregD,jgetregD,stallD;
	wire isbreakD,syscallD,eretD,cp0renM,cp0wenM,reserveD;  //异常处理
	//E阶段
	wire [7:0]alucontrolE;
	wire regdstE,alusrcE,memtoregE,regwriteE,flushE,stallE;
	//M阶段
	wire [7:0]alucontrolM;
	wire memtoregM,regwriteM,flushM;
	//W阶段
	wire memtoregW,regwriteW,flushW;
	//数据使能信号
	assign data_en = (memtoregM | memwriteM) & (~flushM);
	controller c(
		clk, rst,
		/***Decode Stage***/
		//input
		instrD,opD,functD,rtBranch,stallD,
		//output
		pcsrcD,branchD,equalD,jumpD,jtoregD,jgetregD,
		isbreakD,syscallD,eretD,cp0renM,cp0wenM,reserveD,
		/***Execute Stage***/
		//input
		flushE,stallE,
		//output
		memtoregE,alusrcE,regdstE,regwriteE,
		alucontrolD,alucontrolE,
		/***Memory Stage***/
		//input
		flushM,
		//output
		memtoregM,memwriteM,regwriteM,alucontrolM,
		/***Write Back Stage***/
		//input
		flushW,
		//output
		memtoregW,regwriteW,
		//stall
		longest_stall
		);
	datapath dp(
		clk,rst,
		/***Fetch Stage***/
		//input
		instrF,
		//output
		pcF,inst_en,
		/***Decode Stage***/
		//input
		pcsrcD,branchD,jumpD,jtoregD,jgetregD,
		isbreakD,syscallD,eretD,cp0renM,cp0wenM,reserveD,
		//output
		stallD,equalD,opD,functD,instrD,rtBranch,
		/***Execute Stage***/
		//input
		memtoregE,alusrcE,regdstE,regwriteE,
		alucontrolD,alucontrolE,
		//output
		flushE,stallE,
		/***Memory Stage***/
		//input
		memtoregM,regwriteM,readdataM,alucontrolM,
		//output
		aluoutM,writedataM,memenM,flushM,
		/***Write Back Stage***/
		//input
		memtoregW,regwriteW,
		//output
		flushW,
		/***stall***/
		//input
		inst_stall,
		data_stall,
		//output
    	longest_stall,
		//debug
        debug_wb_pc,
        debug_wb_rf_wen,
        debug_wb_rf_wnum,
        debug_wb_rf_wdata
	);
	
endmodule
//25616526262626