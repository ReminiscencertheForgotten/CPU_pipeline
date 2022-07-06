`timescale 1ns/1ps
module ALU (
    input [31:0] in1,
    input [31:0] in2,
    input [3:0] ALUOp,
    input [4:0] Shamt,
    output [31:0] ALU_result
);
    reg [31:0] result;
    assign ALU_result = result;
    always @(*) begin
        case (ALUOp)
            0:result <= in1 + in2;
            1:result <= in1 - in2;
            2:result <= in1 & in2;
            3:result <= in1 | in2;
            4:result <= in1 ^ in2;
            5:result <= in2 << 16;
            6:result <= in2 << Shamt;
            7:result <= in2 >> Shamt;
            8:result <= $signed(in2) >>> in1;
            9:result <= (in1 < in2);
        endcase
    end
endmodule //ALU