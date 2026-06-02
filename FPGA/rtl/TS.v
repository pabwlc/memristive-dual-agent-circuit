`timescale  1ns/1ns

module TS (
    input  wire clk,
    input  wire rst_n,
    input  wire Vin,
    input  wire in_TS,   // ???????????TS
    output wire DC,
    output wire PULSE,
    output wire [7:0] G_code_TS
);

    synapse #(
        .GON      (62500),
        .GOFF     (1453),
        .GINIT    (2064),
        .GTH_ON   (28000),
        .GTH_OFF  (29894),
        .LG_BIN1  (5327),
        .LG_BIN2  (14224),
        .LG_BIN3  (26478),
        .LG_BIN4  (54902),
        .FG_BIN1  (38292),
        .FG_BIN2  (38037),
        .FG_BIN3  (8946),
        .FG_BIN4  (1454),
        .LG_B0    (5000),
        .LG_B1    (4),
        .LG_B2    (48),
        .LG_B3    (1),
        .LG_B4    (1),
        .LG_D0    (1),
        .LG_D1    (1),
        .LG_D2    (1),
        .LG_D3    (4),
        .LG_D4    (207),
        .FG_B0    (1),
        .FG_B1    (1),
        .FG_B2    (1),
        .FG_B3    (101),
        .FG_B4    (1),
        .FG_D0    (4),
        .FG_D1    (4),
        .FG_D2    (1),
        .FG_D3    (1),
        .FG_D4    (666)
    ) syn1 (
        .clk    (clk),
        .rst_n  (rst_n),
        .in     (in_TS),
        .out    (DC),
        .G_out  (),
        .G_code (G_code_TS)
    );

    assign PULSE = Vin & DC;

endmodule

