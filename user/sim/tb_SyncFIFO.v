`timescale 1ns / 1ns

`define FILE_PH_VCD "prj/iverilog/tb_SyncFIFO.vcd"

module tb_SyncFIFO();

parameter SYS_CLK_FRE   = 100;               // 50MHz
localparam PERIOD = (1000 / SYS_CLK_FRE);

localparam DEPTH = 10;
localparam WIDTH = 4;

reg                 sys_clk = 1;
reg                 sys_rst_n = 0;

wire                full;
wire                empty;
wire  [WIDTH-1:0]   rddata;

reg                 wren = 0;
reg                 rden = 0;
reg   [WIDTH-1:0]   wrdata = 0;

integer i;

always #(PERIOD/2) sys_clk = ~sys_clk;

initial begin            
    $dumpfile(`FILE_PH_VCD);
    $dumpvars(0, tb_SyncFIFO);
end

initial begin
    #1;
    #(PERIOD*2); sys_rst_n = 1;
    #(PERIOD*2);
    // 先写满fifo
    wren = 1;
    for (i = 0; i < DEPTH; i = i + 1) begin
        wrdata = i; #(PERIOD*1);
    end
    #(PERIOD*2)
    // 再读空fifo
    wren = 0; rden = 1; #(PERIOD*(DEPTH+2));
    // 再写满fifo
    wren = 1; rden = 0;
    for (i = 0; i < DEPTH; i = i + 1) begin
        wrdata = i; #(PERIOD*1);
    end
    #(PERIOD*2)
    // 读一半fifo
    wren = 0; rden = 1; #(PERIOD*(DEPTH/2));
    // 边读边写
    wren = 1; rden = 1;
    for (i = 0; i < DEPTH; i = i + 1) begin
        wrdata = i; #(PERIOD*1);
    end
    // 读空fifo
    wren = 0; rden = 1; #(PERIOD*1);
    $finish;
end

SyncFIFO #(
    .DEPTH      ( DEPTH         ),
    .WIDTH      ( WIDTH         )
)u_SyncFIFO(
    .clk        ( sys_clk       ),
    .asrst      ( ~sys_rst_n    ),
    .wren       ( wren          ),// i
    .wrdata     ( wrdata        ),// i
    .full       ( full          ),// o
    .rden       ( rden          ),// i
    .rddata     ( rddata        ),// o
    .empty      ( empty         ) // o
);


endmodule
