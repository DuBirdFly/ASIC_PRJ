`timescale 1ns / 1ns

`define FILE_PH_VCD "prj/iverilog/tb_Arb.vcd"

module tb_Arb();

parameter SYS_CLK_FRE   = 50;               // 50MHz
localparam PERIOD = (1000 / SYS_CLK_FRE);

reg             sys_clk = 1;
reg             sys_rst_n = 0;

reg             en = 0;
reg     [2:0]   req_vld = 0;
wire    [2:0]   o_grant;

always #(PERIOD/2) sys_clk = ~sys_clk;
always #(PERIOD*2 + PERIOD/2) sys_rst_n = 1;

initial begin            
    $dumpfile(`FILE_PH_VCD);
    $dumpvars(0, tb_Arb);
end

initial begin
    #1;
    #(PERIOD*4) en = 1;
    #(PERIOD*2) req_vld = 3'b111;
    #(PERIOD*8) req_vld = 3'b000;
    #(PERIOD*8) req_vld = 3'b001;
    #(PERIOD*8) req_vld = 3'b110;
    #(PERIOD*8) req_vld = 3'b011;
    #(PERIOD*8) req_vld = 3'b101;
    #(PERIOD*8) req_vld = 3'b011;
    #(PERIOD*8) req_vld = 3'b111;en = 0;
    #(PERIOD*8) $finish;
end

RoundRobinArbiter u_Arb(
    .clk         ( sys_clk      ),
    .rstn        ( sys_rst_n    ),
    .en          ( en           ),
    .req_vld     ( req_vld      ),
    .o_grant     ( o_grant      )
);

endmodule