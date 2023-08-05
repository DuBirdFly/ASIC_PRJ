/*
关于 Grant(授权) 信号, GhatGPT的回答:
    在带有旁路缓冲的FIFO中，Grant通常指的是授权信号，也称为输入端口的读取授权信号和输出端口的写入授权信号。
    在FIFO中，由于读取和写入是异步的，因此需要一种机制来确保读取和写入的正确性和同步性，这就是授权信号的作用。
    当一个读取请求或写入请求到达FIFO时，FIFO需要检查是否有足够的空间或数据可用，
    如果有，它将向请求方发送授权信号，表示可以进行读取或写入操作。
    如果没有足够的空间或数据可用，FIFO将不会发送授权信号，请求方将需要等待，直到有足够的空间或数据可用为止。
    授权信号通常由FIFO的控制电路生成。
*/

// 旁路先出FIFO, 也就是当FIFO为空且wren有效时, 直接将wrdata输出到rddata (1个DFF打拍)
// SyncFIFO_Bypass模块之外使用"公平轮转策略仲裁器"来控制信号

// 有一个大问题!!!: (i_WrEn && i_Grant)时, 
// 若fifo_emply, 则正常流水读出, 但是若fifo不empty, fifo会发生wren与rden同时存在的情况, 与设计方案不符
// 先姑且认为fifo不empty时, wren与rden有效且保持先入先出顺序

module SyncFIFO_Bypass #(
    parameter   DEPTH = 8,
    parameter   WIDTH = 64
)(
    input                       CLK,
    input                       Reset,      // asynchronous reset

    input                       i_WrEn,     // write enable
    input       [WIDTH-1:0]     i_WrData,   // write data

    output reg                  o_Valid,    // 数据有效信号, assign to i_Grant
    output wire [WIDTH-1:0]     o_Data,     // 组合逻辑

    // i_Grant = 1: 输出信号在"下一拍!"可变; i_Grant = 0: 输出信号(o_Valid, o_Data)不允许改变
    input                       i_Grant,
    // 下一级模块的授权信号, 用于控制下一级i_Grant信号; 也就是仲裁器的req_vld[2:0]
    output wire                 o_Grant     // 组合逻辑
);

wire                    fifo_wren, fifo_rden;
wire                    fifo_empty;
wire  [WIDTH-1:0]       fifo_wrdata, fifo_rddata;

reg   [WIDTH-1:0]       i_WrData_reg;       // 用于旁路的寄存器
reg                     i_Grant_reg;        // 用于旁路的寄存器

// 用于旁路的寄存器, DFF
always @(posedge CLK) begin
    i_WrData_reg <= i_WrData;
    i_Grant_reg  <= i_Grant;
end

// 只要授权信号有效, 那么下一拍的数据必然是有效数据
assign o_Valid = i_Grant;

// BUG: 当i_Grant不给授权, i_WrEn又一直要写, 最后把fifo写爆了的话我可不管
// 当 i_WrEn = 1 时, 检定是需要"写入fifo"还是"旁路输出":
//      当"fifo是空的"且"有授权信号", 此时i_WrEn应该走"旁路输出", 所以此时fifo_wren = 0
assign fifo_wren = (i_WrEn && i_Grant && fifo_empty) ? 0 : i_WrEn;

// 写入数据
assign fifo_wrdata = i_WrData;

// 授权信号有效时读出数据.  若fifo_empty, 再读还是empty, 也就不需要 assign fifo_rden = empty ? 0 : i_Grant;
assign fifo_rden = i_Grant;

// o_Grant信号是控制下一级i_Grant信号的信号, 也就是仲裁器 req_vld[2:0] 的其中一位
// 1. 当fifo不empty, 则o_Grant = 1
// 2. 当fifo_empty, 此时只要有i_WrEn, 就组合逻辑 o_Grant = 1
//    注:如果 i_Grant 暂时未响应, 则数据写入fifo, 下一拍fifo就不再empty, 则继续输出o_Grant = 1直至fifo_empty
assign o_Grant = fifo_empty ? i_WrEn : 1;

// fifo空时, 直接输出i_WrData_reg
assign o_Data  = (i_Grant_reg && fifo_empty) ? i_WrData_reg : fifo_rddata;

SyncFIFO #(
    .DEPTH      ( DEPTH         ),
    .WIDTH      ( WIDTH         )
)u_SyncFIFO(
    .clk        ( CLK           ),
    .asrst      ( Reset         ),
    .wren       ( fifo_wren     ),
    .wrdata     ( fifo_wrdata   ),
    .full       (               ),
    .rden       ( fifo_rden     ),
    .rddata     ( fifo_rddata   ),
    .empty      ( fifo_empty    )
);

endmodule