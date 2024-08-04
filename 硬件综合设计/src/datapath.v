`timescale 1ns / 1ps

module datapath(
	input wire clk,rst,
	/***Fetch Stage***/
	input wire[31:0] instrF,
	output wire[31:0] pcF,
	output inst_en,  
	/***Decode Stage***/
	input wire pcsrcD,branchD,jumpD,jtoregD,jgetregD,
	input wire isbreakD,syscallD,eretD,cp0renM,cp0wenM,reserveD,
	output wire stallD,equalD,
	output wire[5:0] opD,functD,
	output wire[31:0]instrD,
	output wire[4:0] rtBranch,
	/***Execute Stage***/
	input wire memtoregE,alusrcE,regdstE,regwriteE,
	input wire[7:0] alucontrolD,alucontrolE,
	output wire flushE,stallE,
	/***Memory Stage***/
	input wire memtoregM,regwriteM,
	input wire[31:0] readdataM,
	input wire [7:0] alucontrolM,
	output wire[31:0] aluoutMReal,writedataM,
	output wire [3:0] memenM,
	output wire flushM,
	/***Write Back Stage***/
	input wire memtoregW,regwriteW,
	output wire flushW,
	/***stall***/
	input wire inst_stall,
	input wire data_stall,
	//output
    output longest_stall,
	//debug
    output wire [31:0] debug_wb_pc,
    output wire [3 :0] debug_wb_rf_wen,
    output wire [4 :0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
    );
	
	//F阶段
	wire inst_reset;
	wire stallF,flushF,branchorjumpF;
	wire [31:0]newPC,pcplus4F;
	//D阶段
	wire [31:0] pcnextFD,pcnextbrFD,pcbranchD,pcJD1,pcJD2;
	wire [31:0] pcplus4D,pcplus8D;
	wire forwardaD,forwardbD;
	wire jrb_l_astall,jrb_l_bstall;
	wire flushD,branchorjumpD;
	wire [4:0] rsD,rtD,rdD;
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD1,srcbD1,srcaD,srca2D,srcbD,srcb2D,srca3D,srcb3D;
	wire [4:0] saD;
	wire [31:0]pcD;
	wire [6:0] exceptionD;
	wire forwardaD_first,forwardbD_first;
	//E阶段
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE, writeregE1;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE, aluoutEReal;
	wire [4:0] saE;
	wire stall_div;
	wire [31:0]pcE;
	wire jtoregE;   	 //跳转写回寄存器
	wire [31:0]pcplus8E;
	wire overflowE;
	wire branchorjumpE;
	wire [6:0]exceptionE;
	//hilo寄存器
	wire [63:0]hilo_i, hilo_o;
	wire hiloenE;
	//M阶段
	wire [4:0] writeregM;
	wire [4:0] rdM;
	wire [31:0] aluoutM;
    wire [31:0] writedatatmpM;
    wire [31:0] pcM;
	wire [31:0] srcb3M;
	//M阶段例外处理
	wire overflowM,branchorjumpM;
	wire adelM,adesM;    
	wire [6:0] exceptionM;
	wire [31:0] excepttype_i;
	wire [31:0] bad_addr_i;
	//cp0寄存器
	wire [31:0] cp0_data_o,status_o,cause_o,count_o,compare_o;
	wire [31:0] epc_o,config_o,prid_o,badvaddr;
	wire timer_int_o;
	//W�׶�
	wire adelW;
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
	wire [31:0]pcW;
	wire[31:0]lwresultW;
	wire[7:0]alucontrolW;
	wire flush_exceptionW;
	assign rtBranch = instrD[20:16];
	assign branchorjumpF = branchD | jumpD;

	//hazard detection
	hazard h(
		stall_div,
		/***Fetch Stage***/
		stallF,flushF,newPC,

		/***Decode Stage***/
		//input
		rsD,rtD,branchD,jgetregD,
	    forwardaD_first,forwardbD_first,
		//output
		forwardaD,forwardbD,
		stallD,flushD,jrb_l_astall,jrb_l_bstall,

		/***Execute Stage***/
		//input
		rsE,rtE,writeregE,regwriteE,memtoregE,
		//output
		forwardaE,forwardbE,flushE,stallE,

		/***Memory Stage***/
		//input
		writeregM,regwriteM,memtoregM,
		excepttype_i,epc_o,
		//output
		flushM,
		
		/***Write Back Stage***/
		writeregW,regwriteW,
		flushW,

		/***stall***/
		inst_stall,
		data_stall,
		//output
    	longest_stall
		);

	/***Fetch Stage***/
	pc #(32) pcreg(clk,rst,(~stallF & ~longest_stall), flushF,pcnextFD,newPC,pcF,inst_reset);
	assign inst_en = (pcF[1:0] == 2'b00) & (inst_reset) & (~flushF);

	adder pcadd1(pcF,32'b100,pcplus4F);   //pc+4
	//ѡ����תpc��Դ
	mux2 #(32) pcmux1(
		{pcplus4D[31:28],instrD[25:0],2'b00},
		srca3D,
		jgetregD,
		pcJD1
	);
	//�Ƿ�ΪJ��תָ��
	mux2 #(32) pcmux2(
		pcplus4F,
		pcJD1,
		jumpD,
		pcJD2
	);
	//�Ƿ�Ϊbranch��֧��תָ��
	mux2 #(32) pcumx3(
		pcJD2,
		pcbranchD,
		pcsrcD,
		pcnextFD
	);

	//�Ĵ�����
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD1,srcbD1);
	mux2 #(32) mux_da(srcaD1, resultW, forwardaD_first, srcaD);
	mux2 #(32) mux_db(srcbD1, resultW, forwardbD_first, srcbD);
	

	/***Decode Stage***/
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
	//���⣺syscallD, isbreakD,reserveD,eretD
	assign exceptionD[4:1] = {syscallD,isbreakD,reserveD,eretD};
	flopenrc #(32) r1D(clk,rst,(~stallD & ~longest_stall) | flushD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,(~stallD & ~longest_stall) | flushD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,(~stallD & ~longest_stall) | flushD,flushD,pcF,pcD);
	flopenrc #(1)  r4D(clk,rst,(~stallD & ~longest_stall) | flushD,flushD,branchorjumpF,branchorjumpD);
	//����instrD[29:28]������չ,Ϊ2'b11ʱ��������չ,�����Ϊ����λ��չ
	signext dec_signext(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);              //signimmD������λ
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	adder pcadd3(pcplus4D,32'b100,pcplus8D);     //jal
	//����ǰ��
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	//branchָ���ж�����ǰ��
	mux2 #(32) forwardbjrb_lamux(srca2D,readdataM,jrb_l_astall,srca3D);
	mux2 #(32) forwardbjrb_lbmux(srcb2D,readdataM,jrb_l_bstall,srcb3D);
	//beq,bgz,blet,bne,bltz,bltzal,bgez,bgezal
	eqcmp comp(srca3D,srcb3D,alucontrolD,equalD);   
	
	/***Execute Stage***/
	flopenrc #(32) r1E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),signimmD,signimmE);
	flopenrc #(5)  r4E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),rsD,rsE);
	flopenrc #(5)  r5E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),rtD,rtE);
	flopenrc #(5)  r6E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),rdD,rdE);
	flopenrc #(5)  r7E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),saD,saE);
	flopenrc #(32) r8E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),pcD,pcE);
	//��֧��תָ��д�ؼĴ���
	flopenrc #(1)  r9E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),jtoregD,jtoregE);
	flopenrc #(32) r10E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),pcplus8D,pcplus8E);
	flopenrc #(4)  r11E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),exceptionD[4:1],exceptionE[4:1]);  //����
	flopenrc #(1)  r12E(clk,rst,(~stallE & ~longest_stall),flushE & (~longest_stall | flushM),branchorjumpD,branchorjumpE);     //cp0�Ĵ�������
	//����ǰ��
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);

	//alu
	alu alu(
		.clk(clk),
		.rst(rst|flushE),
		.flushM(flushM),
		.a(srca2E),
		.b(srcb3E),
		.alucontrol(alucontrolE),
		.sa(saE),
		.hilo_i(hilo_i),
		.hilo_o(hilo_o),
		.hiloen(hiloenE),
		.stall_div(stall_div),
		.y(aluoutE),
		.overflow(overflowE)
		);
	assign exceptionE[0] = overflowE;              //�������
	mux2 #(32) aluoutmux(
		aluoutE,
		pcplus8E,
		jtoregE,
		aluoutEReal
	);                                             //д�ؼĴ�������alu���㻹�Ƿ�֧��תָ���ַ
	mux2 #(5) wrmux1(rtE,rdE,regdstE,writeregE1);  //��regDstE�ź��ж�
	mux2 #(5) wrmux2(
		writeregE1,
		5'b11111,
		((alucontrolE==`EXE_JAL_OP) | (alucontrolE==`EXE_BGEZAL_OP) | (alucontrolE==`EXE_BLTZAL_OP)),
		writeregE
	);                                            //jal,bgezal,bltzal
	//hilo寄存器
	hilo_reg hilorf(
		.clk(clk), 
		.rst(rst),
		.flushE(flushE),
		.we(hiloenE & ~longest_stall),
		.hi_i(hilo_i[63:32]),
		.lo_i(hilo_i[31:0]),
		.hi_o(hilo_o[63:32]),
		.lo_o(hilo_o[31:0])
    );

	/***Memory Stage***/
	flopenrc #(32) r1M(clk,rst,~longest_stall,flushM,srcb2E,writedatatmpM);
	flopenrc #(32) r2M(clk,rst,~longest_stall,flushM,aluoutEReal,aluoutMReal);
	flopenrc #(5)  r3M(clk,rst,~longest_stall,flushM,writeregE,writeregM);
	flopenrc #(32) r4M(clk,rst,~longest_stall,flushM,pcE,pcM);
	flopenrc #(5)  r5M(clk,rst,~longest_stall,flushM,exceptionE[4:0],exceptionM[4:0]);  
	flopenrc #(5)  r6M(clk,rst,~longest_stall,flushM,rdE,rdM);                           
	flopenrc #(32) r7M(clk,rst,~longest_stall,flushM,srcb3E,srcb3M);                    //cp0寄存器src3bM
	flopenrc #(1)  r8M(clk,rst,~longest_stall,flushM,branchorjumpE,branchorjumpM);
	mux2 #(32) cp0rmux(aluoutMReal,cp0_data_o,cp0renM,aluoutM);       

	//判断访存地址错例外
	judge_addrexcept adrr_ecept(
		.alucontrolM(alucontrolM),
    	.aluoutM(aluoutM),
    	.adelM(adelM),   
    	.adesM(adesM)   
	);
	assign exceptionM[6:5] = {adelM, adesM};

	sw_trans swtransM(adesM, alucontrolM, aluoutMReal, writedatatmpM, writedataM, memenM);
	lw_trans lwtransM(adelW, lwresultW, aluoutW, alucontrolW, resultW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,lwresultW);

	/***Write Back Stage***/
	flopenrc #(32) r1W(clk,rst,~longest_stall,flushW,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~longest_stall,flushW,readdataM,readdataW);
	flopenrc #(5)  r3W(clk,rst,~longest_stall,flushW,writeregM,writeregW);
	flopenrc #(32) r4W(clk,rst,~longest_stall,flushW,pcM,pcW);
	flopenrc #(8)  r5W(clk,rst,~longest_stall,flushW,alucontrolM,alucontrolW);
	flopenrc #(1)  r6W(clk,rst,~longest_stall,flushW,adelM,adelW);
	flopr #(1)r11W(clk,rst,flushM,flush_exceptionW);

	//CP0寄存器
	cp0_reg cp0(
		.clk(clk),  
		.rst(rst),
		.en(flushM),
		.we_i(cp0wenM & ~longest_stall),
		.waddr_i(rdM),
		.raddr_i(rdM),
		.data_i(srcb3M),
		.int_i(0),
		.excepttype_i(excepttype_i),
		.current_inst_addr_i(pcM),
		.is_in_delayslot_i(branchorjumpM),
		.bad_addr_i(bad_addr_i),
		.data_o(cp0_data_o),
		.count_o(count_o),
		.compare_o(compare_o),
		.status_o(status_o),
		.cause_o(cause_o),
		.epc_o(epc_o),
		.config_o(config_o),
		.prid_o(prid_o),
		.badvaddr(badvaddr),
		.timer_int_o(timer_int_o)
	);

	//判断异常类型
	except_type extype(
		.rst(rst),
		.pcM(pcM),
		.exceptionM(exceptionM),
		.status_o(status_o),
		.cause_o(cause_o),
		.aluoutM(aluoutM),
		.excepttype_i(excepttype_i),
		.bad_addr(bad_addr_i)
		);

	//debug信号
    assign debug_wb_pc          = pcW;
	assign debug_wb_rf_wen      = {4{regwriteW & ~flush_exceptionW & ~longest_stall}};
    assign debug_wb_rf_wnum     = writeregW;
    assign debug_wb_rf_wdata    = resultW;
endmodule
