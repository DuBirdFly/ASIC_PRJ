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
    parameter DEPTH = 8,
    parameter WIDTH = 64
)(
    input                       CLK,
    input                       Reset,      // asynchronous reset

    input                       i_WrEn,     // write enable
    input       [WIDTH-1:0]     i_WrData,   // write data

    output                      o_Valid,    // valid
    output wire [WIDTH-1:0]     o_Data,

    // i_Grant = 1: 输出信号在"下一拍!"可变; i_Grant = 0: 输出信号(o_Valid, o_Data)不允许改变
    input                       i_Grant,
    // 下一级模块的授权信号, 用于控制下一级i_Grant信号
    output                      o_Grant
);

wire                    fifo_wren, fifo_rden;
wire                    fifo_full, fifo_empty;
wire  [WIDTH-1:0]       fifo_wrdata, fifo_rddata;

reg   [WIDTH-1:0]       i_WrData_reg;       // 用于旁路的寄存器

assign fifo_wren = i_WrEn;      // 当i_Grant不给授权, i_WrEn又一直要写, 最后把fifo写爆了的话我可不管
assign fifo_wrdata = i_WrData;  // 写入数据
assign fifo_rden = i_Grant;     // 授权信号有效时, 读出数据

// o_Grant信号的生成: 


// Bypass mechanism
always @(posedge CLK) i_WrData_reg <= i_WrData;             // 用于旁路的寄存器
always @(posedge CLK or posedge Reset) begin
    if (Reset) begin
        o_Valid <= 1'b0;
    end
    else begin
        // TODO
    end
end
// fifo空时, 直接输出i_WrData_reg
assign o_Data  = (i_Grant && fifo_empty) ? i_WrData_reg : fifo_rddata;   

SyncFIFO #(
    .DEPTH      ( DEPTH         ),
    .WIDTH      ( WIDTH         )
)u_SyncFIFO(
    .clk        ( clk           ),
    .asrst      ( Reset         ),
    .wren       ( fifo_wren     ),
    .wrdata     ( fifo_wrdata   ),
    .full       ( fifo_full     ),
    .rden       ( fifo_rden     ),
    .rddata     ( fifo_rddata   ),
    .empty      ( fifo_empty    )
);

endmodule