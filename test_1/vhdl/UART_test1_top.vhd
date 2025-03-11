----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 09.04.2024 23:43:17
-- Design Name: 
-- Module Name: uart_test1_top - Behavioral
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

entity uart_test1_top is
    Port ( clock    : in STD_LOGIC;
           reset    : in STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (31 downto 0));
end uart_test1_top;

architecture Behavioral of uart_test1_top is

    component Tx_board is
    Port ( clock     : in  STD_LOGIC;
           reset     : in  STD_LOGIC;
           UART_line : out STD_LOGIC
          );
   end component;
   
   component Rx_board is
    Port ( clock     : in STD_LOGIC;
           reset     : in STD_LOGIC;
           UART_Line : in STD_LOGIC;
           data_out  : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    signal UART_line : std_logic;

begin

    Tx_board_inst1 : Tx_board
        PORT MAP(
            clock     => clock,    
            reset     => reset,    
            UART_line => UART_line
        );
        
    Rx_board_inst1 : Rx_board
        PORT MAP(
            clock     =>  clock,   
            reset     =>  reset,
            UART_Line =>  UART_Line,
            data_out  =>  data_out
        );

end Behavioral;
