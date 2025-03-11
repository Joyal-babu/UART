----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 21.01.2024 16:40:22
-- Design Name: 
-- Module Name: UART_TOP - Behavioral
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

------------------------------------------------------
-- BAUD_RATE_SELECT  |  BAUD_RATE X 8  |  BAUD_RATE  |
------------------------------------------------------
--     0             |    1843200      |   230400    |
--     1             |    921600       |   115200    |
--     2             |    460800       |   57600     |
--     3             |    307200       |   38400     |
--     4             |    230400       |   28800     |
--     5             |    153600       |   19200     |
--     6             |    76800        |   9600      |
--     7             |    38400        |   4800      |
--     8             |    19200        |   2400      |
--     9             |    14400        |   1800      |
--     A             |    9600         |   1200      |
--     B             |    4800         |   600       |
--     C             |    2400         |   300       |
------------------------------------------------------



entity UART_TOP is
    generic ( 
            baud_rate_select : std_logic_vector(3 downto 0) := x"1";
            data_bus_width   : natural := 8
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
end UART_TOP;

architecture Behavioral of UART_TOP is

        component baud_rate_genr is
            generic ( 
                baud_rate_select : std_logic_vector(3 downto 0) 
            );
            
            Port ( 
                clock      : in  STD_LOGIC;
                reset      : in  STD_LOGIC;        
                locked_rst : out STD_LOGIC;
                baud_clkx8 : out STD_LOGIC;
                baud_clk   : out STD_LOGIC
            );
        end component;
        
        
        component uart_transmitter is
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
        end component;
        
        
        component uart_receiver is
            generic (
                data_bus_width : natural                                            -- define the data width here   8, 16, 32 ....
            );
            Port ( clock         : in  STD_LOGIC;
                   reset         : in  STD_LOGIC;
                   baud_clkx8    : in  STD_LOGIC;
                   Rx_in         : in  STD_LOGIC;
                   data_bus_rx   : out STD_LOGIC_VECTOR((data_bus_width-1) downto 0);
                   one_data_recd : out STD_LOGIC
            );
        end component;

signal locked_rst : std_logic;
signal baud_clkx8 : std_logic;
signal baud_clk   : std_logic;
signal Tx_out_loopback  : std_logic;
signal Tx_out_reg : std_logic;

begin

Tx_out <= Tx_out_reg;

    baud_rate_genr_inst1 : baud_rate_genr
        generic map (
            baud_rate_select => baud_rate_select
        )
        port map (
            clock      => clock,
            reset      => reset,
            locked_rst => locked_rst,
            baud_clkx8 => baud_clkx8,
            baud_clk   => baud_clk          
        );


    uart_transmitter_inst1 : uart_transmitter
        generic map (
            data_bus_width => data_bus_width
        )
        port map (
            clock           => clock,
            reset           => locked_rst,
            baud_clk        => baud_clk,
            data_bus_tx     => data_bus_in,
            start_trig      => start_trig,
            Tx_out          => Tx_out_reg,                         ---Tx_out_loopback,
            one_data_transd => one_data_transd            
        );
        
    uart_receiver_inst1 : uart_receiver
        generic map (
            data_bus_width => data_bus_width
        )
        port map (
            clock         => clock,
            reset         => locked_rst,
            baud_clkx8    => baud_clkx8,
            Rx_in         => Rx_in,                   --Tx_out_loopback,                      --loopback for testing
            data_bus_rx   => data_bus_out,
            one_data_recd => one_data_recd        
        );   
        

end Behavioral;
