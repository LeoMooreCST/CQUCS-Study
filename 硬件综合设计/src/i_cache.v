module my_i_cache (
    input wire clk, rst,
    // MIPS核心
    input              cpu_inst_req     ,   //指令使能信号
    input       [31:0] cpu_inst_addr    ,   //指令地址
    input wire longest_stall,              
    output wire [31:0] cpu_inst_rdata   ,
    output wire i_stall, //i指令阻塞信号

    // 仲裁器
    output wire [31:0] araddr,  //读请求的最低字节的地址
    output wire [3:0] arlen,  //读请求的 burst 长度，这个量表示在一次传输中进行的 burst 数量，注意 ARLEN 为0时表示进行一次 burst，以此类推
    output wire arvalid,  //读数据地址有效信号，Master 端通过拉高该信号来发起一次读事务，该信号拉高表示 Master 端已将有效的请求参数（地址，burst 长度等）送到相应的端口上
    input wire arready,  //读数据地址就绪信号，表示 Slave 端已经准备好接受读事务的相关参数，在 AWVALID 和 AWREADY 同时为高的时钟上升沿，事务参数（地址，burst 长度等）的传输即发生

    input wire [31:0] rdata,  //读事务的数据
    input wire rlast,       // 最后一个数据
    input wire rvalid,    //  读有效信号，表示当前 Slave 已经将有效数据送到 RDATA 上
    output wire rready  //   读就绪信号，当 Master 端准备好接受读入数据时，拉高该端口，当 RVALID 和 RREADY 均为高的时钟上升沿到来时，数据传输即进行
);

// 参数
parameter INDEX_WIDTH     = 7; // 根据需要设置INDEX_WIDTH
parameter NUM_BLOCKS      = 2**INDEX_WIDTH;
parameter BLOCK_SIZE      = 8; // 每个块8字节
parameter CACHE_SIZE      = NUM_BLOCKS * BLOCK_SIZE;
parameter OFFSET_WIDTH    = 3 + 2;
parameter TAG_WIDTH       = 32 - INDEX_WIDTH - OFFSET_WIDTH;
parameter BLOCK_NUM       = 32*8;

    // 内部信号
    reg [BLOCK_NUM-1:0] cache [0:NUM_BLOCKS-1];
    reg [TAG_WIDTH-1:0] tag [0:NUM_BLOCKS-1];
    reg valid [0:NUM_BLOCKS-1];
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag_in;
    wire [BLOCK_NUM-1:0] cpu_inst_rdata_block;
    integer read_cnt;
    reg [31:0] read_word [0:BLOCK_SIZE-1];
    wire [BLOCK_NUM-1:0] temp_read_block;
    wire [2:0]offset_idx;
    wire hit,miss;
    assign temp_read_block = {read_word[7], read_word[6], read_word[5], read_word[4], read_word[3], read_word[2], read_word[1], read_word[0]};

    assign cpu_inst_rdata = (~cpu_inst_req)?32'b0:
                            (offset_idx==3'b000)? cpu_inst_rdata_block[31:0]:
                            (offset_idx==3'b001)? cpu_inst_rdata_block[63:32]:
                            (offset_idx==3'b010)? cpu_inst_rdata_block[95:64]:
                            (offset_idx==3'b011)? cpu_inst_rdata_block[127:96]:
                            (offset_idx==3'b100)? cpu_inst_rdata_block[159:128]:
                            (offset_idx==3'b101)? cpu_inst_rdata_block[191:160]:
                            (offset_idx==3'b110)? cpu_inst_rdata_block[223:192]: cpu_inst_rdata_block[255:224];
                            

    // 状态机状态
    parameter IDLE = 2'b000;
    parameter MISS = 2'b001;
    parameter FILL  = 2'b011;
    parameter END_FILL  = 3'b111;



    reg [2:0] state;

    // 输出信号
    assign araddr ={cpu_inst_addr[31:5], 5'd0}; // no_icache ? cpu_inst_addr : {cpu_inst_addr[31:5], 5'd0};
    assign arlen  =  BLOCK_SIZE - 1;// no_icache ? 4'b0: BLOCK_SIZE - 1;
    assign arvalid = (state == MISS);
    assign rready  = (state == FILL);
    assign hit = cpu_inst_req & (tag[index] == tag_in) & (valid[index]==1)? 1 : 0;
    assign miss = ~hit;
    assign cpu_inst_rdata_block = (state==IDLE && hit)? cache[index] :
                                (state==END_FILL)? temp_read_block:260'b0;


    integer t;
    // 缓存读取逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for(t=0; t<NUM_BLOCKS; t=t+1) begin   //鍒氬紑濮嬪皢Cache缃负鏃犳晥
                    valid[t] <= 0;
                    tag[t] <= 32'b0;
                    cache[t] <= 260'b0;
            end
            // 复位逻辑
            state <= IDLE;
            read_cnt <= 0;
            {read_word[7], read_word[6], read_word[5], read_word[4], read_word[3], read_word[2], read_word[1], read_word[0]} <= 260'b0;
        end else begin
            case (state)
                IDLE: 
                begin
                    // 检查是否命中缓存
                    if (cpu_inst_req & hit) begin
                        state <= IDLE;
                    end 
                    else if(cpu_inst_req & miss) begin
                        // 缓存未命中，启动内存访问
                        state <= MISS;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                MISS: begin
                    if(arready==1)
                        state <= FILL;
                    else
                    ;
                end
                FILL: begin
                    // 从内存读取数据并更新缓存
                    if(rvalid) begin
                        read_word[read_cnt] <= rdata;
                        read_cnt <= read_cnt+1;
                    end
                    if(read_cnt >= 10'd7) begin
                        read_cnt <=10'd0;
                    end
                    
                    if (rlast) begin
                        state <= END_FILL;
                    end
                end
                END_FILL: begin
                    if(~longest_stall) begin
                        tag[index]   <= tag_in;
                        cache[index] <= temp_read_block;
                        valid[index] <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end

    end

    // 组合逻辑计算index和tag_in
    assign index = cpu_inst_addr[INDEX_WIDTH + OFFSET_WIDTH - 1:OFFSET_WIDTH];
    assign tag_in = cpu_inst_addr[31:INDEX_WIDTH + OFFSET_WIDTH];
    assign offset_idx = cpu_inst_addr[OFFSET_WIDTH-1:2];
    wire [2:0]idx;
    assign idx = cpu_inst_addr[4:2];
    assign i_stall = state!=END_FILL &((cpu_inst_req & miss) | (state == MISS) | (state == FILL));
    //~(state == IDLE || (cpu_inst_req && hit) || ~cpu_inst_req);
endmodule
