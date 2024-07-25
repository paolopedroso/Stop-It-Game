// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module lfsr_tb;

logic clk_i;
logic rst_ni;
logic next_i;

lfsr lfsr (
    .clk_i,
    .rst_ni,
    .next_i
);

localparam int NUM_CYCLES = 10000;

initial begin
    clk_i = 0;
    forever begin
        clk_i = !clk_i;
        #125ms;
    end
end

logic [5:0][31:0] counters = '0;

always_ff @(posedge clk_i) if (rst_ni) begin
    for (int i = 0; i < 5; i++) begin
        counters[i] <= counters[i] + lfsr.rand_o[i];
    end
end

always @(posedge clk_i) begin
    if (!rst_ni) begin
        @(posedge clk_i);
        assert(lfsr.rand_o != 0)
        else #1 $error("Reset should not set all bits to 0.");
    end
end

initial begin : sim
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);

    rst_ni = 0;
    @(posedge clk_i);
    @(posedge clk_i);
    rst_ni = 1;
    next_i = 1;

    repeat(NUM_CYCLES) @(posedge clk_i);

    for (int i = 0; i < 5; i++) begin
        assert (counters[i] > NUM_CYCLES*0.25 && counters[i] < NUM_CYCLES*0.75)
        else $error("Bit %0d of rand_o doesn't appear to be random.", i);
    end

    $info("All lfsr tests passed, but not every edge case is tested in this testbench. ",
          "View dump.fst to confirm the behavior.");

    $display( "End simulation." );
    $finish;
end

endmodule
