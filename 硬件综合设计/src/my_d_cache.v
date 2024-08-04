module d_cache (
    input wire clk, rst,
    //mips core
    input         cpu_data_req     , 
    input         cpu_data_wr      , 
    input  [1 :0] cpu_data_size    ,
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok ,
    output        cpu_data_data_ok ,

    //axi interface
    output         cache_data_req     ,
    output         cache_data_wr      ,
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok ,
    input          cache_data_data_ok 
);
    //Cache配置
    parameter  INDEX_WIDTH  = 10, OFFSET_WIDTH = 2;
    localparam TAG_WIDTH    = 32 - INDEX_WIDTH - OFFSET_WIDTH;
    localparam CACHE_DEEPTH = 1 << INDEX_WIDTH;
    
    //Cache存储单元
    reg [1:0] cache_valid [CACHE_DEEPTH - 1 : 0];
    reg [1:0] cache_dirty [CACHE_DEEPTH - 1 : 0]; // 是否修改过
    reg [1:0] cache_ru    [CACHE_DEEPTH - 1 : 0]; //* recently used
    reg [TAG_WIDTH-1:0] cache_tag_0 [CACHE_DEEPTH - 1 : 0];
    reg [TAG_WIDTH-1:0] cache_tag_1 [CACHE_DEEPTH - 1 : 0];
    
    reg [31:0]          cache_block_0 [CACHE_DEEPTH - 1 : 0];
    reg [31:0]          cache_block_1 [CACHE_DEEPTH - 1 : 0];


    //访问地址分解
    wire [OFFSET_WIDTH-1:0] offset;
    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    
    assign offset = cpu_data_addr[OFFSET_WIDTH - 1 : 0];
    assign index = cpu_data_addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign tag = cpu_data_addr[31 : INDEX_WIDTH + OFFSET_WIDTH];

    //访问Cache line
    wire                 c_valid[1:0];
    wire                 c_dirty[1:0]; 
    wire                 c_ru   [1:0]; 
    wire [TAG_WIDTH-1:0] c_tag  [1:0];
    wire [31:0]          c_block[1:0];

    assign c_valid[0] = cache_valid[index][0];
    assign c_valid[1] = cache_valid[index][1];
    assign c_dirty[0] = cache_dirty[index][0];
    assign c_dirty[1] = cache_dirty[index][1];
    assign c_ru   [0] = cache_ru   [index][0];
    assign c_ru   [1] = cache_ru   [index][1];
    assign c_tag  [0] = cache_tag_0  [index];
    assign c_tag  [1] = cache_tag_1  [index];
    assign c_block[0] = cache_block_0[index];
    assign c_block[1] = cache_block_1[index];

    //判断是否命中
    wire hit, miss;
    assign hit = c_valid[0] & (c_tag[0] == tag) | c_valid[1] & (c_tag[1] == tag); 
    assign miss = ~hit;

    wire c_way;
    assign c_way = hit ? (c_valid[0] & (c_tag[0] == tag) ? 1'b0 : 1'b1) : 
                   c_ru[0] ? 1'b1 : 1'b0; 

    wire load, store;
    assign store = cpu_data_wr;
    assign load = cpu_data_req & ~store;

    wire dirty, clean;
    assign dirty = c_dirty[c_way];
    assign clean = ~dirty;

    //FSM
    parameter IDLE = 2'b00, RM = 2'b01, WM = 2'b11;
    reg [1:0] state;
    reg in_RM;

    always @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            in_RM <= 1'b0;
        end
        else begin
            case(state)
                IDLE: begin
                    state <= IDLE;
                    if (cpu_data_req) begin
                        if (hit) 
                            state <= IDLE;
                        else if (miss & dirty)
                            state <= WM;
                        else if (miss & clean)
                            state <= RM;
                    end
                    in_RM <= 1'b0;
                end

                WM: begin
                    state <= WM;
                    if (cache_data_data_ok)
                        state <= RM;
                end

                RM: begin
                    state <= RM;
                    if (cache_data_data_ok)
                        state <= IDLE;

                    in_RM <= 1'b1;
                end
            endcase
        end
    end

    //读内存
    wire isRM;      //一次完整的读事务，从发出读请求到结束 // 是不是处于RM状态
    reg addr_rcv;       //地址接收成功(addr_ok)后到结束      // 处于RM状态，且地址已得到mem的确认
    wire read_finish;   //数据接收成功(data_ok)，即读请求结束 // 处于RM状态，且已得到mem读取的数据
    always @(posedge clk) begin
        addr_rcv <= rst ? 1'b0 :
                    cache_data_req & isRM & cache_data_addr_ok ? 1'b1 :
                    read_finish ? 1'b0 : 
                    addr_rcv;
    end
    assign isRM = state==RM;
    assign read_finish = isRM & cache_data_data_ok;

    //写内存
    wire isWM;     // 是不是处于WM状态
    reg waddr_rcv;      // 处于WM状态，且地址已得到mem的确认
    wire write_finish;  // 处于WM状态，且已写入mem的数据
    always @(posedge clk) begin
        waddr_rcv <= rst ? 1'b0 :
                     cache_data_req& isWM & cache_data_addr_ok ? 1'b1 :
                     write_finish ? 1'b0 :
                     waddr_rcv;
    end
    assign isWM = state==WM;
    assign write_finish = isWM & cache_data_data_ok;

    //output to mips core
    //* 输出对应路的cache block
    assign cpu_data_rdata   = hit ? c_block[c_way] : cache_data_rdata;
    assign cpu_data_addr_ok = cpu_data_req & hit | cache_data_req & isRM & cache_data_addr_ok;
    assign cpu_data_data_ok = cpu_data_req & hit | isRM & cache_data_data_ok;

    //output to axi interface
    assign cache_data_req   = isRM & ~addr_rcv | isWM & ~waddr_rcv;
    assign cache_data_wr    = isWM;节
    assign cache_data_size  = cpu_data_size;
    assign cache_data_addr  = cache_data_wr ? {c_tag[c_way], index, offset}:
                                              cpu_data_addr;
    //* cache要写回memory的数据是原cache line的数据
    assign cache_data_wdata = c_block[c_way];

    //写入Cache
    //保存地址中的tag, index，防止addr发生改变
    reg [TAG_WIDTH-1:0] tag_save;
    reg [INDEX_WIDTH-1:0] index_save;
    always @(posedge clk) begin
        tag_save   <= rst ? 0 :
                      cpu_data_req ? tag : tag_save;
        index_save <= rst ? 0 :
                      cpu_data_req ? index : index_save;
    end

    wire [31:0] write_cache_data;
    wire [3:0] write_mask;

    //根据地址低两位和size，生成写掩码（针对sb，sh等不是写完整一个字的指令），4位对应1个字（4字节）中每个字的写使能
    assign write_mask = cpu_data_size==2'b00 ?
                            (cpu_data_addr[1] ? (cpu_data_addr[0] ? 4'b1000 : 4'b0100):
                                                (cpu_data_addr[0] ? 4'b0010 : 4'b0001)) :
                            (cpu_data_size==2'b01 ? (cpu_data_addr[1] ? 4'b1100 : 4'b0011) : 4'b1111);

    //掩码的使用：位为1的代表需要更新的。
    wire [31:0] cache_block_sel;
    assign cache_block_sel = (c_way==1)? cache_block_1[index]:cache_block_0[index];
    assign write_cache_data = cache_block_sel & ~{{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}} | 
                              cpu_data_wdata & {{8{write_mask[3]}}, {8{write_mask[2]}}, {8{write_mask[1]}}, {8{write_mask[0]}}};

    wire isIDLE = state==IDLE;

    integer t, y;
    always @(posedge clk) begin
        if(rst) begin
             for(t=0; t<CACHE_DEEPTH; t=t+1) begin   //刚开始将Cache初始化为无效，dirty 初始化为 0，//* ru 初始化为0
                 for (y = 0; y<2; y=y+1) begin
                     cache_valid[t][y] <= 0;
                     cache_dirty[t][y] <= 0;
                     cache_ru   [t][y] <= 0;
                 end
             end
