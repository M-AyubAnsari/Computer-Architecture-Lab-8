`timescale 1ns / 1ps

module leds(

    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,

    output reg [31:0] readData = 0,
    output reg [15:0] leds = 0

);

always @(posedge clk or posedge rst) begin

    if(rst)
        leds <= 16'd0;

    else if(writeEnable)
        leds <= writeData[15:0];

end


always @(*) begin

    if(readEnable)
        readData = {16'd0, leds};
    else
        readData = 32'd0;

end

endmodule
