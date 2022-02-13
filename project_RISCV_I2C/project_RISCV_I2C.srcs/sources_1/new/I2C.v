`timescale 1ns / 1ps

module I2C(
           inout         SDA,
           output        SCL,
           input  [31:0] addr_mem,
           input         we,
           input  [31:0] data,
           input  [3:0]  be,
           output [31:0] wr_data_en,
           output [31:0] rd_data,          
           output [31:0] rd_data_en,
           input         rst,
           input         clk
    );
reg [7:0]  wr_data_en_reg;   
reg [31:0] data_slave;
reg [7:0]  rd_data_en_reg;
reg        SCL_reg;
reg        SDA_reg;
reg [7:0]  rd_data_reg;
reg [2:0]  num_byte;
reg [6:0]  flag;
reg [6:0]  addr_slave;
reg [2:0]  state;
reg [3:0]  cnt;
reg        cnt_SCL; 
reg        write_en;
reg        read_en;
reg [8:0]  cnt_clk;

assign rd_data    = rd_data_reg;
assign SCL        = SCL_reg;
assign SDA        = SDA_reg;
assign wr_data_en = {wr_data_en_reg[7:0], 24'b0};
assign rd_data_en = {16'b0, rd_data_en_reg[7:0], 8'b0};

initial begin
    SCL_reg        <= 1'b1;
    SDA_reg        <= 1'b1;
    wr_data_en_reg <= 2'b00;
    rd_data_en_reg <= 1'b0;
    write_en       <= 1'b0;
    read_en        <= 1'b0;
end

always@(posedge clk or posedge rst)
begin
    if (!rst) begin
        rd_data_en_reg <= 1'b0;
        SCL_reg        <= 1'b1;
        SDA_reg        <= 1'b1;
        cnt            <= 4'd0;
        cnt_SCL        <= 1'b0;
        state          <= 3'd6;
    end
    else begin
        if (we) begin
            case(addr_mem[2:0])
                3'b000: begin
                    addr_slave <= data[6:0];
                end
                3'b001: begin
                    if (wr_data_en_reg == 2'b00 | wr_data_en_reg == 2'b01) begin
                        wr_data_en_reg  <= 2'b11;
                        data_slave <= data[31:0];
                        if ( be[3:0] == 4'b0001 | be[3:0] == 4'b0010 | be[3:0] == 4'b0100 | be[3:0] == 4'b1000 ) begin
                            num_byte <= 3'd1;
                        end
                        else if ( be[3:0] == 4'b0011 | be[3:0] == 4'b1100 ) begin
                            num_byte <= 3'd2;
                        end
                        else if ( be[3:0] == 4'b1111 ) begin
                            num_byte <= 3'd4;
                        end
                    end
                end
                3'b010: begin
                    case(data[0])
                        1'b0: begin
                            write_en <= 1'b0;
                            read_en  <= 1'b1;
                        end
                        1'b1: begin
                            write_en <= 1'b1;
                            read_en  <= 1'b0;
                        end                
                    endcase  
                end
            endcase
        end
        if (state == 3'd7 & cnt_clk != 9'd249) begin
            if (num_byte == 1'b0) begin
                wr_data_en_reg <= 2'b01;
            end
        end
        if (cnt_clk != 9'd249) begin
            cnt_clk <= cnt_clk + 1'b1;
        end
        else begin       
            cnt_clk <= 9'b0;
            if ((cnt_SCL == 1'b1) && (state != 4'd6)) begin
                SCL_reg <= ~SCL_reg;
                cnt_SCL <= 1'b0;
            end
            if (cnt_SCL == 1'b0 || state == 4'd6 || state == 4'd7 || state == 4'd3) begin
                case (state[2:0])
                    3'd0: begin //ADRESS, WRITE
                        case (cnt[3:0])
                            4'd0: begin
                                SDA_reg <= addr_slave[6];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd1: begin
                                SDA_reg <= addr_slave[5];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd2: begin
                                SDA_reg <= addr_slave[4];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd3: begin
                                SDA_reg <= addr_slave[3];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd4: begin
                                SDA_reg <= addr_slave[2];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd5: begin
                                SDA_reg <= addr_slave[1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd6: begin
                                SDA_reg <= addr_slave[0];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd7: begin
                                SDA_reg <= 1'b0;
                                cnt     <= 4'd0;
                                state   <= 3'd2;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                        endcase
                    end
                    3'd1: begin //ADRESS, READ
                        case (cnt[3:0])
                            4'd0: begin
                                SDA_reg <= addr_slave[6];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd1: begin
                                SDA_reg <= addr_slave[5];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd2: begin
                                SDA_reg <= addr_slave[4];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd3: begin
                                SDA_reg <= addr_slave[3];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd4: begin
                                SDA_reg <= addr_slave[2];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd5: begin
                                SDA_reg <= addr_slave[1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd6: begin
                                SDA_reg <= addr_slave[0];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd7: begin
                                SDA_reg <= 1'b1;
                                cnt     <= 4'd0;
                                state   <= 3'd3;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                        endcase
                    end
                    3'd2: begin //WAITING ANS, WRITE
                        SDA_reg <= 1'bz;
                        SCL_reg <= ~SCL_reg;
                        if (SDA == 1'b0) begin
                            state   <= 3'd4;
                            cnt_SCL <= 1'b1;                        
                        end
                    end
                    3'd3: begin //WAITING ANS, READ
                        case(cnt[3:0])
                            4'd0: begin
                                SDA_reg <= 1'bz;
                                SCL_reg <= ~SCL_reg;
                                cnt <= cnt + 1'b1;
                            end
                            4'd1: begin
                                SCL_reg <= ~SCL_reg;
                                cnt <= cnt + 1'b1;
                            end
                            4'd2: begin
                                SCL_reg <= ~SCL_reg;
                                cnt <= cnt + 1'b1;
                            end
                            4'd3: begin
                                SCL_reg <= ~SCL_reg;
                                cnt <= 4'd0;
                                if (SDA == 1'b0) begin
                                    cnt_SCL <= 1'b1;
                                    state   <= 3'd5;                       
                                end 
                            end
                        endcase
                    end
                    3'd4: begin //WRITE
                        case (cnt[3:0])
                            4'd0: begin
                                SDA_reg <= data_slave[num_byte*8 - cnt[3:0] - 1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd1: begin
                                SDA_reg <= data_slave[num_byte*8 - cnt[3:0] - 1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd2: begin
                                SDA_reg <= data_slave[num_byte*8 - cnt[3:0] - 1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd3: begin
                                SDA_reg <= data_slave[num_byte*8 - cnt[3:0] - 1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd4: begin
                                SDA_reg <= data_slave[num_byte*8 - cnt[3:0] - 1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd5: begin
                                SDA_reg <= data_slave[num_byte*8 - cnt[3:0] - 1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd6: begin
                                SDA_reg <= data_slave[num_byte*8 - cnt[3:0] - 1];
                                cnt     <= cnt + 1'b1;
                                cnt_SCL <= 1'b1;
                                SCL_reg <= ~SCL_reg;
                            end
                            4'd7: begin
                                SDA_reg  <= data_slave[num_byte*8 - cnt[3:0] - 1];
                                cnt      <= 4'd0;
                                cnt_SCL  <= 1'b1;
                                SCL_reg  <= ~SCL_reg;
                                flag     <= num_byte;
                                state    <= 3'd7;
                                num_byte <= num_byte - 1'b1;
                            end
                        endcase
                    end
                    3'd5: begin //READ
                        case (cnt[3:0])
                            4'd0: begin
                                rd_data_reg[7] <= SDA;
                                cnt            <= cnt + 1'b1;
                                cnt_SCL        <= 1'b1;
                                SCL_reg        <= ~SCL_reg;
                            end
                            4'd1: begin
                                rd_data_reg[6] <= SDA;
                                cnt            <= cnt + 1'b1;
                                cnt_SCL        <= 1'b1;
                                SCL_reg        <= ~SCL_reg;
                            end
                            4'd2: begin
                                rd_data_reg[5] <= SDA;
                                cnt            <= cnt + 1'b1;
                                cnt_SCL        <= 1'b1;
                                SCL_reg        <= ~SCL_reg;
                            end
                            4'd3: begin
                                rd_data_reg[4] <= SDA;
                                cnt            <= cnt + 1'b1;
                                cnt_SCL        <= 1'b1;
                                SCL_reg        <= ~SCL_reg;
                            end
                            4'd4: begin
                                rd_data_reg[3] <= SDA;
                                cnt            <= cnt + 1'b1;
                                cnt_SCL        <= 1'b1;
                                SCL_reg        <= ~SCL_reg;
                            end
                            4'd5: begin
                                rd_data_reg[2] <= SDA;
                                cnt            <= cnt + 1'b1;
                                cnt_SCL        <= 1'b1;
                                SCL_reg        <= ~SCL_reg;
                            end
                            4'd6: begin
                                rd_data_reg[1] <= SDA;
                                cnt            <= cnt + 1'b1;
                                cnt_SCL        <= 1'b1;
                                SCL_reg        <= ~SCL_reg;
                            end
                            4'd7: begin
                                rd_data_reg[0] <= SDA;
                                cnt            <= cnt + 1'b1;
                                cnt_SCL        <= 1'b1;
                                SCL_reg        <= ~SCL_reg;
                                SDA_reg        <= 1'b1;
                            end
                            4'd8: begin
                                SDA_reg        <= 1'b0;
                                cnt            <= 4'd0;
                                rd_data_en_reg <= 1'b1;
                                state          <= 3'd6;
                                cnt_SCL        <= 1'b1;
                            end
                        endcase
                    end
                    3'd6: begin //IDLE
                        SCL_reg        <= 1'b1;                    
                        rd_data_en_reg <= 1'b0;
                        if (write_en == 1'b1) begin
                            state        <= 3'd0;                        
                            SDA_reg      <= 1'b0;
                            cnt_SCL      <= 1'b0;
                            write_en     <= 1'b0;
                        end
                        if (read_en == 1'b1) begin
                            state        <= 3'd1;
                            SDA_reg      <= 1'b0;
                            cnt_SCL      <= 1'b0;
                            read_en      <= 1'b0;
                        end
                        if ((write_en == 1'b0) && (read_en == 1'b0)) begin
                            cnt_SCL <= 1'b0;
                            if (SCL_reg == 1'b1) begin
                                SDA_reg <= 1'b1;
                            end
                            else begin
                                SDA_reg <= 1'b0;
                            end                       
                        end
                    end
                    3'd7: begin //WAITING ANS, WRITE
                        case(cnt[3:0])
                            4'd0: begin
                                SDA_reg <= 1'bz;
                                SCL_reg <= ~SCL_reg;
                                cnt <= cnt + 1'b1;
                            end
                            4'd1: begin
                                SDA_reg <= 1'bz;
                                SCL_reg <= ~SCL_reg;
                                cnt <= 4'd0;
                                if (SDA == 1'b0) begin
                                    cnt_SCL <= 1'b1;
                                    if (num_byte == 1'b0) begin
                                        state          <= 3'd6;
                                        wr_data_en_reg <= 2'b00;                                
                                    end
                                    if (num_byte != 1'b0) begin
                                        state   <= 3'd4;
                                    end                        
                                end 
                            end
                        endcase                                      
                    end
                endcase
            end
        end
    end
end
endmodule
