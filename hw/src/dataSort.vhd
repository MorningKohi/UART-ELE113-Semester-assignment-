library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dataSort is
    port(
        clk       : in  std_logic;
        rst_n     : in  std_logic;
        dataValid : in  std_logic;
        dataIn    :     std_logic_vector(7 downto 0);
        sekund    : out std_logic_vector(7 downto 0);
        minutt    : out std_logic_vector(7 downto 0);
        timer     : out std_logic_vector(7 downto 0);
        data_sync : out std_logic
    );
end entity dataSort;

architecture RTL of dataSort is

    --signal count : integer range 0 to 5;
begin

    p_sort : process(clk) is
        variable count : integer range 0 to 5;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                count := 0;
                data_sync<= '0';
            elsif dataValid = '1' then
                if dataIn = "10100101" then --A5h
                    count := 0;
                elsif count >= 4 then
                    count := 0;
                else
                    count := count + 1;
                end if;
                if count = 1 then
                    sekund <= dataIn;
                elsif count = 2 then
                    minutt <= dataIn;
                elsif count = 3 then
                    timer <= dataIn;
                elsif count = 4 then
                    if dataIn ="01011010" then --5Ah 
                        data_sync<= '1';
                    else
                        data_sync<= '0';
                    end if;
                end if;
                    
            end if;
        end if;

    end process p_sort;

--    pDataUT : process(clk)
--    begin
--        if rising_edge(clk) then
--            if dataValid = '1' then
--                if count = 0 then
--                    sekund <= dataIn;
--                elsif count = 1 then
--                    minutt <= dataIn;
--                elsif count = 2 then
--                    timer <= dataIn;
--                end if;
--            end if;
--        end if;
--    end process;

end architecture RTL;
