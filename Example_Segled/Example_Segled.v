module Example_Segled
(  
   //输入端口 
   CLK_50M,RST_N,
   //输出端口
   SEG_DATA,SEG_EN
);
   
input                CLK_50M;          //时钟的端口,开发板用的50M晶振
input                RST_N;            //复位的端口,低电平复位
output reg  [ 5:0]   SEG_EN;           //数码管使能端口
output reg  [ 7:0]   SEG_DATA;         //数码管数据端口(查看管脚分配文档或者原理图)

reg         [15:0]   time_cnt;         //用来控制数码管闪烁频率的定时计数器
reg         [15:0]   time_cnt_n;       //time_cnt的下一个状态
reg         [ 2:0]   led_cnt;          //用来控制数码管亮灭及显示数据的显示计数器
reg         [ 2:0]   led_cnt_n;        //led_cnt的下一个状态

//设置定时器的时间为10ms,计算方法为  (10*10^3)us / (1/50)us  50MHz为开发板晶振
parameter SET_TIME_10MS = 16'd500_000;      

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)  
begin
   if(!RST_N)                          //判断复位
      time_cnt <= 16'h0;               //初始化time_cnt值
   else
      time_cnt <= time_cnt_n;          //用来给time_cnt赋值
end

//组合电路,实现10ms的定时计数器
always @ (*)  
begin
   if(time_cnt == SET_TIME_10MS)       //判断10ms时间
      time_cnt_n = 16'h0;              //如果到达10ms,定时计数器将会被清零
   else
      time_cnt_n = time_cnt + 27'h1;   //如果未到10ms,定时计数器将会继续累加
end

//时序电路,用来给led_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)  
begin
   if(!RST_N)                          //判断复位
      led_cnt <= 3'h0;                 //初始化led_cnt值
   else
      led_cnt <= led_cnt_n;            //用来给led_cnt赋值
end

//组合电路,判断时间，实现控制显示计数器累加
always @ (*)  
begin
   if(time_cnt == SET_TIME_10MS)       //判断10ms时间   
      led_cnt_n = led_cnt + 1'h1;      //如果到达10ms,计数器进行累加
   else
      led_cnt_n = led_cnt;             //如果未到10ms,计数器保持不变
end

//组合电路,实现数码管的数字显示
always @ (*)
begin
   case (led_cnt)  
      3'b000 : SEG_DATA = 8'b10111111; //当计数器为0时,数码管将会显示 "0"
      3'b001 : SEG_DATA = 8'b10000110; //当计数器为1时,数码管将会显示 "1"
      3'b010 : SEG_DATA = 8'b11011011; //当计数器为2时,数码管将会显示 "2"
      3'b011 : SEG_DATA = 8'b11001111; //当计数器为3时,数码管将会显示 "3"
      3'b100 : SEG_DATA = 8'b11100110; //当计数器为4时,数码管将会显示 "4"
      3'b101 : SEG_DATA = 8'b11101101; //当计数器为5时,数码管将会显示 "5" 
      default: SEG_DATA = 8'b10111111; 
   endcase  
end

//组合电路,控制数码管亮灭
always @ (*)
begin
   case (led_cnt)  
      3'b000 : SEG_EN = 6'b111110;     //当计数器为0时,数码管SEG1显示
      3'b001 : SEG_EN = 6'b111101;     //当计数器为1时,数码管SEG2显示
      3'b010 : SEG_EN = 6'b111011;     //当计数器为2时,数码管SEG3显示
      3'b011 : SEG_EN = 6'b110111;     //当计数器为3时,数码管SEG4显示
      3'b100 : SEG_EN = 6'b101111;     //当计数器为4时,数码管SEG5显示
      3'b101 : SEG_EN = 6'b011111;     //当计数器为5时,数码管SEG6显示    
      default: SEG_EN = 6'b111111;        
   endcase  
end
endmodule
