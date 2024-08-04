`timescale 1ns / 1ps
`include "defines.vh"

module sw_trans(
    input wire adesM,
    input wire [7:0]alucontrolM,
    input wire [31:0]aluoutM,
    input wire [31:0]writedatatmpM,
    output wire [31:0]writedataM,
    output wire [3:0]memenM
    );
    reg [3:0]memen;
    reg [31:0]writedata;
    assign memenM=memen;
    assign writedataM=writedata;
    
    always @(*) begin
        case (alucontrolM)
            `EXE_SB_OP:writedata={4{writedatatmpM[7:0]}};
            `EXE_SH_OP:writedata={2{writedatatmpM[15:0]}};
            `EXE_SW_OP: writedata = writedatatmpM;
            default:writedata=32'b0;
        endcase 
    end

    always @(*) begin
        if(adesM) memen = 4'b0000;
        else begin
            case(alucontrolM)
                `EXE_SB_OP: begin
                    case(aluoutM[1:0])
                        2'b00: memen=4'b0001;
                        2'b01: memen=4'b0010;
                        2'b10: memen=4'b0100;
                        2'b11: memen=4'b1000;
                        default: memen=4'b0000;
                    endcase
                end
                `EXE_SH_OP: begin
                    case(aluoutM[1:0])
                        2'b00: memen=4'b0011;
                        2'b10: memen=4'b1100;
                        default: memen=4'b0000;
                    endcase
                end     
                `EXE_SW_OP: memen = 4'b1111;
                default: memen=4'b0000;
            endcase
        end
    end
endmodule
