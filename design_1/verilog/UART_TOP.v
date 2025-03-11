`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: JOYAL 
// 
// Create Date: 09.03.2024 10:44:26
// Design Name: 
// Module Name: UART_TOP_VERILOG
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//     -----------------------------------------------------
//     | BAUD_RATE_SELECT  |  BAUD_RATE X 8  |  BAUD_RATE  |
//     -----------------------------------------------------
//     |     0             |    1843200      |   230400    |
//     |     1             |    921600       |   115200    |
//     |     2             |    460800       |   57600     |
//     |     3             |    307200       |   38400     |
//     |     4             |    230400       |   28800     |
//     |     5             |    153600       |   19200     |
//     |     6             |    76800        |   9600      |
//     |     7             |    38400        |   4800      |
//     |     8             |    19200        |   2400      |
//     |     9             |    14400        |   1800      |
//     |     A             |    9600         |   1200      |
//     |     B             |    4800         |   600       |
//     |     C             |    2400         |   300       |
//     -----------------------------------------------------
//
//
//



module UART_TOP_VERILOG
    #( parameter [3:0]baud_rate_select = 4'b0100,
       parameter data_width            = 8 
 
    )
    (
       input  clock,
       input  reset,
       input  [data_width-1:0]data_bus_in,
       input  start_trig_in,
       input  Rx_in,
       output Tx_out,
       output one_data_send,
       output one_data_recd,
       output [data_width-1:0]data_bus_out
    );
    
    wire locked_rst;
    wire baud_clkx8;
    wire baud_clk;
    wire sys_resetn;
    wire [(data_width-1):0]data_bus_rx;
    wire tx_out_rx_in_loopback;
    
    
    baud_rate_genr_verilog 
        #( .baud_rate_select(baud_rate_select)
    )
    baud_rate_genr_inst1 (
        .clock(clock),    
        .reset(reset),    
        .locked_rst(locked_rst),
        .baud_clkx8(baud_clkx8),
        .baud_clk(baud_clk),
        .sys_resetn(sys_resetn)
    );
    
    
    uart_transmitter_verilog 
        #( .data_width(data_width)
    )  
    uart_transmitter_verilog_inst1 (
        .clock(clock),                     
        .resetn(sys_resetn),                    
        .baud_clk(baud_clk),                  
        .data_bus_tx(data_bus_in),
        .start_trig(start_trig_in),                
        .Tx_out(Tx_out),                          //(tx_out_rx_in_loopback),  - loopback for testing                    
        .one_data_send(one_data_send)              
    );      
    
    uart_receiver_verilog 
        #( .data_width(data_width)
    )
    uart_receiver_verilog_inst1 (
        .clock(clock),                    
        .resetn(sys_resetn),                 
        .baud_clkx8(baud_clkx8),               
        .Rx_in(Rx_in),                           //(tx_out_rx_in_loopback),  - loopback for testing           
        .data_bus_rx(data_bus_out),
        .one_data_recd(one_data_recd)                 
    );
    
    
    
endmodule
