`timescale 1ns / 1ps

`define RESET_ADDR 32'h00000000

`define ALU_OP_WIDTH  5

`define ALU_ADD   5'b00000
`define ALU_SUB   5'b01000

`define ALU_XOR   5'b00100
`define ALU_OR    5'b00110
`define ALU_AND   5'b00111

// shifts
`define ALU_SRA   5'b01101
`define ALU_SRL   5'b00101
`define ALU_SLL   5'b00001

// comparisons
`define ALU_LTS   5'b11100
`define ALU_LTU   5'b11110
`define ALU_GES   5'b11101
`define ALU_GEU   5'b11111
`define ALU_EQ    5'b11000
`define ALU_NE    5'b11001

// set lower than operations
`define ALU_SLTS  5'b00010//`define ALU_SLTS  6'b000010
`define ALU_SLTU  5'b00011//`define ALU_SLTU  6'b000011

// opcodes
`define LOAD_OPCODE      5'b00_000
`define MISC_MEM_OPCODE  5'b00_011
`define OP_IMM_OPCODE    5'b00_100
`define AUIPC_OPCODE     5'b00_101
`define STORE_OPCODE     5'b01_000
`define OP_OPCODE        5'b01_100
`define LUI_OPCODE       5'b01_101
`define BRANCH_OPCODE    5'b11_000
`define JALR_OPCODE      5'b11_001
`define JAL_OPCODE       5'b11_011
`define SYSTEM_OPCODE    5'b11_100

// dmem type load store
`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101

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

// writeback source selection
`define WB_EX_RESULT     1'b0
`define WB_LSU_DATA      1'b1

