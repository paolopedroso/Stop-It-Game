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

// Shift 1 (+1 point)
always_comb begin
    leds_d = {leds_q[14:0], 1'b1};
    if (load_i == 1'b1) begin
        leds_d = switches_i;
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        leds_q <= 0;
    end else if (load_i) begin
        leds_q <= leds_d;
    end else if (shift_i) begin
        leds_q <= leds_d;
    end
end

always_comb begin
    if (off_i) begin
        leds_o = 0;
    end else begin
        leds_o = leds_q;
    end
end

endmodule
