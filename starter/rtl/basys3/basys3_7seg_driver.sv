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
logic [1:0] count_o;

always_comb begin
    if (count_q == 2'b11) begin
        count_d = 2'b00;
    end else begin
        count_d = count_q + 1;
    end
end

always_ff @(posedge clk_1k_i or negedge rst_ni) begin
    if (!rst_ni) begin
        count_q <= 2'b00;
    end else begin
        count_q <= count_d;
    end
end

assign count_o = count_q;

logic [3:0] mux_o;
logic [3:0] digit0_o, digit1_o, digit2_o, digit3_o;

always_ff @(posedge clk_1k_i or negedge rst_ni) begin
    if (!rst_ni) begin
        digit0_o <= 4'b0000;
        digit1_o <= 4'b0000;
        digit2_o <= 4'b0000;
        digit3_o <= 4'b0000;
    end else begin
        if (digit0_en_i) digit0_o <= digit0_i;
        if (digit1_en_i) digit1_o <= digit1_i;
        if (digit2_en_i) digit2_o <= digit2_i;
        if (digit3_en_i) digit3_o <= digit3_i;
    end
end

always_comb begin
    case (count_o)
        2'b00: mux_o = digit0_o;
        2'b01: mux_o = digit1_o;
        2'b10: mux_o = digit2_o;
        2'b11: mux_o = digit3_o;
        default: mux_o = 4'b0000;
    endcase
end

logic A_o, B_o, C_o, D_o, E_o, F_o, G_o;

hex7seg hex7seg_inst (
    .d3(mux_o[3]),
    .d2(mux_o[2]),
    .d1(mux_o[1]),
    .d0(mux_o[0]),
    .A(A_o),
    .B(B_o),
    .C(C_o),
    .D(D_o),
    .E(E_o),
    .F(F_o),
    .G(G_o)
);

always_comb begin
    segments_o = {G_o, F_o, E_o, D_o, C_o, B_o, A_o};
end

// Ring counter
logic [3:0] ringc_o;

always_ff @(posedge clk_1k_i or negedge rst_ni) begin
    if (!rst_ni) begin
        ringc_o <= 4'b1110;
    end else begin
        ringc_o <= {ringc_o[2:0], ringc_o[3]};
    end
end

assign anode_o = ringc_o;

endmodule
