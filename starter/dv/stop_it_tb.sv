// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module stop_it_tb
    import stop_it_pkg::*;
    ;
    timeunit 1ms;

logic        rst_ni;
logic        clk_4_i;
logic        go_i;
logic        stop_i;
logic        load_i;
logic [15:0] switches_i;

/* verilator lint_save */
/* verilator lint_off UNUSEDSIGNAL */
logic [15:0] leds_o;
logic        digit0_en_o;
logic [3:0]  digit0_o;
logic        digit1_en_o;
logic [3:0]  digit1_o;
logic        digit2_en_o;
logic [3:0]  digit2_o;
logic        digit3_en_o;
logic [3:0]  digit3_o;
/* verilator lint_restore */

wire state_t stop_it_state = state_t'(stop_it.state_q);

stop_it stop_it (
    .rst_ni,
    .clk_4_i,
    .go_i,
    .stop_i,
    .load_i,

    .switches_i,
    .leds_o,

    .digit0_en_o,
    .digit0_o,
    .digit1_en_o,
    .digit1_o,
    .digit2_en_o,
    .digit2_o,
    .digit3_en_o,
    .digit3_o
);

initial begin
    clk_4_i = 0;
    forever begin
        clk_4_i = !clk_4_i;
        #125ms;
    end
end

localparam int NUM_TESTS = 2500;

wire valid_go_received = rst_ni && (stop_it_state == WAITING_TO_START) && go_i;
always @(posedge valid_go_received) if (rst_ni) begin
    time go_time, decrementing_time, wait_time;

    @(posedge clk_4_i);
    go_time = $time;

    @(posedge (stop_it_state == DECREMENTING));
    decrementing_time = $time;
    wait_time = decrementing_time-go_time;

    if (rst_ni) assert(wait_time == 2s)
    else #1 $error("Expected 2 second pause after go. Instead paused %t", wait_time);
end

wire valid_stop_received = rst_ni && (stop_it_state == DECREMENTING) && stop_i;
wire digits_match = (digit0_o == digit2_o) && (digit1_o == digit3_o);

wire correct_stop_received = valid_stop_received && digits_match;
always @(posedge correct_stop_received) if (rst_ni) begin
    time stop_time, newround_time, wait_time;

    @(posedge clk_4_i);
    stop_time = $time;

    @(posedge ((stop_it_state == WAITING_TO_START)||(stop_it_state == WON)));
    newround_time = $time;
    wait_time = newround_time-stop_time;

    if (rst_ni) assert(wait_time == 4s)
    else #1 $error("Expected 4 second pause after correct answer. Instead paused %t", wait_time);
end

always @(posedge clk_4_i) if (rst_ni) begin
    repeat(17) @(posedge correct_stop_received);
    repeat(17) @(negedge clk_4_i);
    assert(stop_it_state == WON)
    else #1 $error("Expected WON state after 17 correct answers. Instead in state ", stop_it_state.name());

    repeat(20) @(negedge clk_4_i);
    rst_ni <= 0;
    repeat(2) @(negedge clk_4_i);
    rst_ni <= 1;
end

wire wrong_stop_received = valid_stop_received && !digits_match;
always @(posedge wrong_stop_received) if (rst_ni) begin
    time stop_time, newround_time, wait_time;

    @(posedge clk_4_i);
    stop_time = $time;

    @(posedge (stop_it_state == WAITING_TO_START));
    newround_time = $time;
    wait_time = (newround_time - stop_time);

    if (rst_ni) assert(wait_time == 4s)
    else #1 $error("Expected 4 second pause after wong answer. Instead paused %t", wait_time);
end

always @(posedge clk_4_i) begin
    if (!rst_ni) begin
        @(posedge clk_4_i);
        assert(stop_it_state == WAITING_TO_START)
        else #1 $error("After reset, state should be WAITING_TO_START. Received=", stop_it_state.name());
    end
end

initial begin
    repeat((NUM_TESTS) * 100) @(posedge clk_4_i);
    $display("Timed out");
    $fatal;
end

initial begin : sim
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);

    go_i = 0;
    stop_i = 0;
    load_i = 0;
    switches_i = '0;

    rst_ni = 0;
    @(negedge clk_4_i);
    @(negedge clk_4_i);
    rst_ni = 1;

    @(negedge clk_4_i);

    repeat(NUM_TESTS) begin
        int rand_delay = $urandom_range(0, 80);

        go_i = 1;
        @(negedge clk_4_i);
        go_i = 0;

        assert(stop_it_state == STARTING)
        else #1 $error("After go, state should be STARTING. Received=", stop_it_state.name());

        @(posedge (stop_it_state == DECREMENTING));
        assert({digit1_o, digit0_o}==8'h1f)
        else #1 $error("In DECREMENTING, counter should be initialized to 1f. Received=%h", {digit1_o, digit0_o});

        for (int i = 0; i <= rand_delay; i++) @(negedge clk_4_i);

        stop_i = 1;
        @(negedge clk_4_i);
        stop_i = 0;

        @(posedge (stop_it_state == WAITING_TO_START && rst_ni));
        @(negedge clk_4_i);
    end

    $info("All stop_it tests passed, but not every edge case is tested in this testbench. ",
          "View dump.fst to confirm the behavior.");

    $display( "End simulation." );
    $finish;
end

endmodule
