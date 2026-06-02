module uart_tx #(
    parameter integer CLK_HZ   = 50_000_000,
    parameter integer BAUDRATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,
    input  wire       data_vld,   // 拉高1个clk，启动发送1字节
    output reg        tx,
    output reg        busy
);

    localparam integer BAUD_DIV = CLK_HZ / BAUDRATE;

    reg [15:0] baud_cnt;
    reg        baud_tick;

    reg [3:0]  bit_cnt;
    reg [9:0]  shifter;   // {stop, data[7:0], start}

    //==========================================================
    // 波特率节拍
    //==========================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt  <= 16'd0;
            baud_tick <= 1'b0;
        end else if (busy) begin
            if (baud_cnt == BAUD_DIV - 1) begin
                baud_cnt  <= 16'd0;
                baud_tick <= 1'b1;
            end else begin
                baud_cnt  <= baud_cnt + 16'd1;
                baud_tick <= 1'b0;
            end
        end else begin
            baud_cnt  <= 16'd0;
            baud_tick <= 1'b0;
        end
    end

    //==========================================================
    // UART发送状态机：8N1
    // idle=1, start=0, data LSB first, stop=1
    //==========================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx      <= 1'b1;      // 空闲高电平
            busy    <= 1'b0;
            bit_cnt <= 4'd0;
            shifter <= 10'h3FF;
        end else begin
            if (!busy) begin
                tx <= 1'b1;

                if (data_vld) begin
                    // 装载一帧：停止位 + 8位数据 + 起始位
                    shifter <= {1'b1, data_in, 1'b0};
                    busy    <= 1'b1;
                    bit_cnt <= 4'd0;
                    tx      <= 1'b0;   // 立即输出起始位
                end
            end else if (baud_tick) begin
                bit_cnt <= bit_cnt + 4'd1;

                if (bit_cnt == 4'd9) begin
                    // 最后一位发送完，回到空闲
                    busy <= 1'b0;
                    tx   <= 1'b1;
                end else begin
                    // 继续发送下一位
                    shifter <= {1'b1, shifter[9:1]};
                    tx      <= shifter[1];
                end
            end
        end
    end

endmodule