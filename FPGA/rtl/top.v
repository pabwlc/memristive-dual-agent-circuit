module top (
    input  wire clk,
    input  wire rst_n,

    //==========================================================
    // 个体1基础输入
    //==========================================================
    input  wire ges1,
    input  wire food1,
    input  wire Aux1,

    //==========================================================
    // 个体2基础输入
    //==========================================================
    input  wire ges2,
    input  wire food2,
    input  wire Aux2,

    //==========================================================
    // TS小模块 -> top（TS只接收外部小模块信号）
    //==========================================================
    input  wire ges1_in_ts,
    input  wire foodsight1_in_ts,
    input  wire food1_in_ts,

    input  wire ges2_in_ts,
    input  wire foodsight2_in_ts,
    input  wire food2_in_ts,

    //==========================================================
    // ACC外部输入
    //==========================================================
    input  wire acc1_sig1_neg_in,
    input  wire acc1_sig1_pos_in,
    input  wire acc2_sig1_neg_in,
    input  wire acc2_sig1_pos_in,

    //==========================================================
    // STS / OFC 小模块 -> top（返回信号）
    //==========================================================
    input  wire sts1_in,
    input  wire ofc1_in,
    input  wire sts2_in,
    input  wire ofc2_in,

    //==========================================================
    // 行为输出
    //==========================================================
    output wire immact1,
    output wire Vact1,
    output wire normal1,
    output wire happy1,
    output wire refuse1,

    output wire immact2,
    output wire Vact2,
    output wire normal2,
    output wire happy2,
    output wire refuse2,

    //==========================================================
    // ACC -> 外部
    //==========================================================
    output wire acc1_out_fs,
    output wire acc1_out_f,
    output wire acc2_out_fs,
    output wire acc2_out_f,

    //==========================================================
    // top -> STS / OFC 小模块（送出信号）
    //==========================================================
    output wire sts1_out,
    output wire ofc1_out,
    output wire sts2_out,
    output wire ofc2_out,

    output wire uart_tx_pin,

    //==========================================================
    // 调试引出（示波器观测）
    //==========================================================
    output wire oc1,
    output wire oc2,
    output wire ges1dc,
    output wire ges1pulse,
    output wire foodsight2dc,
    output wire opos1,
    output wire oneg1,
    output wire opos2,
    output wire oneg2,
    output wire RSQ1,
    output wire RSQ2



    //这里进行测试
    
    


);


    //==========================================================
    // 个体1内部 wire
    //==========================================================
    wire ges1_dc;
    wire ges1_pulse;
    wire foodsight1_dc;
    wire foodsight1_pulse;
    wire food1_dc;
    wire food1_pulse;

    wire acc1_neg;
    wire acc1_pos;

    wire amy1_vpos;
    wire amy1_vneg;


    //==========================================================
    // 个体2内部 wire
    //==========================================================
    wire ges2_dc;
    wire ges2_pulse;
    wire foodsight2_dc;
    wire foodsight2_pulse;
    wire food2_dc;
    wire food2_pulse;

    wire acc2_neg;
    wire acc2_pos;

    wire amy2_vpos;
    wire amy2_vneg;


    //==========================================================
    //忆阻输出
    //==========================================================
    reg  [7:0] uart_data;
    reg        uart_vld;
    wire       uart_busy;

    uart_tx u_uart_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (uart_data),
        .data_vld (uart_vld),
        .tx       (uart_tx_pin),
        .busy     (uart_busy)
    );

    //==========================================================
    // 个体1 G_code 调试信号
    //==========================================================
    wire [7:0] gcode_ts_ges1;
    wire [7:0] gcode_ts_foodsight1;
    wire [7:0] gcode_ts_food1;

    wire [7:0] gcode_acc1_neg;
    wire [7:0] gcode_acc1_pos;

    wire [7:0] gcode_amy1_neg;
    wire [7:0] gcode_amy1_pos;

    wire [7:0] gcode_ofc1;

    wire [7:0] gcode_sts1_imm;
    wire [7:0] gcode_sts1_reject;

    //==========================================================
    // 个体2 G_code 调试信号
    //==========================================================
    wire [7:0] gcode_ts_ges2;
    wire [7:0] gcode_ts_foodsight2;
    wire [7:0] gcode_ts_food2;

    wire [7:0] gcode_acc2_neg;
    wire [7:0] gcode_acc2_pos;

    wire [7:0] gcode_amy2_neg;
    wire [7:0] gcode_amy2_pos;

    wire [7:0] gcode_ofc2;

    wire [7:0] gcode_sts2_imm;
    wire [7:0] gcode_sts2_reject;


    // //==========================================================
    // // SignalTap 调试用 10kHz 节拍脉冲
    // // 假设 clk = 50MHz
    // //==========================================================
    // (* keep = "true", preserve, noprune *) reg [12:0] div_cnt;
    // (* keep = "true", preserve, noprune *) reg        sample_en;
    // (* keep = "true", preserve, noprune *) reg        dbg_tick;
    // (* keep = "true", preserve, noprune *) reg [7:0]  dbg_tick_cnt;

    // always @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         div_cnt      <= 13'd0;
    //         sample_en    <= 1'b0;
    //         dbg_tick     <= 1'b0;
    //         dbg_tick_cnt <= 8'd0;
    //     end else begin
    //         if (div_cnt == 13'd4999) begin
    //             div_cnt      <= 13'd0;
    //             sample_en    <= 1'b1;
    //             dbg_tick     <= ~dbg_tick;          // 每100us翻转一次
    //             dbg_tick_cnt <= dbg_tick_cnt + 8'd1; // 每100us加1
    //         end else begin
    //             div_cnt   <= div_cnt + 13'd1;
    //             sample_en <= 1'b0;
    //         end
    //     end
    // end
    //==========================================================
    // 个体1
    //==========================================================

    //--------------------------
    // 个体1：TS
    //--------------------------
    TS u_ts_ges1 (
        .clk   (clk),
        .rst_n (rst_n),
        .Vin   (ges1),
        .in_TS (ges1_in_ts),
        .DC    (ges1_dc),
        .PULSE (ges1_pulse),
        .G_code_TS(gcode_ts_ges1)
    );

    // foodsight1 来自个体2的 food2
    TS u_ts_foodsight1 (
        .clk   (clk),
        .rst_n (rst_n),
        .Vin   (food2),
        .in_TS (foodsight1_in_ts),
        .DC    (foodsight1_dc),
        .PULSE (foodsight1_pulse),
        .G_code_TS(gcode_ts_foodsight1)
    );

    TS u_ts_food1 (
        .clk   (clk),
        .rst_n (rst_n),
        .Vin   (food1),
        .in_TS (food1_in_ts),
        .DC    (food1_dc),
        .PULSE (food1_pulse),
        .G_code_TS(gcode_ts_food1)
    );

    //--------------------------
    // 个体1：ACC
    //--------------------------
    ACC #(
        .ACC_NEG_GTH1_ON (27000)
    ) u_acc1 (
        .I_fs_dc        (foodsight1_dc),
        .I_fs_p         (foodsight1_pulse),
        .I_f_dc         (food1_dc),
        .I_f_p          (food1_pulse),
        .clk            (clk),
        .rst_n          (rst_n),
        .O_neg          (acc1_neg),
        .O_pos          (acc1_pos),
        .acc_out_fs     (acc1_out_fs),
        .acc_out_f      (acc1_out_f),
        .sig1_neg       (acc1_sig1_neg_in),
        .sig1_pos       (acc1_sig1_pos_in),
        .G_code_neg_acc (gcode_acc1_neg),
        .G_code_pos_acc (gcode_acc1_pos)
    );

    //--------------------------
    // 个体1：Amy
    //--------------------------
    Amy #(
        .AMY_POS_GTH_ON (32000)
    ) u_amy1 (
        .I_pos      (acc1_pos),
        .I_neg      (acc1_neg),
        .clk        (clk),
        .rst_n      (rst_n),
        .Vpos       (amy1_vpos),
        .Vneg       (amy1_vneg),
        .G_code_neg (gcode_amy1_neg),
        .G_code_pos (gcode_amy1_pos)
    );

    //--------------------------
    // 个体1：OFC
    //--------------------------
    OFC u_ofc1 (
        .I_ges_dc   (ges1_dc),
        .I_food_dc  (food1_dc),
        .out_OFC    (ofc1_out),
        .Aux        (Aux1),
        .I_ges_p    (ges1_pulse),
        .Vpos       (amy1_vpos),
        .Vneg       (amy1_vneg),
        .O_oc       (oc1),
        .clk        (clk),
        .rst_n      (rst_n),
        .in_OFC     (ofc1_in),
        .happy      (happy1),
        .Vact       (Vact1),
        .normal     (normal1),
        .refuse     (refuse1),
        .I_immact   (immact1),
        .G_code_OFC (gcode_ofc1)
    );

    //--------------------------
    // 个体1：STS
    //--------------------------
    STS #(
        .SYN1_GTH_ON  (28000),
        .SYN1_GTH_OFF (25600)
    ) u_sts1 (
        .I_ges_other_dc (ges2_dc),
        .I_fs_dc        (foodsight1_dc),
        .I_oc           (oc1),
        .I_act_other    (Vact2),
        .I_ges_dc       (ges1_dc),
        .I_f_dc         (food1_dc),
        .out_STS        (sts1_out),
        .in_STS         (sts1_in),
        .I_ges_p        (ges1_pulse),
        .O_immact       (immact1),
        .rst_n          (rst_n),
        .clk            (clk),
        .G_code_imm     (gcode_sts1_imm),
        .G_code_reject  (gcode_sts1_reject),
        .RSQ_dbg        (RSQ1)
    );

    //==========================================================
    // 个体2
    //==========================================================

    //--------------------------
    // 个体2：TS
    //--------------------------
    TS u_ts_ges2 (
        .clk   (clk),
        .rst_n (rst_n),
        .Vin   (ges2),
        .in_TS (ges2_in_ts),
        .DC    (ges2_dc),
        .PULSE (ges2_pulse),
        .G_code_TS(gcode_ts_ges2)
    );
    // foodsight2 来自个体1的 food1
    

    TS u_ts_foodsight2 (
        .clk   (clk),
        .rst_n (rst_n),
        .Vin   (food1),
        .in_TS (foodsight2_in_ts),
        .DC    (foodsight2_dc),
        .PULSE (foodsight2_pulse),
        .G_code_TS(gcode_ts_foodsight2)
    );

    TS u_ts_food2 (
        .clk      (clk),
        .rst_n    (rst_n),
        .Vin      (food2),
        .in_TS    (food2_in_ts),
        .DC       (food2_dc),
        .PULSE    (food2_pulse),
        .G_code_TS(gcode_ts_food2)
    );

    //--------------------------
    // 个体2：ACC
    //--------------------------
    ACC u_acc2 (
        .I_fs_dc        (foodsight2_dc),
        .I_fs_p         (foodsight2_pulse),
        .I_f_dc         (food2_dc),
        .I_f_p          (food2_pulse),
        .clk            (clk),
        .rst_n          (rst_n),
        .O_neg          (acc2_neg),
        .O_pos          (acc2_pos),
        .acc_out_fs     (acc2_out_fs),
        .acc_out_f      (acc2_out_f),
        .sig1_neg       (acc2_sig1_neg_in),
        .sig1_pos       (acc2_sig1_pos_in),
        .G_code_neg_acc (gcode_acc2_neg),
        .G_code_pos_acc (gcode_acc2_pos)
    );

    //--------------------------
    // 个体2：Amy
    //--------------------------
    Amy #(
        .AMY_POS_GTH_ON (32000)
    ) u_amy2 (
        .I_pos      (acc2_pos),
        .I_neg      (acc2_neg),
        .clk        (clk),
        .rst_n      (rst_n),
        .Vpos       (amy2_vpos),
        .Vneg       (amy2_vneg),
        .G_code_neg (gcode_amy2_neg),
        .G_code_pos (gcode_amy2_pos)
    );

    //--------------------------
    // 个体2：OFC
    //--------------------------
    OFC u_ofc2 (
        .I_ges_dc   (ges2_dc),
        .I_food_dc  (food2_dc),
        .out_OFC    (ofc2_out),
        .Aux        (Aux2),
        .I_ges_p    (ges2_pulse),
        .Vpos       (amy2_vpos),
        .Vneg       (amy2_vneg),
        .O_oc       (oc2),
        .clk        (clk),
        .rst_n      (rst_n),
        .in_OFC     (ofc2_in),
        .happy      (happy2),
        .Vact       (Vact2),
        .normal     (normal2),
        .refuse     (refuse2),
        .I_immact   (immact2),
        .G_code_OFC (gcode_ofc2)
    );
    //--------------------------
    // 个体2：STS
    //--------------------------
    STS u_sts2 (
        .I_ges_other_dc (ges1_dc),
        .I_fs_dc        (foodsight2_dc),
        .I_oc           (oc2),
        .I_act_other    (Vact1),
        .I_ges_dc       (ges2_dc),
        .I_f_dc         (food2_dc),
        .out_STS        (sts2_out),
        .in_STS         (sts2_in),
        .I_ges_p        (ges2_pulse),
        .O_immact       (immact2),
        .rst_n          (rst_n),
        .clk            (clk),
        .G_code_imm     (gcode_sts2_imm),
        .G_code_reject  (gcode_sts2_reject),
        .RSQ_dbg        (RSQ2)
    );

    assign ges1dc    = ges1_dc;
    assign ges1pulse = ges1_pulse;
    assign foodsight2dc = foodsight2_dc;
    assign opos1 = acc1_pos;
    assign oneg1 = acc1_neg;
    assign opos2 = acc2_pos;
    assign oneg2 = acc2_neg;



    //==========================================================
    // UART 发送全部 G_code
    // 帧格式:
    //   Byte0  = 8'hAA
    //   Byte1  = 8'h55
    //   Byte2  = 8'h14   // 后面20个G_code
    //   Byte3~Byte22 = 20个G_code
    //==========================================================
    localparam integer FRAME_INTERVAL = 2_500_000; // 50MHz时约50ms一帧
    localparam integer TOTAL_BYTES    = 23;

    reg [21:0] frame_cnt;
    reg        frame_start_req;

    reg        sending;
    reg [5:0]  send_idx;

    reg        uart_busy_d;
    wire       uart_busy_fall;

    assign uart_busy_fall = uart_busy_d & ~uart_busy;

    //==========================================================
    // busy打一拍，用于检测一个字节发送完成
    //==========================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            uart_busy_d <= 1'b0;
        else
            uart_busy_d <= uart_busy;
    end

    //==========================================================
    // 周期启动整帧发送
    //==========================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            frame_cnt       <= 22'd0;
            frame_start_req <= 1'b0;
        end else begin
            if (frame_cnt == FRAME_INTERVAL - 1) begin
                frame_cnt       <= 22'd0;
                frame_start_req <= 1'b1;
            end else begin
                frame_cnt       <= frame_cnt + 22'd1;
                frame_start_req <= 1'b0;
            end
        end
    end

    //==========================================================
    // UART逐字节发送状态机
    //==========================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_data <= 8'd0;
            uart_vld  <= 1'b0;
            sending   <= 1'b0;
            send_idx  <= 6'd0;
        end else begin
            // 默认只打一拍
            uart_vld <= 1'b0;

            if (!sending) begin
                // 空闲状态，收到发送请求就发第0字节
                if (frame_start_req && !uart_busy) begin
                    sending   <= 1'b1;
                    send_idx  <= 6'd0;
                    uart_data <= 8'hAA;
                    uart_vld  <= 1'b1;
                end
            end else begin
                // 每当上一个字节发送结束，准备下一个字节
                if (uart_busy_fall) begin
                    if (send_idx == TOTAL_BYTES - 1) begin
                        // 最后一个字节发完，结束本帧
                        sending  <= 1'b0;
                        send_idx <= 6'd0;
                    end else begin
                        send_idx <= send_idx + 6'd1;

                        case (send_idx + 6'd1)
                            6'd1:  uart_data <= 8'h55;
                            6'd2:  uart_data <= 8'h14;

                            6'd3:  uart_data <= gcode_ts_ges1;
                            6'd4:  uart_data <= gcode_ts_foodsight1;
                            6'd5:  uart_data <= gcode_ts_food1;
                            6'd6:  uart_data <= gcode_acc1_neg;
                            6'd7:  uart_data <= gcode_acc1_pos;
                            6'd8:  uart_data <= gcode_amy1_neg;
                            6'd9:  uart_data <= gcode_amy1_pos;
                            6'd10: uart_data <= gcode_ofc1;
                            6'd11: uart_data <= gcode_sts1_imm;
                            6'd12: uart_data <= gcode_sts1_reject;

                            6'd13: uart_data <= gcode_ts_ges2;
                            6'd14: uart_data <= gcode_ts_foodsight2;
                            6'd15: uart_data <= gcode_ts_food2;
                            6'd16: uart_data <= gcode_acc2_neg;
                            6'd17: uart_data <= gcode_acc2_pos;
                            6'd18: uart_data <= gcode_amy2_neg;
                            6'd19: uart_data <= gcode_amy2_pos;
                            6'd20: uart_data <= gcode_ofc2;
                            6'd21: uart_data <= gcode_sts2_imm;
                            6'd22: uart_data <= gcode_sts2_reject;

                            default: uart_data <= 8'h00;
                        endcase

                        uart_vld <= 1'b1;
                    end
                end
            end
        end
    end



endmodule
