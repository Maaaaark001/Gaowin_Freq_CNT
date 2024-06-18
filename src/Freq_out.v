module Freq_out(
    input wire [27:0] test_Freq,
    input wire [27:0] stand_Freq,
    input wire calc_flag_reg,
    input wire sys_clk,
    input wire sys_rst_n,
    input wire i_SPI_Clk,
    input wire i_SPI_CS_n,
    input wire miso,
    output reg mosi
);
reg [27:0] t_Freq;
reg [27:0] s_Freq;
reg [2:0] stage;
reg [7:0] out_reg;


wire o_RX_DV;
wire [7:0] o_RX_Byte;
wire i_TX_DV;
wire [7:0] i_TX_Byte;

SPI_Slave #(0) new_spi(sys_rst_n,sys_clk,o_RX_DV,o_RX_Byte,i_TX_DV,i_TX_Byte,i_SPI_Clk,miso,mosi,i_SPI_CS_n);

always@(posedge calc_flag_reg or negedge sys_rst_n)begin
    if (sys_rst_n == 1'b0) begin
        t_Freq<=28'd0;
        s_Freq<=28'd0;
    end
    else begin
        t_Freq<=test_Freq;
        s_Freq<=stand_Freq;
    end
end
always@(posedge o_RX_DV or negedge sys_rst_n)begin
    if (sys_rst_n == 1'b0) begin
        out_reg<=8'd0;
    end
    else begin
        case(o_RX_Byte)
            8'd1: out_reg<=t_Freq[7:0];
            8'd2: out_reg<=t_Freq[15:8];
            8'd3: out_reg<=t_Freq[23:16];
            8'd4: out_reg<=s_Freq[7:0];
            8'd5: out_reg<=s_Freq[15:8];
            8'd6: out_reg<=s_Freq[23:16];
            default : out_reg<=8'd0;
        endcase
    end
end
assign i_TX_DV=out_reg;


endmodule



//TODO:
//1.test
//
