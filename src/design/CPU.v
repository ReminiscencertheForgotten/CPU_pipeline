`include "./src/design/Addon/Control.v"
`include "./src/design/Addon/Forwarding.v"
`include "./src/design/Basic/ALU.v"
`include "./src/design/Basic/InstructionMemory.v"
`include "./src/design/Basic/Pipes.v"
`include "./src/design/Basic/ProgramCounter.v"
`include "./src/design/Basic/RegisterFile.v"
`include "./src/design/Peripheral/Bus.v"
`timescale 1ns/1ps

module CPU (
    input clk, 
    input reset
);

    // IF Stage
    wire [31:0] PC, PC_next;
    wire [1:0] PCSrc;           // PC control Signal
    wire [31:0] PC_normal;      // PC + 4
    wire [31:0] PC_branch;      // PC generated by "branch"
    wire [31:0] PC_jump;        // PC generated by "jump"
    wire [31:0] read_data1;     // PC read from rf

    assign PC_normal = PC + 4;
    assign PC_next = (PCSrc == 0)?PC_normal:(PCSrc == 1)?PC_branch:(PCSrc == 2)?PC_jump:read_data1;
    ProgramCounter program_counter(.clk(clk), .reset(reset), .PC_next(PC_next), .PC(PC));


    wire [31:0] Instruction;
    InstructionMemory instruction_memory(.reset(reset), .addr(PC), .inst(Instruction));

    Pipe_IF_ID pipe1(.clk(clk), .reset(reset), .IF_pc_normal(PC_normal), .IF_instruction(Instruction));

    // ID Stage
    wire ID_ExtOp;
    wire ID_ALUSrc;
    wire [3:0] ID_ALUOp;
    wire [1:0] ID_RegDst;
    wire ID_MemWr;
    wire [2:0] ID_Branch;
    wire [1:0] ID_MemtoReg;
    wire ID_RegWr;
    wire ID_MemRead;
    wire [1:0] ID_Jump;
    wire ID_WordorByte;

    Control ctrl_unit(
        .Opcode(pipe1.Instruction[31:26]),
        .Funct(pipe1.Instruction[5:0]),
        .ExtOp(ID_ExtOp),
        .ALUSrc(ID_ALUSrc),
        .ALUOp(ID_ALUOp),
        .RegDst(ID_RegDst),
        .MemWr(ID_MemWr),
        .Branch(ID_Branch),
        .MemtoReg(ID_MemtoReg),
        .MemRead(ID_MemRead),
        .RegWr(ID_RegWr),
        .Jump(ID_Jump),
        .WordorByte(ID_WordorByte)
    );

    wire [31:0] WB_write_data, read_data2;

    RegisterFile register_file(
        .clk(clk), .reset(reset),
        .read_reg1(pipe1.Instruction[25:21]),
        .read_reg2(pipe1.Instruction[20:16]),
        .write_reg(pipe4.write_reg),
        .write_data(WB_write_data),
        .RegWr(pipe4.RegWr),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    wire [31:0] Immediate;
    assign Immediate = (ID_ExtOp == 0)?
            {16'b0, pipe1.Instruction[15:0]}:{{16{pipe1.Instruction[15]}}, pipe1.Instruction[15:0]};

    assign PC_branch = PC + (Immediate << 2);
    assign PC_jump = {PC_normal[31:28], pipe1.Instruction[25:0], 2'b00};

    wire [1:0] CompareA, CompareB;
    wire [31:0] cmp1, cmp2;
    wire [4:0] Dest;

    ForwardingUnitB forwarding_unit_b(
        .MEM_write_reg(pipe4.write_reg),
        .MemRead(pipe3.MemRead),
        .EX_write_reg(pipe3.write_reg),
        .EX_RegWr(pipe3.RegWr),
        .ID_write_reg(Dest),
        .ID_RegWr(pipe2.RegWr),
        .ID_rs(pipe1.Instruction[25:21]),
        .ID_rt(pipe1.Instruction[20:16]),
        .CompareA(CompareA),
        .CompareB(CompareB)
    );

    assign cmp1 = (CompareA == 3)?bus.Read_data:(CompareA == 2)?pipe3.ALU_result:(CompareA == 1)?alu.result:read_data1;
    assign cmp2 = (CompareB == 3)?bus.Read_data:(CompareB == 2)?pipe3.ALU_result:(CompareB == 1)?alu.result:read_data2;


    assign PCSrc = (
        ((ID_Branch == 4) && (cmp1 == cmp2)) ||
        ((ID_Branch == 5) && (cmp1 != cmp2)) ||
        ((ID_Branch == 6) && (cmp1 <= 0)) ||
        ((ID_Branch == 7) && (cmp1 > 0))
    )?1:(ID_Jump != 0)?(ID_Jump + 1):0;

    Pipe_ID_EX pipe2(
        .clk(clk), .reset(reset),
        .ID_read_data1(read_data1),
        .ID_read_data2(read_data2),
        .ID_imm_extend(Immediate),
        .ID_rs(pipe1.Instruction[25:21]),
        .ID_rt(pipe1.Instruction[20:16]),
        .ID_rd(pipe1.Instruction[15:11]),
        .ID_ALUSrc(ID_ALUSrc),
        .ID_ALUOp(ID_ALUOp),
        .ID_RegDst(ID_RegDst),
        .ID_MemWr(ID_MemWr),
        .ID_MemRead(ID_MemRead),
        .ID_MemtoReg(ID_MemtoReg),
        .ID_RegWr(ID_RegWr),
        .ID_shamt(pipe1.Instruction[10:6]),
        .ID_WordorByte(ID_WordorByte),
        .ID_PC_jump(PC)
    );

    // EX Stage
    wire [1:0] ForwardA, ForwardB;

    ForwardingUnitA forwarding_unit_a(
        .EX_write_reg(pipe3.write_reg),
        .MEM_write_reg(pipe4.write_reg),
        .ID_rs(pipe2.rs),
        .ID_rt(pipe2.rt),
        .EX_RegWr(pipe3.RegWr),
        .MEM_RegWr(pipe4.RegWr),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    wire [31:0] in1, in2;
    assign in1 = (ForwardA == 0)?pipe2.read_data1:
    (ForwardA == 1)?WB_write_data:pipe3.ALU_result;
    assign in2 = (pipe2.ALUSrc == 1)?(
        (ForwardB == 0)?pipe2.read_data2:
        (ForwardB == 1)?WB_write_data:pipe3.ALU_result
        ):(pipe2.imm_extend);
    
    wire [31:0] ALU_result;
    ALU alu(.in1(in1), .in2(in2), .ALUOp(pipe2.ALUOp), .ALU_result(ALU_result), .Shamt(pipe2.Shamt));

    assign Dest = (pipe2.RegDst == 2)?31:(pipe2.RegDst)?pipe2.rd:pipe2.rt;

    Pipe_EX_MEM pipe3(
        .clk(clk), .reset(reset),
        .EX_ALU_result(ALU_result),
        .EX_write_data(pipe2.read_data2),
        .EX_write_reg(Dest),
        .EX_MemWr(pipe2.MemWr),
        .EX_MemRead(pipe2.MemRead),
        .EX_MemtoReg(pipe2.MemtoReg),
        .EX_RegWr(pipe2.RegWr),
        .EX_WordorByte(pipe2.WordorByte),
        .EX_PC_jump(pipe2.PC_jump)
    );

    // MEM Stage
    wire [31:0] Data_memory_read, Data_memory_write;
    wire ForwardC;

    ForwardingUnitC forwarding_unit_c(
        .WB_write_reg(pipe4.write_reg),
        .MEM_write_reg(pipe3.write_reg),
        .WB_RegWr(pipe4.RegWr),
        // .MemWr(data_memory.MemWr),
        .MemWr(bus.Write_enable),
        .ForwardC(ForwardC)
    );

    assign Data_memory_write = (ForwardC == 1)?pipe4.ALU_result:pipe3.write_data;

    Bus bus(
        .clk(clk), .reset(reset),
        .Write_enable(pipe3.MemWr),
        .Read_enable(pipe3.MemRead),
        .Addr(pipe3.ALU_result),
        .SystemUse(1'b1),
        .WordorByte(pipe3.WordorByte),
        .Write_data(Data_memory_write),
        .Read_data(Data_memory_read)
    );

    Pipe_MEM_WB pipe4(
        .clk(clk), .reset(reset),
        .MEM_read_data(Data_memory_read),
        .MEM_ALU_result(pipe3.ALU_result),
        .MEM_write_reg(pipe3.write_reg),
        .MEM_MemtoReg(pipe3.MemtoReg),
        .MEM_RegWr(pipe3.RegWr),
        .MEM_PC_jump(pipe3.PC_jump)
    );

    // WB Stage
    assign WB_write_data = (pipe4.MemtoReg == 0)?pipe4.ALU_result:
                        (pipe4.MemtoReg == 1)?pipe4.read_data:pipe4.PC_jump;

endmodule //CPU