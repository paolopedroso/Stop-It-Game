// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module led_shifter_tb;

logic        clk_i;
logic        rst_ni;

logic        shift_i;
logic [15:0] switches_i;
logic        load_i;
logic        off_i;

led_shifter led_shifter (
    .clk_i,
    .rst_ni,

    .shift_i,

    .switches_i,
    .load_i,

    .off_i
);

initial begin
    clk_i = 0;
    forever begin
        clk_i = !clk_i;
        #125ms;
    end
end

always @(posedge clk_i) begin
    if (!rst_ni) begin
        @(posedge clk_i);
        assert(led_shifter.leds_o == 0)
        else #1 $error("Reset should set all LEDs to 0.");
    end
end

always #1 begin
    if (off_i) begin
        assert(led_shifter.leds_o == 0)
        else #1 $error("Off should set all LEDs to 0.");
    end
end

always @(posedge clk_i) if (rst_ni) begin
    if (load_i) begin
        logic [15:0] past_switches = switches_i;
        @(posedge clk_i);
        if (!off_i) begin
            assert(led_shifter.leds_o == past_switches)
            else #1 $error("Load should set LEDs to %b, received %b", past_switches, );
        end
    end
end

always @(posedge clk_i) if (rst_ni) begin
    if (shift_i && !load_i && !off_i) begin
        /* verilator lint_save */
        /* verilator lint_off UNUSEDSIGNAL */
        logic [15:0] past_leds = led_shifter.leds_o;
        /* verilator lint_restore */
        @(posedge clk_i);
        if (!off_i) begin
            assert(led_shifter.leds_o == {past_leds[14:0],1'b1})
            else #1 $error("Shift incorrect. Expected %b. received %b.", {past_leds[14:0],1'b1}, led_shifter.leds_o);
        end
    end
end

initial begin : sim
    logic [15:0] past_leds;
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);

    rst_ni = 0;
    @(posedge clk_i);
    @(negedge clk_i);
    rst_ni = 1;

    switches_i = $urandom;
    load_i = 1;
    off_i = 0;
    shift_i = 0;
    @(negedge clk_i);

    switches_i = $urandom | 1;
    load_i = 1;
    off_i = 0;
    shift_i = 1;
    @(negedge clk_i);

    switches_i = $urandom;
    load_i = 0;
    off_i = 0;
    shift_i = 1;
    @(negedge clk_i);

    switches_i = $urandom;
    load_i = 0;
    off_i = 0;
    shift_i = 1;
    @(negedge clk_i);
    past_leds = led_shifter.leds_o;

    switches_i = $urandom;
    load_i = 0;
    off_i = 1;
    shift_i = 0;
    @(negedge clk_i);

    switches_i = $urandom;
    load_i = 0;
    off_i = 0;
    shift_i = 0;
    @(negedge clk_i);
    assert (past_leds == led_shifter.leds_o)
    else #1 $error("LEDs should not have changed.");

    $info("All led_shifter tests passed, but not every edge case is tested in this testbench. ",
          "View dump.fst to confirm the behavior.");

    $display( "End simulation." );
    $finish;
end

endmodule
