----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2024 17:00:23
-- Design Name: 
-- Module Name: uart_test1_tb - Behavioral
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

entity uart_test1_tb is
--  Port ( );
end uart_test1_tb;

architecture Behavioral of uart_test1_tb is

component uart_test1_top is
    Port ( clock    : in  STD_LOGIC;
           reset    : in  STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR(31 DOWNTO 0)
          );
end component;

signal clock, reset : std_logic := '0';
signal data_out : std_logic_vector(31 downto 0) := (others => '0');

begin
   
    clock <= not clock after 5 ns;
    reset <= '1' , '0' after 500 ns;

    DUT : uart_test1_top
    port map(
        clock    => clock,
        reset    => reset,
        data_out => data_out
    );


end Behavioral;
