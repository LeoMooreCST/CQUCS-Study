module mycpu_top(
    input [5:0] ext_int,
    input aclk,
    input aresetn,  //low active
     //axi
    //ar读地址通道
    output [3 :0] arid         ,  //读事务id,可以直接置为0
    output [31:0] araddr       ,  //读请求的最低字节地址
    output [3 :0] arlen        ,  //读请求的burst长度,一次传输中进行的burst数量，从0开始计数
    output [2 :0] arsize       ,  //读请求的数据大小,000为单字节,001为半字, 010为整字 
    output [1 :0] arburst      ,  //busrt类型,实验中置为2'b01即可
    output [1 :0] arlock       ,  //加锁信号,置为0
    output [3 :0] arcache      ,  //cache类型,置为0
    output [2 :0] arprot       , //保护信号,置为0
    output        arvalid      , //读数据地址有效信号，Master 端通过拉高该信号来发起一次写事务，该信号拉高表示 Master 端已将有效的请求参数（地址，burst 长度等）送到相应的端口上
    input         arready      , //读数据地址就绪信号，表示 Slave 端已经准备好接受写事务的相关参数，在 AWVALID 和 AWREADY 同时为高的时钟上升沿，事务参数（地址，burst 长度等）的传输即发生
    //读数据操作         
    input  [3 :0] rid          , //读事务的id
    input  [31:0] rdata        , //读事务的数据
    input  [1 :0] rresp        , //
    input         rlast        , //burst传输的结束信号
    input         rvalid       , //读有效信号,表示当前slave已经将有效数据送到RDATA上
    output        rready       , //读就绪信号
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [3 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w写数据通道       
    output [3 :0] wid          ,  //写事务id置为0
    output [31:0] wdata        ,  //写事务数据   
    output [3 :0] wstrb        ,  //写字节使能,最低位为低字节,高位为高字节
    output        wlast        ,  //最后一个burst标志信号
    output        wvalid       ,  //写有效信号,当前，master已经将有效数据送到WADATA上
    input         wready       ,  //写就绪信号,slave端准备好接受写入数据时
    //b写响应通道           
    input  [3 :0] bid          ,  //写事务响应的id,可忽略
    input  [1 :0] bresp        ,  //写事务的响应
    input         bvalid       ,  //写响应有效信号
    output        bready       ,  //写响应就绪信号，当 Master 端准备好接受写响应时，将该信号拉高
    // //cpu inst sram
    // output        inst_sram_en   ,
    // output [3 :0] inst_sram_wen  ,
    // output [31:0] inst_sram_addr ,
    // output [31:0] inst_sram_wdata,
    // input  [31:0] inst_sram_rdata,
    // //cpu data sram
    // output        data_sram_en   ,
    // output [3 :0] data_sram_wen  ,
    // output [31:0] data_sram_addr ,
    // output [31:0] data_sram_wdata,
    // input  [31:0] data_sram_rdata,
    //debug
    output wire [31:0] debug_wb_pc,
    output wire [3 :0] debug_wb_rf_wen,
    output wire [4 :0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);


	wire [31:0] pc;
	wire [31:0] instr;
    wire [3:0] memen;
	wire memwrite;
	wire [31:0] aluout, writedata, readdata;
    //物理地址
    wire [31:0] inst_paddr, data_paddr;
    wire no_dcache;


    /***cpu_axi_interface variables***/
    //inst_sram_like
    wire inst_req;
    wire inst_wr;
    wire [1: 0] inst_size;
    wire [31:0] inst_addr;
    wire [31:0] inst_wdata;
    wire [31:0] inst_rdata;
    wire inst_addr_ok;
    wire inst_data_ok;
    //data sram-like
    wire data_req;
    wire data_wr;
    wire [1: 0] data_size;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;
    wire data_addr_ok;
    wire data_data_ok;
    //inst和data使能信号
    wire inst_en, data_en;
    //inst和data的阻塞信号
    wire inst_stall, data_stall, longest_stall;

    /***cache interface variables***/
    wire        cache_data_req  ;
    wire [31:0] cache_data_addr ;
    wire        cache_data_wr   ;
    wire [1:0]  cache_data_size ;
    wire [31:0] cache_data_wdata;
    wire [31:0] cache_data_rdata;
    wire        cache_data_addr_ok;
    wire        cache_data_data_ok;

    wire        cpu_data_req  ;
    wire [31:0] cpu_data_addr ;
    wire        cpu_data_wr   ;
    wire [1:0]  cpu_data_size ;
    wire [31:0] cpu_data_wdata;
    wire [31:0] cpu_data_rdata;
    wire        cpu_data_addr_ok;
    wire        cpu_data_data_ok;

    wire        ram_data_req  ;
    wire [31:0] ram_data_addr ;
    wire        ram_data_wr   ;
    wire [1:0]  ram_data_size ;
    wire [31:0] ram_data_wdata;
    wire [31:0] ram_data_rdata;
    wire        ram_data_addr_ok;
    wire        ram_data_data_ok;

    wire        conf_data_req  ;
    wire [31:0] conf_data_addr ;
    wire        conf_data_wr   ;
    wire [1:0]  conf_data_size ;
    wire [31:0] conf_data_wdata;
    wire [31:0] conf_data_rdata;
    wire        conf_data_addr_ok;
    wire        conf_data_data_ok;
    

    wire        wrap_data_req  ;
    wire [31:0] wrap_data_addr ;
    wire        wrap_data_wr   ;
    wire [1:0]  wrap_data_size ;
    wire [31:0] wrap_data_wdata;
    wire [31:0] wrap_data_rdata;
    wire        wrap_data_addr_ok;
    wire        wrap_data_data_ok;

    wire clk, rst;
    assign clk = aclk;
    assign rst = ~aresetn;
//    wire [31:0]data_sram_rdata;


 mips mips(
        .clk(clk),
        .rst(rst),
        //instr
        .inst_en(inst_en),
        .pcF(pc),                    //pcF
        .instrF(instr),              //instrF
        //data
        .data_en(data_en),
        .memenM(memen),
        .aluoutM(data_addr),
        .writedataM(writedata),
        .readdataM(data_sram_rdata),
        
        .inst_stall(inst_stall),
        .data_stall(data_stall),
        .longest_stall(longest_stall),
        
        .debug_wb_pc       (debug_wb_pc       ),  
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),  
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),  
        .debug_wb_rf_wdata (debug_wb_rf_wdata )  
    );
    

    //虚拟地址 ---> 物理地址
    mmu mmu0(
        .inst_vaddr(pc),
        .inst_paddr(inst_paddr),
        .data_vaddr(data_addr),
        .data_paddr(data_paddr),
        .no_dcache(no_dcache)
    );
    
       /***************************i_cache***********************************/    
    my_i_cache my_i_cache(
        .clk(clk), .rst(rst),
        //与cpu的握手信号
        //input
        .cpu_inst_req     (inst_en     ),
        .cpu_inst_addr    (inst_paddr    ),
        .longest_stall    (longest_stall),
        //output
        .cpu_inst_rdata   (instr   ),
        .i_stall          (inst_stall),

        //与主存的握手信号
        //cache ---> 主存   output
        .araddr(i_araddr),              //Cache向主存发起读请求时所使用的地址
        .arvalid(i_arvalid),            //Cache向主存发起读请求的请求信号
        //主存 ---> cache   input
        .arready(i_arready),            //读请求能否被接收的握手信号
        .rdata(i_rdata),                //主存向Cache返回的数据
        .rlast(i_rlast),                //是否是主存向Cache返回的最后一个数据
        .rvalid(i_rvalid),              //主存向Cache返回数据时的数据有效信号
        //cache ---> 主存    output
        .rready(i_rready),              //标识当前的Cache已经准备好可以接收主存返回的数据  
        .arlen(i_arlen)
    );
     wire        data_sram_en   ;
     wire [3 :0] data_sram_wen  ;
     wire [31:0] data_sram_addr ;
     wire [31:0] data_sram_wdata;
     wire [31:0] data_sram_rdata;
     assign data_sram_en=data_en;
     assign data_sram_wen=memen;
     assign data_sram_addr=data_paddr;
     assign data_sram_wdata=writedata;


