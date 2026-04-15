library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity msg2byte is
    port(
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        dataInn : in  std_logic_vector(23 downto 0);
        klar    : in  std_logic;
        start   : out std_logic;
        dataUt  : out std_logic_vector(7 downto 0)
    );
end entity msg2byte;

architecture RTL of msg2byte is
    type dataArray is array (0 to 4) of std_logic_vector(7 downto 0);
    signal tabell : dataArray;

    signal vippeA, vippeB, vippeC : std_logic;
    signal nyData                 : std_logic;
    signal count                  : integer range 0 to 5;
begin
    tabell(0) <= "10100101";            -- A5
    tabell(1) <= dataInn(7 downto 0);
    tabell(2) <= dataInn(15 downto 8);
    tabell(3) <= dataInn(23 downto 16);
    tabell(4) <= "01011010";            --5A

    process(clk)
    begin
    if rising_edge(clk) then
        if rst_n = '0' then
            vippeA <= '0';
            vippeB <= '0';
            vippeC <= '0';
            nyData <= '0';
        else
            vippeA <= klar;
            vippeB <= vippeA;
            vippeC <= vippeB;
            if vippeC = '0' and vippeB = '1' then
                nyData <= '1';
            else
                nyData <= '0';
            end if;
        end if;
    end if;
    
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                count <= 0;
                start <= '0';
            else
                start <= '0';
                if nyData = '1' then
                --if klar = '1' then
                    dataUt <= tabell(count);
                    start  <= '1';
                    if count >= 4 then
                        count <= 0;
                    else
                        count <= count + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture RTL;
