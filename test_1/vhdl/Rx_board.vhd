----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 09.04.2024 19:41:04
-- Design Name: 
-- Module Name: Rx_board - Behavioral
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

entity Rx_board is
    Port ( clock     : in STD_LOGIC;
           reset     : in STD_LOGIC;
           UART_Line : in STD_LOGIC;
           data_out  : out STD_LOGIC_VECTOR (31 downto 0));
end Rx_board;

architecture Behavioral of Rx_board is

COMPONENT UART_TOP is
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
END COMPONENT;

COMPONENT uart_data_ram_rx
  PORT (
    clka  : IN STD_LOGIC;
    ena   : IN STD_LOGIC;
    wea   : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    dina  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb  : IN STD_LOGIC;
    enb   : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

signal Tx_out_wire, one_data_transd, one_data_recd, one_data_recd_r : std_logic;
signal data_bus_out : std_logic_vector (15 downto 0);
signal one_data_recd_d, one_data_recd_d1, one_data_recd_d2 : std_logic;
signal write_done, ram1_wr_en, ram1_rd_en : std_logic;
signal write_done_d, write_done_d1, write_done_d2, write_done_r  : std_logic;
signal write_done_cnt : std_logic_vector(3 downto 0);
signal ram1_addra     : std_logic_vector(10 downto 0);
signal ram1_addrb     : std_logic_vector(9 downto 0);
--signal doutb          : std_logic_vector(31 downto 0);


constant baud_rate_select : std_logic_vector(3 downto 0) := x"1";
constant data_bus_width   : natural := 16;

type ram1_wr_state is (st1_ram1_idle, st2_ram1_wr_en, st3_check_flag, st4_check_addra, st5_done_flag);
signal ram1_wr_st : ram1_wr_state;

type ram1_rd_state is (st1_ram1_rd_idle, st2_ram1_addr_inc);
signal ram1_rd_st : ram1_rd_state;

begin

    process(clock, reset)
    begin
        if(reset = '1') then
            one_data_recd_d  <= '0';
            one_data_recd_d1 <= '0';
            one_data_recd_d2 <= '0';
        else
            one_data_recd_d  <= one_data_recd;
            one_data_recd_d1 <= one_data_recd_d;
            one_data_recd_d2 <= one_data_recd_d1;
        end if;
    end process;
    
    one_data_recd_r <= one_data_recd and ( not one_data_recd_d2 );
    
    process(clock, reset)
    begin
        if(reset = '1') then
            ram1_wr_st <= st1_ram1_idle;
            ram1_wr_en <= '0';
            write_done <= '0';
            ram1_addra <= (others => '0');
            write_done_cnt <= (others => '0');
        elsif(rising_edge(clock)) then
            case(ram1_wr_st) is 
                when st1_ram1_idle => 
                    if(one_data_recd_r = '1') then
                        ram1_wr_en <= '1';
                        ram1_addra <= (others => '0');
                        ram1_wr_st <= st3_check_flag;
                    else
                        ram1_wr_st <= st1_ram1_idle;
                        ram1_wr_en <= '0';
                        write_done <= '0';
                        ram1_addra <= (others => '0');
                        write_done_cnt <= (others => '0');
                    end if;
                    
                when st3_check_flag =>
                    if(one_data_recd_r = '1') then
                        ram1_wr_en <= '1';
                        ram1_addra <= ram1_addra + '1';
                        ram1_wr_st <= st4_check_addra;
                    else
                        ram1_wr_en <= '0';
                        ram1_addra <= ram1_addra;
                        ram1_wr_st <= st3_check_flag;
                    end if;
                    
                when st4_check_addra => 
                    if( ram1_addra = "01111111111") then  -- 01100100   01111111111
                        write_done <= '1';
                        ram1_wr_st <= st5_done_flag;
                    else
                        write_done <= '0';
                        ram1_wr_st <= st3_check_flag;
                    end if;
                    
                when st5_done_flag => 
                    if(write_done_cnt = "1111") then
                        write_done     <= '0';
                        write_done_cnt <= (others => '0');
                        ram1_wr_st     <= st1_ram1_idle;
                    else
                        write_done     <= '1';
                        ram1_wr_en     <= '0';
                        write_done_cnt <= write_done_cnt + '1';
                        ram1_wr_st     <= st5_done_flag;
                    end if;
                    
                when others => 
                    ram1_wr_st <= st1_ram1_idle;
            end case;
        end if;
    end process;
    
    process(clock, reset)
    begin
        if(reset = '1') then
            write_done_d  <= '0';
            write_done_d1 <= '0';
            write_done_d2 <= '0';
        else
            write_done_d  <= write_done;
            write_done_d1 <= write_done_d;
            write_done_d2 <= write_done_d1;
        end if;
    end process;
    
    write_done_r <= write_done and ( not write_done_d2);
    
    process(clock, reset)
    begin
        if(reset = '1') then
            ram1_rd_st <= st1_ram1_rd_idle;
            ram1_rd_en <= '0';
            ram1_addrb <= (others => '0'); 
        elsif(rising_edge(clock)) then
            case(ram1_rd_st) is
                when  st1_ram1_rd_idle => 
                    if(write_done_r = '1')then
                        ram1_rd_en <= '1';
                        ram1_rd_st <= st2_ram1_addr_inc;
                    else
                        ram1_rd_en <= '0';
                        ram1_addrb <= (others => '0');
                        ram1_rd_st <= st1_ram1_rd_idle;
                    end if;
                    
                when st2_ram1_addr_inc => 
                    if(ram1_addrb = "1000000000") then
                        ram1_rd_en <= '0';
                        ram1_addrb <= (others => '0');
                        ram1_rd_st <= st1_ram1_rd_idle;
                    else
                        ram1_rd_en <= '1';
                        ram1_addrb <= ram1_addrb + '1';
                        ram1_rd_st <= st2_ram1_addr_inc;
                    end if;
                    
                when others => 
                    ram1_rd_st <= st1_ram1_rd_idle;
                    
            end case;
        end if;
    end process;

   uart_inst1_RX : UART_TOP
        GENERIC MAP (
            baud_rate_select => baud_rate_select,
            data_bus_width   => data_bus_width
        )
        PORT MAP (
            clock           => clock,
            reset           => reset,
            data_bus_in     => (others => '0'),
            start_trig      => '0',
            Rx_in           => UART_Line,
            Tx_out          => Tx_out_wire,
            one_data_transd => one_data_transd,
            data_bus_out    => data_bus_out,
            one_data_recd   => one_data_recd     
        );
        
        
   ram_inst1_RX : uart_data_ram_rx
        PORT MAP (
            clka  => clock,
            ena   => ram1_wr_en,
            wea   => "1",
            addra => ram1_addra,
            dina  => data_bus_out,
            clkb  => clock,
            enb   => ram1_rd_en,
            addrb => ram1_addrb,
            doutb => data_out
  );


end Behavioral;
