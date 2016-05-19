library ieee;
use IEEE.std_logic_1164.all;

entity ContComp is
port (CLK : in std_logic; --Clock, active high
      RSTn : in std_logic; --Async. Reset, active 
	  s0, s1, s2, s3, s4, s5: out std_logic_vector(1 downto 0);
	  WeA, WeB, WeC, WeD: out std_logic
  );
end entity;

architecture behavior of ContComp is
	
	signal Cy : integer := 0;

begin
	
	process (CLK, RSTn) begin
		if (RSTn = '0') then
			Cy <= 0;
		elsif (CLK'event and clk = '1') then
			Cy <= (Cy +1) mod 6;	
		end if;
	end process;
	
	process (Cy) begin
		case Cy is
		when 0 => s0 <= "00";
					s1 <= "00";
					s2 <= "00";
					s3 <= "00";
					s4 <= "00";
					s5 <= "00";
					WeA <= '1';
					WeB <= '1';
					WeC <= '1';
					WeD <= '1';
		when 1 => s0 <= "10";
					s1 <= "01";
					s2 <= "00";
					s3 <= "00";
					s4 <= "00";
					s5 <= "01";
					WeA <= '1';
					WeB <= '1';
					WeC <= '0';
					WeD <= '0';
		when 2 => s0 <= "00";
					s1 <= "00";
					s2 <= "10";
					s3 <= "01";
					s4 <= "10";
					s5 <= "11";
					WeA <= '0';
					WeB <= '0';
					WeC <= '1';
					WeD <= '1';
		when 3 => s0 <= "10";
					s1 <= "00";
					s2 <= "01";
					s3 <= "00";
					s4 <= "00";
					s5 <= "10";
					WeA <= '1';
					WeB <= '0';
					WeC <= '1';
					WeD <= '0';
		when 4 => s0 <= "00";
					s1 <= "10";
					s2 <= "00";
					s3 <= "01";
					s4 <= "01";
					s5 <= "11";
					WeA <= '0';
					WeB <= '1';
					WeC <= '0';
					WeD <= '1';
		when 5 => s0 <= "00";
					s1 <= "10";
					s2 <= "01";
					s3 <= "00";
					s4 <= "01";
					s5 <= "10";
					WeA <= '0';
					WeB <= '1';
					WeC <= '1';
					WeD <= '0';
        when others => s1 <= "00";
    end case;
	end process;

	
-- add your code here

end behavior;
