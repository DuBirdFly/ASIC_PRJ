// 公平轮转仲裁器
// 注意: o_grant 和 req_vld 没有1拍的延迟
// https://zhuanlan.zhihu.com/p/622241131

module RoundRobinArbiter(
    input wire clk,
    input wire asrst,           // asynchronous reset, high active
    input wire en,
    input wire [2:0] req_vld,
    output reg [2:0] o_grant
);

reg [2:0] last_grant;           // 上一clk的优先级

always @(*) begin
    if (en)
        case (last_grant)
            'b001: begin
                if      (req_vld[1]) o_grant <= 3'b010;
                else if (req_vld[2]) o_grant <= 3'b100;
                else if (req_vld[0]) o_grant <= 3'b001;
                else                 o_grant <= 3'b000;
            end
            'b010: begin
                if      (req_vld[2]) o_grant <= 3'b100;
                else if (req_vld[0]) o_grant <= 3'b001;
                else if (req_vld[1]) o_grant <= 3'b010;
                else                 o_grant <= 3'b000;
            end
            'b100: begin
                if      (req_vld[0]) o_grant <= 3'b001;
                else if (req_vld[1]) o_grant <= 3'b010;
                else if (req_vld[2]) o_grant <= 3'b100;
                else                 o_grant <= 3'b000;
            end
            default: o_grant <= 3'b000;
        endcase
    else
        o_grant <= 3'b000;
end

// last_grant
always @(posedge clk or posedge asrst) begin
    if (asrst) last_grant <= 'b100;
    else if (en && (| req_vld)) begin
        last_grant <= o_grant;
    end
end

endmodule