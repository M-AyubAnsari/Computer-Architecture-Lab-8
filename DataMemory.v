`timescale 1ns / 1ps

module DataMemory(

    input clk,
    input MemWrite,
    input MemRead,
    input [8:0] address,
    input [31:0] writeData,

    output reg [31:0] readData = 0
);

reg [31:0] memory [0:511];

always @(posedge clk) begin
    if (MemWrite)
        memory[address] <= writeData;
end

always @(*) begin
    if (MemRead)
        readData = memory[address];
    else
        readData = 32'd0;
end

endmodule
