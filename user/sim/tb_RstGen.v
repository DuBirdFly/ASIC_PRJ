`timescale 1ns / 1ns

`define FILE_PH_VCD "prj/iverilog/tb_RstGen.vcd"

module tb_RstGen();

// commem definition-----------------------------------------
parameter CLK_FRE   = 100;               // 100MHz
localparam PERIOD = (1000 / CLK_FRE);    // 10ns

reg             clk = 0;

always #(PERIOD/2) clk = ~clk;

initial begin            
    $dumpfile(`FILE_PH_VCD);
    $dumpvars(0, tb_RstGen);
end

// unique definition------------------------------------------

reg             asrst_n = 0;
wire            srst_n;

initial begin
    #7;
    #(PERIOD*1) asrst_n = 1;
    #(PERIOD*4+PERIOD/2) asrst_n = 0;
    #(PERIOD*2+PERIOD/2) asrst_n = 1;

    #(PERIOD*5) $finish;
end

RstGen u_RstGen(
	.clk     	( clk      ),
	.asrst_n 	( asrst_n  ),
	.srst_n  	( srst_n   )
);


endmodule