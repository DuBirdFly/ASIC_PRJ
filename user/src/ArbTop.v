module ArbTop #(
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

// TODO: 快来写




endmodule