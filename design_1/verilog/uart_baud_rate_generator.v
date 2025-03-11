`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: JOYAL
// 
// Create Date: 04.02.2024 12:58:48
// Design Name: 
// Module Name: baud_rate_genr_verilog
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
//
//
//
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

//////////////////////////////////////////////////////////////////////////////////

module baud_rate_genr_verilog
    #( parameter [3:0]baud_rate_select = 4'b0100
     )
    ( input  clock,
      input  reset,
      output wire locked_rst,
      output baud_clkx8,
      output baud_clk,
      output sys_resetn
    );
    
 reg [11:0]rst_count1 = 12'h0; 
 reg [4:0]clk_count1 = 5'b0;
 reg [1:0]clk_count2 = 2'b0;
 reg [8:0]clk_count3 = 9'b0;
 reg [7:0]clk_count4 = 8'b0;
 reg [2:0]clk_count5 = 3'b0;
 
 reg  locked_rst_ext;
 wire clock_58p982M;
 wire clock_3p686M;
 wire clock_1p843M;
 reg  clock_614p4K = 1'b0;
 
 reg  baud_clkx8_reg = 0;
 reg  baud_clk_reg = 0;
 
 wire baud_clkx8_1843200;
 wire baud_clkx8_460800; 
 wire baud_clkx8_307200; 
 wire baud_clkx8_230400; 
 wire baud_clkx8_153600; 
 wire baud_clkx8_76800;  
 wire baud_clkx8_38400;  
 wire baud_clkx8_19200;  
 wire baud_clkx8_14400;  
 wire baud_clkx8_9600;   
 wire baud_clkx8_4800;   
 wire baud_clkx8_2400;   
 
 
   clk_wiz_0  clk_wiz_int1
  (  
    .clk_out1(clock_58p982M),              
    .reset(reset), 
    .locked(locked_rst),
    .clk_in1(clock)            // Clock in ports
  );
  
  assign sys_resetn   = locked_rst_ext;
  assign baud_clkx8   = baud_clkx8_reg;
  assign baud_clk     = baud_clk_reg;
  
  
  assign clock_3p686M = clk_count1[3];
  assign clock_1p843M = clk_count1[4];
  
  assign baud_clkx8_1843200 = clk_count3[0];
  assign baud_clkx8_921600  = clk_count3[1];
  assign baud_clkx8_460800  = clk_count3[2];
  assign baud_clkx8_230400  = clk_count3[3];
  assign baud_clkx8_14400   = clk_count3[7];
                                          
  assign baud_clkx8_307200  = clk_count4[0];
  assign baud_clkx8_153600  = clk_count4[1];
  assign baud_clkx8_76800   = clk_count4[2];
  assign baud_clkx8_38400   = clk_count4[3];
  assign baud_clkx8_19200   = clk_count4[4];
  assign baud_clkx8_9600    = clk_count4[5];
  assign baud_clkx8_4800    = clk_count4[6];
  assign baud_clkx8_2400    = clk_count4[7];
  
  
  always@(posedge(clock))
  begin
    if(locked_rst)
    begin
      if(rst_count1 > 12'h1f4)
      begin
         rst_count1     <= rst_count1;
         locked_rst_ext <= 1'b1;
      end
      else
      begin
         rst_count1     <= rst_count1 + 1;
         locked_rst_ext <= 1'b0;
      end
    end
    else
    begin
      rst_count1     <= 0;
      locked_rst_ext <= 1'b0;
    end
  end
  
  always@(posedge(clock_58p982M))
  begin
    if(locked_rst_ext)
      clk_count1 <= clk_count1 + 5'b1;
    else
      clk_count1 <= 0;
  end
  
  always@(posedge(clock_3p686M))
  begin
    if(locked_rst_ext)
      clk_count3 <= clk_count3 + 9'b1;
    else
      clk_count3 <= 0;
  end
  
  always@(posedge(clock_1p843M))
  begin
    if(locked_rst_ext)
    begin
        if(clk_count2 == 2'b11)
        begin
            clk_count2   <= 2'b01;          
            clock_614p4K <= 1'b1;
        end
        else if(clk_count2 == 2'b01) 
        begin
            clk_count2   <= clk_count2 + 1'b1;
            clock_614p4K <= 1'b0;
        end
        else
        begin
            clk_count2 <= clk_count2 + 1'b1;    
        end
    end
    else
    begin
       clock_614p4K <= 1'b0;
       clk_count2   <= 2'b01; 
    end
  end
  
  always@(posedge(clock_614p4K))
  begin
    if(locked_rst_ext)
      clk_count4 <= clk_count4 + 8'b1;
    else
      clk_count4 <= 0;
  end
  
  always @(posedge clock)
  begin
        if (locked_rst_ext)
        begin
           case (baud_rate_select)
              4'b0000: baud_clkx8_reg <= baud_clkx8_1843200;
              4'b0001: baud_clkx8_reg <= baud_clkx8_921600; 
              4'b0010: baud_clkx8_reg <= baud_clkx8_460800; 
              4'b0011: baud_clkx8_reg <= baud_clkx8_307200; 
              4'b0100: baud_clkx8_reg <= baud_clkx8_230400; 
              4'b0101: baud_clkx8_reg <= baud_clkx8_153600; 
              4'b0110: baud_clkx8_reg <= baud_clkx8_76800;  
              4'b0111: baud_clkx8_reg <= baud_clkx8_38400;  
              4'b1000: baud_clkx8_reg <= baud_clkx8_19200;  
              4'b1001: baud_clkx8_reg <= baud_clkx8_14400;  
              4'b1010: baud_clkx8_reg <= baud_clkx8_9600;   
              4'b1011: baud_clkx8_reg <= baud_clkx8_4800;   
              4'b1100: baud_clkx8_reg <= baud_clkx8_2400;   
                       
              default: baud_clkx8_reg <= 0;
           endcase
        end
        else
            baud_clkx8_reg <= 0;
            
  end
            
  always@(posedge(baud_clkx8_reg))
  begin
    if(locked_rst_ext)
    begin
        if(clk_count5 == 3'b111)
        begin
            baud_clk_reg <= ~baud_clk_reg;
            clk_count5   <= 0;
        end
        else if(clk_count5 == 3'b011)
        begin
            baud_clk_reg <= ~baud_clk_reg;
            clk_count5   <= clk_count5 + 3'b001;
        end
        else
            clk_count5   <= clk_count5 + 3'b001;
    end
    else
    begin
        clk_count5   <= 0;
        baud_clk_reg <= 0;
    end
  end
  
endmodule