d_sram_to_sram_like d_sram_to_sram_like(
    .clk(clk), .rst(rst),
    //sram
    .data_sram_en(data_sram_en),
    .data_sram_addr(data_sram_addr),
    .data_sram_rdata(data_sram_rdata),
    .data_sram_wen(data_sram_wen),
    .data_sram_wdata(data_sram_wdata),
    .d_stall(data_stall),

    //sram like
        //output
        .data_req(cpu_data_req),                //数据操作请求
        .data_wr(cpu_data_wr),                  //是否为写数据
        .data_size(cpu_data_size),              //根据memen确定操作的数据的大小
        .data_addr(cpu_data_addr),              //操作数据的地址--->aluout
        .data_wdata(cpu_data_wdata),            //写入的数据(writedata)
        //input
        .data_rdata(cpu_data_rdata),           //放置传输的数据(读出)
        .data_addr_ok(cpu_data_addr_ok),       //地址准备就绪
        .data_data_ok(cpu_data_data_ok),      //数据准备就绪
        .longest_stall(longest_stall)
);

    bridge_1x2 bridge_1x2(
        //input
        .no_dcache        (no_dcache    ),

        .cpu_data_req     (cpu_data_req  ),
        .cpu_data_wr      (cpu_data_wr   ),
        .cpu_data_size    (cpu_data_size ),
        .cpu_data_addr    (cpu_data_addr ),    //paddr
        .cpu_data_wdata   (cpu_data_wdata),
        //output
        .cpu_data_rdata   (cpu_data_rdata),
        .cpu_data_addr_ok (cpu_data_addr_ok),
        .cpu_data_data_ok (cpu_data_data_ok),

        //output    过cache的
        .ram_data_req     (ram_data_req  ),    
        .ram_data_wr      (ram_data_wr   ),
        .ram_data_size    (ram_data_size ),
        .ram_data_addr    (ram_data_addr ),
        .ram_data_wdata   (ram_data_wdata),
        //input
        .ram_data_rdata   (ram_data_rdata),
        .ram_data_addr_ok (ram_data_addr_ok),
        .ram_data_data_ok (ram_data_data_ok),

        //output  不过cache的
        .conf_data_req     (conf_data_req  ),
        .conf_data_wr      (conf_data_wr   ),
        .conf_data_size    (conf_data_size ),
        .conf_data_addr    (conf_data_addr ),
        .conf_data_wdata   (conf_data_wdata),
        //input
        .conf_data_rdata   (conf_data_rdata),
        .conf_data_addr_ok (conf_data_addr_ok),
        .conf_data_data_ok (conf_data_data_ok)
    );

     wire [31:0] i_araddr;  // 指令读地址
     wire [3:0] i_arlen;    // 指令读传输长度
     wire i_arvalid;        // 指令读地址有效
     wire i_arready;       // 指令读准备好

    // 指令缓存读数据
     wire [31:0] i_rdata;   // 指令读数据
     wire i_rlast;          // 读传输的最后一个节拍指示
     wire i_rvalid;         // 指令读数据有效
     wire i_rready;          // 指令读数据消费者准备好

    
    
        d_cache d_cache(
        .clk(clk), .rst(rst),
        .cpu_data_req     (ram_data_req     ),
        .cpu_data_wr      (ram_data_wr      ),
        .cpu_data_size    (ram_data_size    ),
        .cpu_data_addr    (ram_data_addr    ),
        .cpu_data_wdata   (ram_data_wdata   ),
        .cpu_data_rdata   (ram_data_rdata   ),
        .cpu_data_addr_ok (ram_data_addr_ok ),
        .cpu_data_data_ok (ram_data_data_ok ),
    
        .cache_data_req     (cache_data_req     ),
        .cache_data_wr      (cache_data_wr      ),
        .cache_data_size    (cache_data_size    ),
        .cache_data_addr    (cache_data_addr    ),
        .cache_data_wdata   (cache_data_wdata   ),
        .cache_data_rdata   (cache_data_rdata   ),
        .cache_data_addr_ok (cache_data_addr_ok ),
        .cache_data_data_ok (cache_data_data_ok )
    );
    

    //根据是否经过Cache，将信号合为一路
    bridge_2x1 bridge_2x1(
        .no_dcache        (no_dcache    ),

        .ram_data_req     (cache_data_req  ),
        .ram_data_wr      (cache_data_wr   ),
        .ram_data_addr    (cache_data_addr ),
        .ram_data_wdata   (cache_data_wdata),
        .ram_data_size    (cache_data_size ),
        .ram_data_rdata   (cache_data_rdata),
        .ram_data_addr_ok (cache_data_addr_ok),
        .ram_data_data_ok (cache_data_data_ok),

        .conf_data_req     (conf_data_req  ),
        .conf_data_wr      (conf_data_wr   ),
        .conf_data_addr    (conf_data_addr ),
        .conf_data_wdata   (conf_data_wdata),
        .conf_data_size    (conf_data_size ),
        .conf_data_rdata   (conf_data_rdata),
        .conf_data_addr_ok (conf_data_addr_ok),
        .conf_data_data_ok (conf_data_data_ok),

        .wrap_data_req     (wrap_data_req  ),
        .wrap_data_wr      (wrap_data_wr   ),
        .wrap_data_addr    (wrap_data_addr ),
        .wrap_data_wdata   (wrap_data_wdata),
        .wrap_data_size    (wrap_data_size ),
        .wrap_data_rdata   (wrap_data_rdata),
        .wrap_data_addr_ok (wrap_data_addr_ok),
        .wrap_data_data_ok (wrap_data_data_ok)
    );
    
        // 数据缓存（D CACHE）读地址
     wire [31:0] d_araddr;   // 数据读地址
     wire [3:0] d_arlen;     // 数据读传输长度
     wire [2:0] d_arsize;    // 数据读传输字节大小
     wire d_arvalid;         // 数据读地址有效
     wire d_arready;        // 数据读准备好

    // 数据缓存读数据
     wire [31:0] d_rdata;   // 数据读数据
     wire d_rlast;          // 读传输的最后一个节拍指示
     wire d_rvalid;         // 数据读数据有效
     wire d_rready;          // 数据读数据消费者准备好

    // 数据缓存写地址
     wire [31:0] d_awaddr;   // 数据写地址
     wire [3:0] d_awlen;     // 数据写传输长度
     wire [2:0] d_awsize;    // 数据写传输字节大小
     wire d_awvalid;         // 数据写地址有效
     wire d_awready;        // 数据写准备好

    // 数据缓存写数据
     wire [31:0] d_wdata;    // 数据写数据
     wire [3:0] d_wstrb;     // 写数据掩码（字节使能）
     wire d_wlast;           // 写传输的最后一个节拍指示
     wire d_wvalid;          // 数据写数据有效
     wire d_wready;        // 数据写数据消费者准备好

    // 数据缓存写响应
     wire d_bvalid;         // 数据写响应有效
     wire d_bready;         // 数据写响应消费者准备好

