`timescale 1ns / 1ps

`define LDST_B           3'b000
`define LDST_H           3'b001
`define LDST_W           3'b010
`define LDST_BU          3'b100
`define LDST_HU          3'b101

module miriscv_lsu(
                    input          clk_i,    // синхронизация
                    input          arstn_i,  // сброс внутренних регистров   
                    // memory protocol
                    input  [31 :0] data_rdata_i,    // запрошенные данные
                    output         data_req_o, //   1  - обратиться к памяти
                    output         data_we_o, //   1  - это запрос на запись
                    output [3:0]   data_be_o, // к каким байтам слова идет обращение
                    output [31 :0] data_addr_o, // адрес, по которому идет обращение
                    output [31 :0] data_wdata_o, // данные, которые требуется записать
                    //   core    protocol
                    input  [31 :0] lsu_addr_i, // адрес, по которому хотим обратиться
                    input          lsu_we_i, //   1  - если нужно записатьв память
                    input  [2:0]   lsu_size_i, // размер обрабатываемых данных
                    input  [31 :0] lsu_data_i, // данные для записи в память
                    input          lsu_req_i, //   1  - обратиться к памяти
                    output         lsu_stall_req_o, // используетсякак !enable pc  
                    output [31 :0] lsu_data_o // данные считанные из памяти
    );
reg         data_we_o_reg;
reg [3:0]   data_be_o_reg;
reg [31 :0] data_wdata_o_reg;

reg [31 :0] lsu_data_o_reg;
reg         cnt;

reg lsu_stall_req_o_reg;
assign lsu_stall_req_o = lsu_stall_req_o_reg;
assign data_req_o      = lsu_stall_req_o_reg;
assign data_we_o       = lsu_stall_req_o_reg && lsu_we_i;


assign data_addr_o     = lsu_addr_i;
assign data_be_o       = data_be_o_reg;
assign data_wdata_o    = data_wdata_o_reg;
assign lsu_data_o      = lsu_data_o_reg;

always@(*)
begin
    if (lsu_req_i) begin
        if (lsu_we_i) begin
            case(lsu_size_i)
                `LDST_B: begin
                    data_wdata_o_reg <= { 4{lsu_data_i[7:0]} };
                    case(lsu_addr_i[1:0])
                        2'b00: data_be_o_reg <= 4'b0001;
                        2'b01: data_be_o_reg <= 4'b0010;
                        2'b10: data_be_o_reg <= 4'b0100;
                        2'b11: data_be_o_reg <= 4'b1000;
                    endcase
                end
                `LDST_H: begin
                    data_wdata_o_reg <= { 2{lsu_data_i[15:0]} };
                    case(lsu_addr_i[1:0])
                        2'b00: data_be_o_reg <= 4'b0011;
                        2'b10: data_be_o_reg <= 4'b1100;
                    endcase
                end
                `LDST_W: begin
                    data_wdata_o_reg <= lsu_data_i[31:0];
                    if (lsu_addr_i[1:0] == 2'b00) begin
                        data_be_o_reg <= 4'b1111;
                    end
                end
            endcase
        end
        if (!lsu_we_i) begin
            case(lsu_size_i)
                `LDST_B: begin
                    case(lsu_addr_i[1:0])
                        2'b00: lsu_data_o_reg <= {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
                        2'b01: lsu_data_o_reg <= {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
                        2'b10: lsu_data_o_reg <= {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
                        2'b11: lsu_data_o_reg <= {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
                    endcase
                end
                `LDST_H: begin
                    case(lsu_addr_i[1:0])
                        2'b00: lsu_data_o_reg <= {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};
                        2'b10: lsu_data_o_reg <= {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
                    endcase
                end
                `LDST_W: begin
                    if (lsu_addr_i[1:0] == 2'b00) begin
                        lsu_data_o_reg <= data_rdata_i[31:0];
                    end
                end
                `LDST_BU: begin
                    case(lsu_addr_i[1:0])
                        2'b00: lsu_data_o_reg <= {24'b0, data_rdata_i[7:0]};
                        2'b01: lsu_data_o_reg <= {24'b0, data_rdata_i[15:8]};
                        2'b10: lsu_data_o_reg <= {24'b0, data_rdata_i[23:16]};
                        2'b11: lsu_data_o_reg <= {24'b0, data_rdata_i[31:24]};
                    endcase
                end
                `LDST_HU: begin
                    case(lsu_addr_i[1:0])
                        2'b00: lsu_data_o_reg <= {16'b0, data_rdata_i[15:0]};
                        2'b10: lsu_data_o_reg <= {16'b0, data_rdata_i[31:16]};
                    endcase
                end
            endcase
        end
    end
end

always@(*)
begin
    if (cnt == 1'b0) begin
        if (lsu_req_i) begin
            lsu_stall_req_o_reg <= 1'b1;
        end
        else begin
            lsu_stall_req_o_reg <= 1'b0;
        end
    end
    else begin
        lsu_stall_req_o_reg <= 1'b0;
    end
end

always@(posedge clk_i) begin
    if (!arstn_i) begin
        cnt <= 1'b0;
    end
    else begin
    if (cnt == 1'b0) begin
        if (lsu_req_i) begin
            cnt <= 1'b1;
        end
    end
    else begin
        cnt <= 1'b0;
    end
    end
end

endmodule
