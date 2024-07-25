// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module led_shifter (
    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic        shift_i,

    input  logic [15:0] switches_i,
    input  logic        load_i,

    input  logic        off_i,
    output logic [15:0] leds_o
);

logic [15:0] leds_d, leds_q;

always_comb begin
    if (shift_i == 1'b1) begin
        leds_d = {leds_q[14:0], 1'b1};
    end else if (load_i == 1'b1) begin
        leds_d = switches_i;
    end else begin
        leds_d = leds_q;
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        leds_q <= 0;
    end else if (off_i) begin
        leds_q <= 0;
    end else begin
        leds_q <= leds_d;
    end
end

assign leds_o = leds_q;


endmodule
