`timescale 1ns / 1ps
`include "defines2.vh"


module instdec(
    input wire [31:0] instr,
    output reg [39:0] ascii
    );

    always @(*)
    begin
        ascii<="N-R";
        case(instr[31:26])
            `NOP:   // R-type
                begin
                    case(instr[5:0])
                        /* logic instraction */
                        `AND: ascii<= "AND";
                        `OR: ascii<= "OR";
                        `XOR: ascii<= "XOR";
                        `NOR: ascii<= "NOR";
                        /* shift instraction */
                        `SLL: ascii<= "SLL";
                        `SRL: ascii<= "SRL";
                        `SRA: ascii<= "SRA";
                        `SLLV: ascii<= "SLLV";
                        `SRLV: ascii<= "SRLV";
                        `SRAV: ascii<= "SRAV";
                        /* move instraction */
                        `MFHI: ascii<= "MFHI";
                        `MTHI: ascii<= "MTHI";
                        `MFLO: ascii<= "MFLO";
                        `MTLO: ascii<= "MTLO";
                        /* arithemtic instraction */
                        `ADD: ascii<= "ADD";
                        `ADDU: ascii<= "ADDU";
                        `SUB: ascii<= "SUB";
                        `SUBU: ascii<= "SUBU";
                        `SLT: ascii<= "SLT";
                        `SLTU: ascii<= "SLTU";

                        `MULT: ascii<= "MULT";
                        `MULTU: ascii<= "MULTU";
                        `DIV: ascii<= "DIV";
                        `DIVU: ascii<= "DIVU";
                        /* jump instraction */
                        `JR: ascii<= "JR";
                        `JALR: ascii<= "JALR";
                        
                        `SYSCALL: ascii<= "SYSC";
                        `BREAK: ascii<= "BRE";
                        default: ascii<="N-R";
                    endcase
                end
            `ANDI: ascii<= "ANDI";
            `XORI: ascii<= "XORI";
            `LUI: ascii<= "LUI";
            `ORI: ascii<= "ORI";

            `ADDI: ascii<= "ADDI";
            `ADDIU: ascii<= "ADDIU";
            `SLTI: ascii<= "SLTI";
            `SLTIU: ascii<= "SLTIU";

            `J: ascii<= "J";
            `JAL: ascii<= "JAL";
            
            `BEQ: ascii<= "BEQ";
            `BGTZ: ascii<= "BGTZ";
            `BLEZ: ascii<= "BLEZ";
            `BNE: ascii<= "BNE";
            
            `LB: ascii<= "LB";
            `LBU: ascii<= "LBU";
            `LH: ascii<= "LH";
            `LHU: ascii<= "LHU";
            `LW: ascii<= "LW";
            `SB: ascii<= "SB";
            `SH: ascii<= "SH";
            `SW: ascii<= "SW";
            6'b000001: begin 
                case (instr[20:16])
                    `BGEZ: ascii<= "BGEZ";
                    `BGEZAL: ascii<= "BGEZAL";
                    `BLTZ: ascii<= "BLTZ";
                    `BLTZAL: ascii<= "BLTZAL";
                    default : ascii<= " ";
                endcase
            end
            6'b010000: begin 
                if(instr==`ERET) begin
                    ascii<="ERET";
                end else begin 
                    case (instr[25:21])
                        5'b00100: ascii<="MTOC0";
                        5'b00000: ascii<="MFC0";
                    endcase
                end
            end
            default: ascii<= "N-R";
       endcase
    if(instr==`ERET)
        ascii<= "ERET";
    if(!instr)
        ascii<= "NOP";
    end

endmodule

