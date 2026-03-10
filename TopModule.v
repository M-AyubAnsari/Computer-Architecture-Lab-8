`timescale 1ns / 1ps
module TopModule(
    input clk,
    input rst,
    input [15:0] switches,
    input btnWrite,
    input btnRead,
    output reg [15:0] leds
);

wire [31:0] address;
wire [31:0] writeData;
wire writeEnable;
wire readEnable;
wire [31:0] readData;

wire DataMemWrite;
wire DataMemRead;
wire LEDWrite;
wire SwitchReadEnable;

wire [31:0] dataMemOut;
wire [31:0] ledOut;
wire [31:0] switchOut;

assign writeData = {24'd0, switches[7:0]};
assign address[9:8] = switches[15:14];
assign address[7:0]  = switches[7:0];
assign address[31:10] = 22'd0;

reg [2:0] state, next_state;

// FSM states
localparam IDLE        = 3'd0;
localparam WRITE_LED   = 3'd1;
localparam WRITE_MEM   = 3'd2;
localparam READ_MEM    = 3'd3;
localparam READ_SWITCH = 3'd4;

always @(posedge clk or posedge rst) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    next_state = IDLE;
    case(state)
        IDLE: begin
            case(switches[15:14])
                2'b01: if(btnWrite) next_state = WRITE_LED;
                2'b00: begin
                    if(btnWrite) next_state = WRITE_MEM;
                    else if(btnRead) next_state = READ_MEM;
                end
                2'b10: if(btnRead) next_state = READ_SWITCH;
                default: next_state = IDLE;
            endcase
        end
        WRITE_LED: next_state = IDLE;
        WRITE_MEM: next_state = IDLE;
        READ_MEM: next_state = IDLE;
        READ_SWITCH: next_state = IDLE;
        default: next_state = IDLE;
    endcase
end

AddressDecoder decoder(
    .address(address),
    .readEnable((state==READ_MEM)||(state==READ_SWITCH)),
    .writeEnable((state==WRITE_MEM)||(state==WRITE_LED)),
    .DataMemWrite(DataMemWrite),
    .DataMemRead(DataMemRead),
    .LEDWrite(LEDWrite),
    .SwitchReadEnable(SwitchReadEnable)
);

DataMemory dataMem(
    .clk(clk),
    .MemWrite(DataMemWrite),
    .MemRead(DataMemRead),
    .address(address[8:0]),
    .writeData(writeData),
    .readData(dataMemOut)
);

wire [15:0] ledOutWire;
leds ledModule(
    .clk(clk),
    .rst(rst),
    .writeData(writeData),
    .writeEnable(LEDWrite),
    .readEnable((state==READ_MEM)||(state==READ_SWITCH)||(state==WRITE_LED)),
    .memAddress(address[31:2]),
    .readData(ledOut),
    .leds(ledOutWire)
);

switches switchModule(
    .clk(clk),
    .rst(rst),
    .btns(16'd0),
    .writeData(writeData),
    .writeEnable(1'b0),
    .readEnable(state==READ_SWITCH),
    .memAddress(address[31:2]),
    .switches(switches),
    .readData(switchOut)
);

assign readData =
       (address[9:8] == 2'b00) ? dataMemOut :
       (address[9:8] == 2'b01) ? ledOut :
       (address[9:8] == 2'b10) ? switchOut :
       32'd0;

always @(posedge clk or posedge rst) begin
    if(rst)
        leds <= 16'd0;
    else begin
        case(state)
            WRITE_LED: leds <= {8'd0, switches[7:0]};
            WRITE_MEM: ; 
            READ_MEM:  leds <= {8'd0, dataMemOut[7:0]};
            READ_SWITCH: leds <= {8'd0, switches[7:0]};
            default: leds <= leds;
        endcase
    end
end

endmodule
