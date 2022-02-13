`timescale 1ns / 1ps

module RF(
                    input         clk,
                    input   [4:0] A1, A2, A3,
                    input         WE3,
                    input  [31:0] WD3,
                    output [31:0] RD1, RD2
                    );        
reg [31:0] RAM [0:31];

assign RD1 = (A1!=0) ? RAM[A1] : 32'b0;
assign RD2 = (A2!=0) ? RAM[A2] : 32'b0;

always@(posedge clk)
begin
    if (WE3) begin
        if (A3 != 0) begin
            RAM[A3] <= WD3;
        end        
    end   
end

endmodule

