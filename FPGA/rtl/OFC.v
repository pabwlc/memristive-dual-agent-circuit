module OFC (
    input  wire I_ges_dc,
    input  wire I_food_dc,
    output wire out_OFC,   // ????????????
    input  wire Aux,
    input  wire I_ges_p,
    input  wire Vpos,
    input  wire Vneg,
    output wire O_oc,
    input  wire clk,
    input  wire rst_n,
    input  wire in_OFC,    // ??????????????
    output wire happy,
    output wire Vact,
    output wire normal,
    output wire refuse,
    input wire I_immact,
    output wire [7:0] G_code_OFC
);
    wire N110956;
    wire N112860;
    wire N112791;
    wire N112240;
    reg div_out;
    wire N126623;
    wire N112847;
    wire Vact_p;
    wire div_in;

    assign out_OFC = I_ges_dc & I_food_dc & Vact;

    synapse #(
        .GON      (62500),
        .GOFF     (1453),
        .GINIT    (1954),
        .GTH_ON  (34000),
        .GTH_OFF (32000),
        .LG_BIN1  (15759),
        .LG_BIN2  (31658),
        .LG_BIN3  (33508),
        .LG_BIN4  (41971),
        .FG_BIN1  (55935),
        .FG_BIN2  (49397),
        .FG_BIN3  (47889),
        .FG_BIN4  (1945),
        .LG_B0    (715),
        .LG_B1    (4),
        .LG_B2    (1),
        .LG_B3    (1),
        .LG_B4    (1),
        .LG_D0    (1),
        .LG_D1    (1),
        .LG_D2    (3),
        .LG_D3    (5),
        .LG_D4    (44),
        .FG_B0    (1),
        .FG_B1    (1),
        .FG_B2    (1),
        .FG_B3    (1),
        .FG_B4    (1),
        .FG_D0    (2),
        .FG_D1    (16),
        .FG_D2    (26),
        .FG_D3    (14),
        .FG_D4    (2253)
    ) syn_u (
        .clk   (clk),
        .rst_n (rst_n),
        .in    (in_OFC),
        .out   (O_oc),
        .G_out (),
        .G_code(G_code_OFC)
    );

    assign refuse = O_oc & Vneg;
    assign happy = O_oc & Vpos;
    assign N112847 = happy & I_ges_p;

    assign N110956 = Aux & I_ges_p;
    assign N112860 = N110956 | N112847;
    
    assign normal = O_oc & (~Vneg) & (~Vpos);
    assign div_in = normal & I_ges_p;


    always @(posedge div_in or negedge rst_n) begin
        if (!rst_n)
            div_out <= 1'b0;
        else
            div_out <= ~div_out;
    end

    assign N126623 = div_out & div_in;
    assign N112240 = N112860 | N126623;
    assign Vact_p = I_immact | N112240;
    assign Vact = Vact_p & ~refuse; // Vact ?????????????????
    

endmodule