wire [31:0]tmp;
assign tmp=32'b0;
wire [31:0]tmp1;
wire tmp2;
wire tmp3;
cpu_axi_interface cpu_axi_interface
(
             .clk(clk),
             .resetn(~rst), 

    //inst sram-like 
             .inst_req(tmp)     ,
             .inst_wr(tmp)      ,
             .inst_size(tmp)    ,
             .inst_addr(tmp)    ,
             .inst_wdata (tmp)  ,
             .inst_rdata(tmp1)   ,
             .inst_addr_ok(tmp2) ,
             .inst_data_ok(tmp3) ,
    
    //data sram-like 
    .data_req(wrap_data_req)    ,
    .data_wr(wrap_data_wr)      ,
    .data_size(wrap_data_size)    ,
    .data_addr(wrap_data_addr)    ,
    .data_wdata(wrap_data_wdata)   ,
    .data_rdata(wrap_data_rdata)   ,
    .data_addr_ok(wrap_data_addr_ok) ,
    .data_data_ok(wrap_data_data_ok) ,

     // 数据缓存（D CACHE）读地址
    .araddr(d_araddr),   // 数据读地址
    .arlen(d_arlen),     // 数据读传输长度
    .arsize(d_arsize),    // 数据读传输字节大小
    .arvalid(d_arvalid),         // 数据读地址有效
    .arready(d_arready),        // 数据读准备好

    // 数据缓存读数据
    .rdata(d_rdata),   // 数据读数据
    .rlast(d_rlast),          // 读传输的最后一个节拍指示
    .rvalid(d_rvalid),         // 数据读数据有效
    .rready(d_rready),          // 数据读数据消费者准备好

    // 数据缓存写地址
    .awaddr(d_awaddr),   // 数据写地址
    .awlen(d_awlen),     // 数据写传输长度
    .awsize(d_awsize),    // 数据写传输字节大小
    .awvalid(d_awvalid),         // 数据写地址有效
    .awready(d_awready),        // 数据写准备好

    // 数据缓存写数据
    .wdata(d_wdata),    // 数据写数据
    .wstrb(d_wstrb),     // 写数据掩码（字节使能）
    .wlast(d_wlast),           // 写传输的最后一个节拍指示
    .wvalid(d_wvalid),          // 数据写数据有效
    .wready(d_wready),         // 数据写数据消费者准备好

    // 数据缓存写响应
    .bvalid(d_bvalid),         // 数据写响应有效
    .bready(d_bready)          // 数据写响应消费者准备好
);

