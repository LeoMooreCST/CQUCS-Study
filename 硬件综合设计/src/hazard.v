`timescale 1ns / 1ps
module hazard(
	input wire stall_div,
	/***Fetch Stage***/
	output wire stallF,flushF,
	output wire[31:0] newPC,
	/***Decode Stage***/
	input wire[4:0] rsD,rtD,
	input wire branchD,jgetregD,
	output wire forwardaD_first,forwardbD_first,
	output wire forwardaD,forwardbD,
	output wire stallD,flushD,jrb_l_astall,jrb_l_bstall,
	/***Execute Stage***/
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,memtoregE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,stallE,
	/***Memory Stage***/
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
	input wire[31:0] excepttype_i, epc_o,
	output wire flushM,
	/***Write Back Stage***/
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire flushW,
	/***stall***/
	input wire inst_stall,
	input wire data_stall,
	//output
    output wire longest_stall
    );
    
    assign forwardaD_first = (rsD != 0 & rsD == writeregW & regwriteW);
    assign forwardbD_first = (rtD != 0 & rtD == writeregW & regwriteW);
	
	wire lwstallD,branchstallD,jgetregstall;

	/***数据前推***/
	//数据前推到D阶段(分支跳转指令)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	//数据前推到E阶段(ALU运算)
	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			if(rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;
			end
		end
	end
	//branch/jr时数据前�?
    assign jrb_l_astall = (jgetregD|branchD) && ((memtoregE && (writeregE==rsD)) || (memtoregM && (writeregM==rsD)));
	assign jrb_l_bstall = (jgetregD|branchD) && ((memtoregE && (writeregE==rtD)) || (memtoregM && (writeregM==rtD)));

	/***阻塞***/
	//stall
	assign longest_stall = inst_stall | data_stall | stall_div;
	assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	//branch分支跳转暂停
	assign branchstallD = branchD &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
	//j获取rs值暂�?
	assign jgetregstall = jgetregD && regwriteE && (writeregE==rsD);
	//D、E、F阶段暂停
    assign stallF = stallD;
	assign stallD = lwstallD | branchstallD | stall_div | jgetregstall | longest_stall;
	assign stallE = stall_div | longest_stall;

	/***流水线刷�?***/
	assign flushF = (excepttype_i == 32'b0)?1'b0:1'b1;
	assign flushD = (excepttype_i == 32'b0)?1'b0:1'b1;
	assign flushE = (lwstallD | branchstallD | jgetregstall) & ~longest_stall | (excepttype_i != 32'b0);
	assign flushM = (excepttype_i == 32'b0)?1'b0:1'b1;
	assign flushW = (excepttype_i == 32'b0)?1'b0:1'b1;

	/***例外处理返回PC***/
    assign newPC = (excepttype_i == 32'h0000_0001)? 32'hbfc00380:
                   (excepttype_i == 32'h0000_0004)? 32'hbfc00380:
                   (excepttype_i == 32'h0000_0005)? 32'hbfc00380:
                   (excepttype_i == 32'h0000_0008)? 32'hbfc00380:
                   (excepttype_i == 32'h0000_0009)? 32'hbfc00380:
                   (excepttype_i == 32'h0000_000a)? 32'hbfc00380:
                   (excepttype_i == 32'h0000_000c)? 32'hbfc00380:
                   (excepttype_i == 32'h0000_000e)? epc_o:
                   32'b0;
endmodule
