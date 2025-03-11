----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL  
-- 
-- Create Date: 14.01.2024 20:02:52
-- Design Name: 
-- Module Name: baud_rate_genr - Behavioral
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

  

entity baud_rate_genr is
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
end baud_rate_genr;

architecture Behavioral of baud_rate_genr is

    component clk_wiz_0
        port (   
             clk_out1          : out    std_logic;
             -- Status and control signals
             reset             : in     std_logic;
             locked            : out    std_logic;
             clk_in1           : in     std_logic
        );
    end component;
    
signal locked_rst_reg       : std_logic;
signal clock_58p982M        : std_logic;
signal clock_3p686M         : std_logic;
signal clock_1p843M         : std_logic;
signal clock_614p4K         : std_logic;

signal clk_count1 : std_logic_vector(4 downto 0);   -- to generate 3.686MHz and 1.843MHz clocks from clocking wizard output of 58.982MHz ->   58.982MHz/16 = 3.686MHz  -> 58.982MHz/32 = 1.843MHz       
signal clk_count2 : std_logic_vector(1 downto 0);   -- to generate 614.4KHz by dividing 1.843MHz by 3   -> 1.843MHz/3 = 614.4KHz
signal clk_count3 : std_logic_vector(8 downto 0);   -- to generate 1843200, 921600, 460800, 230400, 14400  baud_clkx8 's from 3.686MHz
signal clk_count4 : std_logic_vector(7 downto 0);   -- to generate 307200, 153600, 76800, 38400, 19200, 9600, 4800, 2400 baud_clkx8 's from 614.4KHz
signal clk_count5 : std_logic_vector(2 downto 0);   -- to divide baud_clkx8 by 8 to generate baud_clk 

signal baud_clkx8_reg       : std_logic;
signal baud_clk_reg         : std_logic;

signal baud_clkx8_1843200   : std_logic;
signal baud_clkx8_921600    : std_logic;
signal baud_clkx8_460800    : std_logic;
signal baud_clkx8_307200    : std_logic;
signal baud_clkx8_230400    : std_logic;
signal baud_clkx8_153600    : std_logic;
signal baud_clkx8_76800     : std_logic;
signal baud_clkx8_38400     : std_logic;
signal baud_clkx8_19200     : std_logic;
signal baud_clkx8_14400     : std_logic;
signal baud_clkx8_9600      : std_logic;
signal baud_clkx8_4800      : std_logic;
signal baud_clkx8_2400      : std_logic;


begin

locked_rst   <= locked_rst_reg;
clock_3p686M <= clk_count1(3);
clock_1p843M <= clk_count1(4);

baud_clkx8 <= baud_clkx8_reg;
baud_clk   <= baud_clk_reg;

    clk_wiz_int1 : clk_wiz_0
        port map (  
            clk_out1 => clock_58p982M,
            -- Status and control signals                
            reset    => reset,
            locked   => locked_rst_reg,                     -- used as the reset for all other modules
            clk_in1  => clock
        );
        
    
    process(clock_58p982M, locked_rst_reg)
        begin
            if(locked_rst_reg = '0') then
                clk_count1 <= (others => '0');
            elsif(rising_edge(clock_58p982M)) then
                clk_count1 <= clk_count1 + '1';
            end if;
    end process;
    
    process(clock_1p843M, locked_rst_reg)
        begin
            if(locked_rst_reg = '0') then
                clk_count2   <= "01";
                clock_614p4K <= '0';
            elsif(rising_edge(clock_1p843M)) then
                if(clk_count2 = "11") then
                    clock_614p4K <= not (clock_614p4K);
                    clk_count2   <= "01";
                elsif(clk_count2 = "01") then
                    clock_614p4K <= not (clock_614p4K);
                    clk_count2   <= clk_count2 + 1;
                else
                    clk_count2 <= clk_count2 + 1;
                end if;
            end if;
    end process;
    
    process(clock_3p686M, locked_rst_reg)
        begin
            if(locked_rst_reg = '0') then
                clk_count3 <= (others => '0');
            elsif(rising_edge(clock_3p686M)) then
                clk_count3 <= clk_count3 + '1';
            end if;
    end process;
    
    process(clock_614p4K, locked_rst_reg)
        begin
            if(locked_rst_reg = '0') then
                clk_count4 <= (others => '0');
            elsif(rising_edge(clock_614p4K)) then
                clk_count4 <= clk_count4 + '1';
            end if;
    end process;
    
    baud_clkx8_1843200 <= clk_count3(0);
    baud_clkx8_921600  <= clk_count3(1);
    baud_clkx8_460800  <= clk_count3(2);
    baud_clkx8_230400  <= clk_count3(3);
    baud_clkx8_14400   <= clk_count3(7);
    
    baud_clkx8_307200  <= clk_count4(0);
    baud_clkx8_153600  <= clk_count4(1);
    baud_clkx8_76800   <= clk_count4(2);
    baud_clkx8_38400   <= clk_count4(3);
    baud_clkx8_19200   <= clk_count4(4);
    baud_clkx8_9600    <= clk_count4(5);
    baud_clkx8_4800    <= clk_count4(6);
    baud_clkx8_2400    <= clk_count4(7); 
    
    process(clock, locked_rst_reg)
        begin
            if(locked_rst_reg = '0') then
            baud_clkx8_reg <= '0';    
            elsif(rising_edge(clock)) then
                   case (baud_rate_select) is                                       -- selecting the baud_clkx8 according to the select input given in the generic section
                   
                        when x"0" =>   baud_clkx8_reg <= baud_clkx8_1843200;
                        when x"1" =>   baud_clkx8_reg <= baud_clkx8_921600;
                        when x"2" =>   baud_clkx8_reg <= baud_clkx8_460800;
                        when x"3" =>   baud_clkx8_reg <= baud_clkx8_307200;
                        when x"4" =>   baud_clkx8_reg <= baud_clkx8_230400;
                        when x"5" =>   baud_clkx8_reg <= baud_clkx8_153600;
                        when x"6" =>   baud_clkx8_reg <= baud_clkx8_76800;
                        when x"7" =>   baud_clkx8_reg <= baud_clkx8_38400;
                        when x"8" =>   baud_clkx8_reg <= baud_clkx8_19200;
                        when x"9" =>   baud_clkx8_reg <= baud_clkx8_14400;
                        when x"A" =>   baud_clkx8_reg <= baud_clkx8_9600;
                        when x"B" =>   baud_clkx8_reg <= baud_clkx8_4800;
                        when x"C" =>   baud_clkx8_reg <= baud_clkx8_2400;
                        
                        when others => baud_clkx8_reg <= '0';

                  end case;    
            end if;
    end process;
    
    process(baud_clkx8_reg, locked_rst_reg)
    begin
        if(locked_rst_reg = '0') then
            baud_clk_reg <= '0';
            clk_count5   <= (others => '0');     
        elsif(rising_edge(baud_clkx8_reg)) then
            if(clk_count5 = "111") then
                clk_count5   <= (others => '0');
                baud_clk_reg <= not(baud_clk_reg);
            elsif(clk_count5 = "011") then
                baud_clk_reg <= not(baud_clk_reg); 
                clk_count5   <= clk_count5 + '1';
            else 
                clk_count5 <= clk_count5 + '1';
            end if;
        end if;
    end process;

end Behavioral;
