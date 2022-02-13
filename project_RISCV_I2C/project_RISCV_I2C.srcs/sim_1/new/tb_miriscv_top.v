`timescale 1ns / 1ps

module tb_miriscv_top();

  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 10;         // 10 ns reset
  parameter     RAM_SIZE = 1024;       // in 32-bit words

  reg clk;
  reg rst_n;
  reg [4:0] data_in;
  wire SDA;
  wire SCL;

assign SDA = ans ? SDA_reg : 1'bz;

reg       ans;
reg       SDA_reg;
reg [4:0] cnt_slave = 5'd0;
reg [6:0] addres_slave;
reg       mode_slave;
reg [3:0] state_slave;
reg [7:0] data_slave;
reg [7:0] data_master;

  miriscv_top #(
    .RAM_SIZE       ( RAM_SIZE           ),
    .RAM_INIT_FILE  ( "D:/study/5_semestr/APS/labs_aps/labs_aps.srcs/sources_1/new/I2Cver2.txt" )
    //.RAM_INIT_FILE  ( "D:/study/5_semestr/APS/labs_aps/labs_aps.srcs/sources_1/new/test_int.txt" )
  ) dut (
    .clk_i   ( clk     ),
    .rst_n_i ( rst_n   ),
    .data_in ( data_in ),
    .SDA     ( SDA     ),
    .SCL     ( SCL     )
  );

  initial begin
    clk         <= 1'b0;
    rst_n       <= 1'b0;
    state_slave <= 4'd0;
    ans         <= 1'b0;
    #RST_WAIT;
    rst_n = 1'b1;
    cnt_slave   <= 5'd0;
  //#50
  //data_in <= 5'b00001;
  //#150
  //data_in <= 5'b00010;
 // #150
 // data_in <= 5'b00000;
 // #150
 // data_in <= 5'b01000;
  end

  always begin
    #HF_CYCLE;
    clk = ~clk;
  end

//Display
always@(posedge SCL)
begin
    case(state_slave[3:0])
        4'd0: begin //READ ADRESS
            case(cnt_slave[3:0])
                4'd0: begin
                    addres_slave[6] <= SDA;
                    cnt_slave       <= cnt_slave + 1'b1;
                end
                4'd1: begin
                    addres_slave[5] <= SDA;
                    cnt_slave       <= cnt_slave + 1'b1;
                end
                4'd2: begin
                    addres_slave[4] <= SDA;
                    cnt_slave       <= cnt_slave + 1'b1;
                end
                4'd3: begin
                    addres_slave[3] <= SDA;
                    cnt_slave       <= cnt_slave + 1'b1;
                end
                4'd4: begin
                    addres_slave[2] <= SDA;
                    cnt_slave       <= cnt_slave + 1'b1;
                end
                4'd5: begin
                    addres_slave[1] <= SDA;
                    cnt_slave       <= cnt_slave + 1'b1;
                end
                4'd6: begin
                    addres_slave[0] <= SDA;
                    cnt_slave       <= cnt_slave + 1'b1;
                    end
                4'd7: begin
                    cnt_slave       <= 4'd0;
                    mode_slave      <= SDA;
                    ans             <= 1'b1;
                    state_slave <= 4'd3;
                    if (addres_slave == 7'b1101000) begin
                        SDA_reg     <= 1'b0;
                    end
                    else if (addres_slave == 7'b0100000) begin
                        SDA_reg     <= 1'b0;
                    end
                    else begin
                        SDA_reg     <= 1'b1;
                    end                 
                end
            endcase
        end
        4'd3: begin //ans in 0 after addres
            if (addres_slave == 7'b1101000) begin
                state_slave <= 4'd1;
                if (mode_slave == 1'b1) begin
                    ans <= 1'b1;
                end
                else begin
                    ans <= 1'b0;
                end                
            end
            else if (addres_slave == 7'b0100000) begin
                state_slave <= 4'd2;
                ans       <= 1'b0;
            end
        end
        4'd1: begin
            if (mode_slave == 1'b0) begin
                case(cnt_slave[3:0])
                    4'd0: begin
                        data_slave[7] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd1: begin
                        data_slave[6] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd2: begin
                        data_slave[5] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd3: begin
                        data_slave[4] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd4: begin
                        data_slave[3] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd5: begin
                        data_slave[2] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd6: begin
                        data_slave[1] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd7: begin
                        data_slave[0] <= SDA;
                        cnt_slave     <= 4'd0;
                        ans           <= 1'b1;
                        SDA_reg       <= 1'b0;
                        state_slave   <= 4'd5;
                    end                       
                endcase
            end
            else begin
                case(cnt_slave[3:0])
                    4'd0: begin
                        SDA_reg <= data_master[7];
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd1: begin
                        SDA_reg <= data_master[6];
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd2: begin
                        SDA_reg <= data_master[5];
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd3: begin
                        SDA_reg <= data_master[4];
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd4: begin
                        SDA_reg <= data_master[3];
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd5: begin
                        SDA_reg <= data_master[2];
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd6: begin
                        SDA_reg <= data_master[1];
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd7: begin
                        SDA_reg <= data_master[0];
                        cnt_slave     <= 4'd0;
                        //ans           <= 1'b0;
                        //SDA_reg       <= 1'b0;
                        state_slave   <= 4'd7;
                    end                       
                endcase
            end
        end
        4'd2: begin  // DISPLAY
            if (mode_slave == 1'b0) begin
                case(cnt_slave[3:0])
                    4'd0: begin
                        data_slave[7] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd1: begin
                        data_slave[6] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd2: begin
                        data_slave[5] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd3: begin
                        data_slave[4] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd4: begin
                        data_slave[3] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd5: begin
                        data_slave[2] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd6: begin
                        data_slave[1] <= SDA;
                        cnt_slave     <= cnt_slave + 1'b1;
                    end
                    4'd7: begin
                        data_slave[0] <= SDA;
                        cnt_slave     <= 4'd0;
                        ans           <= 1'b1;
                        SDA_reg       <= 1'b0;
                        state_slave   <= 4'd4;
                    end                       
                endcase
            end
        end
        4'd4: begin //ans in 0
            ans         <= 1'b0;
            if (data_slave == 8'b00000001) begin
                $display("Display is clear");
                state_slave <= 4'd0;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b01100001) begin
                $display("a");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b01100100) begin
                $display("d");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b01110011) begin
                $display("r");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b00100000) begin
                $display(" ");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b01000001) begin
                $display("A");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b01000100) begin
                $display("D");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b01010010) begin
                $display("R");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b01011111) begin
                $display("_");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b00110010) begin
                $display("2");
                state_slave <= 4'd2;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b00110000) begin
                $display("0");
                state_slave <= 4'd0;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b00111000) begin
                $display("2 строки, 8-битный интерфейс, шрифт 5х8 символов");
                state_slave <= 4'd0;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b11000111) begin
                $display("Печать в центре");
                state_slave <= 4'd0;
                data_slave <= 8'd0;
            end            
            if (data_slave == 8'b00000111) begin
                $display("Сдвиг экрана");
                state_slave <= 4'd0;
                data_slave <= 8'd0;
            end
            if (data_slave == 8'b00110101) begin
                $display("5");
                state_slave <= 4'd0;
                data_slave <= 8'd0;
            end
        end
        4'd5: begin
            ans         <= 1'b0;
            if (data_slave == 8'b01110100) begin
                $display("Register FIFO_R_W is choosen");
                state_slave <= 4'd0;
                data_slave <= 8'd0;
                data_master <= 8'b00011001;
            end
        end
        4'd6: begin
            if (SDA == 1'b0) begin
                data_slave <= 8'd0;
            end
        end
        4'd7: begin
            ans <= 1'b0;
            state_slave <= 4'd0;
        end
    endcase
end

endmodule