arbitrater arbitrater (
    // 时钟和复位
    .clk(clk), .rst(rst),

    // 指令缓存（I CACHE）读地址
    .i_araddr(i_araddr),  // 指令读地址
    . i_arlen(i_arlen),    // 指令读传输长度
    . i_arvalid(i_arvalid),        // 指令读地址有效
    . i_arready(i_arready),       // 指令读准备好

    // 指令缓存读数据
    .i_rdata(i_rdata),   // 指令读数据
    .i_rlast(i_rlast),          // 读传输的最后一个节拍指示
    .i_rvalid(i_rvalid),         // 指令读数据有效
    . i_rready(i_rready),          // 指令读数据消费者准备好

    // 数据缓存（D CACHE）读地址
    . d_araddr(d_araddr),   // 数据读地址
    . d_arlen(d_arlen),     // 数据读传输长度
    . d_arsize(d_arsize),    // 数据读传输字节大小
    . d_arvalid(d_arvalid),         // 数据读地址有效
    . d_arready(d_arready),        // 数据读准备好

    // 数据缓存读数据
   . d_rdata(d_rdata),   // 数据读数据
    .d_rlast(d_rlast),          // 读传输的最后一个节拍指示
    . d_rvalid(d_rvalid),         // 数据读数据有效
    . d_rready(d_rready),          // 数据读数据消费者准备好

    // 数据缓存写地址
    . d_awaddr(d_awaddr),   // 数据写地址
    . d_awlen(d_awlen),     // 数据写传输长度
    . d_awsize(d_awsize),    // 数据写传输字节大小
    . d_awvalid(d_awvalid),         // 数据写地址有效
    . d_awready(d_awready),        // 数据写准备好

    // 数据缓存写数据
    . d_wdata(d_wdata),    // 数据写数据
    . d_wstrb(d_wstrb),     // 写数据掩码（字节使能）
    . d_wlast(d_wlast),           // 写传输的最后一个节拍指示
    . d_wvalid(d_wvalid),          // 数据写数据有效
    . d_wready(d_wready),         // 数据写数据消费者准备好

    // 数据缓存写响应
    . d_bvalid(d_bvalid),         // 数据写响应有效
    . d_bready(d_bready),          // 数据写响应消费者准备好

    // 外部接口
    . arid(arid),
    . araddr(araddr),
    . arlen(arlen),
   . arsize(arsize),
    . arburst(arburst),
    . arlock(arlock),
    .arcache(arcache),
   . arprot(arprot),
    . arvalid(arvalid),
   . arready(arready),
                
    . rid(rid),
    . rdata(rdata),
    . rresp(rresp),
    . rlast(rlast),
    . rvalid(rvalid),
    . rready(rready),
               
    . awid(awid),
    . awaddr(awaddr),
    . awlen(awlen),
    . awsize(awsize),
    . awburst(awburst),
    . awlock(awlock),
    . awcache(awcache),
    . awprot(awprot),
    . awvalid(awvalid),
    . awready(awready),
    
    . wid(wid),
    . wdata(wdata),
    . wstrb(wstrb),
    . wlast(wlast),
    . wvalid(wvalid),
    . wready(wready),
    
    . bid(bid),
    . bresp(bresp),
    . bvalid(bvalid),
    . bready(bready)
);


    
endmodule