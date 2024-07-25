
# Stop It

```bash
# open in VS Code
code .

# lint with Verilator and Verible
make lint

# simulate with Verilator
make sim TOP=basys3_7seg_driver_tb
make sim TOP=counters_tb
make sim TOP=led_shifter_tb
make sim TOP=lfsr_tb
make sim TOP=stop_it_tb

# synthesize with Yosys, then simulate with Verilator
make gls TOP=basys3_7seg_driver_tb
make gls TOP=counters_tb
make gls TOP=led_shifter_tb
make gls TOP=lfsr_tb
make gls TOP=stop_it_tb

# view waveforms
gtkwave dump.fst

# synthesize, place-and-route, and program with Vivado
make vivado-program
```
