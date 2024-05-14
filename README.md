# 20006DS

It is a watch which includes 4 functions: Clock, Stop Timmer, Countdown Timmmer, and Game.

## Functions

### Clock

The 7-segments display hours, minutes and seconds. If we click both **KEY1** and **KEY0**, the clock will stop.

To modify the clock, press and hold **KEY2** to enter edit mode. In this mode, the modifiable segment will flash at a frequency of 2Hz with an 80% duty cycle.

Use **KEY1** and **KEY0** to increment or decrement this digit. There are the following features:

- Upon clicking the KEY, one unit will be immediately added to the ones place.
- If the KEY is pressed and held for at least 0.5 seconds, the one place will change by 10 per second.
- After the adjustment of seconds, the clock will reset at the start of the current second.
- The carry of seconds will not be effective during the seconds and minutes are being changed, but it is enabled when modifing hours.

### Stop Watch

**KEY0** serves as the start/stop button, while **KEY2** functions as the reset button.

The 7-segments display indicates the minutes, seconds, and milliseconds.

### Countdown Watch

The 7-segments display hours, minutes and seconds. **KEY2** is the reset button, **KEY1** can increase seconds place, **KEY0** is the start/stop button.

When time is up, the LED0 will be lit (reset button will not light this LED).

LED[0] is always enabled whatever the mode is. And the reset button can always turn off this LED.

### Game

To do.

### Mode

**KEY3** can select different modes. And LED[9: 6] will show which mode it is.

|LED9|LED8|LED7|LED6|
|---|---|---|---|
|mode: 2'b00|mode: 2'b01|mode: 2'b10|mode: 2'b11|

## Verilog Code Specification
