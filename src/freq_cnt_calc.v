module freq_cnt_calc (
    input wire clk_stand,
    input wire clk_test,
    input wire sys_clk,
    input wire sys_rst_n,
    output reg [27:0] cnt_clk_stand_reg,
    output reg [27:0] cnt_clk_test_reg,
    output reg calc_flag_reg
);
  //parameter define
  parameter CNT_GATE_S_MAX = 28'd26_999_999,  //软件闸门计数器计数最大值
  CNT_RISE_MAX = 28'd3_000_000;  //软件闸门拉高计数值
  parameter CLK_STAND_FREQ = 28'd60_000_000;  //标准时钟时钟频率
  //wire  define
wire            gate_a_fall_s       ;   //实际闸门下降沿(标准时钟下)
wire            gate_a_fall_t       ;   //实际闸门下降沿(待检测时钟下)

//reg   define
reg     [27:0]  cnt_gate_s          ;   //软件闸门计数器
reg             gate_s              ;   //软件闸门
reg             gate_a              ;   //实际闸门
reg             gate_a_stand        ;   //实际闸门打一拍(标准时钟下)
reg             gate_a_test         ;   //实际闸门打一拍(待检测时钟下)
reg     [27:0]  cnt_clk_stand       ;   //标准时钟周期计数器
//reg     [27:0]  cnt_clk_stand_reg   ;   //实际闸门下标志时钟周期数
reg     [27:0]  cnt_clk_test        ;   //待检测时钟周期计数器
//reg     [27:0]  cnt_clk_test_reg    ;   //实际闸门下待检测时钟周期数
reg             calc_flag           ;   //待检测时钟时钟频率计算标志信号
reg     [33:0]  freq_reg            ;   //待检测时钟频率寄存
//reg             calc_flag_reg       ;   //待检测时钟频率输出标志信号
reg     [33:0]  freq_ff             ;
//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//cnt_gate_s:软件闸门计数器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_gate_s  <=  28'd0;
    else    if(cnt_gate_s == CNT_GATE_S_MAX)
        cnt_gate_s  <=  28'd0;
    else
        cnt_gate_s  <=  cnt_gate_s + 1'b1;

//gate_s:软件闸门
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_s  <=  1'b0;
    else    if((cnt_gate_s>= CNT_RISE_MAX)
                && (cnt_gate_s <= (CNT_GATE_S_MAX - CNT_RISE_MAX)))
        gate_s  <=  1'b1;
    else
        gate_s  <=  1'b0;

//gate_a:实际闸门
always@(posedge clk_test or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_a  <=  1'b0;
    else
        gate_a  <=  gate_s;

//cnt_clk_stand:标准时钟周期计数器,计数实际闸门下标准时钟周期数
always@(posedge clk_stand or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk_stand   <=  28'd0;
    else    if(gate_a == 1'b0)
        cnt_clk_stand   <=  28'd0;
    else    if(gate_a == 1'b1)
        cnt_clk_stand   <=  cnt_clk_stand + 1'b1;

//cnt_clk_test:待检测时钟周期计数器,计数实际闸门下待检测时钟周期数
always@(posedge clk_test or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk_test    <=  28'd0;
    else    if(gate_a == 1'b0)
        cnt_clk_test    <=  28'd0;
    else    if(gate_a == 1'b1)
        cnt_clk_test    <=  cnt_clk_test + 1'b1;

//gate_a_stand:实际闸门打一拍(标准时钟下)
always@(posedge clk_stand or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_a_stand    <=  1'b0;
    else
        gate_a_stand    <=  gate_a;

//gate_a_fall_s:实际闸门下降沿(标准时钟下)
assign  gate_a_fall_s = ((gate_a_stand == 1'b1) && (gate_a == 1'b0))
                        ? 1'b1 : 1'b0;

//cnt_clk_stand_reg:实际闸门下标志时钟周期数
always@(posedge clk_stand or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk_stand_reg   <=  28'd0;
    else    if(gate_a_fall_s == 1'b1)
        cnt_clk_stand_reg   <=  cnt_clk_stand;

//gate_a_test:实际闸门打一拍(待检测时钟下)
always@(posedge clk_test or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_a_test <=  1'b0;
    else
        gate_a_test <=  gate_a;

//gate_a_fall_t:实际闸门下降沿(待检测时钟下)
assign  gate_a_fall_t = ((gate_a_test == 1'b1) && (gate_a == 1'b0))
                        ? 1'b1 : 1'b0;

//cnt_clk_test_reg:实际闸门下待检测时钟周期数
always@(posedge clk_test or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk_test_reg   <=  28'd0;
    else    if(gate_a_fall_t == 1'b1)
        cnt_clk_test_reg   <=  cnt_clk_test;

//calc_flag:待检测时钟时钟频率计算标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        calc_flag   <=  1'b0;
    else    if(cnt_gate_s == (CNT_GATE_S_MAX - 1'b1))
        calc_flag   <=  1'b1;
    else
        calc_flag   <=  1'b0;

//freq_reg:待检测时钟信号时钟频率寄存
//always@(posedge sys_clk or negedge sys_rst_n)
//    if(sys_rst_n == 1'b0)
//        freq_reg    <=  34'd0;
//    else    if(calc_flag == 1'b1)
//        freq_reg    <=  (CLK_STAND_FREQ * cnt_clk_test_reg / cnt_clk_stand_reg);

//calc_flag_reg:待检测时钟频率输出标志信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        calc_flag_reg   <=  1'b0;
    else
        calc_flag_reg   <=  calc_flag;


//always@(posedge sys_clk or negedge sys_rst_n)begin
//    if(sys_rst_n == 1'b0)begin
//        freq    <=  34'd0;
//        freq_ff <=  34'd0;
//    end
//    else begin
//        if(calc_flag_reg == 1'b1)begin
//        freq_ff    <=  freq_reg[33:0];
//        freq    <=  freq_ff[33:0];
//        end
//    end
//end

endmodule
