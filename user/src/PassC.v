module PassC #(
    parameter WIDTH = 8
)(
    input                       CLK,
    input                       Reset,      // asynchronous reset, high active

    input                       i_WrEn,     // write enable
    input       [WIDTH-1:0]     i_WrData,   // write data

    output reg                  o_Valid,    // 数据有效信号, assign to i_Grant
    output reg  [WIDTH-1:0]     o_Data,

    input                       i_Grant,
    output wire                 o_Grant
);

// o_Grant
assign o_Grant = i_WrEn;

// o_Valid
always @(posedge CLK or posedge Reset) begin
    if (Reset)
        o_Valid <= 'd0;
    else
        o_Valid <= i_Grant;
end

// o_Data
always @(posedge CLK or posedge Reset) begin
    if (Reset)
        o_Data  <= 'd0;
    else if (i_Grant)
        o_Data  <= i_WrData;
end

endmodule