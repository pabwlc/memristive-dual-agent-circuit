`timescale 1ns/1ns

module synapse_double #(
    parameter integer CLK_HZ  = 50_000_000,
    parameter integer TICK_US = 10,

    parameter integer GON   = 62_500,
    parameter integer GOFF  = 1_453,
    parameter integer GINIT = 4_310,

    parameter integer GTH1_ON  = 62_500,
    parameter integer GTH1_OFF = 52_632,
    parameter integer GTH2_ON  = 62_500,

    parameter integer LG1_BIN1 = 52_585,
    parameter integer LG1_BIN2 = 62_500,
    parameter integer LG1_BIN3 = 62_500,
    parameter integer LG1_BIN4 = 62_500,

    parameter integer LG2_BIN1 = 52_585,
    parameter integer LG2_BIN2 = 62_500,
    parameter integer LG2_BIN3 = 62_500,
    parameter integer LG2_BIN4 = 62_500,

    parameter integer FG1_BIN1 = 62_500,
    parameter integer FG1_BIN2 = 46_627,
    parameter integer FG1_BIN3 = 30_634,
    parameter integer FG1_BIN4 = 3_571,

    parameter integer LG1_B0 = 503,
    parameter integer LG1_B1 = 83,
    parameter integer LG1_B2 = 13,
    parameter integer LG1_B3 = 2,
    parameter integer LG1_B4 = 1,

    parameter integer LG1_D0 = 2,
    parameter integer LG1_D1 = 100,
    parameter integer LG1_D2 = 100,
    parameter integer LG1_D3 = 45,
    parameter integer LG1_D4 = 59,

    parameter integer LG2_B0 = 503,
    parameter integer LG2_B1 = 83,
    parameter integer LG2_B2 = 13,
    parameter integer LG2_B3 = 2,
    parameter integer LG2_B4 = 1,

    parameter integer LG2_D0 = 2,
    parameter integer LG2_D1 = 100,
    parameter integer LG2_D2 = 100,
    parameter integer LG2_D3 = 45,
    parameter integer LG2_D4 = 59,

    parameter integer FG1_B0 = 15,
    parameter integer FG1_B1 = 37,
    parameter integer FG1_B2 = 166,
    parameter integer FG1_B3 = 700,
    parameter integer FG1_B4 = 80,

    parameter integer FG1_D0 = 100,
    parameter integer FG1_D1 = 100,
    parameter integer FG1_D2 = 100,
    parameter integer FG1_D3 = 20,
    parameter integer FG1_D4 = 20
)(
    input  wire clk,
    input  wire rst_n,
    input  wire in1,
    input  wire in2,
    output reg  out,
    output reg  [31:0] G_out,
    output reg  [7:0]  G_code
);

    reg in1_ff1, in1_ff2;
    reg in2_ff1, in2_ff2;
    wire in1_sync;
    wire in2_sync;
    reg [31:0] cnt;
    reg tick;
    reg [31:0] step_v;
    reg [15:0] lg_div_cnt;
    reg [15:0] fg_div_cnt;

    localparam integer DIV = (CLK_HZ / 1_000_000) * TICK_US;

    assign in1_sync = in1_ff2;
    assign in2_sync = in2_ff2;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            in1_ff1 <= 1'b0;
            in1_ff2 <= 1'b0;
            in2_ff1 <= 1'b0;
            in2_ff2 <= 1'b0;
        end else begin
            in1_ff1 <= in1;
            in1_ff2 <= in1_ff1;
            in2_ff1 <= in2;
            in2_ff2 <= in2_ff1;
        end
    end

    function [31:0] learn1_step;
        input [31:0] g;
        begin
            if (g < LG1_BIN1) learn1_step = LG1_B0;
            else if (g < LG1_BIN2) learn1_step = LG1_B1;
            else if (g < LG1_BIN3) learn1_step = LG1_B2;
            else if (g < LG1_BIN4) learn1_step = LG1_B3;
            else learn1_step = LG1_B4;
        end
    endfunction

    function [15:0] learn1_div;
        input [31:0] g;
        begin
            if (g < LG1_BIN1) learn1_div = LG1_D0[15:0];
            else if (g < LG1_BIN2) learn1_div = LG1_D1[15:0];
            else if (g < LG1_BIN3) learn1_div = LG1_D2[15:0];
            else if (g < LG1_BIN4) learn1_div = LG1_D3[15:0];
            else learn1_div = LG1_D4[15:0];
        end
    endfunction

    function [31:0] learn2_step;
        input [31:0] g;
        begin
            if (g < LG2_BIN1) learn2_step = LG2_B0;
            else if (g < LG2_BIN2) learn2_step = LG2_B1;
            else if (g < LG2_BIN3) learn2_step = LG2_B2;
            else if (g < LG2_BIN4) learn2_step = LG2_B3;
            else learn2_step = LG2_B4;
        end
    endfunction

    function [15:0] learn2_div;
        input [31:0] g;
        begin
            if (g < LG2_BIN1) learn2_div = LG2_D0[15:0];
            else if (g < LG2_BIN2) learn2_div = LG2_D1[15:0];
            else if (g < LG2_BIN3) learn2_div = LG2_D2[15:0];
            else if (g < LG2_BIN4) learn2_div = LG2_D3[15:0];
            else learn2_div = LG2_D4[15:0];
        end
    endfunction

    function [31:0] forget1_step;
        input [31:0] g;
        begin
            if (g > FG1_BIN1) forget1_step = FG1_B0;
            else if (g > FG1_BIN2) forget1_step = FG1_B1;
            else if (g > FG1_BIN3) forget1_step = FG1_B2;
            else if (g > FG1_BIN4) forget1_step = FG1_B3;
            else forget1_step = FG1_B4;
        end
    endfunction

    function [15:0] forget1_div;
        input [31:0] g;
        begin
            if (g > FG1_BIN1) forget1_div = FG1_D0[15:0];
            else if (g > FG1_BIN2) forget1_div = FG1_D1[15:0];
            else if (g > FG1_BIN3) forget1_div = FG1_D2[15:0];
            else if (g > FG1_BIN4) forget1_div = FG1_D3[15:0];
            else forget1_div = FG1_D4[15:0];
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt  <= 32'd0;
            tick <= 1'b0;
        end else begin
            if(cnt == DIV - 1) begin
                cnt  <= 32'd0;
                tick <= 1'b1;
            end else begin
                cnt  <= cnt + 32'd1;
                tick <= 1'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            G_out <= GINIT;
            lg_div_cnt <= 16'd0;
            fg_div_cnt <= 16'd0;
        end else if(tick) begin
            if(in2_sync) begin
                fg_div_cnt <= 16'd0;
                if (lg_div_cnt >= learn2_div(G_out) - 1) begin
                    lg_div_cnt <= 16'd0;
                    step_v = learn2_step(G_out);
                    if (G_out + step_v < GON) G_out <= G_out + step_v;
                    else G_out <= GON;
                end else begin
                    lg_div_cnt <= lg_div_cnt + 16'd1;
                end
            end else if(in1_sync) begin
                fg_div_cnt <= 16'd0;
                if (lg_div_cnt >= learn1_div(G_out) - 1) begin
                    lg_div_cnt <= 16'd0;
                    step_v = learn1_step(G_out);
                    if (G_out + step_v < GON) G_out <= G_out + step_v;
                    else G_out <= GON;
                end else begin
                    lg_div_cnt <= lg_div_cnt + 16'd1;
                end
            end else begin
                lg_div_cnt <= 16'd0;
                if (fg_div_cnt >= forget1_div(G_out) - 1) begin
                    fg_div_cnt <= 16'd0;
                    step_v = forget1_step(G_out);
                    if (G_out > GOFF + step_v) G_out <= G_out - step_v;
                    else G_out <= GOFF;
                end else begin
                    fg_div_cnt <= fg_div_cnt + 16'd1;
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out <= 1'b0;
        end else if(tick) begin
            if(in2_sync) begin
                if(G_out >= GTH2_ON) out <= 1'b1;
            end else if(in1_sync) begin
                if(G_out >= GTH1_ON) out <= 1'b1;
            end else begin
                if(G_out <= GTH1_OFF) out <= 1'b0;
            end
        end
    end

    always @(*) begin
        if      (G_out <  32'd5268 ) G_code = 8'd0;
        else if (G_out <  32'd9084 ) G_code = 8'd16;
        else if (G_out <  32'd12900) G_code = 8'd32;
        else if (G_out <  32'd16715) G_code = 8'd48;
        else if (G_out <  32'd20531) G_code = 8'd64;
        else if (G_out <  32'd24346) G_code = 8'd80;
        else if (G_out <  32'd28162) G_code = 8'd96;
        else if (G_out <  32'd31977) G_code = 8'd112;
        else if (G_out <  32'd35793) G_code = 8'd128;
        else if (G_out <  32'd39608) G_code = 8'd144;
        else if (G_out <  32'd43424) G_code = 8'd160;
        else if (G_out <  32'd47239) G_code = 8'd176;
        else if (G_out <  32'd51055) G_code = 8'd192;
        else if (G_out <  32'd54870) G_code = 8'd208;
        else if (G_out <  32'd58686) G_code = 8'd224;
        else if (G_out <  32'd62500) G_code = 8'd240;
        else                          G_code = 8'd255;
    end
endmodule
