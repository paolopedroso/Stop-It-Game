// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module synchronizer #(
    parameter int WIDTH = 4
) (
    input  logic             clk_sample_i,
    input  logic             clk_target_i,

    input  logic [WIDTH-1:0] async_data_i,
    output logic [WIDTH-1:0] sync_data_o
);

logic [WIDTH-1:0] sync_data_d, sync_data_q;
assign sync_data_o = sync_data_q;

logic clk_target_q1, clk_target_q2;
logic clk_target_edge;
assign clk_target_edge = clk_target_q1 && !clk_target_q2;

always_comb begin
    sync_data_d = sync_data_q;
    for (int i = 0; i < WIDTH; i++) begin
        if (clk_target_edge || async_data_i[i])
            sync_data_d[i] = async_data_i[i];
    end
end

always_ff @(posedge clk_sample_i) begin
    clk_target_q1 <= clk_target_i;
    clk_target_q2 <= clk_target_q1;
    sync_data_q <= sync_data_d;
end

endmodule
