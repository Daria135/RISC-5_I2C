`timescale 1ns / 1ps

module buttons(
               input  [4:0] data_in,
               output [4:0] data_out
);
reg [4:0] buttons = 5'b0;
assign data_out   = buttons;

always@(*)
    begin
        buttons <= data_in;
    end
endmodule
