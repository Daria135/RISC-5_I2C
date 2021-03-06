`timescale 1ns / 1ps

module addr_dec(
                input          req,
                input          we,
                input  [31:0]  addr,
                output         req_m,
                output         we_m,
                output         we_d0, // leds
                output         we_d1, // I2C
                output [1:0]   RDsel     
    );
reg [1:0] RDsel_reg;
   
assign we_d0 = req & we & ({addr[31:1], 1'b0}  == 32'h80000800); // write to leds
assign we_d1 = req & we & ({addr[31:2], 2'b00} == 32'h80000808); // write to I2C
assign req_m = req & ({addr[31:10], 10'b0} == 32'h0);
assign we_m  = req & we & ({addr[31:10], 10'b0} == 32'h0);
assign RDsel = RDsel_reg;
    
always@(*)
begin
if (req && (!we)) begin
    case (addr[31])
        2'b0 : RDsel_reg <= 2'd0; // read from memory
        2'b1 : begin                
            if (addr[2:0] == 3'b011) RDsel_reg <= 2'd1;// read from I2C - writing availability flag
            if (addr[2:0] == 3'b100) RDsel_reg <= 2'd2;// read from I2C - data
            if (addr[2:0] == 3'b101) RDsel_reg <= 2'd3;// read from I2C - data readiness flag            
        end
    endcase
end
end
endmodule
