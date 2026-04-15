   
	Library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
	Entity Enable_gen Is
	Port ( clock_50 : in std_logic;
			 resetn : in std_logic;
			 velg_enable:in std_logic_vector(2 downto 0);
			 Enable: out std_logic);
	End;
	
	Architecture rtl of Enable_gen is
	
	type rom is array (0 to 7 ) of integer range 0 to 50000000;
	Constant RomEN: rom:=(50_000_000,12_500_000,50_0000,50000,5000,500,50,5); 
	Signal teller : integer range 0 to 50000000;
	
	Begin
	-- velg 001 peker på plass 1, der legges 12_500_000 så gjør enable 4 ganger i sekundet
	process(clock_50)
	begin
		if rising_edge(clock_50) then
			if resetn = '0' then
				teller <= 0;
			else	
				teller <= teller +1;
					if teller = romEN(to_integer(unsigned(velg_enable))) then 
					Enable <= '1';
					teller <= 0;
				else
					Enable <= '0';
				end if;
			end if;
		end if;
	end process;
	End;
	
	