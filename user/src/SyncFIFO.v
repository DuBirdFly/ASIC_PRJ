// 注意: !!!!不支持同时读写一个条目, 这是题目规定的

// 注意: clog2 是 Verilog-2005 添加的, 如果使用其他版本, 需要将DEPTH替换为ADDR_WIDTH

// 说明: 前缀的WR/wr表示write, RD/rd表示read

// Verilog使用Latch阵列实现一个读写宽度一致的同步FIFO, 接口如下:

module SyncFIFO #(
    parameter DEPTH = 256,                  // 必须是2的幂次
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

reg  [WIDTH-1:0] mem [ADDR_WIDTH-1:0];      // fifo memory

reg  [ADDR_WIDTH-1:0] wrptr, rdptr;         // ptr = pointer, cnt = cnt

reg  [ADDR_WIDTH:0] cnt;                    // 因为full是由'cnt==DEPTH'得到的, 所以cnt需要多1位

always @(posedge clk or posedge asrst) begin
    if (asrst) begin
        wrptr <= 'd0;
        rdptr <= 'd0;
        rddata <= 'd0;
        cnt <= 'd0;
    end
    else if (wren && !full) begin
        mem[wrptr] <= wrdata;
        wrptr <= wrptr + 'd1;               // 指针的追逐是溢出控制的, 所以要求param-DEPTH必须是2的幂次
        cnt <= cnt + 'd1;
    end
    else if (rden && !empty) begin
        rddata <= mem[rdptr];
        rdptr <= rdptr + 'd1;
        cnt <= cnt - 'd1;
    end
end

assign full = (cnt == DEPTH);
assign empty = (cnt == 0);

endmodule