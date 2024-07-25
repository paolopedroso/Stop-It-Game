# Copyright (c) 2024 Ethan Sifferman.
# All rights reserved. Distribution Prohibited.

RTL := $(shell python3 scripts/convert_filelist.py rtl/rtl.f)
YOSYS_DATDIR := $(shell yosys-config --datdir)

TOP := stop_it_tb
PART := xc7a35tcpg236-1

sim:
	verilator --Mdir ${TOP}_$@_dir -f rtl/rtl.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+0
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+1
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

lint:
	verilator --lint-only -f rtl/rtl.f -f dv/dv.f synth/basys3/basys3.sv --top basys3
	verilator --lint-only -f rtl/rtl.f -f dv/dv.f --top stop_it
	verible-verilog-lint \
	 --waiver_files dv/lint/verible.waiver \
	 --rules_config dv/lint/verible.lint \
	 --autofix=inplace-interactive \
	 ${RTL} synth/basys3/basys3.sv

synth/yosys_common/build/rtl.sv2v.v: ${RTL} scripts/convert_filelist.py rtl/rtl.f
	mkdir -p $(dir $@)
	sv2v ${RTL} -w $@ -DSYNTHESIS

synth/yosys_common/build/synth.v: synth/yosys_common/build/rtl.sv2v.v synth/yosys_common/yosys.tcl
	rm -rf slpp_all
	yosys -p 'tcl synth/yosys_common/yosys.tcl' -l synth/yosys_common/build/yosys.log

gls: synth/yosys_common/build/synth.v
	verilator -I${YOSYS_DATDIR} --Mdir ${TOP}_$@_dir -f synth/yosys_common/gls.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+0
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+1
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/basys3/build/basys3/basys3.runs/impl_1/basys3.bit: ${RTL} synth/basys3/basys3.sv synth/basys3/Basys3_Master.xdc synth/basys3/constraints.xdc synth/basys3/vivado.tcl
	rm -rf synth/basys3/build/basys3
	mkdir -p synth/basys3/build
	cd synth/basys3/build && \
	 vivado -quiet -nolog -nojournal -notrace -mode tcl \
	  -source ../vivado.tcl

vivado-program: synth/basys3/build/basys3/basys3.runs/impl_1/basys3.bit
	cd synth/basys3/build && \
	 vivado -quiet -nolog -nojournal -notrace -mode tcl \
	  -source ../vivado-program.tcl -tclargs ${PART} ../../../$<

clean:
	rm -rf \
	 *.memh \
	 dump.fst \
	 sim_dir gls_dir \
	 synth/basys3/build \
	 synth/yosys_common/build
