`include "./src/design/CPU.v"
`define PERIOD 10
`timescale 1ns/1ps

module tb_CPU;
    reg clk;
    reg reset;

    CPU cpu(.clk(clk), .reset(reset));

    initial begin
        forever begin
            #(`PERIOD / 2)
            clk = ~clk;
        end
    end

    initial begin
        clk = 1'b1;
        reset = 1'b0;
        #(`PERIOD / 2)
        reset = 1'b1;
        #(`PERIOD)
        reset = 1'b0;

        #(`PERIOD * 1500)
        $display("$v0=%d", cpu.register_file.register_data[2]);
        $finish;
    end

    initial begin
        $dumpfile("tb_CPU.vcd");
        $dumpvars(0,tb_CPU);
    end


endmodule //tb_CPU