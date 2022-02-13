`timescale 1ns / 1ps

module leds(
            input           clk,
            input           we,
            input  [31:0]   data
);
reg [15:0] leds = 16'b0;
    
always@(posedge clk)
begin
    if (we) leds <= data[31:16];
end
    
endmodule