`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: JOYAL
// 
// Create Date: 15.02.2024 22:18:17
// Design Name: 
// Module Name: uart_receiver_verilog
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


module uart_receiver_verilog
    #(parameter data_width = 8)                                                  // define the data width here   8, 16, 32 ....
    
    ( input  clock,
      input  resetn,                                                             // Active low reset
      input  baud_clkx8,                                                         // clock 8 times baud clock to detect each bit
      input  Rx_in,                                                              // serial data in
      output [(data_width-1):0]data_bus,                                         // parallel data output
      output one_data_recd                                                       // flag indicates one data is received through serial line
     );


reg baud_clkx8_d  = 0;
reg baud_clkx8_d1 = 0;
reg [(data_width-1):0]data_bus_reg;
reg one_data_recd_reg;
reg [3:0]start_count;
reg [3:0]baud_clkx8_rise_count;
reg [3:0]hold_count;
reg [data_width:0]data_shift_reg;

wire baud_clkx8_rise;

integer bit_count = 0;


parameter st1_idle               = 3'b000;
parameter st2_start_bit_detect   = 3'b001;
parameter st3_start_bit_middle   = 3'b010;
parameter st4_receive_data       = 3'b011;
parameter st5_shift_data         = 3'b100;
parameter st6_bit_count_check    = 3'b101;
parameter st7_load_data          = 3'b110;
parameter st8_one_data_recd_flag = 3'b111;

reg [2:0]rx_state = st1_idle;

assign baud_clkx8_rise = baud_clkx8_d & (~baud_clkx8_d1);                                // finding the rising edge if baud_clkx8
assign data_bus        = data_bus_reg;
assign one_data_recd   = one_data_recd_reg;

    always@(posedge(clock))
    begin
        if(!resetn)
        begin
            baud_clkx8_d  <= 0;
            baud_clkx8_d1 <= 0;
        end
        else
        begin
            baud_clkx8_d  <= baud_clkx8;
            baud_clkx8_d1 <= baud_clkx8_d;
        end
    end
    
    always@(posedge(clock))
    begin
        if(!resetn)
        begin
            data_shift_reg        <= {(data_width+1){1'b0}};
            data_bus_reg          <= {data_width{1'b0}};
            one_data_recd_reg     <= 1'b0;
            start_count           <= 4'b0000;
            baud_clkx8_rise_count <= 4'b0000;
            hold_count            <= 4'b0000;
            bit_count             <= 0;
            rx_state              <= st1_idle;
        end
        else
        begin
            case(rx_state)
                st1_idle : begin
                    if(!Rx_in)                                                                                 // detect the start bit and count 4 baud_clkx8 rising edges if Rx_in is 0 to confirm the start bit
                    begin
                        rx_state <= st2_start_bit_detect;
                    end
                    else
                    begin
                        data_shift_reg        <= {(data_width+1){1'b0}};     
                        one_data_recd_reg     <= 1'b0;                  
                        start_count           <= 4'b0000;               
                        baud_clkx8_rise_count <= 4'b0000;               
                        hold_count            <= 4'b0000; 
                        bit_count             <= 0;              
                        rx_state              <= st1_idle;                 
                    end
                end   
                
                st2_start_bit_detect : begin
                    if(baud_clkx8_rise)
                    begin
                        if(Rx_in)
                        begin
                            rx_state <= st1_idle;
                        end
                        else
                        begin
                            baud_clkx8_rise_count <= baud_clkx8_rise_count + 4'b0001;
                            rx_state <= st3_start_bit_middle;
                        end
                    end
                    else
                    begin
                        rx_state <= st2_start_bit_detect;
                    end
                end
                
                st3_start_bit_middle : begin                                                           // reach the middle of start bit
                    if(baud_clkx8_rise_count == 4'b0100)
                    begin
                        baud_clkx8_rise_count <= 4'b0000;
                        rx_state <= st4_receive_data;
                    end
                    else
                    begin
                        rx_state <= st2_start_bit_detect;
                    end
                end
                
                st4_receive_data : begin                                                                 // count 8 baud_clkx8 rising edges to reach the middle of serial data bit and load into the shift register
                    if(baud_clkx8_rise)
                    begin
                        baud_clkx8_rise_count <= baud_clkx8_rise_count + 4'b0001;
                        rx_state <= st5_shift_data;
                    end
                    else
                    begin
                        rx_state <= st4_receive_data;
                    end
                end 
                
                st5_shift_data : begin                                                                    // loading each received bit to the shift register
                    if(baud_clkx8_rise_count == 4'b1000)
                    begin
                       data_shift_reg <= {Rx_in, data_shift_reg[data_width:1]};
                       baud_clkx8_rise_count <= 4'b0000;
                       bit_count <= bit_count + 1;
                       rx_state  <= st6_bit_count_check; 
                    end
                    else
                    begin
                        rx_state <= st4_receive_data;
                    end
                end
                
                st6_bit_count_check : begin                                                        // receive as many serial data bits defined in the generic section , data_bus_width
                    if(bit_count == (data_width + 1))
                    begin
                        bit_count <= 0;
                        rx_state  <= st7_load_data;
                    end
                    else
                    begin
                        rx_state <= st4_receive_data;
                    end
                end
                
                st7_load_data : begin                                                              // load the received data from shift register to output reg
                    if(Rx_in)
                    begin
                        data_bus_reg <= data_shift_reg[(data_width-1):0];
                        one_data_recd_reg <= 1'b1;
                        rx_state <= st8_one_data_recd_flag;
                    end
                    else
                    begin
                        rx_state <= st1_idle;
                    end
                end
                
                st8_one_data_recd_flag : begin                                                    // make one data received flag high for 7 clock cycles
                    if(hold_count == 4'b0111)
                    begin
                        hold_count <= 4'b0000;
                        one_data_recd_reg <= 1'b0;
                        rx_state <= st1_idle;
                    end
                    else
                    begin
                        hold_count <= hold_count + 4'b0001;
                        one_data_recd_reg <= 1'b1;
                        rx_state <= st8_one_data_recd_flag;
                    end
                end
            endcase
        end
    end

endmodule

