module ArbTop #(
    parameter   FIFO_DEPTH = 8,
    parameter   WIDTH = 64
)(
    // sys
    input                       CLK,
    input                       ASynReset_N,
    // input
    input                       i_DataValid_A, i_DataValid_B, i_DataValid_C,
    input       [WIDTH-1:0]     i_DataIn_A,    i_DataIn_B,    i_DataIn_C,
    input                       i_DataGrant_D,
    // output
    output wire                 o_DataValid_D,
    output wire [WIDTH-1:0]     o_DataOut_D,
    output wire                 o_DataGrant_A, o_DataGrant_B, o_DataGrant_C
);

wire                SynReset_N;
wire  [2:0]         arb_req, arb_grant;
wire                PassA_DataVld, PassB_DataVld, PassC_DataVld;
wire  [WIDTH-1:0]   PassA_Data,    PassB_Data,    PassC_Data;

assign {o_DataGrant_C, o_DataGrant_B, o_DataGrant_A} = arb_grant;

assign o_DataValid_D = (PassA_DataVld || PassB_DataVld || PassC_DataVld);

assign o_DataOut_D = PassA_DataVld ? PassA_Data :
                     PassB_DataVld ? PassB_Data :
                     PassC_DataVld ? PassC_Data :
                     0;

// 异步复位, 同步释放
RstGen u_RstGen(
    .clk        ( CLK           ),
    .asrst_n    ( ASynReset_N   ),
    .srst_n     ( SynReset_N    )
);

// 仲裁器
RoundRobinArbiter u_RoundRobinArbiter(
    .clk        ( CLK           ),
    .asrst      ( ~SynReset_N   ),
    .en         ( i_DataGrant_D ),
    .req_vld    ( arb_req       ),
    .o_grant    ( arb_grant     )
);

// FIFO缓冲通路A
SyncFIFO_Bypass #(
    .DEPTH      ( FIFO_DEPTH    ),
    .WIDTH      ( WIDTH         )
) u_PassA (
    .CLK        ( CLK           ),
    .Reset      ( ~SynReset_N   ),
    .i_Grant    ( arb_grant[0]  ),
    .i_WrEn     ( i_DataValid_A ),
    .i_WrData   ( i_DataIn_A    ),
    .o_Grant    ( arb_req[0]    ),
    .o_Valid    ( PassA_DataVld ),
    .o_Data     ( PassA_Data    )
);

// FIFO缓冲通路B
SyncFIFO_Bypass #(
    .DEPTH      ( FIFO_DEPTH    ),
    .WIDTH      ( WIDTH         )
) u_PassB (
    .CLK        ( CLK           ),
    .Reset      ( ~SynReset_N   ),
    .i_Grant    ( arb_grant[1]  ),
    .i_WrEn     ( i_DataValid_B ),
    .i_WrData   ( i_DataIn_B    ),
    .o_Grant    ( arb_req[1]    ),
    .o_Valid    ( PassB_DataVld ),
    .o_Data     ( PassB_Data    )
);

// BUG: 当PassA和PassB都有arb_req时, PassC会有数据丢失
PassC #(
    .WIDTH      ( WIDTH         )
)u_PassC (
    .CLK        ( CLK           ),
    .Reset      ( ~SynReset_N   ),
    .i_Grant    ( arb_grant[2]  ),
    .i_WrEn     ( i_DataValid_C ),
    .i_WrData   ( i_DataIn_C    ),
    .o_Grant    ( arb_req[2]    ),
    .o_Valid    ( PassC_DataVld ),
    .o_Data     ( PassC_Data    )
);

endmodule