// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module counters_tb;

logic       clk_4_i;
logic       rst_ni;
logic       en_i;

time_counter time_counter (
    .clk_4_i,
    .rst_ni,
    .en_i
);

game_counter game_counter (
    .clk_4_i,
    .rst_ni,
    .en_i
);

initial begin
    clk_4_i = 0;
    forever begin
        clk_4_i = !clk_4_i;
        #125ms;
    end
end

always @(posedge clk_4_i) begin
    if (!rst_ni) begin
        @(posedge clk_4_i);
        assert(time_counter.count_o == 0)
        else #1 $error("Time counter should be initialized to 0.");
        assert(game_counter.count_o == 5'h1f)
        else #1 $error("Game counter should be initialized to 1f.");
    end
end

initial begin : sim
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);

    rst_ni = 0;
    @(posedge clk_4_i);
    @(posedge clk_4_i);
    rst_ni = 1;
    en_i = 1;
    @(negedge clk_4_i);

    @(posedge clk_4_i);
    assert(game_counter.count_o == 5'h1e)
    else #1 $error("Game counter did not decrement from 1f to 1e.");
    en_i = 0;
    @(posedge clk_4_i);
    assert(game_counter.count_o == 5'h1e)
    else #1 $error("Game counter did not pause on en=0.");
    en_i = 1;
    repeat(30) @(posedge clk_4_i);
    assert(game_counter.count_o == 0)
    else #1 $error("Game counter: Expected=0, received=%h", game_counter.count_o);
    @(posedge clk_4_i);
    assert(game_counter.count_o == 31)
    else #1 $error("Game counter: Expected=0, received=%h", game_counter.count_o);

    rst_ni = 0;
    @(posedge clk_4_i);
    @(posedge clk_4_i);
    rst_ni = 1;

    @(posedge clk_4_i);
    assert(time_counter.count_o == 1)
    else #1 $error("Time counter: Expected=1, received=%h", time_counter.count_o);
    @(posedge clk_4_i);
    assert(time_counter.count_o == 2)
    else #1 $error("Time counter: Expected=2, received=%h", time_counter.count_o);
    repeat(3) @(posedge clk_4_i);
    assert(time_counter.count_o == 5)
    else #1 $error("Time counter: Expected=5, received=%h", time_counter.count_o);

    $info("All counters tests passed, but not every edge case is tested in this testbench. ",
          "View dump.fst to confirm the behavior.");

    $display( "End simulation." );
    $finish;
end

endmodule
