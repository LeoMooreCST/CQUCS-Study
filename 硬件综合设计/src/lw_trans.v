`timescale 1ns / 1ps
`include "defines.vh"

module lw_trans(
    input wire adelW,
    input wire [31:0] readdatatmpM,
    input wire [31:0] aluoutM,
    input wire [7:0] alucontrolM,
    output wire [31:0] readdataM
    );
    reg [31:0]readdata;
    assign readdataM=readdata;
    always @(*) begin
        if(adelW == 1'b1) begin
            readdata = 32'b0;   //触发例外
        end
        else begin
            case (alucontrolM)
                `EXE_LB_OP:
                    case (aluoutM[1:0])
                        2'b00: readdata={{24{readdatatmpM[7]}}, readdatatmpM[7:0]};
                        2'b01: readdata={{24{readdatatmpM[15]}},readdatatmpM[15:8]};
                        2'b10: readdata={{24{readdatatmpM[23]}},readdatatmpM[23:16]};
                        2'b11: readdata={{24{readdatatmpM[31]}},readdatatmpM[31:24]};
                        default:readdata=readdatatmpM;
                    endcase
                `EXE_LBU_OP:
                    case (aluoutM[1:0])
                        2'b00: readdata={{24{1'b0}},readdatatmpM[7:0]};
                        2'b01: readdata={{24{1'b0}},readdatatmpM[15:8]};
                        2'b10: readdata={{24{1'b0}},readdatatmpM[23:16]};
                        2'b11: readdata={{24{1'b0}},readdatatmpM[31:24]};
                        default:readdata=readdatatmpM;
                    endcase
                `EXE_LH_OP:
                    case (aluoutM[1:0])
                        2'b00: readdata={{16{readdatatmpM[15]}},readdatatmpM[15:0]};
                        2'b10: readdata={{16{readdatatmpM[31]}},readdatatmpM[31:16]};
                        default:readdata=readdatatmpM;
                    endcase
                `EXE_LHU_OP:
                    case (aluoutM[1:0])
                        2'b00: readdata={{16{1'b0}},readdatatmpM[15:0]};
                        2'b10: readdata={{16{1'b0}},readdatatmpM[31:16]};
                        default:readdata=readdatatmpM;
                    endcase
                `EXE_LW_OP: readdata = readdatatmpM;
                default:readdata=readdatatmpM;
            endcase
        end
    end
endmodule
