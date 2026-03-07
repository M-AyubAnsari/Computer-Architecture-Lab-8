`timescale 1ns / 1ps

module TopModule(
    input clk,
    input rst,
    input [15:0] switches,
    output [15:0] leds
);

    // Internal control signals
    reg [31:0] address;
    reg readEnable;
    reg writeEnable;
    reg [31:0] writeData;
    wire [31:0] readData;

    // Decoder signals
    wire DataMemWrite;
    wire DataMemRead;
    wire LEDWrite;
    wire SwitchReadEnable;

    // Module outputs
    wire [31:0] dataMemOut;
    wire [31:0] ledOut;
    wire [31:0] switchOut;

    // Address Decoder
    AddressDecoder decoder(
        .address(address),
        .readEnable(readEnable),
        .writeEnable(writeEnable),

        .DataMemWrite(DataMemWrite),
        .DataMemRead(DataMemRead),
        .LEDWrite(LEDWrite),
        .SwitchReadEnable(SwitchReadEnable)
    );

    // Data Memory
    DataMemory dataMem(
        .clk(clk),
        .MemWrite(DataMemWrite),
        .MemRead(DataMemRead),
        .address(address[8:0]),
        .writeData(writeData),
        .readData(dataMemOut)
    );

    // LED Interface
    leds ledModule(
        .clk(clk),
        .rst(rst),
        .writeData(writeData),
        .writeEnable(LEDWrite),
        .readEnable(readEnable),
        .memAddress(address[31:2]),
        .readData(ledOut),
        .leds(leds)
    );

    // Switch Interface
    switches switchModule(
        .clk(clk),
        .rst(rst),
        .btns(16'd0),
        .writeData(writeData),
        .writeEnable(1'b0),
        .readEnable(SwitchReadEnable),
        .memAddress(address[31:2]),
        .switches(switches),
        .readData(switchOut)
    );

    // Read Data Multiplexer
    assign readData =
           (address[9:8] == 2'b00) ? dataMemOut :
           (address[9:8] == 2'b01) ? ledOut :
           (address[9:8] == 2'b10) ? switchOut :
           32'd0;

    // Internal testbench Sequence 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            address <= 32'd0;
            writeEnable <= 0;
            readEnable <= 0;
            writeData <= 32'd0;
        end
        else begin
        end
    end

endmodule
