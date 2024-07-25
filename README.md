# Stop It Game

## Contents
1. [Overview](#overview)

**Currently Working**
---

### Overview

Watch this video to understand what to do for this lab: [Lab 4 Overview Video](https://youtu.be/GrlDUsAk_Ig).

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


CSE100 - Lab 4
Copyright ©2024 Martine Schlag and Ethan Sifferman.
All rights reserved. **Distribution Prohibited.**

