module miriscv_top
#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = "D:/study/5_semestr/APS/labs_aps/labs_aps.srcs/sources_1/new/run1.txt"
)
(
  // clock, reset
  input       clk_i,
  input       rst_n_i,
  input [4:0] data_in,
  inout       SDA,
  output      SCL
);
  
  logic  [31:0]  int_req_i;
  logic  [31:0]  int_fin_o;
  logic  [31:0]  instr_rdata_core;
  logic  [31:0]  instr_addr_core;

  logic  [31:0]  data_rdata_core;
  logic          data_req_core;
  logic          data_we_core;
  logic  [3:0]   data_be_core;
  logic  [31:0]  data_addr_core;
  logic  [31:0]  data_wdata_core;

  logic  [31:0]  data_rdata_ram;
  logic          data_req_ram;
  logic          data_we_ram;
  logic  [3:0]   data_be_ram;
  logic  [31:0]  data_addr_ram;
  logic  [31:0]  data_wdata_ram;

  assign data_be_ram      =  data_be_core;
  assign data_addr_ram    =  data_addr_core;
  assign data_wdata_ram   =  data_wdata_core;

  logic INT;
  logic [31:0] mcause;
  logic int_rst;
  logic [31:0] mie;
  logic data_we_d0;
  logic data_we_d1;
  logic [31:0] data_rdata_d1;
  logic [31:0] data_rdata_d2;
  logic [31:0] data_rdata_d3;
  logic [1:0] RDsel;
  
  new_proc core (
    .clk_i   ( clk_i   ),
    .arstn_i ( rst_n_i ),

    .instr_rdata_i ( instr_rdata_core ),
    .INT           ( INT              ),
    .mcause        ( mcause[31:0]     ),
    .instr_addr_o  ( instr_addr_core  ),

    .data_rdata_i  ( data_rdata_core  ),
    .data_req_o    ( data_req_core    ),
    .data_we_o     ( data_we_core     ),
    .data_be_o     ( data_be_core     ),
    .data_addr_o   ( data_addr_core   ),
    .data_wdata_o  ( data_wdata_core  ),
    .int_rst       ( int_rst          ),
    .mie           ( mie[31:0]        )
  );

  miriscv_ram
  #(
    .RAM_SIZE      (RAM_SIZE),
    .RAM_INIT_FILE (RAM_INIT_FILE)
  ) ram (
    .clk_i   ( clk_i   ),
    .rst_n_i ( rst_n_i ),

    .instr_rdata_o ( instr_rdata_core ),
    .instr_addr_i  ( instr_addr_core  ),

    .data_rdata_o  ( data_rdata_ram  ),
    .data_req_i    ( data_req_ram    ),
    .data_we_i     ( data_we_ram     ),
    .data_be_i     ( data_be_ram     ),
    .data_addr_i   ( data_addr_ram   ),
    .data_wdata_i  ( data_wdata_ram  )
  );

  Interrupt_Controller IC(
    .clk     ( clk_i           ),
    .mie     ( mie[31:0]       ),
    .int_req ( int_req_i[31:0] ),
    .INT_RST ( int_rst         ),
    .mcause  ( mcause[31:0]    ),
    .INT     ( INT             ),
    .int_fin ( int_fin_o[31:0] )
  );
  
  addr_dec addr_decoder (
    .req   ( data_req_core  ),
    .we    ( data_we_core   ),
    .addr  ( data_addr_core ),
    .req_m ( data_req_ram   ),
    .we_m  ( data_we_ram    ),
    .we_d0 ( data_we_d0     ),
    .we_d1 ( data_we_d1     ),
    .RDsel ( RDsel          )
);

  leds blink (
    .clk  ( clk_i           ),
    .we   ( data_we_d0      ),
    .data ( data_wdata_core )
);

  buttons press(
    .data_in  ( data_in[4:0]   ),
    .data_out ( int_req_i[4:0] )
  );

  I2C I2C_interface(
    .SDA        ( SDA             ),
    .SCL        ( SCL             ),
    .addr_mem   ( data_addr_core  ),
    .we         ( data_we_d1      ),
    .data       ( data_wdata_core ),
    .be         ( data_be_core    ),
    .wr_data_en ( data_rdata_d1   ),
    .rd_data    ( data_rdata_d2   ),  
    .rd_data_en ( data_rdata_d3   ),
    .rst        ( rst_n_i         ),
    .clk        ( clk_i           )
);

always@(*)
begin
    case (RDsel[1:0])
        3'd0 : data_rdata_core <= data_rdata_ram;
        3'd1 : data_rdata_core <= data_rdata_d1;
        3'd2 : data_rdata_core <= data_rdata_d2;
        3'd3 : data_rdata_core <= data_rdata_d3;
    endcase
end
endmodule
