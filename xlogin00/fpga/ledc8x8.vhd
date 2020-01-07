-- Autor reseni: Martin Žovinec xzovin00

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
	port ( -- Sem doplnte popis rozhrani obvodu.
		 
		ROW : out std_logic_vector(0 to 7);	-- radek matice
		LED : out std_logic_vector(0 to 7);	-- sloupec matice
		RESET : in std_logic;
		SMCLK : in std_logic
	);
end ledc8x8;

architecture main of ledc8x8 is
	-- Sem doplnte definice vnitrnich signalu.		-- 
	signal second : std_logic_vector(0 to 22); -- pocitani sekund
	signal active : std_logic := '1';			-- 
	signal s : std_logic := '0';
	signal count : std_logic_vector(7 downto 0) := (others => '1');
	signal rows_active : std_logic_vector(0 to 7):= "10000000";
	signal leds_active : std_logic_vector(0 to 7):= "11111111";
begin

    -- Sem doplnte popis obvodu. Doporuceni: pouzivejte zakladni obvodove prvky
    -- (multiplexory, registry, dekodery,...), jejich funkce popisujte pomoci
    -- procesu VHDL a propojeni techto prvku, tj. komunikaci mezi procesy,
    -- realizujte pomoci vnitrnich signalu deklarovanych vyse.

    -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL KODU OBVODOVYCH PRVKU,
    -- JEZ JSOU PROBIRANY ZEJMENA NA UVODNICH CVICENI INP A SHRNUTY NA WEBU:
    -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html.

    -- Nezapomente take doplnit mapovani signalu rozhrani na piny FPGA
    -- v souboru ledc8x8.ucf.

--generator signalu
	process(RESET, SMCLK)
	begin
		if (RESET = '1') then
			count <= (others => '0');
		elsif (SMCLK'event) and (SMCLK = '1') then
			count <= count + 1;
		end if;
	end process;

	s <= '1' when count = "11111111" else '0';

-- vypinac
	process(second)
	begin
		if (second <= "01110000011111111111111") then -- pokud je cas nizsi nez pul sekundy
			active <= '1';
		elsif (second < "11100000111111111111111") then -- pokud je cas nizsi nez sekunda
			active <= '0';
		else 
			active <= '1';
		end if;
	end process;

--pocitani sekund
process(RESET, second)
begin
	if ( RESET = '1') then
		second <= (others => '0');
	elsif (second /= "11100000111111111111111") then	--na sekunde zastavime pocitani
		if (SMCLK'event) and (SMCLK = '1') then
			second <= second+1;
		end if;
	end if;
end process;

-- aktivni ledky
	process(active, rows_active)
	begin
		if (active = '1') then --pokud maji ledky svitit
			case rows_active is
				when "10000000" => leds_active <= "00100111";
				when "01000000" => leds_active <= "01010111";
				when "00100000" => leds_active <= "01110111";
				when "00010000" => leds_active <= "01110111";
				when "00001000" => leds_active <= "11110000";
				when "00000100" => leds_active <= "11111101";
				when "00000010" => leds_active <= "11111011";
				when "00000001" => leds_active <= "11110000";
				when others => leds_active <= (others => '1');
			end case;
		else
			leds_active <= "11111111";
		end if;
	end process;

	LED <= leds_active;


-- rotacni registr, rows_active 
	process(RESET, SMCLK)
	begin
		if (RESET = '1') then
			rows_active <= "10000000";
		elsif (SMCLK'event) and (SMCLK = '1') then
			if (s = '1') then
				rows_active <= rows_active(7) & rows_active(0 to 6);
			end if;
		end if;
	end process;

	ROW <= rows_active;

end main;

-- ISID: 75579
