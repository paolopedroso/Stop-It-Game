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

    lfsr lfsr_inst(
        .clk_i(clk_4_i),
        .rst_ni(rst_ni),
        .next_i(next_i),

        .rand_o(rand_o)
);

    game_counter game_counter_inst (
        .clk_4_i(clk_4_i),
        .rst_ni(rst_gc_ni & rst_ni),
        .en_i(en_gc_i),

        .count_o(count_gc_o)
);

    time_counter time_counter_inst (
        .clk_4_i(clk_4_i),
        .rst_ni(rst_tc_ni & rst_ni),
        .en_i(en_tc_i),

        .count_o(count_tc_o)
);

    led_shifter led_shifter_inst (
        .clk_i(clk_4_i),
        .rst_ni(rst_ni),

        .shift_i(shift_i),

        .switches_i(switches_i),
        .load_i(load_i),

        .off_i(off_ls_i),

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

// INIT //
// led shifter
logic       shift_i;
//logic       off_i;

// time counter
logic [4:0] count_tc_o;
logic       rst_tc_ni;
logic       en_tc_i;

// game counter
logic [4:0] count_gc_o;
logic       en_gc_i;
logic       rst_gc_ni;

// lfsr
logic       next_i;
logic [4:0] rand_o;

logic [4:0] target_n;

// led shifter
logic       off_ls_i;

always_comb begin
    state_d = state_q;
    digit0_en_o = 1'b0;
    digit1_en_o = 1'b0;
    digit2_en_o = 1'b1;
    digit3_en_o = 1'b1;

    digit0_o = 1'b0;
    digit1_o = 1'b0;
    digit2_o = 1'b0;
    digit3_o = 1'b0;

    off_ls_i = 1'b0;
    // lfsr
    next_i = 0;
    // Led shifter
    shift_i = 0;
    // Time counter
    en_tc_i = 0;
    rst_tc_ni = 0;
    // Game counter
    en_gc_i = 0;
    rst_gc_ni = 1;

    target_n = rand_o;
    unique case (state_q)
        WAITING_TO_START: begin
            // Resetting time counter
            en_tc_i = 0;
            rst_tc_ni = 0;
            // Game counter init
            // Resetting game counter to 1f
            en_gc_i = 0;
            // rst_gc_ni = 0;
            digit0_en_o = 1;
            digit0_o = count_gc_o[3:0]; // f
            digit1_en_o = 1;
            digit1_o = count_gc_o[4]; // 1
            // Keep top bits off
            digit2_en_o = 0;
            digit3_en_o = 0;
            // New random number
            next_i = 1;
            // For next round
            if (go_i) begin
                rst_gc_ni = 0;
                state_d = STARTING;
            end else begin
                state_d = WAITING_TO_START;
            end
        end
        STARTING: begin
            // Game counter init
            digit0_en_o = 1;
            digit0_o = count_gc_o[3:0];
            digit1_en_o = 1;
            digit1_o = count_gc_o[4];

            next_i = 0;

            // lfsr init
            digit2_en_o = 1;
            digit2_o = rand_o[3:0];
            digit3_en_o = 1;
            digit3_o = rand_o[4];
            // Start time counter
            rst_tc_ni = 1;
            en_tc_i = 1;

            // Going to next state
            if (count_tc_o == 7) begin // 2 seconds
                state_d = DECREMENTING;
            end else begin
                state_d = STARTING;
            end
        end
        DECREMENTING: begin
            // Stop counting
            en_tc_i = 0;
            rst_tc_ni = 0;
            // Game counter
            en_gc_i = 1;
            // Game counter init
            digit0_en_o = 1;
            digit0_o = count_gc_o[3:0]; // f
            digit1_en_o = 1;
            digit1_o = count_gc_o[4]; // 1
            // lfsr init
            digit2_en_o = 1;
            digit2_o = rand_o[3:0];
            digit3_en_o = 1;
            digit3_o = rand_o[4];

            // Stop (btnU)
            if (stop_i) begin
                en_gc_i = 0;
                if (target_n == count_gc_o) begin
                    state_d = CORRECT;
                end else if (target_n == count_gc_o && leds_o == 16'hFFFF) begin
                    state_d = WON;
                end else if (target_n != count_gc_o) begin
                    state_d = WRONG;
                end else begin
                    state_d = DECREMENTING;
                end
            end else begin
                state_d = DECREMENTING;
            end
        end
        WRONG: begin
            // Time counter init
            en_tc_i = 1;
            rst_tc_ni = 1;
            // Digits init
            digit0_o = count_gc_o[3:0];
            digit1_o = count_gc_o[4];
            digit2_o = rand_o[3:0];
            digit3_o = rand_o[4];
            // Flashing
            if (count_tc_o % 2 == 0) begin
                digit0_en_o = 1;
                digit1_en_o = 1;
                digit2_en_o = 0;
                digit3_en_o = 0;
            end else if (count_tc_o % 2 == 1) begin
                digit2_en_o = 1;
                digit3_en_o = 1;
                digit0_en_o = 0;
                digit1_en_o = 0;
            end

            // Going to next state
            if (count_tc_o == 15) begin
                state_d = WAITING_TO_START;
            end else begin
                state_d = WRONG;
            end
        end
        CORRECT: begin
            // Time counter init
            en_tc_i = 1;
            rst_tc_ni = 1;
            shift_i = 0;

            digit0_o = count_gc_o[3:0];
            digit1_o = count_gc_o[4];
            digit2_o = rand_o[3:0];
            digit3_o = rand_o[4];

            // Flashing
            if (count_tc_o % 2 == 1) begin
                digit0_en_o = 0;
                digit1_en_o = 0;
                digit2_en_o = 0;
                digit3_en_o = 0;
            end else if (count_tc_o % 2 == 0) begin
                digit0_en_o = 1;
                digit1_en_o = 1;
                digit2_en_o = 1;
                digit3_en_o = 1;
            end

            // Going to next state
            if (count_tc_o == 15) begin
                shift_i = 1; // +1 point
                if (leds_o == 16'hFFFF) begin // Debug
                    en_tc_i = 0;
                    rst_tc_ni = 0;
                    state_d = WON;
                end else begin
                    state_d = WAITING_TO_START;
                end
            end else begin
                state_d = CORRECT;
            end
        end
        WON: begin
            // Start time counter
            en_tc_i = 1;
            rst_tc_ni = 1;

            digit0_en_o = 1;
            digit1_en_o = 1;
            digit2_en_o = 1;
            digit3_en_o = 1;
            digit0_o = count_gc_o[3:0];
            digit1_o = count_gc_o[4];
            digit2_o = rand_o[3:0];
            digit3_o = rand_o[4];

            state_d = WON;

            // Flashing until rst (btnL)
            if (count_tc_o % 1) begin
                off_ls_i = 0;
            end else if (count_tc_o  % 2 == 0) begin
                off_ls_i = 1;
            end
        end
        default: begin
            state_d = WAITING_TO_START;
        end
    endcase
end

endmodule
