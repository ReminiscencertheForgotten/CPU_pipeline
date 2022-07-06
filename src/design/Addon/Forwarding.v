`timescale 1ns/1ps
module ForwardingUnitA (
    input [4:0] EX_write_reg,
    input [4:0] MEM_write_reg,
    input [4:0] ID_rt,
    input [4:0] ID_rs,
    input EX_RegWr,
    input MEM_RegWr,
    output [1:0] ForwardA,
    output [1:0] ForwardB
);
    reg [1:0] fa;
    reg [1:0] fb;
    assign ForwardA = fa;
    assign ForwardB = fb;
    always @(*) begin
        fa <= 2'b0;
        fb <= 2'b0;
        if (EX_RegWr && EX_write_reg && EX_write_reg == ID_rs)
            fa <= 2'b10;
        if (EX_RegWr && EX_write_reg && EX_write_reg == ID_rt)
            fb <= 2'b10;
        if (MEM_RegWr && MEM_write_reg && MEM_write_reg == ID_rs &&
        (EX_write_reg != ID_rs || ~EX_RegWr))
            fa <= 2'b01;
        if (MEM_RegWr && MEM_write_reg && MEM_write_reg == ID_rt &&
        (EX_write_reg != ID_rt || ~EX_RegWr))
            fb <= 2'b01;
    end
endmodule

module ForwardingUnitB (
    input [4:0] EX_write_reg,
    input [4:0] ID_write_reg,
    input [4:0] MEM_write_reg,
    input EX_RegWr,
    input ID_RegWr,
    input MemRead,
    input [4:0] ID_rs,
    input [4:0] ID_rt,
    output [1:0] CompareA,
    output [1:0] CompareB
);
    reg [1:0] ca;
    reg [1:0] cb;
    assign CompareA = ca;
    assign CompareB = cb;
    always @(*) begin
        ca <= 2'b00;
        cb <= 2'b00;
        if (ID_RegWr && ID_write_reg && ID_write_reg == ID_rs)
            ca <= 2'b01;
        if (ID_RegWr && ID_write_reg && ID_write_reg == ID_rt)
            cb <= 2'b01;
        if (EX_RegWr && EX_write_reg && EX_write_reg == ID_rs)
            ca <= 2'b10;
        if (EX_RegWr && EX_write_reg && EX_write_reg == ID_rt)
            cb <= 2'b10;
        if (MemRead && MEM_write_reg && MEM_write_reg == ID_rs)
            ca <= 2'b11;
        if (MemRead && MEM_write_reg && MEM_write_reg == ID_rt)
            cb <= 2'b11;
    end
endmodule

module ForwardingUnitC (
    input [4:0] WB_write_reg,
    input [4:0] MEM_write_reg,
    input WB_RegWr,
    input MemWr,
    output ForwardC
);
    reg fc;
    assign ForwardC = fc;
    always @(*) begin
        fc <= 1'b0;
        if ((WB_write_reg == MEM_write_reg) && WB_RegWr && MemWr && WB_write_reg)
            fc <= 1'b1;
    end
endmodule