//            cache_valid <= '{default: '0};
//            cache_dirty <= '{default: '0};
//            cache_ru <= '{default: '0};
        end
        else begin
            if(read_finish) begin // 处于RM状态，且已得到mem读取的数据
                if(c_way==0) begin
                cache_valid[index_save][c_way] <= 1'b1;             //将Cache line置为有效
                cache_dirty[index_save][c_way] <= 1'b0; // 读取内存的数据后，一定是clean
                cache_tag_0  [index_save] <= tag_save;
                cache_block_0[index_save] <= cache_data_rdata; //写入Cache line
                end
                else begin
                    cache_valid[index_save][c_way] <= 1'b1;             //将Cache line置为有效
                    cache_dirty[index_save][c_way] <= 1'b0; // 读取内存的数据后，一定是clean
                    cache_tag_1  [index_save] <= tag_save;
                    cache_block_1[index_save] <= cache_data_rdata; //写入Cache line
                end     
            end
            else if (store & isIDLE & (hit | in_RM)) begin 
                cache_dirty[index][c_way] <= 1'b1; // 改了数据，变dirty
                if(c_way==0)
                    cache_block_0[index] <= write_cache_data;      //写入Cache line，使用index而不是index_save
                else
                    cache_block_1[index] <= write_cache_data;
            end

            if ((load | store) & isIDLE & (hit | in_RM)) begin
                //* load 或 store指令，hit进入IDLE状态 或 从读内存回到IDLE后，将最近使用情况更新
                cache_ru[index][c_way]   <= 1'b1; //* c_way 路最近使用了
                cache_ru[index][1-c_way] <= 1'b0; //* 1-c_way 路最近未使用
            end
        end
    end
endmodule