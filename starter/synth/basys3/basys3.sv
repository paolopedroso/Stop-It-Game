// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module basys3 (
    input  logic        clk_100,

    input  logic        btnC,
    input  logic        btnU,
    input  logic        btnL,
    input  logic        btnR,

    input  logic [15:0] sw,
    output logic [15:0] led,

    output logic  [6:0] seg,
    output logic  [3:0] an
);

wire rst_ni = !btnR_sync;

logic clk_1k;
clk_100M_to_clk_1k clk_100M_to_clk_1k (
    .clk_100M_i(clk_100),
    .clk_1k_o(clk_1k)
);

logic clk_4;
clk_100M_to_clk_4 clk_100M_to_clk_4 (
    .clk_100M_i(clk_100),
    .clk_4_o(clk_4)
);

logic btnC_sync, btnU_sync, btnL_sync, btnR_sync;
logic [3:0] synchronizer_in, synchronizer_out;

assign synchronizer_in = {btnC, btnU, btnL, btnR};
assign {btnC_sync, btnU_sync, btnL_sync, btnR_sync} = synchronizer_out;

synchronizer #(
    .WIDTH(4)
) synchronizer (
    .clk_sample_i(clk_100),
    .clk_target_i(clk_4),
    .async_data_i(synchronizer_in),
    .sync_data_o(synchronizer_out)
);

logic       digit0_en;
logic [3:0] digit0;
logic       digit1_en;
logic [3:0] digit1;
logic       digit2_en;
logic [3:0] digit2;
logic       digit3_en;
logic [3:0] digit3;

basys3_7seg_driver basys3_7seg_driver (
    .clk_1k_i(clk_1k),
    .rst_ni,

    .digit0_en_i(digit0_en),
    .digit0_i(digit0),
    .digit1_en_i(digit1_en),
    .digit1_i(digit1),
    .digit2_en_i(digit2_en),
    .digit2_i(digit2),
    .digit3_en_i(digit3_en),
    .digit3_i(digit3),

    .anode_o(an),
    .segments_o(seg)
);

stop_it stop_it (
    .rst_ni,

    .clk_4_i(clk_4),
    .go_i(btnC_sync),
    .stop_i(btnU_sync),
    .load_i(btnL_sync),

    .switches_i(sw),
    .leds_o(led),

    .digit0_en_o(digit0_en),
    .digit0_o(digit0),
    .digit1_en_o(digit1_en),
    .digit1_o(digit1),
    .digit2_en_o(digit2_en),
    .digit2_o(digit2),
    .digit3_en_o(digit3_en),
    .digit3_o(digit3)
);

endmodule
