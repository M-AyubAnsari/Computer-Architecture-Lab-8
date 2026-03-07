`timescale 1ns / 1ps

module TopModule_tb;

    reg clk;
    reg rst;
    reg [15:0] switches;
    wire [15:0] leds;

    // Internal signals from TopModule
    wire [31:0] address;
    wire [31:0] writeData;
    wire readEnable;
    wire writeEnable;
    wire [31:0] readData;

    // Instantiate TopModule
    TopModule uut (
        .clk(clk),
        .rst(rst),
        .switches(switches),
        .leds(leds)
    );

    // Map internal signals for simulation access
    assign address    = uut.address;
    assign writeData  = uut.writeData;
    assign readEnable = uut.readEnable;
    assign writeEnable= uut.writeEnable;
    assign readData   = uut.readData;

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        switches = 16'h0000;
        #10 rst = 0;

        // Write to Data Memory
        uut.address <= 32'd10;
        uut.writeData <= 32'hAAAA5555;
        uut.writeEnable <= 1;
        uut.readEnable <= 0;
        #10;

        // Read from Data Memory
        uut.writeEnable <= 0;
        uut.readEnable <= 1;
        #10;

        // Write to LEDs
        uut.address <= 32'd300;       // Address in LED range
        uut.writeData <= 32'h000000FF;
        uut.writeEnable <= 1;
        uut.readEnable <= 0;
        #10;

        // Read Switches
        switches = 16'h00AA;
        uut.address <= 32'd600;       // Address in Switch range
        uut.writeEnable <= 0;
        uut.readEnable <= 1;
        #10;

        $stop;
    end

endmodule
