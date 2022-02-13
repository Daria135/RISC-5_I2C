`timescale 1ns / 1ps

module Interrupt_Controller(
                            input         clk,
                            input  [31:0] mie,
                            input  [31:0] int_req,
                            input         INT_RST,
                            output [31:0] mcause,
                            output        INT,
                            output [31:0] int_fin
                           );
reg [4:0]  cnt         = 5'd0;
reg [5:0]  device_en   = 6'd0;
reg        en;    
reg        for_int;
reg [31:0] int_fin_reg = 32'b0;
wire       enable      = en;
assign     mcause      = cnt;
assign     INT         = enable ^ for_int;
assign     int_fin     = int_fin_reg;

initial begin
    for_int <= 1'b0;
    en      <= 1'b0;
end

always@(*) begin
    en <= device_en[0] | device_en[1] | device_en[2] | device_en[3] | device_en[4] | device_en[5];
end

always@(posedge clk)
begin
    if (INT_RST) begin
        cnt         <= 5'd0;
        for_int     <= 1'b0;
        device_en   <= 6'b0;
        int_fin_reg <= 32'b0;
    end
    else begin
        if (!enable) cnt <= cnt + 1;
        for_int <= en;
    end
end


always@(*)
begin
    case (cnt)
        5'd0: if (mie[0] & int_req[0]) device_en[0] <= 1'b1;
        5'd1: if (mie[1] & int_req[1]) device_en[1] <= 1'b1;
        5'd2: if (mie[2] & int_req[2]) device_en[2] <= 1'b1;
        5'd3: if (mie[3] & int_req[3]) device_en[3] <= 1'b1;
        5'd4: if (mie[4] & int_req[4]) device_en[4] <= 1'b1;
        5'd5: if (mie[5] & int_req[5]) device_en[5] <= 1'b1;
        // ...
        // до 5'd31
        default: device_en <= 6'd0;
    endcase
    
    if (INT_RST) begin
        if (device_en[0]) int_fin_reg[0] <= 1'b1;
        if (device_en[1]) int_fin_reg[1] <= 1'b1;
        if (device_en[2]) int_fin_reg[2] <= 1'b1;
        if (device_en[3]) int_fin_reg[3] <= 1'b1;
        if (device_en[4]) int_fin_reg[4] <= 1'b1;
        if (device_en[5]) int_fin_reg[5] <= 1'b1;
        // ...
        // до device_en[31]
    end
end


endmodule
