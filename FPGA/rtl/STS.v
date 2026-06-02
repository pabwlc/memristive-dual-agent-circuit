module STS #(
    parameter integer SYN1_GTH_ON  = 32570,
    parameter integer SYN1_GTH_OFF = 40300
) (
    input  wire I_ges_other_dc,
    input  wire I_fs_dc,
    input  wire I_oc,
    input  wire I_act_other,
    input  wire I_ges_dc,
    input  wire I_f_dc,
    output wire out_STS,
    input  wire in_STS,
    input  wire I_ges_p,
    output wire O_immact,
    input  wire rst_n,
    input  wire clk,
    output wire [7:0] G_code_imm,
    output wire [7:0] G_code_reject,
    output wire RSQ_dbg
);

    wire N121105;
    wire N121285;
    wire N121109;
    wire signal_imm;
    wire se;
    wire RSQ;
    wire div_in;
    reg  div_out;

    reg se_d, I_oc_d;

    wire se_rise;
    wire I_oc_rise;

    reg RSout_reg;

    assign N121105 = I_ges_other_dc & I_fs_dc;
    assign N121285 = I_act_other & (~I_oc);
    assign out_STS = N121105 & N121285 & RSQ;

    synapse #(
        .GON      (62500),
        .GOFF     (1453),
        .GINIT    (1524),
        .GTH_ON   (SYN1_GTH_ON),
        .GTH_OFF  (SYN1_GTH_OFF),
        .LG_BIN1  (21973),
        .LG_BIN2  (28042),
        .LG_BIN3  (28225),
        .LG_BIN4  (44333),
        .FG_BIN1  (61527),
        .FG_BIN2  (55039),
        .FG_BIN3  (37189),
        .FG_BIN4  (1454),
        .LG_B0    (112),
        .LG_B1    (3),
        .LG_B2    (1),
        .LG_B3    (1),
        .LG_B4    (1),
        .LG_D0    (1),
        .LG_D1    (1),
        .LG_D2    (32),
        .LG_D3    (3),
        .LG_D4    (38),
        .FG_B0    (1),
        .FG_B1    (1),
        .FG_B2    (1),
        .FG_B3    (1),
        .FG_B4    (1),
        .FG_D0    (31),
        .FG_D1    (1),
        .FG_D2    (9),
        .FG_D3    (3),
        .FG_D4    (7)
    ) syn1 (
        .clk   (clk),
        .rst_n (rst_n),
        .in    (in_STS),
        .out   (signal_imm),
        .G_out (),
        .G_code(G_code_imm)
    );

    assign N121109 = I_ges_dc & (~I_f_dc) & signal_imm;

    synapse #(
        .GON      (62500),
        .GOFF     (1453),
        .GINIT    (2063),
        .GTH_ON   (39675),
        .GTH_OFF  (44123),
        .LG_BIN1  (12468),
        .LG_BIN2  (25152),
        .LG_BIN3  (29373),
        .LG_BIN4  (38901),
        .FG_BIN1  (38383),
        .FG_BIN2  (29390),
        .FG_BIN3  (19136),
        .FG_BIN4  (7445),
        .LG_B0    (65),
        .LG_B1    (1),
        .LG_B2    (1),
        .LG_B3    (1),
        .LG_B4    (1),
        .LG_D0    (1),
        .LG_D1    (1),
        .LG_D2    (8),
        .LG_D3    (14),
        .LG_D4    (54),
        .FG_B0    (1),
        .FG_B1    (1),
        .FG_B2    (1),
        .FG_B3    (1),
        .FG_B4    (1),
        .FG_D0    (60),
        .FG_D1    (58),
        .FG_D2    (80),
        .FG_D3    (122),
        .FG_D4    (312)
    ) syn2 (
        .clk   (clk),
        .rst_n (rst_n),
        .in    (N121109),
        .out   (se),
        .G_out (),
        .G_code(G_code_reject)
    );

    assign se_rise   = ~se_d   & se;
    assign I_oc_rise = ~I_oc_d & I_oc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RSout_reg <= 1'b1;
            se_d      <= 1'b0;
            I_oc_d    <= 1'b0;
        end
        else begin
            se_d   <= se;
            I_oc_d <= I_oc;

            if (se_rise)
                RSout_reg <= 1'b0;
            else if (I_oc_rise)
                RSout_reg <= 1'b1;
        end
    end

    assign RSQ  = RSout_reg;
    assign RSQ_dbg = RSQ;
    assign div_in = I_ges_p & signal_imm & RSQ;

    always @(posedge div_in or negedge rst_n) begin
        if (!rst_n)
            div_out <= 1'b0;
        else
            div_out <= ~div_out;
    end

    assign O_immact = div_out & div_in & (~I_oc);

endmodule
