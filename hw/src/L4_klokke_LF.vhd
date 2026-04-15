library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity L4_klokke_LF is
    port(
        CLOCK_50 : in std_logic;
        resetn : in std_logic;
        SW : in std_logic_vector(2 downto 0);
        LEDR : out std_logic_vector(17 downto 0);
        klokkeUt : out std_logic_vector(23 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
    );
end entity L4_klokke_LF;

architecture RTL of L4_klokke_LF is
        component Enable_gen Is
    Port ( clock_50 : in std_logic;
             resetn : in std_logic;
             velg_enable:in std_logic_vector(2 downto 0);
             Enable: out std_logic);
    End component Enable_gen;
    
    component bin2bcd is
    port(
        bin_in  : in  std_logic_vector(6 downto 0);
        bcd_out : out std_logic_vector(7 downto 0)
    );
end component bin2bcd;
    
    component ROM_7_seg is
    port(
        adresse : in std_logic_vector(3 downto 0);
        HEX     : out std_logic_vector(0 to 6)
    );
end component ROM_7_seg;
    
    
    signal hallo: std_logic;
    signal halloEnable: std_logic;
    signal clk_50 : std_logic;
    signal sekunder : integer range 0 to 60;
    signal sekund_std : std_logic_vector(6 downto 0);
    signal minutter : integer range 0 to 60;
    signal minutt_std : std_logic_vector(6 downto 0);
    signal timer : integer range 0 to 24;
    signal timer_std : std_logic_vector(6 downto 0);
    
    signal velg_enable : std_logic_vector(2 downto 0);
    signal sekund_enable : std_logic; 
    
    signal sekund_bcd : std_logic_vector(7 downto 0);
    signal minutt_bcd : std_logic_vector(7 downto 0);
    signal timer_bcd  : std_logic_vector(7 downto 0);
    
    
    
begin
    
    -- koble porter med interne signal
    clk_50 <= CLOCK_50;
    LEDR(17) <= hallo;
    velg_enable <= SW(2 downto 0);
    
    LEDR(5 downto 0) <= sekund_std(5 downto 0);
    LEDR(11 downto 6) <= minutt_std(5 downto 0);
    LEDR(16 downto 12) <= timer_std(4 downto 0);
    
    
    Enable_gen_Hallo : component Enable_gen
        port map(
            clock_50    => clk_50,
            resetn      => resetn,
            velg_enable => "001", -- "VelgEnable = 001 gir ein puls kvar 0.25 sekund
            Enable      => halloEnable
        ) ;
    
    p_hallo : process (CLOCK_50) is
    begin
        if rising_edge(CLOCK_50) then
            if resetn = '0' then
                hallo <= '0';
            else
                if halloEnable = '1' then
                    hallo <= not hallo;
                end if;                
            end if;
        end if;
    end process p_hallo;
    
    Enable_gen_klokke : component Enable_gen
        port map(
            clock_50    => clk_50,
            resetn      => resetn,
            velg_enable => velg_enable,
            Enable      => sekund_enable
        ) ;
    
    p_klokke : process (clk_50) is
    begin
        if rising_edge(clk_50) then
            if resetn = '0' then
                sekunder <= 0;
                minutter <= 0;
                timer <= 0;
            else
                if sekund_enable = '1' then
                    if sekunder >= 59 then
                        sekunder <= 0;
                        if minutter >= 59 then
                            minutter <= 0;
                            if timer >= 23 then
                                timer <= 0;
                            else
                                timer <= timer +1;
                            end if;--timer >= 23
                        else
                            minutter <= minutter +1;
                        end if; -- minutter >= 59
                    else
                        sekunder <= sekunder + 1;
                    end if; -- sekunder >= 59
                end if; --sekund_enable = '1'
            end if; -- resetn = '0'
        end if; --rising_edge(clk_50)
    end process p_klokke;
    
    sekund_std <= std_logic_vector(to_unsigned(sekunder,7));
    minutt_std <= std_logic_vector(to_unsigned(minutter,7));
    timer_std <= std_logic_vector(to_unsigned(timer,7));
    
    klokkeUt <= timer_bcd & minutt_bcd & sekund_bcd;
    
    -- konverter bin�rtal til bcd:
    
    bin2bcd_sekund : component bin2bcd
        port map(
            bin_in  => sekund_std,
            bcd_out => sekund_bcd
        ) ;
    bin2bcd_minutt : component bin2bcd
        port map(
            bin_in  => minutt_std,
            bcd_out => minutt_bcd
        ) ;
    bin2bcd_timer : component bin2bcd
        port map(
            bin_in  => timer_std,
            bcd_out => timer_bcd
        ) ;
    
    -- Vis klokke p� 7-segment-display
    ROM_7_seg_sekund_lsb : component ROM_7_seg
        port map(
            adresse => sekund_bcd(3 downto 0),
            HEX     => HEX0
        ) ;
        
   ROM_7_seg_sekund_msb : component ROM_7_seg
        port map(
            adresse => sekund_bcd(7 downto 4),
            HEX     => HEX1
        ) ;
   ROM_7_seg_minutt_lsb : component ROM_7_seg
        port map(
            adresse => minutt_bcd(3 downto 0),
            HEX     => HEX2
        ) ;
   ROM_7_seg_minutt_msb : component ROM_7_seg
        port map(
            adresse => minutt_bcd(7 downto 4),
            HEX     => HEX3
        ) ;
       ROM_7_seg_time_lsb : component ROM_7_seg
        port map(
            adresse => timer_bcd(3 downto 0),
            HEX     => HEX4
        ) ;
       ROM_7_seg_time_msb : component ROM_7_seg
        port map(
            adresse => timer_bcd(7 downto 4),
            HEX     => HEX5
        ) ;
    
end architecture RTL;
