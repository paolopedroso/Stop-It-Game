// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module game_counter (
    input  logic       clk_4_i,
    input  logic       rst_ni,
    input  logic       en_i,
    output logic [4:0] count_o
);

logic [4:0] count0_q;


always_ff @(posedge clk_4_i) begin
    if (!rst_ni) begin
        count0_q <= 5'h1f;
    end else if (en_i) begin
        count0_q <= count0_q - 1;
    end else begin
        count0_q <= count0_q;
    end
end

assign count_o = count0_q;

endmodule
