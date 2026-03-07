`timescale 1ns / 1ps

module debouncher(
    input clk,
    input pbin,
    output reg pbout
);

reg [19:0] counter = 0;
reg pb_state = 0;

always @(posedge clk) begin

    if(pbin != pb_state) begin
        counter <= counter + 1;

        if(counter == 20'd1000000) begin
            pb_state <= pbin;
            pbout <= pbin;
            counter <= 0;
        end
    end
    else begin
        counter <= 0;
    end

end

endmodule
