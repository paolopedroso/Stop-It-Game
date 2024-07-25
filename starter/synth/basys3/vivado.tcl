# Copyright (c) 2024 Ethan Sifferman.
# All rights reserved. Distribution Prohibited.

# start_gui

create_project basys3 basys3 -part xc7a35tcpg236-1

add_files -norecurse {
 ../../../rtl/basys3/basys3_7seg_driver.sv
 ../../../rtl/basys3/clk_100M_to_clk_1k.sv
 ../../../rtl/basys3/clk_100M_to_clk_4.sv
 ../../../rtl/basys3/hex7seg.sv
 ../../../rtl/basys3/synchronizer.sv
 ../../../rtl/game_counter.sv
 ../../../rtl/led_shifter.sv
 ../../../rtl/lfsr.sv
 ../../../rtl/stop_it_pkg.sv
 ../../../rtl/stop_it.sv
 ../../../rtl/time_counter.sv
 ../basys3.sv
}
add_files -fileset constrs_1 -norecurse {
 ../Basys3_Master.xdc
 ../constraints.xdc
}

set_property top basys3 [current_fileset]

# Run Synthesis
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
launch_runs synth_1 -jobs [exec nproc]
wait_on_run synth_1

# Run PNR
launch_runs impl_1
wait_on_run impl_1

# Create Bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

exit
