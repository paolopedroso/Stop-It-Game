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

always_ff @(posedge clk_1k_i) begin
    if (!rst_ni) begin
        count_q <= 2'b00;
    end else begin
        count_q <= count_d;
    end
end

assign count_o = count_q;

always_comb begin
    case(count_o)
    2'b00: begin  // 1110
        anode_o[0] = ~digit0_en_i;
        anode_o[3:1] = 3'b111;
        hex7_i = digit0_i;
    end
    2'b01: begin // 1101
        anode_o[1] = ~digit1_en_i;
        anode_o[0] = 1'b1;
        anode_o[3:2] = 2'b11;
        hex7_i = digit1_i;
    end
    2'b10: begin // 1011
        anode_o[2] = ~digit2_en_i;
        anode_o[3] = 1'b1;
        anode_o [1:0] = 2'b11;
        hex7_i = digit2_i;
    end
    2'b11: begin // 0111
        anode_o[3] = ~digit3_en_i;
        anode_o[2:0] = 3'b111;
        hex7_i = digit3_i;
    end
    default:;
    endcase
end

logic [3:0] hex7_i;
logic A_o, B_o, C_o, D_o, E_o, F_o, G_o;

hex7seg hex7seg_inst (
    .d3(hex7_i[3]),
    .d2(hex7_i[2]),
    .d1(hex7_i[1]),
    .d0(hex7_i[0]),
    .A(A_o),
    .B(B_o),
    .C(C_o),
    .D(D_o),
    .E(E_o),
    .F(F_o),
    .G(G_o)
);

always_comb begin
    if (anode_o == 4'b1111) begin
        segments_o = 8'hff;
    end else begin
        segments_o = ~{G_o, F_o, E_o, D_o, C_o, B_o, A_o};
    end
end

endmodule
