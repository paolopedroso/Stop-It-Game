// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module basys3_7seg_driver_tb;

logic       clk_1k_i;
logic       rst_ni;

logic       digit0_en_i;
logic [3:0] digit0_i;
logic       digit1_en_i;
logic [3:0] digit1_i;
logic       digit2_en_i;
logic [3:0] digit2_i;
logic       digit3_en_i;
logic [3:0] digit3_i;

basys3_7seg_driver basys3_7seg_driver (
    .clk_1k_i,
    .rst_ni,

    .digit0_en_i,
    .digit0_i,
    .digit1_en_i,
    .digit1_i,
    .digit2_en_i,
    .digit2_i,
    .digit3_en_i,
    .digit3_i
);

function logic [6:0] hex7seg_expected(logic [3:0] in);
    unique case (in)
        4'h0: return 7'b1000000;
        4'h1: return 7'b1111001;
        4'h2: return 7'b0100100;
        4'h3: return 7'b0110000;
        4'h4: return 7'b0011001;
        4'h5: return 7'b0010010;
        4'h6: return 7'b0000010;
        4'h7: return 7'b1111000;
        4'h8: return 7'b0000000;
        4'h9: return 7'b0010000;
        4'ha: return 7'b0001000;
        4'hb: return 7'b0000011;
        4'hc: return 7'b1000110;
        4'hd: return 7'b0100001;
        4'he: return 7'b0000110;
        4'hf: return 7'b0001110;
    endcase
endfunction

function void randomize_input;
    digit0_en_i = 1'($urandom);
    digit1_en_i = 1'($urandom);
    digit2_en_i = 1'($urandom);
    digit3_en_i = 1'($urandom);
    digit0_i = 4'($urandom);
    digit1_i = 4'($urandom);
    digit2_i = 4'($urandom);
    digit3_i = 4'($urandom);
endfunction

initial begin
    clk_1k_i = 0;
    forever begin
        clk_1k_i = !clk_1k_i;
        #1ms;
    end
end

localparam int NUM_TESTS = 100;

logic [3:0] expected_digit;
logic expected_digit_en;
always_comb begin
    expected_digit = 'x;
    expected_digit_en = 1;
    case (basys3_7seg_driver.anode_o)
        4'b1110: expected_digit = digit0_i;
        4'b1101: expected_digit = digit1_i;
        4'b1011: expected_digit = digit2_i;
        4'b0111: expected_digit = digit3_i;
        default: expected_digit_en = 0;
    endcase
end

initial begin : sim
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);

    rst_ni = 0;
    @(posedge clk_1k_i);
    @(posedge clk_1k_i);
    rst_ni = 1;
    @(negedge clk_1k_i);

    repeat(NUM_TESTS) begin
        randomize_input();
        @(negedge clk_1k_i);

        assert($countones(basys3_7seg_driver.anode_o) >= 3)
        else #1 $error("At most 1 anode should be enabled at a time. anode=%b", basys3_7seg_driver.anode_o);

        if (expected_digit_en) begin
            assert(basys3_7seg_driver.segments_o == hex7seg_expected(expected_digit))
            else #1 $error("Incorrect segments for anode=%b. segments=%b, expected=%b", basys3_7seg_driver.anode_o, basys3_7seg_driver.segments_o, hex7seg_expected(expected_digit));
        end else begin
            assert(basys3_7seg_driver.segments_o == '1)
            else #1 $error("No segments should be enabled for anode=%b", basys3_7seg_driver.anode_o);
        end
    end

    $display( "End simulation." );
    $finish;
end

endmodule
