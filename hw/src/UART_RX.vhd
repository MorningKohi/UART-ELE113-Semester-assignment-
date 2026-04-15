
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RX is
    port(
        clk         : in  std_logic; -- systemklokke
        rst_n       : in  std_logic; -- reset aktiv låg
        dataInn     : in  std_logic; -- Serielle data inn
        baudRateDivider : in std_logic_vector(15 downto 0); -- Baud-periode i antall (50 MHz) klokkeperiodar
        error       : out std_logic; -- flag som er høg om mottatt data ikkje er gyldig RS-232-data.
        dataValidUt : out std_logic; -- høg når feilfrie data er mottatt og tilgjengeleg i dataUt
        dataUt      : out std_logic_vector(7 downto 0) -- 8 bit mottatt data 
    );
end entity UART_RX;

architecture RTL of UART_RX is

component baud_gen is
    port(
        CLOCK_50 : in std_logic;
        rst : in std_logic;
        start_cnt : in std_logic; -- varer 1 klokkeperioden n�r vi skal begynne � lage baud_en
        baud_rate_divider : in std_logic_vector(15 downto 0); -- Baud-periode i antall (50 MHz) klokkeperiodar
        sender : in std_logic;
        baud_en : out std_logic
    );
end component baud_gen;

    type tilstandType is (restart, vent, startMottak, startBit, skiftInn, stoppBit, lastUt, feil, etter_feil);
    signal tilstand : tilstandType;

    signal dff, dff2, dff3, startBitFunnet : std_logic;
    signal skiftReg                        : std_logic_vector(7 downto 0);
    signal errorBit                        : std_logic;
    signal dataValid                       : std_logic;
    signal baudEn                           : std_logic;
    signal mottakStart                     : std_logic;
    signal tilfeldigVenteTid               :unsigned(3 downto 0);
    signal venteTid                        :unsigned(3 downto 0);
begin

baud_gen_inst : component baud_gen
    port map(
        CLOCK_50      => clk,
        rst           => rst_n,
        start_cnt     => mottakStart,
        baud_rate_divider => baudRateDivider,
        sender        => '0',
        baud_en       => baudEn
    );

    p_detekt_startBit : process(clk) is
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                dff            <= '0';
                startBitFunnet <= '0';
            else
                dff3           <= dataInn;
                dff2           <= dff3;
                startBitFunnet <= '0';
                dff            <= dff2;
                if dff2 = '0' and dff = '1' then
                    --dff2 <= '1';
                    startBitFunnet <= '1';
                end if;
            end if;
        end if;
    end process p_detekt_startBit;

    tilstandsmaskin : process(clk) is
        variable bitTeller : integer range 0 to 8;
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                tilstand <= restart;
                skiftReg <= (others => '0');
                tilfeldigVenteTid <= (others => '0');                
            else
                case tilstand is
                    when restart =>
                        tilstand <= vent;
                        dataValid   <= '0';
                    when vent =>
                        if startBitFunnet = '1' then
                            tilstand <= startMottak;
                        end if;
                        dataValid   <= dataValid;
                    when startMottak =>
                        tilstand <= startBit;
                        dataValid   <= '0';
                    when startBit =>
                        if baudEn = '1' then
                            skiftReg  <= (others => '0');
                            bitTeller := 0;
                            if dataInn = '0' then
                                tilstand <= skiftInn;
                            else
                                tilstand <= feil;
                            end if;
                        end if;
                    when skiftInn =>
                        if baudEn = '1' then
                            skiftReg  <= dataInn & skiftReg(7 downto 1); -- h�greskift, mottar lsb f�rst.
                            bitTeller := bitTeller + 1;
                            if bitTeller = 8 then
                                tilstand <= stoppBit;
                            end if;
                        end if;
                    when stoppBit =>
                        if baudEn = '1' then
                            if dataInn = '1' then
                                tilstand <= lastUt;
                            else
                                tilstand <= feil;
                                
                            end if;
                        end if;
                    when lastUt =>
                        tilstand <= vent;
                        dataValid   <= '1';
                    when feil =>
                        if baudEn = '1' then
                            tilstand <= etter_feil;
                            venteTid <= (others => '0');
                            tilfeldigVenteTid <= tilfeldigVenteTid +1;
                        end if;
                        dataValid   <= '0';
                    when etter_feil =>
                        if baudEn = '1' then
                            venteTid <= venteTid + 1;
                            if venteTid = tilfeldigVenteTid then
                                tilstand <= vent;
                            end if;
                        end if;
                    when others =>
                        tilstand <= restart;
                end case;
            end if;
        end if;
    end process tilstandsmaskin;

    p_utsignal : process(tilstand)
    begin
        case tilstand is
            when restart =>
                error       <= '0';
                mottakStart <= '0';
            when vent =>
                error       <= '0';
                mottakStart <= '0';
            when startMottak =>
                error       <= '0';
                mottakStart <= '1';
            when startBit =>
                error       <= '0';
                mottakStart <= '0';
            when skiftInn =>
                error       <= '0';
                mottakStart <= '0';
            when stoppBit =>
                error       <= '0';
                mottakStart <= '0';
            when lastUt =>
                
                error     <= '0';
                mottakStart <= '0';
            when feil =>
                error       <= '1';
                mottakStart <= '0';
            when etter_feil =>
                mottakStart <= '0';
                error       <= '1';
        end case;
    end process;
    
    dataUt    <= skiftReg;
    dataValidUt <= dataValid;

end architecture RTL;

