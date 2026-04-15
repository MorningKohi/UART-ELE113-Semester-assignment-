library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen is
    port(
        CLOCK_50 : in std_logic;
        rst : in std_logic;
        start_cnt : in std_logic; -- varer 1 klokkeperioden n�r vi skal begynne � lage baud_en
        baud_rate_divider : in std_logic_vector(15 downto 0);
        sender : in std_logic;
        
        baud_en : out std_logic
    );
end entity baud_gen;

architecture RTL of baud_gen is
    
--    type tabell is array (0 to 8) of integer range 0 to 1000000;
--    constant baud_tabell : tabell := (1200,2400,4800,9600,19200,38400,576600,115200,1000000);
--    signal  baud_index : integer range 0 to 8 := 8;
    signal baud_periode : integer range 0 to 50000000;
--    signal baud_select_int : integer range 0 to 15;
    
begin
--    baud_select_int <= to_integer(unsigned(baud_rate_sel));
--    baud_index <= baud_select_int when baud_select_int < 9 else 8;
        
--    baud_periode <= 50000000/baud_tabell(baud_index);
baud_periode <= to_integer(unsigned(baud_rate_divider));

    p_Baud_teller: process(CLOCK_50)
        variable baud_teller : integer range 0 to 50000000/1200 := 0;
        
    begin
        if rising_edge(CLOCK_50) then
            if rst = '0' then
                baud_teller := 0;
               
            else
                
                if start_cnt = '1' then                    
                    baud_teller := 0;                    
                elsif baud_teller >= baud_periode-1 then
                    baud_teller := 0;                    
                else
                    baud_teller := baud_teller + 1;
                end if;  -- baud_Teller >= baud_teller
                
                if sender = '1' and baud_teller = 0 then
                    baud_en <= '1';
                elsif sender = '0' and baud_teller = baud_periode/2 then
                    baud_en <= '1';
                else
                    baud_en <= '0';
                end if;
                
            end if; -- rst
        end if; -- CLOCK_50
        end process p_Baud_teller;
                
end architecture RTL;

