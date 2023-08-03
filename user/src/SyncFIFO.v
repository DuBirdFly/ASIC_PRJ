// 注意: !!!!不支持同时读写一个条目, 这是题目规定的

// 注意: clog2 是 Verilog-2005 添加的, 如果使用其他版本, 需要将DEPTH替换为ADDR_WIDTH

// 说明: 前缀的WR/wr表示write, RD/rd表示read

// Verilog使用Latch阵列实现一个读写宽度一致的同步FIFO, 使用计数器法
// 参数: DEPTH, WIDTH
// 输入: clk, asrst, wren, wrdata, rden
// 输出: full, rddata, empty

module SyncFIFO #(
    parameter DEPTH = 192,
    parameter WIDTH = 8
)(
    input                           clk,
    input                           asrst,  // asynchronous reset
    // FIFO WRITE
    input                           wren,   // write enable
    input           [WIDTH-1:0]     wrdata, // write data
    output   wire                   full,
    // FIFO READ
    input                           rden,   // read enable
    output   reg    [WIDTH-1:0]     rddata, // read data
    output   wire                   empty
);

localparam ADDR_WIDTH = $clog2(DEPTH);      // Verilog-2005 添加了clog函数

reg  [WIDTH-1:0] mem [0:DEPTH-1];           // fifo memory

reg  [ADDR_WIDTH-1:0] wrptr;                // ptr = pointer
reg  [ADDR_WIDTH-1:0] rdptr;

reg  [ADDR_WIDTH:0] cnt;                    // 因为full是由'cnt==DEPTH'得到的, 所以cnt需要多1位

// read
always @(posedge clk or posedge asrst) begin
    if (asrst) begin
        rdptr  <= 'd0;
        rddata <= 'd0;
    end 
    else if (rden && !empty) begin
        rddata <= mem[rdptr];
        if (rdptr < DEPTH - 1) 
            rdptr <= rdptr + 'd1;
        else rdptr <= 'd0;
    end
end

// write:
always @(posedge clk or posedge asrst) begin
    if (asrst) begin
        wrptr <= 'd0;
    end 
    else if (wren && !full) begin
        mem[wrptr] <= wrdata;
        if (wrptr < DEPTH - 1) 
            wrptr <= wrptr + 'd1;
        else wrptr <= 'd0;
    end
end

// cnt: 写而未满自增, 读而未空自减, 否则不变
always @(posedge clk or posedge asrst) begin
    if (asrst) 
        cnt <= 'd0;
    else if (wren && !rden && !full)
        cnt <= cnt + 'd1;
    else if (!wren && rden && !empty)
        cnt <= cnt - 'd1;
end

assign full = (cnt == DEPTH);
assign empty = (cnt == 0);

endmodule