module TOP(
    input wire sys_clk,
    input wire sys_rst_n,
    input clk_test,
    output wire [33:0] freq_o
);
//wire [33:0] freq;
//assign freq_o=freq;
//wire ref_clk_o;
Gowin_rPLL ref_OSC(ref_clk_o,sys_clk);
Gowin_OSC OSC_2_5M(clk_test);
freq_cnt_calc new_freq_cnt(ref_clk_o,clk_test,sys_clk,sys_rst_n,freq_o);

endmodule
