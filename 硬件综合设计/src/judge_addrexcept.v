`timescale 1ns / 1ps
`include "defines.vh"

module judge_addrexcept(
    input wire [7:0]alucontrolM,
    input wire [31:0]aluoutM,
    output reg adelM,
    output reg adesM
    );
    always @(*) begin
        adelM <= 1'b0;    //取地址例外
        adesM <= 1'b0;    //存地址例外
        case (alucontrolM)
            `EXE_SH_OP: begin
                if(aluoutM[1:0] != 2'b00 & aluoutM[1:0] != 2'b10) adesM <= 1'b1;  //sh存半字例外
            end
            `EXE_SW_OP: begin
                if(aluoutM[1:0] != 2'b00) adesM <= 1'b1;                          //sw存整字例外
            end
            `EXE_LH_OP: begin
                if(aluoutM[1:0] != 2'b00 & aluoutM[1:0] != 2'b10) adelM <= 1'b1;  //取半字例外
            end
            `EXE_LHU_OP: begin
                if(aluoutM[1:0] != 2'b00 & aluoutM[1:0] != 2'b10) adelM <= 1'b1;   //取无符号半字例外
            end
            `EXE_LW_OP: begin
                if(aluoutM[1:0] != 2'b00) adelM <= 1'b1;                           //取整字例外
            end
            default:begin adelM <= 0; adesM <= 0; end
        endcase 
    end
    
endmodule
