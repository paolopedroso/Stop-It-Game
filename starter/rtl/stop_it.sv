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
        // .clk_i(clk_lfsr_i),
        // .rst_n(rst_lfsr_n),
        .next_i(next_i),

        .rand_o(rand_o)
    );

    game_counter game_counter_inst (
        // .clk_4_i(clk_gc_i),
        // .rst_ni(rst_gc_ni),
        .en_i(en_gc_i),

        .count_o(count_gc_o)
    );

    time_counter time_counter_inst (
        // .clk_4_i(clk_tc_i),
        // .rst_ni(rst_tc_ni),
        // .en_i(en_tc_i),

        .count_o(count_tc_o)
    );

    led_shifter led_shifter_inst (
        // .clk_i(clk_ls_i),
        // .rst_n(rst_ls_n),

        .shift_i(shift_i),

        .switches_i(switches_i),
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

logic       load_ls_i;
logic [4:0] target_n;
always_comb begin
    state_d = state_q;

    next_i = 0;
    en_gc_i = 0;
    en_tc_i = 0;
    shift_i = 0;
    load_ls_i = 0;
    off_i = 0;
    digit0_en_o = 1;
    digit1_en_o = 1;
    digit2_en_o = 1;
    digit3_en_o = 1;

    unique case (state_q)
        WAITING_TO_START: begin
           if (go_i) begin
            state_d = STARTING;
           end

           if (load_i) begin
            load_ls_i = 1;
           end
        end
        STARTING: begin
            next_i = 1; // New Target Number
            target_n = rand_o;
            digit0_o = count_gc_o[3:0];
            digit1_o = count_gc_o[4];

            digit2_o = count_gc_o[3:0];
            digit3_o = count_gc_o[4];
            en_tc_i = 1; // Enable Time Counter
            state_d = DECREMENTING;
        end
        DECREMENTING: begin
            en_gc_i = 1; // Enable Game Counter

            digit_0_o = count_gc_o[3:0];
            digit_1_o = count_gc_o[4];

            if (stop_i) begin
                if (count_gc_o == target_n) begin
                    state_d = CORRECT;
                end else begin
                    state_d = WRONG;
                end
            end
        end
        WRONG: begin
            digit0_en_i = 0;
            digit1_en_i = 0;
            digit2_en_i = 0;
            digit3_en_i = 0;

            // Flashing
            if (count_tc_o < 4) begin
                digit0_o = count_gc_o[3:0];
                digit1_o = count_gc_o[4];
                digit2_o = target_n[3:0];
                digit3_o = target_n[4];
            end else begin
                digit0_o = 4'b1111;
                digit1_o = 1'b1;
                digit2_o = 1'b1;
                digit3_o = 4'b1111;
            end
            en_tc_i = 1;
            if (count_tc_o == 8) begin
                state_d = WAITING_TO_START;
            end

        end
        CORRECT: begin
            digit0_en_o = 1;
            digit1_en_o = 1;
            digit2_en_o = 1;
            digit3_en_o = 1;

            digit0_o = 4'b1111;
            digit1_o = 1'b1;
            digit2_o = 4'b1111;
            digit3_o = 1'b1;
            en_tc_i = 1; // Enable Time Counter
            if (count_tc_o == 8) begin
                shift_i = 1;
                state_d = WAITING_TO_START;
            end
        end
        WON: begin
            // Falshing Game Won
            off_i = 1;
            en_tc_i = 1;
            if (count_tc_o == 8) begin
                state_d = WAITING_TO_START;
            end
        end
        default: begin
            state_d = WAITING_TO_START;
        end
    endcase
end

endmodule
