Digital Multimode Watch | Verilog & FPGA

A hardware-based multimode system designed for the DE10-Lite FPGA (Intel/Altera). This project implements a central control system that manages a real-time clock, alarm, stopwatch, and countdown timer using a Finite State Machine (FSM).



System Architecture

This project is built using a modular "Top-Down" hierarchy to ensure reliability and clean signal processing:

State Control (main.v): The central logic unit that manages system states (Time, Alarm, Stopwatch, Timer) and handles user inputs via push-buttons.

Clock Management: Uses dedicated dividers (clock_divider.v, ms_clock_divider.v) to transform the 50 MHz system clock into accurate 1Hz and millisecond pulses.

Peripheral Interface: A custom driver (seven_seg.v) that translates binary-coded decimal data into patterns for the physical 7-segment displays.


Key Engineering Concepts

Finite State Machine (FSM): The core of the project is a logic-driven state machine that handles transitions between various operational modes.

Modular Hardware Design: Separating timing logic, display drivers, and state control into independent, reusable modules.

Debouncing & Synchronization: Ensuring stable user interaction by filtering hardware signal noise.


How to Deploy

Open the project in Intel Quartus Prime.

Assign the pins according to the DE10-Lite user manual.

Compile the design and program the .sof file to the FPGA.
