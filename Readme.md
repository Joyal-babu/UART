# UART - Universal Asynchronous Receiver and Transmitter

UART plays an important role in serial communication. A reuseable UART design using VHDL and VERILOG is proposed here. The proposed URT is composed of a Baud Rate Generator, Transmiter module and a receiver module. The N-8-1 (No Parity(N), Eight(8) data bits, One(1) stop bit) format is implemented but the design can be reconfigured for required width such as 16, 32 etc by making changes in generic section of top module.

The UART contains a receiver (serial to parallel converter) and a transmitter (parallel to serial converter). It handles the convertion between serial and parallel data. Serial communication reduces the distortion of a signal, therefore makes data transfer between two systems seperated in great distance possible. 

The UART frame consists of 1 start bit, a number of data bits, an optional parity bit and 1 or 2 stop bits. The start bit goes **_low_** for one bit time, then a number of data bits are transmitted,**_least significant bit first_** and stop bit goes **_high_** for one or two bit time. When no data is being transmitted, a logic 1 must be placed in the transmitted data line. The number of data bits, the parity bit and the number of stop bits must be set as a priori in all communication partners.  

Many UART performs multiple sample points to detect a bit cell and decide on a major vote. This method affords a multiple of the sampling frequency for single bit detection but provides immunity to short spike disturbances on the communication line.

>Simulation result with Tx_out loopbacked to RX_in

![Simulation result with Tx_out loopbacked to RX_in](https://github.com/Joyal-babu/FPGA_VERILOG_VHDL/assets/123290522/bdea56c3-30af-4058-8c7b-18b1607221c1)


### BAUD RATE GENERATOR

The number of bits transmitted per second is frequently referred to as the baud rate. The proposed baud rate generator can provide standard RS-232C baud rate clocks such as **230400, 115200, 57600, 38400, 28800, 19200, 9600, 4800, 2400, 1800, 1200, 600, 300** ans 8 times the data rate clock for single bit detection sampling in receiver module. One can select the required baud rate by assigning different values from the table to "baud_rate_select" in generic section.

~~~
____________________________________________________
| BAUD_RATE_SELECT  |  BAUD_RATE X 8  |  BAUD_RATE  |
|___________________|_________________|_____________|
|     0             |    1843200      |   230400    |
|     1             |    921600       |   115200    |
|     2             |    460800       |   57600     |
|     3             |    307200       |   38400     |
|     4             |    230400       |   28800     |
|     5             |    153600       |   19200     |
|     6             |    76800        |   9600      |
|     7             |    38400        |   4800      |
|     8             |    19200        |   2400      |
|     9             |    14400        |   1800      |
|     A             |    9600         |   1200      |
|     B             |    4800         |   600       |
|     C             |    2400         |   300       |
|___________________|_________________|_____________|
~~~

>Baud rate generator simulation result

![Screenshot (40)](https://github.com/Joyal-babu/FPGA_VERILOG_VHDL/assets/123290522/4b723bc2-91ae-4a3d-9e23-6e0f6103724c)



### TRANSMITTER MODULE

The transmitter circuitry converts a parallel data word into serial form and appends the start and stop bits.The module waits for **_start_trig_** to be HIGH to load the data that has to be transmitted.After sending one data **_one_data_transd_** signal is made HIGH for 3 clock cycles.


>Transmitter module simulation results

![tx simulation](https://github.com/Joyal-babu/FPGA_VERILOG_VHDL/assets/123290522/adaa5424-0cb1-47cc-89fe-056f3954bf18)


### RECEIVER MODULE

The task of receiver is to receive a serial bit sream in the form: start bits, data, stop bits and store the contained data. To avoid setup and hold time problems and reading some bits at the wrong time, the data is sampled 8 times during each bit time ie sampled on the rising edge of baud_clkx8.
when Rx_in first goes to 0, wait 4 more baud_clkx8 clocks to reach middle of the start bit.Then wait 8 more clock cycles to reach the middle of first data bit, read the data and continue reading at every 8 baud_clkx8 clock until reading the stop bit.After receiving one data **_one_data_recvd_** signal is made HIGH for 7 clock cycles.



> ELABORATED DESIGN

   ![Screenshot (35)](https://github.com/Joyal-babu/FPGA_VERILOG_VHDL/assets/123290522/9e9149d8-28d2-40c3-a6c4-f436117f5f28)



















