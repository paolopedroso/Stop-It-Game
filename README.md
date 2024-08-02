# Stop It Game

## Table of Contents

1. [Submission](#submission)
2. [Goals](#goals)
   1. [Overview](#overview)
   2. [Random Number Generator](#random-number-generator)
   3. [Game Counter](#game-counter)
   4. [Time Counter](#time-counter)
   5. [7 Segment Display](#7-segment-display)
   6. [LED Display](#led-display)
   7. [Stop It State Machine](#stop-it-state-machine)
3. [Write-Up](#write-up)
4. [How to Run](#how-to-run)


### Overview

Watch the following video for an overview: [Lab Overview Video](https://youtu.be/GrlDUsAk_Ig).

The video is summarized here:

- At the start of each round, the Game Counter is displayed on the rightmost two digits of the BASYS3 7-segment display. The left two digits are off.
- A `go_i` signal is given (pushbutton `btnC` is pressed) to start the next round.
- In each round, a random 5-bit binary value, the target number, is selected and displayed on the two leftmost digits, and the 5-bit Game Counter (still displayed on the rightmost digits) is set to `1f`.
- After 2 seconds, the Game Counter begins to decrement every quarter second.
- The Game Counter will keep decrementing, rolling under to `1f` (31 decimal) after reaching 0.
- When the `stop_i` signal is given (pushbutton `btnU`), the Game Counter stops decrementing.
- At this point, if the value of the Game Counter matches the target number, then all 4 display digits flash for four seconds in unison.
- If the value of the Game Counter does not match the target number, then all 4 display digits flash for four seconds, with the target number and Game Counter digits alternating as they flash.
- The flashing continues for four seconds, and then the leftmost digits are again blank, and a new round can begin with a `go_i` signal.
- Each time the player succeeds in matching the target, one more LED lights up, beginning with the rightmost.
- If all 16 LEDs are lit, and the target number was matched, then the game has been won. After the digits flash for 4 seconds, all 16 LEDs flash, and no button, except `btnR` will have an effect.
- To make the game easier to win (without 17 matches), pressing `btnL` will be a cheat switch that will load the switches into the LEDs (or actually the shift register holding the values of the LEDs).

## Goals

- Learn to Implement Finite State Machines (FSMs): Gain practical experience in designing, implementing, and debugging FSMs in SystemVerilog.
- Develop Sequential Circuit Design Skills: Create and integrate various sequential circuit components such as counters, shift registers, and display drivers.
- FPGA Programming Experience: Program your design onto a Basys 3 FPGA Board and work with FPGA-specific tools like Vivado for synthesis and programming.

# Modules Implemented:

### Random Number Generator

- Created random number generator in `rtl/lfsr.sv` using a Linear Feedback Shift Register (LFSR) to generate a pseudorandom 8-bit binary number.
- Uses 5 bits from the LFSR as the target number.

### Game Counter

- Created Game Counter in `rtl/game_counter.sv`.
- This counter decrements on the 7-segment display and initializes to `1f` when `rst_ni` is active.

### Time Counter

- Created Time Counter in `rtl/time_counter.sv`.
- This counter tracks quarter-second increments and initializes to `0` when `rst_ni` is active.

### 7 Segment Display

- Created 7 Segment Display driver in `rtl/basys3/basys3_7seg_driver.sv`.
- It will display the target number and the Game Counter, making them flash based on the game state.

### LED Display

- Created LED display in `rtl/led_shifter.sv` using a 16-bit shift register controlled by the `shift_i` signal.

### Stop It State Machine

- Implemented the state machine in `rtl/stop_it.sv`.

## Project

### Requirements

To run this project, you will need the following:

- **Basys 3 FPGA Board:** Required to program and run the final implementation.
- **Xilinx Vivado:** Software for synthesizing, place-and-route, and programming the Basys 3 FPGA Board.
- **Verilator:** Tool for linting and simulating Verilog code.
- **Verible:** Linter for SystemVerilog.
- **GTKWave:** Waveform viewer for viewing simulation results.

### Files

- `synth/basys3/Basys3_Master.xdc`
- `rtl/game_counter.sv`
- `rtl/lfsr.sv`
- `rtl/basys3`
- `rtl/basys3/basys3_7seg_driver.sv`
- `rtl/basys3/hex7seg.sv`
- `rtl/stop_it.sv`
- `rtl/led_shifter.sv`
- `rtl/time_counter.sv`

## How to Run

To run this project, follow the steps below:

```bash

# synthesize, place-and-route, and program with Vivado
make vivado-program

# view waveforms
gtkwave dump.fst

```

### Contact

For any questions or further information, please contact:

- **Paolo Pedroso**
- **Email:** [paoloapedroso@gmail.com](mailto:paoloapedroso@gmail.com)
- **GitHub:** [github.com/paolopedroso](https://github.com/paolopedroso)

---

Enjoy playing the "Stop It" game!

---

CSE100 - Lab 4

Copyright ©2024 Martine Schlag and Ethan Sifferman.

All rights reserved. **Distribution Prohibited.**

---

