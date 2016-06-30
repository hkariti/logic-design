library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity MIPS is
  port(
    rst : in std_logic;
    clk : in std_logic
    );

end MIPS;

-- purpose: put all the components together
architecture str of MIPS is

  component Datapath 
	port(
	   rst : in std_logic;
	   clk : in std_logic);

  end component;

begin  -- bhv
  Mips_Datapath : Datapath
  port map(
	rst    => rst,
	clk    => clk);
end str;

