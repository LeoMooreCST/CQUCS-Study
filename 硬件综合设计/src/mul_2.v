

module mul_2(
    input wire clk,rst,
    input wire[31:0] a,b,
    input valid,               //fg=0 means the first period, fg=1 means the second   en=1 means multi
    input issign,
    output wire[63:0] result,//remember fg=~fg every clk in datapath
    input flush,
    input flush_exceptionM,
    output wire stall_mul,
    input wire mult_res_ready,
    output reg mult_res_valid,
    output reg we
    );
    reg[31:0] hi,lo;
    reg [31:0] tmpa,tmpb;
    reg [15:0] a_lo,a_hi,b_lo,b_hi;
    reg [31:0] tmp1,tmp2,tmp3,tmp4;
    reg [63:0] res;
    reg sign,issign1;
    reg tmpfordebug;
    reg[5:0]cnt;reg start_cnt;
    always@(posedge clk)begin
        we<=0;
        if(flush|rst)begin
            cnt<=0;start_cnt<=0;
        end else if(!start_cnt&valid&~mult_res_valid)begin
            we<=0;
            cnt<=1;start_cnt<=1;
            if(issign&&a[31]==1)tmpa=(~a[30:0])+1;else tmpa=a;
            if(issign&&b[31]==1)tmpb=(~b[30:0])+1;else tmpb=b;
            if(issign)begin
                a_lo=tmpa[15:0];a_hi={1'b0,tmpa[30:16]};
                b_lo=tmpb[15:0];b_hi={1'b0,tmpb[30:16]};
            end else begin
                a_lo=a[15:0];a_hi=a[31:16];
                b_lo=b[15:0];b_hi=b[31:16];
            end
            // tmp1=a_lo*b_lo;tmp2=a_hi*b_lo;
            // tmp3=a_lo*b_hi;tmp4=a_hi*b_hi;
            // sign=a[31]^b[31];
            // //hi=0;lo=0;
            // issign1=issign;tmpfordebug=0;
        end else if(start_cnt)begin 
            if(cnt==2)begin
                we<=1;
                cnt<=0;start_cnt<=0;
                res=tmp1+(tmp2<<16)+(tmp3<<16)+(tmp4<<32);
                if(issign1&&sign)res={1'b1,~res+1};
//                if(a[31]^b[31])lo={1'b1,res[30:0]};
//                else lo={1'b0,res[30:0]};
                lo=res[31:0];
                hi=res[63:32];
                tmpfordebug=1;
            end else begin
                cnt<=cnt+1;
                tmp1=a_lo*b_lo;tmp2=a_hi*b_lo;
                tmp3=a_lo*b_hi;tmp4=a_hi*b_hi;
                sign=a[31]^b[31];
                //hi=0;lo=0;
                issign1=issign;tmpfordebug=0;
            end
        end
    end

    wire data_go;
    assign data_go = mult_res_valid & mult_res_ready;
    always @(posedge clk) begin
        mult_res_valid <= rst     ? 1'b0 :
                     cnt==2  ? 1'b1 :
                     data_go ? 1'b0 : mult_res_valid;
    end
    assign result={hi,lo};
    assign stall_mul=(|cnt)&~flush_exceptionM;
endmodule