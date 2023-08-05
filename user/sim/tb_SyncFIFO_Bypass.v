`timescale 1ns / 1ns

`define FILE_PH_VCD "prj/iverilog/tb_SyncFIFO_Bypass.vcd"

module tb_SyncFIFO_Bypass();

// commem definition
parameter CLK_FRE   = 100;               // 50MHz
localparam PERIOD = (1000 / CLK_FRE);

reg                     clk = 1;
reg                     rst = 1;

always #(PERIOD/2) clk = ~clk;
always #(PERIOD*2 + PERIOD/2) rst = 0;

initial begin            
    $dumpfile(`FILE_PH_VCD);
    $dumpvars(0, tb_SyncFIFO_Bypass);
end

// unique definition

localparam              DEPTH = 8;
localparam              WIDTH = 8;

reg                     i_WrEn = 0;
reg   [WIDTH-1:0]       i_WrData = 0;
wire                    i_Grant;

wire  [WIDTH-1:0]       o_Data;
wire                    o_Grant;

reg                     o_Grant_reg = 0;
reg   [2:0]             arb_grant = 3'b000;       // 当前正在给其他模块授权

assign i_Grant = (arb_grant[0] && o_Grant) ? 1 : 0;

initial begin
    // 需要控制的信号: i_WrEn, i_WrData, i_Grant_ctrl
    #1;
    #(PERIOD*5);
    // 第一种情况: 其他模块无授权, fifo空, 写入数据
    // 此时应该 SyncFIFO_Bypass 旁路直出数据(1拍)
    i_WrEn = 1;  arb_grant = 3'b001;
    i_WrData = 'd1; #(PERIOD*1);
    i_WrData = 'd2; #(PERIOD*1);
    i_WrData = 'd3; #(PERIOD*1);
    i_WrData = 'd4; #(PERIOD*1);
    i_WrEn = 0; #(PERIOD*4);
    // 第二种情况: 其他模块有授权, fifo空/非空, 写入数据
    // 此时应该 SyncFIFO_Bypass 写入FIFO并给出请求信号 o_Grant
    i_WrEn = 1;  arb_grant = 3'b010;
    i_WrData = 'd5; #(PERIOD*1);
    i_WrData = 'd6; #(PERIOD*1);
    i_WrData = 'd7; #(PERIOD*1);
    i_WrData = 'd8; #(PERIOD*1);
    i_WrEn = 0; #(PERIOD*4);
    // 第三种情况: 其他模块无授权, fifo非空, 写入数据
    // 此时应该 SyncFIFO_Bypass 走FIFO缓存流水
    // 需要 4拍读出老数据 + 4拍读出新数据
    i_WrEn = 1;  arb_grant = 3'b001;
    i_WrData = 'd9;  #(PERIOD*1);
    i_WrData = 'd10; #(PERIOD*1);
    i_WrData = 'd11; #(PERIOD*1);
    i_WrData = 'd12; #(PERIOD*1);
    i_WrEn = 0; #(PERIOD*8);
    // 第二种情况: 其他模块有授权, fifo空/非空, 写入数据
    // 此时应该 SyncFIFO_Bypass 写入FIFO并给出请求信号 o_Grant
    i_WrEn = 1;  arb_grant = 3'b010;
    i_WrData = 'd13; #(PERIOD*1);
    i_WrData = 'd14; #(PERIOD*1);
    i_WrData = 'd15; #(PERIOD*1);
    i_WrData = 'd16; #(PERIOD*1);
    i_WrEn = 0; #(PERIOD*4);
    // 第四种情况: 其他模块无授权, fifo恰好空的时候续上i_WrEn
    // 此时 o_Data 应该是连续的数据
    arb_grant = 3'b001; #(PERIOD*4);  // 先读空4个数据
    i_WrEn = 1;                       // 恰好空的时候续上i_WrEn
    i_WrData = 'd17; #(PERIOD*1);
    i_WrData = 'd18; #(PERIOD*1);
    i_WrData = 'd19; #(PERIOD*1);
    i_WrData = 'd20; #(PERIOD*1);
    i_WrEn = 0; #(PERIOD*4);
    $finish;
end

SyncFIFO_Bypass #(
    .DEPTH          ( DEPTH     ),
    .WIDTH          ( WIDTH     )
)u0(
    .CLK            ( clk       ),
    .Reset          ( rst       ),
    .i_WrEn         ( i_WrEn    ),
    .i_WrData       ( i_WrData  ),
    .i_Grant        ( i_Grant   ),
    .o_Valid        (           ),
    .o_Data         ( o_Data    ),
    .o_Grant        ( o_Grant   )
);

endmodule