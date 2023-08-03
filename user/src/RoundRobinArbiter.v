module RoundRobinArbiter(
    input            clk,
    input            rstn,
    input            en,
    input      [2:0] req_vld,
    output reg [2:0] o_grant            // 组合逻辑输出
);

    reg [3:0] priority;                 // 实质上不过是o_grant_delay1罢了

    always @(posedge clk or negedge rstn) begin
        if (!rstn) priority <= 'b001;
        else if (en & ( |req_vld )) priority <= o_grant;
    end

    always @(*) begin
        o_grant = 'b000;
        
        if (en) begin
            case(priority)
            // 优先级1>2>0 
            'b001: begin
                if      (req_vld[1]) o_grant = 'b010;
                else if (req_vld[2]) o_grant = 'b100;
                else if (req_vld[0]) o_grant = 'b001;
            end
            // 优先级2>0>1
            'b010: begin
                if      (req_vld[2]) o_grant = 'b010;
                else if (req_vld[0]) o_grant = 'b100;
                else if (req_vld[1]) o_grant = 'b001;
            end
            // 优先级0>1>2
            default: begin
                if      (req_vld[0]) o_grant = 'b010;
                else if (req_vld[1]) o_grant = 'b100;
                else if (req_vld[2]) o_grant = 'b001;
            end
            endcase
        end

    end

    

endmodule
