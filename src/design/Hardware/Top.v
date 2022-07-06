`include "./src/design/CPU.v"
`timescale 1ns/1ps
module Top (
    input clk, 
    input reset,
    output reg [3:0] an,
    output reg [6:0] leds
);
    CPU cpu(.clk(clk), .reset(reset));

    always @(posedge clk) begin
        if (reset) begin
            an <= 4'b0;
            leds <= 7'b0;
        end
        else begin
            an <= cpu.bus.BCD_value[11:8];
            leds <= cpu.bus.BCD_value[7:0];
        end
    end
endmodule //Top