module dec(
        input   [31:0]               fetched_instr_i,
        input                        INT,
        output  [1:0]                ex_op_a_sel_o,
        output  [2:0]                ex_op_b_sel_o,
        output  [`ALU_OP_WIDTH-1:0]  alu_op_o,
        output                       mem_req_o,
        output                       mem_we_o,
        output  [2:0]                mem_size_o,
        output                       gpr_we_a_o,
        output                       wb_src_sel_o,
        output                       illegal_instr_o,
        output                       branch_o,
        output                       jal_o,
        output  [1:0]                jalr_o,
        output                       csr,
        output                       int_rst,
        output  [2:0]                CSRop
    );

reg illegal_instr_o_r;
reg [1:0] ex_op_a_sel_o_r;
reg [2:0] ex_op_b_sel_o_r;
reg [`ALU_OP_WIDTH-1:0] alu_op_o_r;
reg gpr_we_a_o_r;
reg wb_src_sel_o_r;
reg mem_we_o_r;
reg mem_req_o_r;
reg [2:0] mem_size_o_r;
reg branch_o_r;
reg jal_o_r;
reg [1:0] jalr_o_r;
reg [2:0] CSRop_reg;
reg csr_reg;
reg int_rst_reg;

assign illegal_instr_o              = illegal_instr_o_r;
assign ex_op_a_sel_o[1:0]           = ex_op_a_sel_o_r [1:0];
assign ex_op_b_sel_o[2:0]           = ex_op_b_sel_o_r [2:0];
assign alu_op_o [`ALU_OP_WIDTH-1:0] = alu_op_o_r [`ALU_OP_WIDTH-1:0];
assign gpr_we_a_o                   = gpr_we_a_o_r;
assign wb_src_sel_o                 = wb_src_sel_o_r;
assign mem_we_o                     = mem_we_o_r;
assign mem_req_o                    = mem_req_o_r;
assign mem_size_o [2:0]             = mem_size_o_r [2:0];
assign branch_o                     = branch_o_r;
assign jal_o                        = jal_o_r;
assign jalr_o [1:0]                 = jalr_o_r [1:0];
assign CSRop [2:0]                  = CSRop_reg [2:0];
assign csr                          = csr_reg;
assign int_rst                      = int_rst_reg;

always@(*)
begin
case(fetched_instr_i[1:0])
    2'b11: begin
        if (INT) begin
            CSRop_reg[2]      <= 1'b1;
            CSRop_reg[1:0]    <= 2'b00;
            csr_reg           <= 1'b0;
            branch_o_r        <= 1'b0;
            jal_o_r           <= 1'b0;
            jalr_o_r          <= 2'b11;
            illegal_instr_o_r <= 1'b0;
            mem_req_o_r       <= 1'b0;
            gpr_we_a_o_r      <= 1'b0;
            int_rst_reg       <= 1'b0;
        end
        else begin
        case(fetched_instr_i[6:2])
            `OP_OPCODE: begin
                branch_o_r      <= 1'b0;
                jal_o_r         <= 1'b0;
                jalr_o_r        <= 2'b00;
                ex_op_a_sel_o_r <= `OP_A_RS1;
                ex_op_b_sel_o_r <= `OP_B_RS2;
                gpr_we_a_o_r    <= 1'b1;
                wb_src_sel_o_r  <= `WB_EX_RESULT;
                mem_req_o_r     <= 1'b0;
                CSRop_reg[2:0]  <= 3'b000;
                csr_reg         <= 1'b0;
                int_rst_reg     <= 1'b0;
                case ({fetched_instr_i[31:25],fetched_instr_i[14:12]})
                    10'b0000000000: begin
                        alu_op_o_r        <= `ALU_ADD;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0100000000: begin
                        alu_op_o_r        <= `ALU_SUB;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0000000100: begin
                        alu_op_o_r        <= `ALU_XOR;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0000000110: begin
                        alu_op_o_r        <= `ALU_OR;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0000000111: begin
                        alu_op_o_r        <= `ALU_AND;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0100000101: begin
                        alu_op_o_r        <= `ALU_SRA;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0000000101: begin
                        alu_op_o_r        <= `ALU_SRL;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0000000001: begin
                        alu_op_o_r        <= `ALU_SLL;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0000000010: begin
                        alu_op_o_r        <= `ALU_SLTS;
                        illegal_instr_o_r <= 1'b0;
                    end
                    10'b0000000011: begin
                        alu_op_o_r        <= `ALU_SLTU;
                        illegal_instr_o_r <= 1'b0;
                    end
                    default: illegal_instr_o_r <= 1'b1;
                endcase
            end
            `OP_IMM_OPCODE: begin
                branch_o_r      <= 1'b0;
                jal_o_r         <= 1'b0;
                jalr_o_r        <= 2'b00;
                ex_op_a_sel_o_r <= `OP_A_RS1;
                ex_op_b_sel_o_r <= `OP_B_IMM_I;
                wb_src_sel_o_r  <= `WB_EX_RESULT;
                gpr_we_a_o_r    <= 1'b1;                
                mem_req_o_r     <= 1'b0;
                CSRop_reg[2:0]  <= 3'b000;
                csr_reg         <= 1'b0;
                int_rst_reg     <= 1'b0;
                case (fetched_instr_i[14:12])
                    3'b000: begin
                        alu_op_o_r        <= `ALU_ADD;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b100: begin
                        alu_op_o_r        <= `ALU_XOR;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b110: begin
                        alu_op_o_r        <= `ALU_OR;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b111: begin
                        alu_op_o_r        <= `ALU_AND;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b101: begin
                        case(fetched_instr_i[31:25])
                            7'b0000000: begin
                                alu_op_o_r        <= `ALU_SRL;
                                illegal_instr_o_r <= 1'b0;
                            end
                            7'b0100000: begin
                                alu_op_o_r        <= `ALU_SRA;
                                illegal_instr_o_r <= 1'b0;
                            end
                            default: illegal_instr_o_r <= 1'b1;
                        endcase
                    end
                    3'b001: begin
                        case(fetched_instr_i[31:25])
                            7'b0000000: begin
                                alu_op_o_r        <= `ALU_SLL;
                                illegal_instr_o_r <= 1'b0;
                            end
                        default: illegal_instr_o_r <= 1'b1;
                        endcase
                    end
                    3'b010: begin
                        alu_op_o_r        <= `ALU_SLTS;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b011: begin
                        alu_op_o_r        <= `ALU_SLTU;
                        illegal_instr_o_r <= 1'b0;
                    end
                    default: illegal_instr_o_r <= 1'b1;
                endcase
            end
            `LUI_OPCODE: begin
                branch_o_r        <= 1'b0;
                jal_o_r           <= 1'b0;
                jalr_o_r          <= 2'b00;
                ex_op_a_sel_o_r   <= `OP_A_ZERO;
                ex_op_b_sel_o_r   <= `OP_B_IMM_U;
                alu_op_o_r        <= `ALU_ADD;                
                wb_src_sel_o_r    <= `WB_EX_RESULT;
                gpr_we_a_o_r      <= 1'b1;
                mem_req_o_r       <= 1'b0;
                illegal_instr_o_r <= 1'b0;
                CSRop_reg[2:0]    <= 3'b000;
                csr_reg           <= 1'b0;
                int_rst_reg       <= 1'b0;
            end
            `LOAD_OPCODE: begin
                branch_o_r      <= 1'b0;
                jal_o_r         <= 1'b0;
                jalr_o_r        <= 2'b00;
                ex_op_a_sel_o_r <= `OP_A_RS1;
                ex_op_b_sel_o_r <= `OP_B_IMM_I;
                alu_op_o_r      <= `ALU_ADD;
                gpr_we_a_o_r    <= 1'b1;
                wb_src_sel_o_r  <= `WB_LSU_DATA;                                
                mem_req_o_r     <= 1'b1;
                mem_we_o_r      <= 1'b0;
                CSRop_reg[2:0]  <= 3'b000;
                csr_reg         <= 1'b0;
                int_rst_reg     <= 1'b0;                              
                case(fetched_instr_i[14:12])
                    `LDST_B: begin
                        mem_size_o_r      <= `LDST_B;
                        illegal_instr_o_r <= 1'b0;
                    end
                    `LDST_H: begin
                        mem_size_o_r      <= `LDST_H;
                        illegal_instr_o_r <= 1'b0;
                    end
                    `LDST_W: begin
                        mem_size_o_r      <= `LDST_W;
                        illegal_instr_o_r <= 1'b0;
                    end
                    `LDST_BU: begin
                        mem_size_o_r      <= `LDST_BU;
                        illegal_instr_o_r <= 1'b0;
                    end
                    `LDST_HU: begin
                        mem_size_o_r      <= `LDST_HU;
                        illegal_instr_o_r <= 1'b0;
                    end
                    default: illegal_instr_o_r <= 1'b1;
                endcase
            end
            `STORE_OPCODE: begin
                branch_o_r      <= 1'b0;
                jal_o_r         <= 1'b0;
                jalr_o_r        <= 2'b00;
                ex_op_a_sel_o_r <= `OP_A_RS1;
                ex_op_b_sel_o_r <= `OP_B_IMM_S;
                alu_op_o_r      <= `ALU_ADD;
                gpr_we_a_o_r    <= 1'b0;
                mem_req_o_r     <= 1'b1;
                mem_we_o_r      <= 1'b1;
                CSRop_reg[2:0]  <= 3'b000;
                csr_reg         <= 1'b0;
                int_rst_reg     <= 1'b0;
                case(fetched_instr_i[14:12])
                    `LDST_B: begin
                        mem_size_o_r      <= `LDST_B;
                        illegal_instr_o_r <= 1'b0;
                    end
                    `LDST_H: begin
                        mem_size_o_r      <= `LDST_H;
                        illegal_instr_o_r <= 1'b0;
                    end
                    `LDST_W: begin
                        mem_size_o_r      <= `LDST_W;
                        illegal_instr_o_r <= 1'b0;
                    end
                    default: illegal_instr_o_r <= 1'b1;
                endcase
            end
            `BRANCH_OPCODE: begin
                branch_o_r      <= 1'b1;
                jal_o_r         <= 1'b0;
                jalr_o_r        <= 2'b00;
                ex_op_a_sel_o_r <= `OP_A_RS1;
                ex_op_b_sel_o_r <= `OP_B_RS2;                
                gpr_we_a_o_r    <= 1'b0;
                mem_req_o_r     <= 1'b0;
                CSRop_reg[2:0]  <= 3'b000;
                csr_reg         <= 1'b0;
                int_rst_reg     <= 1'b0;
                case(fetched_instr_i[14:12])
                    3'b100: begin
                        alu_op_o_r        <= `ALU_LTS;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b110: begin
                        alu_op_o_r        <= `ALU_LTU;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b101: begin
                        alu_op_o_r        <= `ALU_GES;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b111: begin
                        alu_op_o_r        <= `ALU_GEU;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b000: begin
                        alu_op_o_r        <= `ALU_EQ;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'b001: begin
                        alu_op_o_r        <= `ALU_NE;
                        illegal_instr_o_r <= 1'b0;
                    end
                    default: illegal_instr_o_r <= 1'b1;
                endcase
            end
            `JAL_OPCODE: begin
                branch_o_r      <= 1'b0;
                jal_o_r         <= 1'b1;
                jalr_o_r        <= 2'b00;
                ex_op_a_sel_o_r <= `OP_A_CURR_PC;
                ex_op_b_sel_o_r <= `OP_B_INCR;
                alu_op_o_r      <= `ALU_ADD;
                gpr_we_a_o_r    <= 1'b1;
                wb_src_sel_o_r  <= `WB_EX_RESULT;
                mem_req_o_r     <= 1'b0;
                illegal_instr_o_r <= 1'b0;
                CSRop_reg[2:0]  <= 3'b000;
                csr_reg         <= 1'b0;
                int_rst_reg     <= 1'b0;
            end
            `JALR_OPCODE: begin
                branch_o_r      <= 1'b0;
                jal_o_r         <= 1'b0;
                jalr_o_r        <= 2'b01;
                ex_op_a_sel_o_r <= `OP_A_CURR_PC;
                ex_op_b_sel_o_r <= `OP_B_INCR;
                alu_op_o_r      <= `ALU_ADD;
                gpr_we_a_o_r    <= 1'b1;
                wb_src_sel_o_r  <= `WB_EX_RESULT;
                mem_req_o_r     <= 1'b0;
                CSRop_reg[2:0]  <= 3'b000;
                csr_reg         <= 1'b0;
                int_rst_reg     <= 1'b0;
                case(fetched_instr_i[14:12])
                    3'b000: begin
                        illegal_instr_o_r <= 1'b0;
                    end
                    default: begin
                        illegal_instr_o_r <= 1'b1;
                    end
                endcase
            end
            `AUIPC_OPCODE: begin
                branch_o_r        <= 1'b0;
                jal_o_r           <= 1'b0;
                jalr_o_r          <= 2'b00;
                ex_op_a_sel_o_r   <= `OP_A_CURR_PC;
                ex_op_b_sel_o_r   <= `OP_B_IMM_U;
                alu_op_o_r        <= `ALU_ADD;
                gpr_we_a_o_r      <= 1'b1;
                wb_src_sel_o_r    <= `WB_EX_RESULT;
                mem_req_o_r       <= 1'b0;
                illegal_instr_o_r <= 1'b0;
                CSRop_reg[2:0]    <= 3'b000;
                csr_reg           <= 1'b0;
                int_rst_reg       <= 1'b0;
            end
            `MISC_MEM_OPCODE: begin
                illegal_instr_o_r <= 1'b0;
                branch_o_r        <= 1'b0;
                jal_o_r           <= 1'b0;
                jalr_o_r          <= 2'b00;
                gpr_we_a_o_r      <= 1'b0;
                mem_req_o_r       <= 1'b0;
                CSRop_reg[2:0]    <= 3'b000;
                csr_reg           <= 1'b0;
                int_rst_reg       <= 1'b0;
            end
            `SYSTEM_OPCODE: begin                
                branch_o_r        <= 1'b0;
                jal_o_r           <= 1'b0;
                mem_req_o_r       <= 1'b0;
                case (fetched_instr_i[14:12])
                    3'd0: begin
                        int_rst_reg       <= 1'b1;
                        csr_reg           <= 1'b0;
                        CSRop_reg[2:0]    <= 3'b000;
                        jalr_o_r          <= 2'b10;
                        gpr_we_a_o_r      <= 1'b0;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'd1: begin
                        int_rst_reg       <= 1'b0;
                        csr_reg           <= 1'b1;
                        CSRop_reg[2:0]    <= 3'b001;
                        jalr_o_r          <= 2'b00;
                        gpr_we_a_o_r      <= 1'b1;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'd2: begin
                        int_rst_reg       <= 1'b0;
                        csr_reg           <= 1'b1;
                        CSRop_reg[2:0]    <= 3'b011;
                        jalr_o_r          <= 2'b00;
                        gpr_we_a_o_r      <= 1'b1;
                        illegal_instr_o_r <= 1'b0;
                    end
                    3'd3: begin
                        int_rst_reg       <= 1'b0;
                        csr_reg           <= 1'b1;
                        CSRop_reg[2:0]    <= 3'b010;
                        jalr_o_r          <= 2'b00;
                        gpr_we_a_o_r      <= 1'b1;
                        illegal_instr_o_r <= 1'b0;
                    end
                    default: illegal_instr_o_r <= 1'b1;
                endcase
            end
            default: illegal_instr_o_r <= 1'b1;
            endcase
            end
    end
    default: illegal_instr_o_r <= 1'b1;
endcase    
end
endmodule
