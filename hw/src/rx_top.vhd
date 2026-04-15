library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_top is
    port(
        CLOCK_50                                       : in    std_logic;
        SW                                             : in    std_logic_vector(17 downto 0);
        KEY                                            : in    std_logic_vector(3 downto 0);
        EX_IO : inout std_logic_vector(6 downto 0);
        LEDR                                           : out   std_logic_vector(17 downto 0);
        LEDG                                           : out   std_logic_vector(7 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out   std_logic_vector(6 downto 0)
    );
end entity rx_top;

architecture struct of rx_top is
    component UART_RX is
        port(
            clk             : in  std_logic;
            rst_n           : in  std_logic;
            dataInn         : in  std_logic;
            baudRateDivider : in  std_logic_vector(15 downto 0);
            error           : out std_logic;
            dataUt          : out std_logic_vector(7 downto 0);
            dataValidUt     : out std_logic
        );
    end component UART_RX;
    component ROM_7_seg is
        port(
            adresse : in  std_logic_vector(3 downto 0);
            HEX     : out std_logic_vector(0 to 6)
        );
    end component ROM_7_seg;

    component Enable_gen Is
        Port(clock_50    : in  std_logic;
             resetn      : in  std_logic;
             velg_enable : in  std_logic_vector(2 downto 0);
             Enable      : out std_logic);
    End component;

    component dataSort is
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
    end component dataSort;

    component baudRateSelect is
        port(
            baud_rate_sel   : in  std_logic_vector(2 downto 0);
            baudRateDivider : out std_logic_vector(15 downto 0)
        );
    end component baudRateSelect;

    signal resetN                      : std_logic;
    signal dataInn                     : std_logic;
    signal dataValid                   : std_logic;
    signal dataMottatt                 : std_logic_vector(7 downto 0);
    signal halloEn, hallo              : std_logic;
    signal sekundUt, minuttUt, timerUt : std_logic_vector(7 downto 0);
    signal baudRateDivider             : std_logic_vector(15 downto 0);
    signal dataValid_pulse             : std_logic;
    signal dataValid_1T                : std_logic;
    signal error                       : std_logic;


begin
    Enable_gen_inst : component Enable_gen
        port map(
            clock_50    => clock_50,
            resetn      => resetn,
            velg_enable => "001",
            Enable      => halloEn
        ) ;
        
        p_hallo: process(CLOCK_50)
        begin
            if rising_edge(CLOCK_50) then
                if resetn = '0' then
                    hallo <= '0';
                elsif halloEn = '1' then
                    hallo <= not hallo;
                end if;
            end if;
        end process;
        
    LEDG(7) <= hallo;
    
    resetn <= KEY(0); 
    
    dataInn <= EX_IO(6);
    --EX_IO(6) <= 'Z';

    p_data_Valid_pulse : process (CLOCK_50) is
    begin
        if rising_edge(CLOCK_50) then
            if resetn = '0' then
                dataValid_pulse <= '0';
                dataValid_1T <= '0';
            elsif dataValid = '1' and dataValid_1T ='0' then
                dataValid_pulse <= '1';
            else
                dataValid_pulse <= '0';
            end if;
            dataValid_1T <= dataValid;
        end if;
    end process p_data_Valid_pulse;
    
    
    baudRateSelect_inst : component baudRateSelect
        port map(
            baud_rate_sel   => SW(16 downto 14),
            baudRateDivider => baudRateDivider
        );
    
    mottaker_inst : component UART_RX
        port map(
            clk         => CLOCK_50,
            rst_n       => resetn,
            dataInn     => dataInn,
            baudRateDivider  => baudRateDivider,
            error       => error,
            dataUt      => dataMottatt,
            dataValidUt => dataValid
        ) ;
    
    
    LEDG(0) <= dataValid;
    LEDG(1) <= error;

    --LEDG(5 downto 0) <= sekundUt(5 downto 0);
    --LEDR(5 downto 0) <= minuttUt(5 downto 0);
    --LEDR(10 downto 6) <= timerUt(4 downto 0);
    
    dataSort_inst : component dataSort
        port map(
            clk       => CLOCK_50,
            rst_n     => resetN,
            dataValid => dataValid_pulse,
            dataIn    => dataMottatt,
            sekund    => sekundUt,
            minutt    => minuttUt,
            timer     => timerUt,
            data_sync => LEDG(2)
        ) ;
    
    
 ROM_7_seg_inst0 : component ROM_7_seg
     port map(
         adresse => sekundUt(3 downto 0),
         HEX     => HEX0
     ) ;
 ROM_7_seg_inst1 : component ROM_7_seg
     port map(
         adresse => sekundUt(7 downto 4),
         HEX     => HEX1
     ) ;
ROM_7_seg_inst2 : component ROM_7_seg
     port map(
         adresse => minuttUt(3 downto 0),
         HEX     => HEX2
     ) ;
 ROM_7_seg_inst3 : component ROM_7_seg
     port map(
         adresse => minuttUt(7 downto 4),
         HEX     => HEX3
     ) ;
ROM_7_seg_inst4 : component ROM_7_seg
     port map(
         adresse => timerUt(3 downto 0),
         HEX     => HEX4
     ) ;
 ROM_7_seg_inst5 : component ROM_7_seg
     port map(
         adresse => timerUt(7 downto 4),
         HEX     => HEX5
     ) ;
     
     HEX6 <= "1111111";
     HEX7 <= "1111111";

end architecture struct;
