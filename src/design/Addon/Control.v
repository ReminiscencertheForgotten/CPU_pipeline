`timescale 1ns/1ps
module Control (
    input [5:0] Opcode,
    input [5:0] Funct,
    output ExtOp,
    output ALUSrc,
    output [3:0] ALUOp,
    output [1:0] RegDst,
    output MemWr,
    output MemRead,
    output [2:0] Branch,
    output [1:0] MemtoReg,
    output RegWr,
    output [1:0] Jump,
    output WordorByte
);
    wire [2:0] Category;
    reg [3:0] op;
    assign ALUOp = op;
    parameter [3:0] ALU_ADD = 0;
    parameter [3:0] ALU_SUB = 1;
    parameter [3:0] ALU_AND = 2;
    parameter [3:0] ALU_OR = 3;
    parameter [3:0] ALU_NOR = 4;
    parameter [3:0] ALU_LUI = 5;
    parameter [3:0] ALU_SLL = 6;
    parameter [3:0] ALU_SRL = 7;
    parameter [3:0] ALU_SRA = 8;
    parameter [3:0] ALU_SLT = 9;

    assign Category = ((Funct == 8 || Funct == 9) && Opcode == 0)?3:
                   (Opcode == 2 || Opcode == 3)?4:
                   (Opcode >= 4 && Opcode <= 7)?5:
                   (Opcode >= 8 && Opcode <= 15)?1:
                   (Opcode == 0)?0:2;
    assign ExtOp = (Category == 2 || Opcode == 8 || Opcode == 10);
    assign ALUSrc = (Category == 0);
    assign RegDst = ((Opcode == 0 && Funct == 9) || Opcode == 3)?2:(Category == 0)?1:0;
    assign MemWr = (Opcode == 40 || Opcode == 43);
    assign MemRead = (Opcode == 32 || Opcode == 35);
    assign Branch = (Category == 5)?Opcode:0;
    assign RegWr = (Category == 5 || Opcode == 40 || Opcode == 43 || Opcode == 2 || (Opcode == 0 && Funct == 8))?0:1;
    assign Jump = (Category == 4)?1:(Category == 3)?2:0;
    assign WordorByte = (Opcode == 32) || (Opcode == 40);
    assign MemtoReg = (Opcode == 32 || Opcode == 35)?1:
                    ((Opcode == 0 && Funct == 9) || (Opcode == 3))?2:0;
    
    always @(*) begin
        case (Opcode)
            0: begin
                case (Funct)
                    32,33:op <= ALU_ADD;
                    34,35:op <= ALU_SUB;
                    36:op <= ALU_AND;
                    37:op <= ALU_OR;
                    39:op <= ALU_NOR;
                    0:op <= ALU_SLL;
                    2:op <= ALU_SRL;
                    3:op <= ALU_SRA;
                    42,43:op <= ALU_SLT;
                    default:op <= 16;
                endcase
            end
            8,9,32,35,40,43:op <= ALU_ADD;
            12:op <= ALU_AND;
            13:op <= ALU_OR;
            15:op <= ALU_LUI;
            10,11:op <= ALU_SLT;
            default:op <= 16;
        endcase
    end
endmodule //Control