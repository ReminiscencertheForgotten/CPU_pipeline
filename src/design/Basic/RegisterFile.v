`timescale 1ns/1ps
module RegisterFile (
    input clk,
    input reset,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [31:0] write_data,
    input RegWr,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] register_data [31:0];
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i <= 31; i = i + 1) register_data[i] <= 0;
            register_data[29] <= 32'h7fff_effc;
        end
        else if (RegWr && write_reg) begin
            register_data[write_reg] <= write_data;
        end
    end
    assign read_data1 = (write_reg == read_reg1 && RegWr)?write_data:register_data[read_reg1];
    assign read_data2 = (write_reg == read_reg2 && RegWr)?write_data:register_data[read_reg2];
endmodule //RegisterFile