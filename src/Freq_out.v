module Freq_out(
    input wire [27:0] test_Freq,
    input wire [27:0] stand_Freq,
    input wire calc_flag_reg,
    input wire sys_clk,
    input wire sys_rst_n,
    input wire miso,
    output reg mosi
);
reg [27:0] t_Freq;
reg [27:0] s_Freq;
reg [2:0] stage;
always@(posedge calc_flag_reg or negedge sys_rst_n)
    if (sys_rst_n == 1'b0) begin
        t_Freq<=28'd0;
        s_Freq<=28'd0;
    end
    else begin
        t_Freq<=test_Freq;
        s_Freq<=stand_Freq;
    end
endmodule

//TODO:
//1.SPI_Slave
//2.ADDR:0001=[7:0],0002=[15:8],0003=[23:16]
