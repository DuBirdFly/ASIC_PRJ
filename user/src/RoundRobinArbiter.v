// 公平轮转仲裁器
// 输入端口: clk, rstn, en, req_vld[2:0]
// 输出端口: o_grant[2:0]

module RoundRobinArbiter(
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [2:0] req_vld,
    output reg [2:0] o_grant
);

reg [2:0] last_grant;           // 上一clk的优先级

always @(posedge clk) begin
    if (en) begin
        case (last_grant)
            'b001: begin
                if      (req_vld[0]) o_grant <= 3'b001;
                else if (req_vld[1]) o_grant <= 3'b010;
                else if (req_vld[2]) o_grant <= 3'b100;
                else                 o_grant <= 3'b000;
            end
            'b010: begin
                if      (req_vld[1]) o_grant <= 3'b010;
                else if (req_vld[2]) o_grant <= 3'b100;
                else if (req_vld[0]) o_grant <= 3'b001;
                else                 o_grant <= 3'b000;
            end
            'b100: begin
                if      (req_vld[2]) o_grant <= 3'b100;
                else if (req_vld[0]) o_grant <= 3'b001;
                else if (req_vld[1]) o_grant <= 3'b010;
                else                 o_grant <= 3'b000;
            end
            default: o_grant <= 3'b000;
        endcase
    end
    else
        o_grant <= 3'b000;
end

// last_grant
always @(posedge clk or negedge rstn) begin
    if (!rstn) last_grant <= 'b001;
    else if (en) begin
        if (o_grant[0])
            last_grant <= 'b001;
        else if (o_grant[1])
            last_grant <= 'b010;
        else if (o_grant[2])
            last_grant <= 'b100;
    end
end

endmodule