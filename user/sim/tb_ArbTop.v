`timescale 1ns / 1ns

`define FILE_PH_VCD "prj/iverilog/tb_ArbTop.vcd"

module tb_ArbTop();


// commem definition-----------------------------------------
parameter CLK_FRE   = 100;               // 100MHz
localparam PERIOD = (1000 / CLK_FRE);

reg                     clk = 0;
reg                     rst_n;

always #(PERIOD/2) clk = ~clk;

initial begin
    rst_n = 1; #30;
    rst_n = 0; #30;
    rst_n = 1;
end

initial begin            
    $dumpfile(`FILE_PH_VCD);
    $dumpvars(0, tb_ArbTop);
end

// unique definition------------------------------------------

localparam WIDTH = 8;
localparam FIFO_DEPTH = 8;

reg                 i_DataValid_A, i_DataValid_B, i_DataValid_C;
reg   [WIDTH-1:0]   i_DataIn_A,    i_DataIn_B,    i_DataIn_C;
reg                 i_DataGrant_D;

wire                o_DataValid_D;
wire  [WIDTH-1:0]   o_DataOut_D;
wire                o_DataGrant_A, o_DataGrant_B, o_DataGrant_C;

integer i;

initial begin
    // 初始化
    i_DataValid_A = 0; i_DataValid_B = 0; i_DataValid_C = 0;
    i_DataIn_A = 'd0; i_DataIn_B = 'd0; i_DataIn_C = 'd0;
    i_DataGrant_D = 0;
    #6;
    #(PERIOD*10);
    // 三个通道同时有效(4个clk), 但是不给i_DataGrant_D 
    // 此时应该FIFO_A, FIFO_B存入数据
    i_DataValid_A = 1; i_DataValid_B = 1; i_DataValid_C = 1;
    for (i = 0; i < 4; i = i + 1) begin
        i_DataIn_A = i*3; i_DataIn_B = i*3+1; i_DataIn_C = i*3+2; #(PERIOD*1);
    end
    // 轮空wait
    i_DataValid_A = 0; i_DataValid_B = 0; i_DataValid_C = 0; #(PERIOD*4);
    // 三个通道无输入, 但是给i_DataGrant_D
    // 此时应该花至少8个clk把FIFO_A, FIFO_B的数据分别依序读完
    i_DataGrant_D = 1; #(PERIOD*10);
    // 轮空wait
    i_DataGrant_D = 0; #(PERIOD*4);
    // 三个通道同时有效(4个clk), 但是给i_DataGrant_D
    // 此时仲裁轮询输出, 需要花费 8 ~ 12 个clk
    // BUG: 因为没有FIFO, 所以PassC的数据会被丢弃一部分
    i_DataGrant_D = 1;
    i_DataValid_A = 1; i_DataValid_B = 1; i_DataValid_C = 1;
    for (i = 4; i < 8; i = i + 1) begin
        i_DataIn_A = i*3; i_DataIn_B = i*3+1; i_DataIn_C = i*3+2; #(PERIOD*1);
    end
    // 等待把FIFO里的数读完
    i_DataValid_A = 0; i_DataValid_B = 0; i_DataValid_C = 0; #(PERIOD*9);
    i_DataGrant_D = 0; #(PERIOD*3);
    // 构建接口缓存满之后还想存入数据的情况
    // FIFO缓存满的情况如果还想写入数据, 则写入FIFO的数据会被丢弃
    i_DataValid_A = 1; i_DataValid_B = 1; i_DataValid_C = 1;
    for (i = 8; i < 20; i = i + 1) begin
        i_DataIn_A = i*3; i_DataIn_B = i*3+1; i_DataIn_C = i*3+2; #(PERIOD*1);
    end
    // 轮空 wait
    i_DataValid_A = 0; i_DataValid_B = 0; i_DataValid_C = 0; #(PERIOD*4);
    // 读出所有数据, 发现 FIFO 满的情况下还写入的话新数据会被丢弃
    i_DataGrant_D = 1; #(PERIOD*20);
    // 轮空 wait
    i_DataGrant_D = 0; #(PERIOD*4);
    // FIFO_A为空, 如果有数据进入且有授权, 则应该走FIFO旁路输出
    // 以PassA为例:
    i_DataGrant_D = 1; i_DataValid_A = 1;
    for (i = 20; i < 24; i = i + 1) begin
        i_DataIn_A = i*3; #(PERIOD*1);
    end
    i_DataGrant_D = 0; i_DataValid_A = 0;
    // 轮空 wait
    #(PERIOD*20);
    $finish;
end

ArbTop #(
    .WIDTH              ( WIDTH         ),
    .FIFO_DEPTH         ( FIFO_DEPTH    )
)u_ArbTop(
    .CLK                ( clk           ),
    .ASynReset_N        ( rst_n           ),
    .i_DataValid_A      ( i_DataValid_A ),
    .i_DataValid_B      ( i_DataValid_B ),
    .i_DataValid_C      ( i_DataValid_C ),
    .i_DataIn_A         ( i_DataIn_A    ),
    .i_DataIn_B         ( i_DataIn_B    ),
    .i_DataIn_C         ( i_DataIn_C    ),
    .i_DataGrant_D      ( i_DataGrant_D ),
    .o_DataValid_D      ( o_DataValid_D ),
    .o_DataOut_D        ( o_DataOut_D   ),
    .o_DataGrant_A      ( o_DataGrant_A ),
    .o_DataGrant_B      ( o_DataGrant_B ),
    .o_DataGrant_C      ( o_DataGrant_C )
);


endmodule