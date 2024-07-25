// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module stop_it import stop_it_pkg::*; (
    input  logic        rst_ni,

    input  logic        clk_4_i,
    input  logic        go_i,
    input  logic        stop_i,
    input  logic        load_i,

    input  logic [15:0] switches_i,
    output logic [15:0] leds_o,

    output logic        digit0_en_o,
    output logic [3:0]  digit0_o,
    output logic        digit1_en_o,
    output logic [3:0]  digit1_o,
    output logic        digit2_en_o,
    output logic [3:0]  digit2_o,
    output logic        digit3_en_o,
    output logic [3:0]  digit3_o
);

// TODO
// Instantiate and drive all required nets and modules

    lfsr lfsr_inst(
        .clk_i(clk_lfsr_i),
        .rst_n(rst_lfsr_n),

        .next_i(next_i),
        .rand_o(rand_o)
    );

    game_counter game_counter_inst (
        .clk_4_i(clk_gc_i),
        .rst_ni(rst_gc_ni),
        .en_i(en_gc_i),
        .count_o(count_gc_o)
    );

    time_counter time_counter_inst (
        .clk_4_i(clk_tc_i),
        .rst_ni(rst_tc_ni),
        .en_i(en_tc_i),
        .count_o(count_tc_o)
    );

    led_shifter led_shifter_inst (
        .clk_i(clk_ls_i),
        .rst_n(rst_ls_n),

        .shift_i(shift_i),

        .switches_i(switches_ls_i),
        .load_i(load_ls_i),

        .off_i(off_i),
        .leds_o(leds_o)
    );

state_t state_d, state_q;
always_ff @(posedge clk_4_i) begin
    if (!rst_ni) begin
        state_q <= WAITING_TO_START;
    end else begin
        state_q <= state_d;
    end
end

always_comb begin
    state_d = state_q;

    // TODO

    unique case (state_q)
        WAITING_TO_START: begin
            // TODO
        end
        STARTING: begin
            // TODO
        end
        DECREMENTING: begin
            // TODO
        end
        WRONG: begin
            // TODO
        end
        CORRECT: begin
            // TODO
        end
        WON: begin
            // TODO
        end
        default: begin
            state_d = WAITING_TO_START;
        end
    endcase
end

endmodule
