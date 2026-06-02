`timescale 1ns/1ns

module synapse #(
    parameter integer CLK_HZ  = 50_000_000,
    parameter integer TICK_US = 10,

    // Conductance is represented in nS with Ron=16k and Roff=688k.
    parameter integer GON   = 62_500,
    parameter integer GOFF  = 1_453,
    parameter integer GINIT = 4_310,

    // hysteresis threshold
    parameter integer GTH_ON  = 62_500,
    parameter integer GTH_OFF = 50_505,

    // learning bins, ordered from low G to high G
    parameter integer LG_BIN1 = 52_585,
    parameter integer LG_BIN2 = 62_500,
    parameter integer LG_BIN3 = 62_500,
    parameter integer LG_BIN4 = 62_500,

    // forgetting bins, ordered from high G to low G
    parameter integer FG_BIN1 = 62_500,
    parameter integer FG_BIN2 = 46_627,
    parameter integer FG_BIN3 = 30_634,
    parameter integer FG_BIN4 = 3_571,

    // learning conductance step
    parameter integer LG_B0 = 503,
    parameter integer LG_B1 = 83,
    parameter integer LG_B2 = 13,
    parameter integer LG_B3 = 2,
    parameter integer LG_B4 = 1,

    // learning cadence
    parameter integer LG_D0 = 2,
    parameter integer LG_D1 = 100,
    parameter integer LG_D2 = 100,
    parameter integer LG_D3 = 45,
    parameter integer LG_D4 = 59,

    // forgetting conductance step
    parameter integer FG_B0 = 15,
    parameter integer FG_B1 = 37,
    parameter integer FG_B2 = 166,
    parameter integer FG_B3 = 700,
    parameter integer FG_B4 = 80,

    // forgetting cadence
    parameter integer FG_D0 = 100,
    parameter integer FG_D1 = 100,
    parameter integer FG_D2 = 100,
    parameter integer FG_D3 = 20,
    parameter integer FG_D4 = 20
)(
    input  wire clk,
    input  wire rst_n,
    input  wire in,
    output reg  out,
    output reg  [31:0] G_out,
    output reg  [7:0]  G_code
);

    reg in_ff1, in_ff2;
    wire in_sync;

    reg [31:0] cnt;
    reg tick;
    reg [31:0] step_v;
    reg [15:0] lg_div_cnt;
    reg [15:0] fg_div_cnt;

    localparam integer DIV = (CLK_HZ / 1_000_000) * TICK_US;

    assign in_sync = in_ff2;

    function [31:0] learn_step;
        input [31:0] g;
        begin
            if (g < LG_BIN1)
                learn_step = LG_B0;
            else if (g < LG_BIN2)
                learn_step = LG_B1;
            else if (g < LG_BIN3)
                learn_step = LG_B2;
            else if (g < LG_BIN4)
                learn_step = LG_B3;
            else
                learn_step = LG_B4;
        end
    endfunction

    function [15:0] learn_div;
        input [31:0] g;
        begin
            if (g < LG_BIN1)
                learn_div = LG_D0[15:0];
            else if (g < LG_BIN2)
                learn_div = LG_D1[15:0];
            else if (g < LG_BIN3)
                learn_div = LG_D2[15:0];
            else if (g < LG_BIN4)
                learn_div = LG_D3[15:0];
            else
                learn_div = LG_D4[15:0];
        end
    endfunction

    function [31:0] forget_step;
        input [31:0] g;
        begin
            if (g > FG_BIN1)
                forget_step = FG_B0;
            else if (g > FG_BIN2)
                forget_step = FG_B1;
            else if (g > FG_BIN3)
                forget_step = FG_B2;
            else if (g > FG_BIN4)
                forget_step = FG_B3;
            else
                forget_step = FG_B4;
        end
    endfunction

    function [15:0] forget_div;
        input [31:0] g;
        begin
            if (g > FG_BIN1)
                forget_div = FG_D0[15:0];
            else if (g > FG_BIN2)
                forget_div = FG_D1[15:0];
            else if (g > FG_BIN3)
                forget_div = FG_D2[15:0];
            else if (g > FG_BIN4)
                forget_div = FG_D3[15:0];
            else
                forget_div = FG_D4[15:0];
        end
    endfunction

    // input sync
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            in_ff1 <= 1'b0;
            in_ff2 <= 1'b0;
        end else begin
            in_ff1 <= in;
            in_ff2 <= in_ff1;
        end
    end

    // local tick
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

    // G update
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            G_out <= GINIT;
            lg_div_cnt <= 16'd0;
            fg_div_cnt <= 16'd0;
        end else if(tick) begin
            if(in_sync) begin
                // learning: conductance increases
                fg_div_cnt <= 16'd0;
                if (lg_div_cnt >= learn_div(G_out) - 1) begin
                    lg_div_cnt <= 16'd0;
                    step_v = learn_step(G_out);
                    if (G_out + step_v < GON)
                        G_out <= G_out + step_v;
                    else
                        G_out <= GON;
                end else begin
                    lg_div_cnt <= lg_div_cnt + 16'd1;
                end
            end else begin
                // forgetting: conductance decreases
                lg_div_cnt <= 16'd0;
                if (fg_div_cnt >= forget_div(G_out) - 1) begin
                    fg_div_cnt <= 16'd0;
                    step_v = forget_step(G_out);
                    if (G_out > GOFF + step_v)
                        G_out <= G_out - step_v;
                    else
                        G_out <= GOFF;
                end else begin
                    fg_div_cnt <= fg_div_cnt + 16'd1;
                end
            end
        end
    end

    // phase-dependent output threshold
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out <= 1'b0;
        end else if(tick) begin
            if(in_sync) begin
                if(G_out >= GTH_ON)
                    out <= 1'b1;
            end else begin
                if(G_out <= GTH_OFF)
                    out <= 1'b0;
            end
        end
    end

    // G_code: 8-bit uniform quantization over Ron=16k/Roff=688k conductance range.
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

