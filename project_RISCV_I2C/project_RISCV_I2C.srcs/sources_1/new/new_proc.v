`timescale 1ns / 1ps

`define RESET_ADDR 32'h00000000

`define ALU_OP_WIDTH  5

// operand a selection
`define OP_A_RS1         2'b00
`define OP_A_CURR_PC     2'b01
`define OP_A_ZERO        2'b10

// operand b selection
`define OP_B_RS2         3'b000
`define OP_B_IMM_I       3'b001
`define OP_B_IMM_U       3'b010
`define OP_B_IMM_S       3'b011
`define OP_B_INCR        3'b100

module new_proc(
            input         clk_i,
            input         arstn_i,
            input  [31:0] instr_rdata_i,
            input         INT,
            input  [31:0] mcause,
            output [31:0] instr_addr_o,
            input  [31:0] data_rdata_i,
            output        data_req_o,
            output        data_we_o,
            output [3:0]  data_be_o,
            output [31:0] data_addr_o,
            output [31:0] data_wdata_o,
            output        int_rst,
            output [31:0] mie
            );

reg  [31:0] PC;
assign instr_addr_o[31:0] = PC[31:0];

wire [31:0] sum_PC;

wire [31:0] instr = instr_rdata_i[31:0];
wire [1:0] jalr;
wire jal;
wire branch;
wire gpr_we_a;
wire mem_req;
wire mem_we;
wire [2:0] mem_size;
wire [`ALU_OP_WIDTH-1:0] alu_op;
wire [1:0] ex_op_a_sel;
wire [2:0] ex_op_b_sel;
wire wb_src_sel;
wire illegal_instr;

wire [31:0] imm_I;
wire [31:0] imm_S;
wire [31:0] imm_J;
wire [31:0] imm_B;

wire [31:0] J_or_B;

wire [31:0] RD1;
wire [31:0] RD2;

reg [31:0] A;
reg [31:0] B;

wire [31:0] res_alu;
wire comp;

wire [31:0] write_reg;
wire [31:0] read_data;

wire n_en_PC;

wire csr;
wire [2:0] CSRop;
wire [31:0] mtvec;
wire [31:0] mepc;
wire [31:0] RD_for_csr;

initial PC   <= 32'b0;

dec decoder(.fetched_instr_i(instr), 
            .INT            (INT),
            .ex_op_a_sel_o  (ex_op_a_sel[1:0]), 
            .ex_op_b_sel_o  (ex_op_b_sel[2:0]),
            .alu_op_o       (alu_op[`ALU_OP_WIDTH-1:0]), 
            .mem_req_o      (mem_req),
            .mem_we_o       (mem_we), 
            .mem_size_o     (mem_size[2:0]), 
            .gpr_we_a_o     (gpr_we_a), 
            .wb_src_sel_o   (wb_src_sel), 
            .illegal_instr_o(illegal_instr), 
            .branch_o       (branch), 
            .jal_o          (jal), 
            .jalr_o         (jalr[1:0]),
            .csr            (csr),
            .int_rst        (int_rst),
            .CSRop          (CSRop[2:0]));

RF register_file(.clk(clk_i), 
                 .A1 (instr[19:15]), 
                 .A2 (instr[24:20]), 
                 .A3 (instr[11:7]),
                 .WE3(gpr_we_a), 
                 .WD3(write_reg[31:0]), 
                 .RD1(RD1[31:0]), 
                 .RD2(RD2[31:0]));

ALU alu5(.ALUOp(alu_op[`ALU_OP_WIDTH-1:0]), 
         .A     (A), 
         .B     (B), 
         .Result(res_alu[31:0]), 
         .Flag  (comp));

miriscv_lsu LSU(.clk_i          (clk_i), 
                .arstn_i        (arstn_i), 
                .data_rdata_i   (data_rdata_i[31:0]), 
                .data_req_o     (data_req_o), 
                .data_we_o      (data_we_o), 
                .data_be_o      (data_be_o), 
                .data_addr_o    (data_addr_o[31:0]), 
                .data_wdata_o   (data_wdata_o[31:0]),
                .lsu_addr_i     (res_alu[31:0]), 
                .lsu_we_i       (mem_we), 
                .lsu_size_i     (mem_size[2:0]),
                .lsu_data_i     (RD2[31:0]), 
                .lsu_req_i      (mem_req), 
                .lsu_stall_req_o(n_en_PC), 
                .lsu_data_o     (read_data[31:0]));

Control_Status_Reg CSR(.clk     (clk_i),
                       .OP      (CSRop[2:0]),
                       .mcause  (mcause[31:0]),
                       .PC      (PC[31:0]),
                       .A       (instr_rdata_i[31:20]),
                       .WD      (RD1[31:0]),
                       .mie     (mie[31:0]),
                       .mtvec   (mtvec[31:0]),
                       .mepc    (mepc[31:0]),
                       .RD      (RD_for_csr[31:0]));

assign imm_I[31:0] = { {20{instr[31]}}, instr[31:20]};
assign imm_S[31:0] = { {20{instr[31]}}, instr[31:25], instr[11:7]};
assign imm_J[31:0] = { {13{instr[31]}}, instr[19:12],  instr[20], instr[30:21], 1'b0};
assign imm_B[31:0] = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

assign J_or_B[31:0] = branch ? imm_B[31:0] : imm_J[31:0];
assign sum_PC[31:0] = ( jal | (comp & branch) ) ? J_or_B[31:0] : 32'd4;

assign write_reg[31:0] = csr ? RD_for_csr[31:0] : (wb_src_sel ? read_data[31:0] : res_alu[31:0]);

always@(posedge clk_i)
begin
    if (!arstn_i) begin
        PC <= `RESET_ADDR;
    end
    else begin
        if (!n_en_PC) begin
            case(jalr[1:0])
                2'd0: PC <= PC + sum_PC;
                2'd1: PC <= RD1 + imm_I;
                2'd2: PC <= mepc;
                2'd3: PC <= mtvec;
            endcase
        end
    end
end

always@(*)
begin
    case(ex_op_a_sel)
        `OP_A_RS1: begin
            A <= RD1[31:0];
        end
        `OP_A_CURR_PC: begin
            A <= PC[31:0];
        end
        `OP_A_ZERO: begin
            A <= 32'd0;
        end
    endcase
end

always@(*)
begin
    case(ex_op_b_sel)
        `OP_B_RS2: begin
            B <= RD2[31:0];
        end
        `OP_B_IMM_I: begin
            B <= imm_I[31:0];
        end
        `OP_B_IMM_U: begin
            B <= {instr[31:12], 12'b0};
        end
        `OP_B_IMM_S: begin
            B <= imm_S[31:0];
        end
        `OP_B_INCR: begin
            B <= 32'd1;
        end
    endcase
end

endmodule

