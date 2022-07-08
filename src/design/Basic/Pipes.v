`timescale 1ns/1ps
module Pipe_IF_ID (
    input clk,
    input reset,
    input [31:0] IF_pc_normal,
    input [31:0] IF_instruction
);
    reg [31:0] PC_normal;
    reg [31:0] Instruction;
    always @(posedge clk) begin
        if (reset) begin
            PC_normal <= 0;
            Instruction <= 0;
        end
        else begin
            PC_normal <= IF_pc_normal;
            Instruction <= IF_instruction;
        end
    end
endmodule

module Pipe_ID_EX (
    input clk,
    input reset,
    input [31:0] ID_read_data1,
    input [31:0] ID_read_data2,
    input [31:0] ID_imm_extend,
    input [4:0] ID_rs,
    input [4:0] ID_rt,
    input [4:0] ID_rd,
    input ID_ALUSrc,
    input [3:0] ID_ALUOp,
    input [1:0] ID_RegDst,
    input ID_MemWr,
    input ID_MemRead,
    input [1:0] ID_MemtoReg,
    input ID_RegWr,
    input [4:0] ID_shamt,
    input ID_WordorByte,
    input [31:0] ID_PC_jump
);
    reg [31:0] read_data1;
    reg [31:0] read_data2;
    reg [31:0] imm_extend;
    reg [4:0] rs;
    reg [4:0] rt;
    reg [4:0] rd;
    reg ALUSrc;
    reg [3:0] ALUOp;
    reg [1:0] RegDst;
    reg MemWr;
    reg MemRead;
    reg [1:0] MemtoReg;
    reg RegWr;
    reg [4:0] Shamt;
    reg WordorByte;
    reg [31:0] PC_jump;
    always @(posedge clk) begin
        if (reset) begin
            read_data1 <= 32'b0;
            read_data2 <= 32'b0;
            imm_extend <= 32'b0;
            rs <= 5'b0;
            rd <= 5'b0;
            rt <= 5'b0;
            ALUSrc <= 1'b0;
            ALUOp <= 4'b0;
            RegDst <= 2'b0;
            MemWr <= 1'b0;
            MemRead <= 1'b0;
            MemtoReg <= 2'b0;
            RegWr <= 1'b0;
            Shamt <= 5'b0;
            WordorByte <= 1'b0;
            PC_jump <= 32'b0;
        end
        else begin
            read_data1 <= ID_read_data1;
            read_data2 <= ID_read_data2;
            imm_extend <= ID_imm_extend;
            rs <= ID_rs;
            rd <= ID_rd;
            rt <= ID_rt;
            ALUSrc <= ID_ALUSrc;
            ALUOp <= ID_ALUOp;
            RegDst <= ID_RegDst;
            MemWr <= ID_MemWr;
            MemtoReg <= ID_MemtoReg;
            RegWr <= ID_RegWr;   
            Shamt <= ID_shamt;
            WordorByte <= ID_WordorByte;
            PC_jump <= ID_PC_jump;
            MemRead <= ID_MemRead;
        end
    end
endmodule

module Pipe_EX_MEM (
    input clk,
    input reset,
    input [31:0] EX_ALU_result,
    input [31:0] EX_write_data,
    input [4:0] EX_write_reg,
    input EX_MemWr,
    input EX_MemRead,
    input [1:0] EX_MemtoReg,
    input EX_RegWr,
    input EX_WordorByte,
    input [31:0] EX_PC_jump
);
    reg [31:0] ALU_result;
    reg [31:0] write_data;
    reg [4:0] write_reg;
    reg MemWr;
    reg MemRead;
    reg [1:0] MemtoReg;
    reg RegWr; 
    reg WordorByte;
    reg [31:0] PC_jump;
    always @(posedge clk) begin
        if (reset) begin
            ALU_result <= 32'b0;
            write_data <= 32'b0;
            write_reg <= 5'b0;
            MemWr <= 1'b0;
            MemRead <= 1'b0;
            MemtoReg <= 2'b0;
            RegWr <= 1'b0;
            WordorByte <= 1'b0;
            PC_jump <= 32'b0;
        end
        else begin
            ALU_result <= EX_ALU_result;
            write_data <= EX_write_data;
            write_reg <= EX_write_reg;
            MemWr <= EX_MemWr;
            MemtoReg <= EX_MemtoReg;
            RegWr <= EX_RegWr;   
            WordorByte <= EX_WordorByte;
            PC_jump <= EX_PC_jump;
            MemRead <= EX_MemRead;
        end
    end    
endmodule

module Pipe_MEM_WB (
    input clk,
    input reset,
    input [31:0] MEM_read_data,
    input [31:0] MEM_ALU_result,
    input [4:0] MEM_write_reg,
    input [1:0] MEM_MemtoReg,
    input MEM_RegWr,
    input [31:0] MEM_PC_jump
);
    reg [31:0] read_data;
    reg [31:0] ALU_result;
    reg [4:0] write_reg;
    reg [1:0] MemtoReg;
    reg RegWr;
    reg [31:0] PC_jump;
    always @(posedge clk) begin
        if (reset) begin
            read_data <= 32'b0;
            ALU_result <= 32'b0;
            write_reg <= 5'b0;
            MemtoReg <= 2'b0;
            RegWr <= 1'b0;
            PC_jump <= 32'b0;
        end
        else begin
            read_data <= MEM_read_data;
            ALU_result <= MEM_ALU_result;
            write_reg <= MEM_write_reg;
            MemtoReg <= MEM_MemtoReg;
            RegWr <= MEM_RegWr;   
            PC_jump <= MEM_PC_jump;
        end
    end
endmodule