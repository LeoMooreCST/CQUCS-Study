module d_sram_to_sram_like (
    input wire clk, rst,                 
    //sram
    input wire data_sram_en,             
    input wire [31:0] data_sram_addr,    
    output wire [31:0] data_sram_rdata,  
    input wire [3:0] data_sram_wen,       
    input wire [31:0] data_sram_wdata,    
    output wire d_stall,               

    //sram like
    output wire data_req,            
    output wire data_wr,                 
    output wire [1:0] data_size,        
    output wire [31:0] data_addr,        
    output wire [31:0] data_wdata,   

    input wire [31:0] data_rdata,     
    input wire data_addr_ok,         
    input wire data_data_ok,      

    input wire longest_stall 
);

    reg addr_rcv;   
    reg do_finish;    

    always @(posedge clk) begin
        if (rst) begin
            addr_rcv <= 1'b0;
        end
        else begin
            if (data_req & data_addr_ok & ~data_data_ok) begin
                addr_rcv <= 1'b1; 
            end
            else if (data_data_ok) begin
                addr_rcv <= 1'b0;
            end
            else begin
                addr_rcv <= addr_rcv;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            do_finish <= 1'b0;
        end
        else begin
            if (data_data_ok) begin
                do_finish <= 1'b1;
            end
            else if (~longest_stall) begin
                do_finish <= 1'b0;
            end
            else begin
                do_finish <= do_finish;
            end
        end
    end

    // Save rdata
    reg [31:0] data_rdata_save;
    always @(posedge clk) begin
        if (rst) begin
            data_rdata_save <= 32'b0;
        end
        else begin
            if (data_data_ok) begin
                data_rdata_save <= data_rdata;
            end
            else begin
                data_rdata_save <= data_rdata_save;
            end
        end
    end

    //sram like
    assign data_req = data_sram_en & ~addr_rcv & ~do_finish;
    assign data_wr = data_sram_en & |data_sram_wen;
    assign data_size = (data_sram_wen==4'b0001 || data_sram_wen==4'b0010 || data_sram_wen==4'b0100 || data_sram_wen==4'b1000) ? 2'b00:
                       (data_sram_wen==4'b0011 || data_sram_wen==4'b1100 ) ? 2'b01 : 2'b10;  // ��sram��дʹ��תΪaxi�Ĵ�С����

    assign data_addr = data_wr? data_sram_addr : {data_sram_addr[31:2], 2'b00};
    assign data_wdata = data_sram_wdata;

    //sram
    assign data_sram_rdata = data_rdata_save;
    assign d_stall = data_sram_en & ~do_finish;
endmodule