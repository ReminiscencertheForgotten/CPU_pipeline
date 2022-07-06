`timescale 1ns/1ps
module Sysclk (
    input clk,
    input reset,
    output [31:0] number
);
    reg [31:0] num;
    assign number = num;
    always @(posedge clk) begin
        if (reset) num <= 32'b0;
        else num <= num + 1;
    end
endmodule //Sysclk