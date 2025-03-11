----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 16.01.2024 22:26:02
-- Design Name: 
-- Module Name: uart_transmitter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_transmitter is
    generic ( 
        data_bus_width : natural 
    );
    Port ( 
        clock           : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        baud_clk        : in  STD_LOGIC;
        data_bus_tx     : in  STD_LOGIC_VECTOR((data_bus_width-1) DOWNTO 0);     -- Parallel data input 
        start_trig      : in  STD_LOGIC;
        Tx_out          : out STD_LOGIC;                                         -- Serial data output
        one_data_transd : out STD_LOGIC                                          -- trigger output indicates one data serial transmission is done    
    );
end uart_transmitter;

architecture Behavioral of uart_transmitter is

signal baud_clk_d, baud_clk_d1, baud_clk_rise : std_logic;
signal Tx_out_reg     : std_logic;
signal bit_count      : natural := 0;--std_logic_vector(3 downto 0);
signal data_bus_reg   : std_logic_vector(data_bus_width DOWNTO 0);

   type uart_tx_state is (st1_idle, st2_start_bit, st3_data_transfer, st4_check_bit_count, st5_stop_bit, st6_done_flag, st7_delay1, st8_delay2);
   signal tx_state : uart_tx_state;

begin

    process(clock, reset)
    begin
        if(reset = '0') then
            baud_clk_d  <= '0';
            baud_clk_d1 <= '0';
        elsif(rising_edge(clock)) then 
            baud_clk_d  <= baud_clk;
            baud_clk_d1 <= baud_clk_d;
        end if;
    end process;
    
    baud_clk_rise <= baud_clk and (not baud_clk_d);
    
    process(clock, reset)
    begin
        if(reset = '0') then
            tx_state        <= st1_idle;
            Tx_out_reg      <= '1';
            one_data_transd <= '0';
            bit_count       <= 0;                 --(others => '0');
            data_bus_reg    <= (others => '1');
        elsif(rising_edge(clock)) then
            case(tx_state) is 
             
                when st1_idle => 
                    if(start_trig = '1') then
                        tx_state     <= st2_start_bit;
                        data_bus_reg <= data_bus_tx & '1';
                    else
                        tx_state        <= st1_idle;
                        bit_count       <= 0;                  --(others => '0');
                        Tx_out_reg      <= '1';
                        one_data_transd <= '0';
                        data_bus_reg    <= (others => '1');                       
                    end if;
                      
                 when st2_start_bit =>
                      if(baud_clk_rise = '1') then 
                        Tx_out_reg <= '0';
                        tx_state   <= st3_data_transfer;
                      else
                        Tx_out_reg <= '1';
                        tx_state   <= st2_start_bit;
                      end if;
                            
                 when st3_data_transfer => 
                    if(baud_clk_rise = '1') then
                        data_bus_reg <= '1' & data_bus_reg(data_bus_width DOWNTO 1);
                        Tx_out_reg   <= data_bus_reg(1);
                        bit_count    <= bit_count + 1;
                        tx_state     <= st4_check_bit_count;
                    else
                        Tx_out_reg <= Tx_out_reg;
                        bit_count  <= bit_count;
                        tx_state   <= st3_data_transfer;
                    end if;
                    
                 when st4_check_bit_count => 
                       if(bit_count >= data_bus_width ) then
                            tx_state <= st5_stop_bit;
                       else
                            tx_state <= st3_data_transfer;
                       end if;
                    
                 when st5_stop_bit => 
                      if(baud_clk_rise = '1') then 
                        Tx_out_reg <= '1';
                        bit_count  <= bit_count + 1;
                        tx_state   <= st6_done_flag;
                      else
                        Tx_out_reg <= Tx_out_reg;
                        bit_count  <= bit_count;
                        tx_state   <= st5_stop_bit;
                      end if;
                      
                 when st6_done_flag => 
                      if(baud_clk_rise = '1') then 
                        Tx_out_reg      <= '1'; 
                        one_data_transd <= '1';
                        bit_count       <= 0;                            --(others => '0');
                        tx_state        <= st7_delay1;
                      else
                        Tx_out_reg      <= Tx_out_reg;
                        one_data_transd <= '0';
                        bit_count       <= bit_count;   
                        tx_state        <= st6_done_flag;
                      end if;
                      
                 when st7_delay1 => 
                        tx_state      <= st8_delay2;
                        
                 when st8_delay2 => 
                        tx_state      <= st1_idle;           
                    
                 when others => 
                        tx_state <= st1_idle;
                      
            end case;
        
        end if;           
    end process;
    
    Tx_out <= Tx_out_reg;


end Behavioral;
