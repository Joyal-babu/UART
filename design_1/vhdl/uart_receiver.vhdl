----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL 
-- 
-- Create Date: 20.01.2024 22:07:50
-- Design Name: 
-- Module Name: uart_receiver - Behavioral
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

entity uart_receiver is
    generic (
           data_bus_width : natural                                                 -- define the data width here   8, 16, 32 ....
    );
    Port ( clock         : in  STD_LOGIC;
           reset         : in  STD_LOGIC;
           baud_clkx8    : in  STD_LOGIC;
           Rx_in         : in  STD_LOGIC;
           data_bus_rx   : out STD_LOGIC_VECTOR((data_bus_width-1) downto 0);
           one_data_recd : out STD_LOGIC
    );
end uart_receiver;

architecture Behavioral of uart_receiver is

signal baud_clkx8_d1 : std_logic;
signal baud_clkx8_d2 : std_logic;
signal baud_clkx8_rise : std_logic;
--signal start_bit_count : std_logic_vector(3 downto 0);
signal baud_clkx8_rise_count : std_logic_vector(3 downto 0);
signal hold_cnt              : std_logic_vector(3 downto 0);
signal data_shift_reg        : std_logic_vector(data_bus_width downto 0);
signal data_bus_rx_reg       : std_logic_vector((data_bus_width-1) downto 0);

signal bit_count       : natural := 0;

type uart_rx_state is (
    st1_idle,
    st2_start_bit_detect,
    st3_start_bit_middle,
    st4_receive_data,
    st5_shift_data,
    st6_bit_count_check,   
    st7_load_data,
    st8_one_data_recd_flag
);
signal rx_state : uart_rx_state;

begin

    process(clock, reset)
    begin
        if(reset = '0') then
            baud_clkx8_d1 <= '0';
            baud_clkx8_d2 <= '0';
        elsif(rising_edge(clock)) then
            baud_clkx8_d1 <= baud_clkx8;
            baud_clkx8_d2 <= baud_clkx8_d1;
        end if;
    end process;
    
    baud_clkx8_rise <= baud_clkx8 and (not baud_clkx8_d1);                      -- finding the rising edge if baud_clkx8
    
    data_bus_rx <= data_bus_rx_reg;
    
    process(clock, reset)
    begin
        if(reset = '0') then
            one_data_recd   <= '0';
            rx_state        <= st1_idle;
            data_shift_reg  <= (others => '0');
            data_bus_rx_reg <= (others => '0');
            hold_cnt        <= (others => '0');
            bit_count       <= 0;
            baud_clkx8_rise_count <= (others => '0');
        elsif(rising_edge(clock)) then
            case(rx_state) is 
                
                when st1_idle => 
                    if(Rx_in = '0') then                                                -- detect the start bit and count 4 baud_clkx8 rising edges if Rx_in is 0 to confirm the start bit
                        rx_state <= st2_start_bit_detect;
                    else
                        one_data_recd   <= '0';
                        data_shift_reg  <= (others => '0');
                        --data_bus_rx_reg <= (others => '0');
                        hold_cnt        <= (others => '0');
                        bit_count       <= 0;
                        baud_clkx8_rise_count <= (others => '0');
                        rx_state        <= st1_idle;
                    end if;
                    
                when st2_start_bit_detect =>
                    if(baud_clkx8_rise = '1') then
                        if(Rx_in = '1') then
                            rx_state <= st1_idle;
                        else
                            baud_clkx8_rise_count <= baud_clkx8_rise_count + '1';
                            rx_state <= st3_start_bit_middle;
                        end if;
                    else
                        rx_state <= st2_start_bit_detect;
                    end if;
                    
                when st3_start_bit_middle =>                                              -- reach the middle of start bit 
                    if(baud_clkx8_rise_count = "0100") then
                        baud_clkx8_rise_count <= (others => '0');
                        rx_state <= st4_receive_data;
                    else
                        rx_state <= st2_start_bit_detect;
                    end if;
                         
                when st4_receive_data =>                                                 -- count 8 baud_clkx8 rising edges to reach the middle of serial data bit and load into the shift register
                    if(baud_clkx8_rise = '1') then
                        baud_clkx8_rise_count <= baud_clkx8_rise_count + '1';
                        rx_state  <= st5_shift_data;
                    else
                        rx_state <= st4_receive_data;
                    end if;
                    
                when st5_shift_data =>                                                    -- loading each received bit to the shift register
                    if(baud_clkx8_rise_count = "1000") then
                        baud_clkx8_rise_count <= (others => '0');
                        data_shift_reg <= Rx_in & data_shift_reg(data_bus_width downto 1);
                        bit_count      <= bit_count + 1;
                        rx_state       <= st6_bit_count_check;
                    else
                        rx_state <= st4_receive_data;
                    end if;
                    
               when st6_bit_count_check =>                                                 -- receive as many serial data bits defined in the generic section , data_bus_width
                    if(bit_count = data_bus_width + 1) then                 
                        bit_count <= 0;
                        rx_state  <= st7_load_data;
                    else
                        rx_state <= st4_receive_data;
                    end if;
                    
               when st7_load_data =>                                                       -- load the received data from shift register to output reg
                    if(Rx_in = '1') then
                        data_bus_rx_reg       <= data_shift_reg((data_bus_width-1) downto 0);                          
                        baud_clkx8_rise_count <= (others => '0');
                        one_data_recd         <= '1';
                        rx_state <= st8_one_data_recd_flag;
                    else
                        rx_state   <= st1_idle; 
                        bit_count  <= 0;
                        baud_clkx8_rise_count <= (others => '0');
                    end if;
                    
               when st8_one_data_recd_flag =>                                                 -- make one data received flag high for 7 clock cycles 
                    if(hold_cnt = "0111") then
                        hold_cnt      <= (others => '0');
                        one_data_recd <= '0';
                        rx_state      <= st1_idle;
                    else
                        hold_cnt      <= hold_cnt + '1';
                        one_data_recd <= '1';
                        rx_state      <= st8_one_data_recd_flag; 
                    end if;
                    
               when others => 
                    rx_state <= st1_idle;
                
            end case;
        end if;
    end process;


end Behavioral;
