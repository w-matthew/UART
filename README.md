# UART Implementation in SystemVerilog
## Overview
UART (Universal Asynchronous Receiver/Transmitter) is a serial communication protocol used to transfer data between two devices. In my implementation, I choose to send the 8-bit ASCII character representations between my PC and FPGA (PYNQ-Z2). Though this protocol is quite dated, what makes this special compared to SPI or I2C, is that it does not require a clock to communicate, instead, both devices agree to a baud rate. A typical waveform of UART is shown below.

![UART Waveform](https://github.com/user-attachments/assets/cfbd64e1-db43-4701-b576-28829290f85b)
## Implementation
Two parts, the transmitter and the receiver. The transmitter takes in 8 parallel bits (ex. ASCII char) and outputs them in serial from LSB to MSB. The reciever takes in serial bits and reconstructs them into a parallel 8 bit output.


