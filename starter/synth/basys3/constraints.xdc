create_generated_clock -name clk_1k -source [get_pins clk_100M_to_clk_1k/clk_100M_i] -divide_by   100000 [get_pins clk_100M_to_clk_1k/clk_1k_o]
create_generated_clock -name clk_1k -source [get_pins clk_100M_to_clk_4/clk_100M_i]  -divide_by 25000000 [get_pins clk_100M_to_clk_4/clk_4_o]
