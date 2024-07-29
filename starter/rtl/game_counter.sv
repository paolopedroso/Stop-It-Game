// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module game_counter (
    input  logic       clk_4_i,
    input  logic       rst_ni,
    input  logic       en_i,
    output logic [4:0] count_o
);

logic [4:0] count0_q, count0_d;

always_comb begin
    case(en_i)
    1'b0: count0_d = count0_q;
    1'b1: count0_d = count0_q - 1;
    default;
    endcase
end


always_ff @(posedge clk_4_i) begin
    if (!rst_ni) begin
        count0_q <= 5'h1f;
    end else begin
        count0_q <= count0_d;
    end
end

assign count_o = count0_q;

endmodule
