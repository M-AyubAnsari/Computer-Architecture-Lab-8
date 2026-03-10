`timescale 1ns / 1ps
module TopModule_tb;

reg clk;
reg rst;
reg [15:0] switches;
reg btnWrite;
reg btnRead;
wire [15:0] leds;

TopModule uut (
    .clk(clk),
    .rst(rst),
    .switches(switches),
    .btnWrite(btnWrite),
    .btnRead(btnRead),
    .leds(leds)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    switches = 16'd0;
    btnWrite = 0;
    btnRead = 0;
    #10 rst = 0;

    // LED test to write 0xAA to LEDs
    switches = 16'b01_10101010; 
    btnWrite = 1; #10 btnWrite = 0; #10;

    // Data Memory test of write to memory
    switches = 16'b00_00000101; 
    btnWrite = 1; #10 btnWrite = 0; #10;

    // Data Memory test of read memory
    switches = 16'b00_00000101;
    btnRead = 1; #10 btnRead = 0; #10;

    // Switch Test to show lower 8 switches on LEDs
    switches = 16'b10_10101010; 
    btnRead = 1; #10 btnRead = 0; #10;

    // Reset LEDs 
    rst = 1; #10 rst = 0;

    #20 $stop;
end

endmodule
