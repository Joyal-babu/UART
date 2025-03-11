----------------------------------------------------------------------------------
-- Company: 
-- Engineer: JOYAL
-- 
-- Create Date: 09.03.2024 14:37:31
-- Design Name: 
-- Module Name: uart_test1 - Behavioral
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

entity Tx_board is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           UART_line : out STD_LOGIC
          );
end Tx_board;

architecture Behavioral of Tx_board is

COMPONENT uart_data_rom
  PORT (
    clka  : IN  STD_LOGIC;
    ena   : IN  STD_LOGIC;
    addra : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT uart_data_ram
  PORT (
    clka  : IN STD_LOGIC;
    ena   : IN STD_LOGIC;
    wea   : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb  : IN STD_LOGIC;
    enb   : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
  );
END COMPONENT;

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


signal rom_addra, ram1_addra : std_logic_vector(9 downto 0);
signal ram1_addrb            : std_logic_vector(10 downto 0);
signal start_ram1_wr , uart_start_trig, uart_start_trig_r : std_logic;
signal uart_start_trig_d1 , uart_start_trig_d2            : std_logic;
signal rom_rd_en, ram1_wr_en, ram1_rd_en   : std_logic;
signal one_data_transd_fall, tx_start_trig : std_logic;
signal wait_count          : std_logic_vector(19 downto 0);
signal dout_rom_reg        : std_logic_vector(31 downto 0);
signal doutb_ram1          : std_logic_vector(15 downto 0);
signal uart_start_trig_cnt : std_logic_vector(2 downto 0);


signal one_data_transd, one_data_recd : std_logic;
signal tx_start_trig_d, tx_start_trig_d1, tx_start_trig_d2, tx_start_trig_d3, tx_start_trig_d4 : std_logic;
signal one_data_transd_d1, one_data_transd_d : std_logic;         
signal data_bus_out : std_logic_vector (15 downto 0);
signal Tx_out_wire  : std_logic;

constant wait_1msec    : std_logic_vector(19 downto 0) := x"186A0";
constant rom_addra_lim : std_logic_vector(9 downto 0)  := "1000000000";

constant baud_rate_select : std_logic_vector(3 downto 0) := x"1";
constant data_bus_width   : natural := 16;



    type rom_rd_state is (st1_idle, st2_rd_enble, st3_addra_inc, st4_addra_check, st5_stop);
    signal rom_rd_st : rom_rd_state;
    
    type ram1_wr_state is (st1_idle_ram1, st2_addra_inc_ram1, st3_uart_start_trig );
    signal ram1_wr_st : ram1_wr_state;

    type ram1_rd_state is (st1_idle_ram1, st2_ram1_rd_en, st3_ram1_rd_delay1, st4_check_flag, st5_check_addrb );
    signal ram1_rd_st : ram1_rd_state;
    
begin

    UART_line <= Tx_out_wire;
    
    process(clock, reset)
    begin
        if(reset = '1') then
            rom_rd_st    <= st1_idle;
            wait_count   <= (others => '0');
            start_ram1_wr <= '0';
            rom_rd_en    <= '0';
            rom_addra    <= (others => '0');
        elsif(rising_edge(clock)) then
            case(rom_rd_st) is
                when st1_idle => 
                    if(wait_count = wait_1msec) then
                        rom_rd_st  <= st2_rd_enble;
                        wait_count <= (others => '0');
                    else 
                        wait_count <= wait_count + '1';
                        rom_rd_en  <= '0';
                        rom_rd_st  <= st1_idle;
                        rom_addra  <= (others => '0');
                        start_ram1_wr <= '0';
                    end if;
                    
                when st2_rd_enble => 
                    rom_rd_en  <= '1';
                    rom_rd_st  <= st3_addra_inc;
                    
                when st3_addra_inc => 
                    rom_addra    <= rom_addra + '1';
                    start_ram1_wr <= '1';
                    rom_rd_st    <= st4_addra_check;
                    
                when st4_addra_check => 
                    if(rom_addra = rom_addra_lim) then
                        rom_addra  <= (others => '0');
                        rom_rd_en  <= '0';
                        rom_rd_st  <= st5_stop;
                    else
                        rom_addra    <= rom_addra + '1';
                        start_ram1_wr <= '0';
                        rom_rd_st    <= st4_addra_check;
                    end if;
                    
                when st5_stop => 
                    rom_rd_st  <= st5_stop;                            -- read only once after reset, to read again reset has to be given
                                                                       -- stays in the stop state till next reset
                when others => 
                    rom_rd_st <= st1_idle;
            end case;
        
        end if;       
    end process;
      
    
    process(clock, reset)
    begin
        if(reset = '1') then
            ram1_wr_st <= st1_idle_ram1;
            ram1_wr_en <= '0';
            ram1_addra <= (others => '0');
            uart_start_trig  <= '0';
            uart_start_trig_cnt <= (others => '0');
        elsif(rising_edge(clock)) then
            case(ram1_wr_st) is 
                when st1_idle_ram1 => 
                    if(start_ram1_wr = '1') then 
                        ram1_wr_en  <= '1';
                        ram1_wr_st <= st2_addra_inc_ram1;
                    else
                        ram1_wr_en  <= '0';
                        ram1_addra  <= (others => '0');
                        ram1_wr_st <= st1_idle_ram1;
                        uart_start_trig  <= '0';
                        uart_start_trig_cnt <= (others => '0');
                    end if;
                    
                when st2_addra_inc_ram1 => 
                    if(rom_rd_en = '0') then
                        ram1_wr_en  <= '0';
                        uart_start_trig <= '1';
                        ram1_addra  <= (others => '0');
                        ram1_wr_st <= st3_uart_start_trig;
                    else
                        ram1_wr_en  <= '1';
                        ram1_addra  <= ram1_addra + '1';
                        ram1_wr_st <= st2_addra_inc_ram1;
                    end if;
                    
                when st3_uart_start_trig => 
                    if(uart_start_trig_cnt = "111") then
                        uart_start_trig     <= '0';
                        uart_start_trig_cnt <= (others => '0');
                        ram1_wr_st          <= st1_idle_ram1;
                    else
                        uart_start_trig <= '1';
                        uart_start_trig_cnt <= uart_start_trig_cnt  + '1';
                        ram1_wr_st          <= st3_uart_start_trig;
                    end if;  
                    
                 when others => 
                    ram1_wr_st <= st1_idle_ram1;
                
            end case;
        end if;
    end process;
    
    process(clock, reset)
    begin
        if(reset = '1') then
            uart_start_trig_d1 <= '0';
            uart_start_trig_d2 <= '0';
            one_data_transd_d  <= '0';
            one_data_transd_d1 <= '0';
        else
           uart_start_trig_d1 <= uart_start_trig; 
           uart_start_trig_d2 <= uart_start_trig_d1;
           one_data_transd_d  <= one_data_transd; 
           one_data_transd_d1 <= one_data_transd_d;
        end if;
    end process;
    
    
    
    process(clock, reset)
    begin
        if(reset = '1') then
            tx_start_trig_d  <= '0';
            tx_start_trig_d1 <= '0';
            tx_start_trig_d2 <= '0';
            tx_start_trig_d3 <= '0';
            tx_start_trig_d4 <= '0';
        else
           tx_start_trig_d   <= tx_start_trig; 
           tx_start_trig_d1  <= tx_start_trig_d;
           tx_start_trig_d2  <= tx_start_trig_d1;
           tx_start_trig_d3  <= tx_start_trig_d2;
           tx_start_trig_d4  <= tx_start_trig_d3; 
        end if;
    end process;

    uart_start_trig_r    <= uart_start_trig_d1 and (not uart_start_trig_d2);
    one_data_transd_fall <= one_data_transd_d1 and (not one_data_transd_d);
    
    process(clock, reset)
    begin
        if(reset = '1') then
           ram1_rd_st      <= st1_idle_ram1;
           ram1_rd_en      <= '0';
           ram1_addrb      <= (others => '0');
           tx_start_trig <= '0';
        elsif(rising_edge(clock)) then
            case(ram1_rd_st) is 
                when st1_idle_ram1 => 
                    if(uart_start_trig_r = '1') then
                        ram1_rd_st      <= st2_ram1_rd_en;
                    else
                        ram1_rd_st      <= st1_idle_ram1;
                        ram1_rd_en      <= '0';
                        ram1_addrb      <= (others => '0');
                        tx_start_trig   <= '0';
                    end if;
                    
                when st2_ram1_rd_en => 
                    ram1_rd_en <= '1';
                    ram1_rd_st <= st3_ram1_rd_delay1;
                    
                when st3_ram1_rd_delay1 => 
                    ram1_rd_st <= st4_check_flag;   
                    
                when st4_check_flag => 
                    if(one_data_transd_fall = '1') then
                        ram1_addrb <= ram1_addrb + '1';
                        ram1_rd_en <= '0';
                        tx_start_trig <= '0';
                        ram1_rd_st    <= st5_check_addrb;
                    else
                        ram1_addrb    <= ram1_addrb;
                        ram1_rd_en    <= '1';
                        tx_start_trig <= '1';
                        ram1_rd_st    <= st4_check_flag;
                    end if;
                    
                when st5_check_addrb => 
                    if(ram1_addrb = "10000000000") then
                        ram1_rd_st <= st1_idle_ram1;
                    else
                        ram1_rd_st <= st4_check_flag;
                    end if;
                            
                when others => 
                    ram1_rd_st      <= st1_idle_ram1;
                    
            end case;
            
        end if;     
    end process;
    

    rom_inst1_Tx : uart_data_rom
        PORT MAP (
            clka  => clock,
            ena   => rom_rd_en,   --'1',
            addra => rom_addra,
            douta => dout_rom_reg
      );
      
      
    ram_inst1_Tx : uart_data_ram
        PORT MAP (
            clka  => clock,
            ena   => ram1_wr_en,
            wea   => "1",
            addra => ram1_addra,             
            dina  => dout_rom_reg,
            clkb  => clock,
            enb   => ram1_rd_en,
            addrb => ram1_addrb,
            doutb => doutb_ram1
   );
   
   uart_inst1_TX : UART_TOP
        GENERIC MAP (
            baud_rate_select => baud_rate_select,
            data_bus_width   => data_bus_width
        )
        PORT MAP (
            clock           => clock,
            reset           => reset,
            data_bus_in     => doutb_ram1,
            start_trig      => tx_start_trig_d4,
            Rx_in           => '0',
            Tx_out          => Tx_out_wire,
            one_data_transd => one_data_transd,
            data_bus_out    => data_bus_out,
            one_data_recd   => one_data_recd     
        );

end Behavioral;


