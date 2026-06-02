module ACC #(
    parameter integer ACC_NEG_GTH1_ON  = 32344,
    parameter integer ACC_NEG_GTH1_OFF = 28517,
    parameter integer ACC_NEG_GTH2_ON  = 21497,
    parameter integer ACC_POS_GTH1_ON  = 32344,
    parameter integer ACC_POS_GTH1_OFF = 28517,
    parameter integer ACC_POS_GTH2_ON  = 21497
) (
    input  wire I_fs_dc,
    input  wire I_fs_p,
    input  wire I_f_dc,
    input  wire I_f_p,
    input  wire clk,
    input  wire rst_n,
    output wire O_neg,
    output wire O_pos,
    output wire acc_out_fs,
    output wire acc_out_f,
    input  wire sig1_neg,
    input  wire sig1_pos,
    output wire [7:0] G_code_neg_acc,
    output wire [7:0] G_code_pos_acc
);

    wire sig2_neg;
    wire sig2_pos;

    assign sig2_pos = I_f_dc  & ~I_fs_dc & sig1_pos;
    assign sig2_neg = I_fs_dc & ~I_f_dc & sig1_neg;
    assign acc_out_fs = I_fs_p;
    assign acc_out_f = I_f_p;

    synapse_double #(
        .GON       (62500),
        .GOFF      (1453),
        .GINIT     (1762),
        .GTH1_ON   (ACC_NEG_GTH1_ON),
        .GTH1_OFF  (ACC_NEG_GTH1_OFF),
        .GTH2_ON   (ACC_NEG_GTH2_ON),

        .LG1_BIN1  (5132),
        .LG1_BIN2  (15070),
        .LG1_BIN3  (26726),
        .LG1_BIN4  (54651),

        .LG2_BIN1  (3225),
        .LG2_BIN2  (21270),
        .LG2_BIN3  (38961),
        .LG2_BIN4  (49051),

        .FG1_BIN1  (38048),
        .FG1_BIN2  (37625),
        .FG1_BIN3  (9412),
        .FG1_BIN4  (3490),

        .LG1_B0    (5840),
        .LG1_B1    (4),
        .LG1_B2    (51),
        .LG1_B3    (1),
        .LG1_B4    (1),

        .LG1_D0    (1),
        .LG1_D1    (1),
        .LG1_D2    (1),
        .LG1_D3    (4),
        .LG1_D4    (65535),

        .LG2_B0    (28),
        .LG2_B1    (416),
        .LG2_B2    (3),
        .LG2_B3    (1),
        .LG2_B4    (1),

        .LG2_D0    (1),
        .LG2_D1    (1),
        .LG2_D2    (1),
        .LG2_D3    (6),
        .LG2_D4    (48),

        .FG1_B0    (1),
        .FG1_B1    (1),
        .FG1_B2    (1),
        .FG1_B3    (130),
        .FG1_B4    (1),

        .FG1_D0    (4),
        .FG1_D1    (4),
        .FG1_D2    (1),
        .FG1_D3    (1),
        .FG1_D4    (4750)
    ) syn_neg (
        .clk   (clk),
        .rst_n (rst_n),
        .in1   (sig1_neg),
        .in2   (sig2_neg),
        .out   (O_neg),
        .G_out (),
        .G_code(G_code_neg_acc)
    );

    synapse_double #(
        .GON       (62500),
        .GOFF      (1453),
        .GINIT     (1762),
        .GTH1_ON   (ACC_POS_GTH1_ON),
        .GTH1_OFF  (ACC_POS_GTH1_OFF),
        .GTH2_ON   (ACC_POS_GTH2_ON),

        .LG1_BIN1  (5132),
        .LG1_BIN2  (15070),
        .LG1_BIN3  (26726),
        .LG1_BIN4  (54651),

        .LG2_BIN1  (3225),
        .LG2_BIN2  (21270),
        .LG2_BIN3  (38961),
        .LG2_BIN4  (49051),

        .FG1_BIN1  (38048),
        .FG1_BIN2  (37625),
        .FG1_BIN3  (9412),
        .FG1_BIN4  (3490),

        .LG1_B0    (5840),
        .LG1_B1    (4),
        .LG1_B2    (51),
        .LG1_B3    (1),
        .LG1_B4    (1),

        .LG1_D0    (1),
        .LG1_D1    (1),
        .LG1_D2    (1),
        .LG1_D3    (4),
        .LG1_D4    (65535),

        .LG2_B0    (28),
        .LG2_B1    (416),
        .LG2_B2    (3),
        .LG2_B3    (1),
        .LG2_B4    (1),

        .LG2_D0    (1),
        .LG2_D1    (1),
        .LG2_D2    (1),
        .LG2_D3    (6),
        .LG2_D4    (48),

        .FG1_B0    (1),
        .FG1_B1    (1),
        .FG1_B2    (1),
        .FG1_B3    (130),
        .FG1_B4    (1),

        .FG1_D0    (4),
        .FG1_D1    (4),
        .FG1_D2    (1),
        .FG1_D3    (1),
        .FG1_D4    (4750)
    ) syn_pos (
        .clk   (clk),
        .rst_n (rst_n),
        .in1   (sig1_pos),
        .in2   (sig2_pos),
        .out   (O_pos),
        .G_out (),
        .G_code(G_code_pos_acc)
    );

endmodule
