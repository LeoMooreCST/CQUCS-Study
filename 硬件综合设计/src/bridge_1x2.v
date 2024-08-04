module bridge_1x2 (
    input no_dcache,
    input         cpu_data_req     ,
    input         cpu_data_wr      ,
    input  [1 :0] cpu_data_size    ,
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok ,
    output        cpu_data_data_ok ,

    output         ram_data_req     ,
    output         ram_data_wr      ,
    output  [1 :0] ram_data_size    ,
    output  [31:0] ram_data_addr    ,
    output  [31:0] ram_data_wdata   ,
    input   [31:0] ram_data_rdata   ,
    input          ram_data_addr_ok ,
    input          ram_data_data_ok ,

    output         conf_data_req     ,
    output         conf_data_wr      ,
    output  [1 :0] conf_data_size    ,
    output  [31:0] conf_data_addr    ,
    output  [31:0] conf_data_wdata   ,
    input   [31:0] conf_data_rdata   ,
    input          conf_data_addr_ok ,
    input          conf_data_data_ok 
);
    assign cpu_data_rdata   = no_dcache ? conf_data_rdata   : ram_data_rdata  ;
    assign cpu_data_addr_ok = no_dcache ? conf_data_addr_ok : ram_data_addr_ok;
    assign cpu_data_data_ok = no_dcache ? conf_data_data_ok : ram_data_data_ok;

    assign ram_data_req   = no_dcache ? 0 : cpu_data_req  ;
    assign ram_data_wr    = no_dcache ? 0 : cpu_data_wr   ;
    assign ram_data_size  = no_dcache ? 0 : cpu_data_size ;
    assign ram_data_addr  = no_dcache ? 0 : cpu_data_addr ;
    assign ram_data_wdata = no_dcache ? 0 : cpu_data_wdata;

    assign conf_data_req   = no_dcache ? cpu_data_req   : 0;
    assign conf_data_wr    = no_dcache ? cpu_data_wr    : 0;
    assign conf_data_size  = no_dcache ? cpu_data_size  : 0;
    assign conf_data_addr  = no_dcache ? cpu_data_addr  : 0;
    assign conf_data_wdata = no_dcache ? cpu_data_wdata : 0;
endmodule