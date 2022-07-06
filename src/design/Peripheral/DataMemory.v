`timescale 1ns/1ps
module DataMemory (
    input clk,
    input reset,
    input MemWr,
    input MemRead,
    input [31:0] addr,
    input [31:0] data_w,
    input WordorByte,
    output [31:0] data_r
);
    parameter DATA_SRC_FILE = "C:\\Users\\Zs_Byqx2020\\Desktop\\CPU_pipeline\\src\\bin\\data.txt";

    reg [31:0]dm[0:511];
    integer i = 0;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i <= 511; i = i + 1)
                dm[i] = 32'h0;
            $readmemh(DATA_SRC_FILE, dm);
        end
        else begin
            if (MemWr) begin
                if (~WordorByte) dm[addr[10:2]] <= data_w;
                else begin
                    case (addr[1:0])
                        0:dm[addr[10:2]][7:0] <= data_w[7:0];
                        1:dm[addr[10:2]][15:8] <= data_w[7:0];
                        2:dm[addr[10:2]][23:16] <= data_w[7:0];
                        3:dm[addr[10:2]][31:24] <= data_w[7:0];
                    endcase
                end
            end 
        end 
    end

    assign data_r = MemRead?((~WordorByte)?dm[addr[10:2]]:
                (addr[1:0] == 0)?{24'b0, dm[addr[10:2]][7:0]}:
                (addr[1:0] == 1)?{24'b0, dm[addr[10:2]][15:8]}:
                (addr[1:0] == 2)?{24'b0, dm[addr[10:2]][23:16]}:
                {24'b0, dm[addr[10:2]][31:24]}):32'b0;

endmodule //DataMemory