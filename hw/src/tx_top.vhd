library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_top is
    port(
        CLOCK_50 : in std_logic;
        SW : in std_logic_vector(17 downto 0);
        KEY : in std_logic_vector(3 downto 0);
        EX_IO : inout std_logic_vector(6 downto 0);
        LEDR : out std_logic_vector(17 downto 0)
        --HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
    );
end entity tx_top;

architecture Struct of tx_top is
component UART_TX is
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        startPuls : in std_logic;
        baud_rate_divider : in std_logic_vector(15 downto 0);
        dataIn : in std_logic_vector(7 downto 0);
        txReady : out std_logic;
        dataOut : out std_logic
    );
end component UART_TX;

component baudRateSelect is
    port(
        baud_rate_sel : in std_logic_vector(2 downto 0);
        baudRateDivider : out std_logic_vector(15 downto 0)
    );
end component baudRateSelect;


component L4_klokke_LF is
    port(
        CLOCK_50 : in std_logic;
        resetn : in std_logic;
        SW : in std_logic_vector(2 downto 0);
        LEDR : out std_logic_vector(17 downto 0);
        klokkeUt : out std_logic_vector(23 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
    );
end component L4_klokke_LF;

component msg2byte is
    port(
        clk : in std_logic;
        rst_n : in std_logic;
        dataInn : in std_logic_vector(23 downto 0);
        klar : in std_logic;
        start :out std_logic;
        dataUt : out std_logic_vector(7 downto 0)
    );
end component  msg2byte;


signal startSender: std_logic;
signal rst_n : std_logic ; 
signal dataOut : std_logic;
signal dff : std_logic;
signal klokke : std_logic_vector(23 downto 0);
signal TXbyte : std_logic_vector(7 downto 0);
signal txReady : std_logic;
signal baud_rate_divider : std_logic_vector(15 downto 0);

begin
    
--    p_start : process (CLOCK_50) is
--    begin
--        if rising_edge(CLOCK_50) then
--            if rst_n = '0' then
--                dff <= '0';
--                startSender <= '0';
--            else
--                startSender <= '0';
--                dff <= KEY(3);
--                if (KEY(3) = '0') and (dff = '1') then
--                    startSender <= '1';
--                end if;
--                
--            end if;
--        end if;
--    end process p_start;
    
    rst_n <= KEY(0);
        
        L4_klokke_LF_inst : component L4_klokke_LF
            port map(
                CLOCK_50   => CLOCK_50,
                resetn     => rst_n,
                SW         => SW(12 downto 10),
                LEDR       => LEDR,
                klokkeUt   => klokke,
                HEX0       => open,
                HEX1       => open,
                HEX2       => open,
                HEX3       => open,
                HEX4       => open,
                HEX5       => open
            ) ;
       
       msg2byte_inst : component msg2byte
           port map(
               clk     => CLOCK_50,
               rst_n   => rst_n,
               dataInn => klokke,
               klar    => txReady,
               start   => startSender,
               dataUt  => TXbyte
           ) ;
        
    baudRateSelect_inst : component baudRateSelect
        port map(
            baud_rate_sel   => SW(16 downto 14),
            baudRateDivider => baud_rate_divider
        );
    
    sender_inst : component UART_TX
        port map(
            clk       => CLOCK_50,
            rst_n     => rst_n,
            startPuls => startSender,
            baud_rate_divider => baud_rate_divider,
            dataIn   => TXbyte,
            txReady      => txReady,
            dataOut    => dataOut
        ) ;
    
    EX_IO(0) <= dataOut;
    
    
end architecture Struct;
