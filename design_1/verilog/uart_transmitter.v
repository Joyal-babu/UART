`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: JOYAL
// 
// Create Date: 07.02.2024 20:53:20
// Design Name: 
// Module Name: uart_transmitter_verilog
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module uart_transmitter_verilog
    #( parameter data_width = 8 )
    
    ( input  clock,
      input  resetn,
      input  baud_clk,
      input  [data_width-1:0]data_bus,                                //Parallel data input
      input  start_trig,
      output Tx_out,                                                  //Serial data output
      output one_data_send                                            //output trigger signal indicates one data serial transmission is done
    );
    
    
reg  Tx_out_reg = 0;
reg  [data_width:0]data_bus_reg;
reg  one_data_send_reg = 0;
reg  baud_clk_d, baud_clk_d1 = 0;

wire baud_clk_rise;

integer bit_count = 0;

parameter st1_idle            = 3'b000;
parameter st2_start_bit       = 3'b001;
parameter st3_data_transfer   = 3'b010;
parameter st4_check_bit_count = 3'b011;
parameter st5_stop_bit        = 3'b100;
parameter st6_done_flag       = 3'b101;
parameter st7_delay1          = 3'b110;
parameter st8_delay2          = 3'b111;

reg [2:0]tx_state = st1_idle;

assign baud_clk_rise = baud_clk_d & (~(baud_clk_d1));
assign one_data_send = one_data_send_reg;
assign Tx_out        = Tx_out_reg;

    always@(posedge(clock))
    begin
        if(resetn)
        begin
            baud_clk_d  <= baud_clk;
            baud_clk_d1 <= baud_clk_d;
        end
        else
        begin
            baud_clk_d  <= 0;
            baud_clk_d1 <= 0;
        end
    end
    
    always@(posedge(clock))
    begin
        if(resetn == 0)
        begin
            tx_state          <= st1_idle;
            Tx_out_reg        <= 1'b1;                                    // HIGH when no data is transfered
            data_bus_reg      <= {data_width{1'b1}};
            bit_count         <= 0;
            one_data_send_reg <= 1'b0;
        end
        else
        begin
            case(tx_state)
                st1_idle : begin
                    if(start_trig)
                    begin
                        tx_state     <= st2_start_bit;
                        data_bus_reg <= {data_bus, 1'b1};
                    end
                    else
                    begin
                        tx_state          <= st1_idle;
                        Tx_out_reg        <= 1'b1;
                        data_bus_reg      <= {data_width{1'b1}};
                        bit_count         <= 0;
                        one_data_send_reg <= 1'b0;                        
                    end
                end
                
                st2_start_bit : begin
                    if(baud_clk_rise)
                    begin
                        tx_state   <= st3_data_transfer;
                        Tx_out_reg <= 1'b0;
                    end
                    else
                    begin
                        tx_state   <= st2_start_bit;
                        Tx_out_reg <= 1'b1;
                    end
                end
                
                st3_data_transfer : begin
                    if(baud_clk_rise)
                    begin
                        data_bus_reg <= {1'b1, data_bus_reg[data_width:1]};
                        Tx_out_reg   <= data_bus_reg[1];
                        bit_count    <= bit_count + 1;
                        tx_state     <= st4_check_bit_count;
                    end
                    else
                    begin
                        Tx_out_reg <= Tx_out_reg;
                        bit_count  <= bit_count;
                        tx_state   <= st3_data_transfer;
                    end
                end
                
                st4_check_bit_count : begin
                    if(bit_count >= data_width)
                        tx_state <= st5_stop_bit;
                    else
                        tx_state <= st3_data_transfer;
                end
                
                st5_stop_bit : begin
                    if(baud_clk_rise)
                    begin
                        Tx_out_reg <= 1'b1;
                        bit_count  <= bit_count + 1;
                        tx_state   <= st6_done_flag;
                    end
                    else
                    begin
                        Tx_out_reg <= Tx_out_reg;
                        bit_count  <= bit_count;
                        tx_state   <= st5_stop_bit;
                    end
                end
                
                st6_done_flag : begin
                    if(baud_clk_rise)
                    begin
                        Tx_out_reg        <= 1'b1;
                        bit_count         <= 0;
                        one_data_send_reg <= 1'b1;
                        tx_state          <= st7_delay1;
                    end
                    else
                    begin
                        Tx_out_reg        <= Tx_out_reg;
                        bit_count         <= bit_count;
                        one_data_send_reg <= 1'b0;
                        tx_state          <= st6_done_flag;
                    end
                end
                
                st7_delay1 : begin
                    tx_state <= st8_delay2;
                end
                
                st8_delay2 : begin
                    tx_state <= st1_idle;
                end
                
            endcase
        end
    end
   
endmodule
