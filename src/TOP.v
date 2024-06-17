module TOP(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire spi_clk,
    input wire spi_mosi,
    output wire miso
);
//wire [33:0] freq;
//assign freq_o=freq;
//wire ref_clk_o;
wire [33:0] stand_cnt,test_cnt;
wire clk_d,calc_flag;
Gowin_rPLL ref_OSC(ref_clk_o,sys_clk);
Gowin_OSC OSC_2_5M(clk_test);
freq_cnt_calc new_freq_cnt(ref_clk_o,clk_test,sys_clk,sys_rst_n,stand_cnt,test_cnt,calc_flag);
clk_div #(64) new_clk(sys_clk,sys_rst_n,clk_d);
SPI_Slave #(0) new_spi(i_Rst_L,i_Clk,o_RX_DV,o_RX_Byte,i_TX_DV,i_TX_Byte,i_SPI_Clk,o_SPI_MISO,i_SPI_MOSI,i_SPI_CS_n);
endmodule
