// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module basys3_7seg_driver (
    input              clk_1k_i,
    input              rst_ni,

    input  logic       digit0_en_i,
    input  logic [3:0] digit0_i,
    input  logic       digit1_en_i,
    input  logic [3:0] digit1_i,
    input  logic       digit2_en_i,
    input  logic [3:0] digit2_i,
    input  logic       digit3_en_i,
    input  logic [3:0] digit3_i,

    output logic [3:0] anode_o,
    output logic [6:0] segments_o
);


logic [1:0] count_q, count_d;

always_comb begin
    if (en_i) begin
        count_d = count_q + 1;
    end else begin
        count_d = count_q;
    end
end

always_ff @(posedge clk_1k_i) begin
    if (!rst_ni) begin
        count_q <= 0;
    end else begin
        count_q <= count_d;
    end
end

assign count_o = count_q;

logic [3:0] mux_o;
logic [3:0] digit0_o, digit1_o, digit2_o, digit3_o;

always_comb begin
    case (count_o)
    2'b00: mux_o = digit0_o;
    2'b01: mux_o = digit1_o;
    2'b10: mux_o = digit2_o;
    2'b11: mux_o = digit3_o;
    default;
    endcase
end

logic [3:0] digit_q, digit_d;

always_ff @(posedge clk_1k_i) begin
    if (!rst_ni) begin
        digit0_o <= 0;
        digit1_o <= 0;
        digit2_o <= 0;
        digit3_o <= 0;
    end else if (digit0_i) begin
        digit0_o <= digit0_i;
    end else if (digit1_i) begin
        digit1_o <= digit1_i;
    end else if (digit2_i) begin
        digit2_o <= digit2_i;
    end else if (digit3_i) begin
        digit3_o <= digit3_i;
    end
end

hex7seg hex7seg_inst (
    .d3(mux_o[3]),
    .d2(mux_o[2]),
    .d1(mux_o[1]),
    .d0(mux_o[0]),
    .A(A),
    .B(B),
    .C(C),
    .D(D),
    .E(E),
    .F(F),
    .G(G)
);

logic [3:0] hex7_o;

always_comb begin
    segments_o[0] = A;
    segments_o[1] = B;
    segments_o[2] = C;
    segments_o[3] = D;
    segments_o[4] = E;
    segments_o[5] = F;
    segments_o[6] = G;
end

// Ring Counter

logic [3:0] ringc_o;

always_ff @(posedge clk_1k_i) begin
    if (!rst) begin
        ringc_o = 4'b1110;
    end else begin
        ringc_o = {ringc_o[2:0], ringc_o[3]};
    end
end

assign anode_o = ringc_o;

// Ring Tutorial
// https://www.youtube.com/watch?v=OLYPY9xtv1Y&list=PLLHwVz4euyqh9jH6t1aOxuty7BY1gvXzg&index=10

endmodule
