`timescale 1ns/1ps
module InstructionMemory (
    input reset,
    input [31:0] addr,
    output [31:0] inst
);
    parameter INST_SRC_FILE = "C:\\Users\\Zs_Byqx2020\\Desktop\\CPU_pipeline\\src\\bin\\inst.txt";

    reg [31:0] im [0:511];
    integer i;
    always @(posedge reset) begin
        $readmemh(INST_SRC_FILE, im);
    end
    assign inst = im[addr[10:2]];
endmodule //InstructionMemory