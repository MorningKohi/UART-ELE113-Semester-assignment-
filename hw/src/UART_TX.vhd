library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TX is
    port(
        clk : in std_logic; -- systemklokke
        rst_n : in std_logic; -- reset, aktiv låg
        startPuls : in std_logic; --puls som startar sending av 8 bit med data
        baud_rate_divider : in std_logic_vector(15 downto 0); -- Baud-periode i antall (50 MHz) klokkeperiodar 
        dataIn : in std_logic_vector(7 downto 0); -- 8 bit med data som skal overførast i ei melding
        txReady : out std_logic;  -- Når txReady = '1' ventar på ny sendEnable for å starta sending av nye data.
        dataOut : out std_logic -- serielle data , skal koplast mot GPIO-port 
    );
end entity UART_TX;

architecture RTL of UART_TX is
    
    component baud_gen is
    port(
        CLOCK_50 : in std_logic;
        rst : in std_logic;
        start_cnt : in std_logic; -- varer 1 klokkeperioden n�r vi skal begynne � lage baud_en
        baud_rate_divider : in std_logic_vector(15 downto 0);
        sender : in std_logic;
        
        baud_en : out std_logic
    );
end component baud_gen;
    
    type tilstandType is (vent,lastData,startbit,skiftUt,stopBit);
    signal tilstand : tilstandType; 
    
    signal skiftReg : std_logic_vector(7 downto 0); 
    signal baudEn : std_logic;
    
begin
    
    baud_gen_inst : component baud_gen
        port map(
            CLOCK_50      => clk,
            rst           => rst_n,
            start_cnt     => startPuls,
            baud_rate_divider => baud_rate_divider,
            sender        => '1',
            baud_en       => baudEn
        );
    
    p_tilstandsmaskin : process (clk) is
        variable bitCount : integer range 0 to 8;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                tilstand<= vent;
            else
                case tilstand is 
                    when vent =>
                        if startPuls = '1' then
                            tilstand <= lastData;
                        end if;
                        
                    when lastData =>
                        skiftReg <= dataIn;
                        if baudEn = '1' then
                            tilstand <= startbit;
                        end if;
                        
                    when startbit =>
                        bitCount := 0;
                        if baudEn = '1' then
                            tilstand <= skiftUt;
                        end if;    
                        
                    when skiftUt =>
                        if baudEn = '1' then
                            skiftReg <= '0' & skiftReg(7 downto 1);
                            bitCount := bitCount + 1;
                            if bitCount = 8 then
                                tilstand <= stopBit;
                            end if;
                        end if;                            
                    when stopBit =>
                        if baudEn = '1' then
                            tilstand <= vent;
                        end if;
                end case;
            end if;
        end if;
    end process p_tilstandsmaskin;
    
    p_utgang: process(tilstand,skiftReg)
    begin
        case tilstand is 
            when vent =>
                dataOut <= '1';
                txReady <= '1';
            when lastData =>
                dataOut <= '1';
                txReady <= '0';
            when startbit =>
                dataOut <= '0';
                txReady <= '0';
            when skiftUt =>
                dataOut <= skiftReg(0);
                txReady <= '0';
            when stopBit =>
                dataOut <= '1';
                txReady <= '0';
        end case;
    end process;
end architecture RTL;

