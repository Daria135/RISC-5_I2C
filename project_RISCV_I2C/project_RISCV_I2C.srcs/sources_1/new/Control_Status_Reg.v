`timescale 1ns / 1ps

module Control_Status_Reg(
                          input         clk,
                          input  [2:0]  OP,
                          input  [31:0] mcause,
                          input  [31:0] PC,
                          input  [11:0] A,
                          input  [31:0] WD,
                          output [31:0] mie,
                          output [31:0] mtvec,
                          output [31:0] mepc,
                          output [31:0] RD
    );
reg [31:0] MUX1;
reg        EN_mie;
reg        EN_mtvec;
reg        EN_mepc;
reg        EN_for_scratch;
reg        EN_for_cause;

reg [31:0] mie_reg;
reg [31:0] mtvec_reg;
reg [31:0] mepc_reg;
reg [31:0] for_scratch;
reg [31:0] for_cause;
reg [31:0] RD_reg;

reg [31:0] MUX1_for_mepc;
reg [31:0] MUX1_for_cause;

assign mie[31:0]   = mie_reg[31:0];
assign mtvec[31:0] = mtvec_reg[31:0];
assign mepc[31:0]  = mepc_reg[31:0];
assign RD[31:0]    = RD_reg[31:0];

always@(*)
begin
    case(OP[1:0])
        2'd0: MUX1 <=  32'b0;
        2'd1: MUX1 <=  WD[31:0];
        2'd2: MUX1 <= ~WD[31:0] & RD[31:0];
        2'd3: MUX1 <=  RD[31:0] | WD[31:0];
    endcase
end

always@(*)
begin
    case(A[11:0])
        12'h304: begin
            EN_mie         <= OP[1] | OP[0];
            EN_mtvec       <= 1'b0;
            EN_for_scratch <= 1'b0;
            EN_mepc        <= 1'b0;
            EN_for_cause   <= 1'b0;
        end
        12'h305: begin
            EN_mie         <= 1'b0;
            EN_mtvec       <= OP[1] | OP[0];
            EN_for_scratch <= 1'b0;
            EN_mepc        <= 1'b0;
            EN_for_cause   <= 1'b0;
        end
        12'h340: begin
            EN_mie         <= 1'b0;
            EN_mtvec       <= 1'b0;
            EN_for_scratch <= OP[1] | OP[0];
            EN_mepc        <= 1'b0;
            EN_for_cause   <= 1'b0;
        end
        12'h341: begin
            EN_mie         <= 1'b0;
            EN_mtvec       <= 1'b0;
            EN_for_scratch <= 1'b0;
            EN_mepc        <= OP[1] | OP[0];
            EN_for_cause   <= 1'b0;
        end
        12'h342: begin
            EN_mie         <= 1'b0;
            EN_mtvec       <= 1'b0;
            EN_for_scratch <= 1'b0;
            EN_mepc        <= 1'b0;
            EN_for_cause   <= OP[1] | OP[0];
        end
        default: begin
            EN_mie         <= 1'b0;
            EN_mtvec       <= 1'b0;
            EN_for_scratch <= 1'b0;
            EN_mepc        <= 1'b0;
            EN_for_cause   <= 1'b0;
        end
    endcase
end

always@(*)
begin
    case(OP[2])
        1'b0: begin
            MUX1_for_mepc[31:0]  <= MUX1[31:0];
            MUX1_for_cause[31:0] <= MUX1[31:0];
        end
        1'b1: begin
            MUX1_for_mepc[31:0]  <= PC[31:0];
            MUX1_for_cause[31:0] <= mcause[31:0];
        end
    endcase
end

always@(posedge clk)
begin
    if (EN_mie               == 1'b1) mie_reg[31:0]     <= MUX1[31:0];
    if (EN_mtvec             == 1'b1) mtvec_reg[31:0]   <= MUX1[31:0];
    if (EN_mepc | OP[2]      == 1'b1) mepc_reg[31:0]    <= MUX1_for_mepc[31:0];
    if (EN_for_scratch       == 1'b1) for_scratch[31:0] <= MUX1[31:0];
    if (EN_for_cause | OP[2] == 1'b1) for_cause[31:0]   <= MUX1_for_cause[31:0];
end

always@(*)
begin
    case(A[11:0])
        12'h304: RD_reg[31:0] <= mie_reg[31:0];
        12'h305: RD_reg[31:0] <= mtvec_reg[31:0];
        12'h340: RD_reg[31:0] <= for_scratch[31:0];
        12'h341: RD_reg[31:0] <= mepc_reg[31:0];
        12'h342: RD_reg[31:0] <= for_cause[31:0];
    endcase
end

endmodule
