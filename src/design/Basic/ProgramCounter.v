`timescale 1ns/1ps
module ProgramCounter (
    input clk,
    input reset,
    input [31:0] PC_next,
    output [31:0] PC
);
reg [31:0] pc;
assign PC = pc;
always @(posedge clk) begin
    if (reset) pc <= 32'h0040_0000;
    else begin
        pc <= PC_next;
    end
end

endmodule //ProgramCounter