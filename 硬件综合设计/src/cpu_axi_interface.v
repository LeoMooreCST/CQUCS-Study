module cpu_axi_interface
(
    input         clk,
    input         resetn, 

    //inst sram-like 
    input         inst_req     ,
    input         inst_wr      ,
    input  [1 :0] inst_size    ,
    input  [31:0] inst_addr    ,
    input  [31:0] inst_wdata   ,
    output [31:0] inst_rdata   ,
    output        inst_addr_ok ,
    output        inst_data_ok ,
    
    //data sram-like 
    input         data_req     ,
    input         data_wr      ,
    input  [1 :0] data_size    ,
    input  [31:0] data_addr    ,
    input  [31:0] data_wdata   ,
    output [31:0] data_rdata   ,
    output        data_addr_ok ,
    output        data_data_ok ,

    //axi
    //ar����ַͨ��
    output [3 :0] arid         ,  //������id,����ֱ����Ϊ0
    output [31:0] araddr       ,  //�����������ֽڵ�ַ
    output [7 :0] arlen        ,  //�������burst����,һ�δ����н��е�burst��������0��ʼ����
    output [2 :0] arsize       ,  //����������ݴ�С,000Ϊ���ֽ�,001Ϊ����, 010Ϊ���� 
    output [1 :0] arburst      ,  //busrt����,ʵ������Ϊ2'b01����
    output [1 :0] arlock       ,  //�����ź�,��Ϊ0
    output [3 :0] arcache      ,  //cache����,��Ϊ0
    output [2 :0] arprot       , //�����ź�,��Ϊ0
    output        arvalid      , //�����ݵ�ַ��Ч�źţ�Master ��ͨ�����߸��ź�������һ��д���񣬸��ź����߱�ʾ Master ���ѽ���Ч�������������ַ��burst ���ȵȣ��͵���Ӧ�Ķ˿���
    input         arready      , //�����ݵ�ַ�����źţ���ʾ Slave ���Ѿ�׼���ý���д�������ز������� AWVALID �� AWREADY ͬʱΪ�ߵ�ʱ�������أ������������ַ��burst ���ȵȣ��Ĵ��伴����
    //�����ݲ���         
    input  [3 :0] rid          , //�������id
    input  [31:0] rdata        , //�����������
    input  [1 :0] rresp        , //
    input         rlast        , //burst����Ľ����ź�
    input         rvalid       , //����Ч�ź�,��ʾ��ǰslave�Ѿ�����Ч�����͵�RDATA��
    output        rready       , //�������ź�
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //wд����ͨ��       
    output [3 :0] wid          ,  //д����id��Ϊ0
    output [31:0] wdata        ,  //д��������   
    output [3 :0] wstrb        ,  //д�ֽ�ʹ��,���λΪ���ֽ�,��λΪ���ֽ�
    output        wlast        ,  //���һ��burst��־�ź�
    output        wvalid       ,  //д��Ч�ź�,��ǰ��master�Ѿ�����Ч�����͵�WADATA��
    input         wready       ,  //д�����ź�,slave��׼���ý���д������ʱ
    //bд��Ӧͨ��           
    input  [3 :0] bid          ,  //д������Ӧ��id,�ɺ���
    input  [1 :0] bresp        ,  //д�������Ӧ
    input         bvalid       ,  //д��Ӧ��Ч�ź�
    output        bready          //д��Ӧ�����źţ��� Master ��׼���ý���д��Ӧʱ�������ź�����
);
//addr
reg do_req;
reg do_req_or; //req is inst or data;1:data,0:inst
reg        do_wr_r;
reg [1 :0] do_size_r;
reg [31:0] do_addr_r;
reg [31:0] do_wdata_r;
wire data_back;

assign inst_addr_ok = !do_req&&!data_req;
assign data_addr_ok = !do_req;
always @(posedge clk)
begin
    do_req     <= !resetn                       ? 1'b0 : 
                  (inst_req||data_req)&&!do_req ? 1'b1 :
                  data_back                     ? 1'b0 : do_req;
    do_req_or  <= !resetn ? 1'b0 : 
                  !do_req ? data_req : do_req_or;

    do_wr_r    <= data_req&&data_addr_ok ? data_wr :
                  inst_req&&inst_addr_ok ? inst_wr : do_wr_r;
    do_size_r  <= data_req&&data_addr_ok ? data_size :
                  inst_req&&inst_addr_ok ? inst_size : do_size_r;
    do_addr_r  <= data_req&&data_addr_ok ? data_addr :
                  inst_req&&inst_addr_ok ? inst_addr : do_addr_r;
    do_wdata_r <= data_req&&data_addr_ok ? data_wdata :
                  inst_req&&inst_addr_ok ? inst_wdata :do_wdata_r;
end

//inst sram-like
assign inst_data_ok = do_req&&!do_req_or&&data_back;
assign data_data_ok = do_req&& do_req_or&&data_back;
assign inst_rdata   = rdata;
assign data_rdata   = rdata;

//---axi
reg addr_rcv;
reg wdata_rcv;

assign data_back = addr_rcv && (rvalid&&rready||bvalid&&bready);
always @(posedge clk)
begin
    addr_rcv  <= !resetn          ? 1'b0 :
                 arvalid&&arready ? 1'b1 :
                 awvalid&&awready ? 1'b1 :
                 data_back        ? 1'b0 : addr_rcv;
    wdata_rcv <= !resetn        ? 1'b0 :
                 wvalid&&wready ? 1'b1 :
                 data_back      ? 1'b0 : wdata_rcv;
end
//ar
assign arid    = 4'd0;
assign araddr  = do_addr_r;
assign arlen   = 8'd0;
assign arsize  = do_size_r;
assign arburst = 2'd0;
assign arlock  = 2'd0;
assign arcache = 4'd0;
assign arprot  = 3'd0;
assign arvalid = do_req&&!do_wr_r&&!addr_rcv;
//r
assign rready  = 1'b1;

//aw
assign awid    = 4'd0;
assign awaddr  = do_addr_r;
assign awlen   = 8'd0;
assign awsize  = do_size_r;
assign awburst = 2'd0;
assign awlock  = 2'd0;
assign awcache = 4'd0;
assign awprot  = 3'd0;
assign awvalid = do_req&&do_wr_r&&!addr_rcv;
//w
assign wid    = 4'd0;
assign wdata  = do_wdata_r;
assign wstrb  = do_size_r==2'd0 ? 4'b0001<<do_addr_r[1:0] :
                do_size_r==2'd1 ? 4'b0011<<do_addr_r[1:0] : 4'b1111;
assign wlast  = 1'd1;
assign wvalid = do_req&&do_wr_r&&!wdata_rcv;
//b
assign bready  = 1'b1;

endmodule

