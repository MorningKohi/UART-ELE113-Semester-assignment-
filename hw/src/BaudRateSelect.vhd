library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudRateSelect is
    port(
        baud_rate_sel : in std_logic_vector(2 downto 0);
        baudRateDivider : out std_logic_vector(15 downto 0)
    );
end entity baudRateSelect;

architecture RTL of baudRateSelect is
      type tabell is array (0 to 7) of integer range 0 to 1000000;
    constant baud_tabell : tabell := (2400,4800,9600,19200,38400,576600,115200,1000000);
    signal baud_index : integer range 0 to 7 := 7;
    signal baud_periode : integer range 0 to 50000000/2400;
    
begin
      baud_index <= to_integer(unsigned(baud_rate_sel));
        
      baud_periode <= 50000000/baud_tabell(baud_index);
    
      baudRateDivider <= std_logic_vector(to_unsigned(baud_periode,16));
end architecture RTL;
