`include "./src/design/Peripheral/DataMemory.v"
`include "./src/design/Peripheral/Sysclk.v"
`timescale 1ns/1ps
module Bus (
    input clk,
    input reset,
    input Write_enable,
    input Read_enable,
    input WordorByte,
    input SystemUse,
    input [31:0] Addr,
    input [31:0] Write_data,
    output [31:0] Read_data
);
    wire Dm_wen, Dm_ren;
    wire [31:0] Dm_data_r;
    assign Dm_wen = Write_enable && (Addr < 32'h00000800 || SystemUse);
    assign Dm_ren = Read_enable && (Addr < 32'h00000800 || SystemUse);
    DataMemory data_memory(
        .clk(clk), .reset(reset),
        .MemWr(Dm_wen),
        .MemRead(Dm_ren),
        .addr(Addr), .data_w(Write_data),
        .WordorByte(WordorByte), .data_r(Dm_data_r)
    );

    reg [31:0] BCD_value;
    reg [31:0] sys_cnt;

    wire [31:0] cnt;
    assign cnt = sys_cnt;
    Sysclk sys_clk(.clk(clk), .reset(reset), .number(cnt));

    always @(*) begin
        if (Write_enable && ~Dm_wen) begin
            case (Addr)
                32'h40000010: BCD_value <= Write_data;
                32'h40000014: sys_cnt <= Write_data;
            endcase
        end
    end

    assign Read_data = (~Read_enable)?32'h0:(Dm_ren)?Dm_data_r:
                        (Addr == 32'h40000010)?BCD_value:sys_cnt;

endmodule //Bus