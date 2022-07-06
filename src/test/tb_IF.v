`timescale 1ns/1ps
`include "./src/design/CPU.v"
`define PERIOD 10
module tb_IF ();
    reg clk;
    reg reset;
    reg [1:0] PCSrc;
    CPU cpu(.clk(clk), .reset(reset));

    initial begin
        forever begin
            #(`PERIOD / 2)
            clk = ~clk;
        end
    end

    initial begin
        clk <= 1'b0;
        reset <= 1'b0;
        PCSrc <= 0;

        #(`PERIOD / 2)
        reset <= 1'b1;
        #(`PERIOD)
        reset <= 1'b0;

        #(`PERIOD * 2)
        $finish;
    end

    initial begin
        $dumpfile("tb_IF.vcd");
        $dumpvars(0, tb_IF);
    end
endmodule //tb_IF