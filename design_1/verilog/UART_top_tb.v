`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: JOYAL 
// 
// Create Date: 09.03.2024 12:35:20
// Design Name: 
// Module Name: UART_TOP_tb
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


module UART_TOP_tb();

    localparam [3:0]baud_rate_select = 4'b0100;
    localparam data_width            = 8;


    reg clock;                     
    reg reset;                      
    reg [data_width-1:0]data_bus_in;
    reg start_trig_in;              
    
    wire one_data_send;              
    wire one_data_recd;              
    wire [data_width-1:0]data_bus_out;
    
    
    UART_TOP_VERILOG #(
        .baud_rate_select(baud_rate_select),
        .data_width(data_width)
    )
    UART_TOP_VERILOG_inst1 (
        .clock(clock),                      
        .reset(reset),                      
        .data_bus_in(data_bus_in),
        .start_trig_in(start_trig_in),              
        .one_data_send(one_data_send),              
        .one_data_recd(one_data_recd),              
        .data_bus_out(data_bus_out)
    );
    
    always #5     clock    <= ~clock;
    
    initial
    begin
        clock          <= 1'b0;
        reset          <= 1'b1;
        start_trig_in  <= 1'b0;
        data_bus_in    <= 8'b01011011;              
        #500 reset     <= 1'b0;
        #18545 start_trig_in <= 1'b1;
        #50  start_trig_in   <= 1'b0;
    end   

endmodule
