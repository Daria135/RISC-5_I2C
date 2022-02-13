`timescale 1ns / 1ps

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


module ALU(
           input [`ALU_OP_WIDTH-1:0] ALUOp,
           input [31:0] A,
           input [31:0] B,
           output reg [31:0] Result,
           output reg Flag
    );

always@(*)
begin
case(ALUOp)
    `ALU_ADD: begin
        Result <= A + B; 
        Flag   <= 0;
    end
    `ALU_SUB: begin
        Result <= A - B; 
        Flag   <= 0;
    end
    `ALU_SLL: begin
        Result <= A<<B[4:0];
        Flag   <= 0;
    end
    `ALU_LTS: begin
        Result <= ($signed(A) < $signed(B)) ? 1:0;
        Flag   <= ($signed(A) < $signed(B)) ? 1:0;
    end
    `ALU_LTU: begin
        Result <= ($unsigned(A) < $unsigned(B)) ? 1:0;
        Flag   <= ($unsigned(A) < $unsigned(B)) ? 1:0;
    end 
    `ALU_XOR: begin
        Result <= A^B;
        Flag   <= 0;
    end 
    `ALU_SRL: begin
        Result <= A>>B[4:0];
        Flag   <= 0;
    end
    `ALU_SRA: begin
        Result <= A>>>B[4:0];
        Flag   <= 0;
    end
    `ALU_OR: begin
        Result <= A|B;
        Flag   <= 0;
    end
    `ALU_AND: begin
        Result <= A&B;
        Flag   <= 0;
    end
    `ALU_EQ: begin
        Result <= (A==B)? 1:0;
        Flag   <= (A==B)? 1:0;
    end
    `ALU_NE: begin
        Result <= ((A!=B))? 1:0;
        Flag   <= (~(A==B))? 1:0;
    end 
    //`LESSF: begin
    //    Result =  ($signed(A) < $signed(B)) ? 1:0;
    //    Flag = ($signed(A) < $signed(B)) ? 1:0;
    //end
    `ALU_GES: begin
        Result <=  (~($signed(A) < $signed(B))) ? 1:0;
        Flag   <= (~($signed(A) < $signed(B))) ? 1:0;
    end
    //`UNSLESSF: begin
    //    Result =  ($unsigned(A) < $unsigned(B)) ? 1:0;
    //    Flag = ($unsigned(A) < $unsigned(B)) ? 1:0;
    //end
    `ALU_GEU: begin
        Result <=  (~($unsigned(A) < $unsigned(B))) ? 1:0;
        Flag   <= (~($unsigned(A) < $unsigned(B))) ? 1:0;
    end    
endcase
end
endmodule