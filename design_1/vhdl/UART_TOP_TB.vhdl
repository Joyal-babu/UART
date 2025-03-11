----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 21.01.2024 19:47:01
-- Design Name: 
-- Module Name: UART_TOP_TB - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_TOP_TB is
--  Port ( );
end UART_TOP_TB;

architecture Behavioral of UART_TOP_TB is

component UART_TOP is
    generic ( 
        baud_rate_select : std_logic_vector(3 downto 0);
        data_bus_width   : natural
    );
    Port ( 
        clock           : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        data_bus_in     : in  STD_LOGIC_VECTOR((data_bus_width-1) downto 0);
        start_trig      : in  STD_LOGIC;
        Rx_in           : in  STD_LOGIC;
        Tx_out          : out STD_LOGIC;
        one_data_transd : out STD_LOGIC;
        data_bus_out    : out STD_LOGIC_VECTOR((data_bus_width-1) downto 0);
        one_data_recd   : out STD_LOGIC        
    );
end component;

constant baud_rate_select : std_logic_vector(3 downto 0) := x"1";
constant data_bus_width   : natural := 8;

signal clock, reset, start_trig, Rx_in        : std_logic := '0';
signal Tx_out, one_data_transd, one_data_recd : std_logic := '0';
 
signal data_bus_in  : std_logic_vector((data_bus_width-1) downto 0) := (others => '0');
signal data_bus_out : std_logic_vector((data_bus_width-1) downto 0) := (others => '0');


begin

    clock <= not clock after 5 ns;
    reset <= '1' , '0' after 500 ns;
    data_bus_in <= "01011011", "11011010" after 100 us;
    
    process
    begin
        wait for 20 us;
        start_trig  <= '1'; wait for 100 ns;
        start_trig  <= '0'; wait for 160 us;
    end process; 

    DUT : UART_TOP
        generic map(
            baud_rate_select => baud_rate_select,
            data_bus_width   => data_bus_width
        )
        port map (
            clock            => clock,
            reset            => reset,
            data_bus_in      => data_bus_in,
            start_trig       => start_trig,
            Rx_in            => Rx_in,
            Tx_out           => Tx_out,
            one_data_transd  => one_data_transd,
            data_bus_out     => data_bus_out,
            one_data_recd    => one_data_recd    
        );
        


end Behavioral;
