module Amy #(
    parameter integer AMY_POS_GTH_ON  = 39803,
    parameter integer AMY_POS_GTH_OFF = 39803,
    parameter integer AMY_NEG_GTH_ON  = 39803,
    parameter integer AMY_NEG_GTH_OFF = 39803
) (
    input wire I_pos,
    input wire I_neg,
    input wire clk,
    input wire rst_n,
    output wire Vpos,
    output wire Vneg,
    output wire [7:0] G_code_neg,
    output wire [7:0] G_code_pos

);

    wire OR1;
    wire OR2;
    wire judge;

    synapse #(
        .GON      (62500),
        .GOFF     (1453),
        .GINIT    (1524),
        .GTH_ON   (AMY_POS_GTH_ON),
        .GTH_OFF  (AMY_POS_GTH_OFF),
        .LG_BIN1  (5036),
        .LG_BIN2  (19735),
        .LG_BIN3  (30466),
        .LG_BIN4  (47671),
        .FG_BIN1  (55868),
        .FG_BIN2  (29885),
        .FG_BIN3  (28861),
        .FG_BIN4  (4842),
        .LG_B0    (64),
        .LG_B1    (202),
        .LG_B2    (3),
        .LG_B3    (1),
        .LG_B4    (1),
        .LG_D0    (1),
        .LG_D1    (1),
        .LG_D2    (1),
        .LG_D3    (2),
        .LG_D4    (137),
        .FG_B0    (217),
        .FG_B1    (1),
        .FG_B2    (1),
        .FG_B3    (1),
        .FG_B4    (1),
        .FG_D0    (1),
        .FG_D1    (8),
        .FG_D2    (15),
        .FG_D3    (1),
        .FG_D4    (3)
    ) syn_p (
        .clk   (clk),
        .rst_n (rst_n),
        .in    (I_pos),
        .out   (OR1),
        .G_out (),
        .G_code(G_code_pos)
    );

    synapse #(
        .GON      (62500),
        .GOFF     (1453),
        .GINIT    (1524),
        .GTH_ON   (AMY_NEG_GTH_ON),
        .GTH_OFF  (AMY_NEG_GTH_OFF),
        .LG_BIN1  (5036),
        .LG_BIN2  (19735),
        .LG_BIN3  (30466),
        .LG_BIN4  (47671),
        .FG_BIN1  (55868),
        .FG_BIN2  (29885),
        .FG_BIN3  (28861),
        .FG_BIN4  (4842),
        .LG_B0    (64),
        .LG_B1    (202),
        .LG_B2    (3),
        .LG_B3    (1),
        .LG_B4    (1),
        .LG_D0    (1),
        .LG_D1    (1),
        .LG_D2    (1),
        .LG_D3    (2),
        .LG_D4    (137),
        .FG_B0    (217),
        .FG_B1    (1),
        .FG_B2    (1),
        .FG_B3    (1),
        .FG_B4    (1),
        .FG_D0    (1),
        .FG_D1    (8),
        .FG_D2    (15),
        .FG_D3    (1),
        .FG_D4    (3)
    ) syn_n (
        .clk   (clk),
        .rst_n (rst_n),
        .in    (I_neg),
        .out   (OR2),
        .G_out (),
        .G_code(G_code_neg)
    );

    assign judge = ~(OR1 & OR2);
    assign Vpos = judge & OR1;
    assign Vneg = judge & OR2;
endmodule
