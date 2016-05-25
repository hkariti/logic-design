-------------------------------------------------------------------------------
-- jr testbench
-------------------------------------------------------------------------------  
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
--library modelsim_lib;
--use modelsim_lib.util.all;

entity tb_mips is
end tb_mips;

architecture tb_mips_arch of tb_mips is


  
  component MIPS
    port(
      rst : in std_logic;
      clk : in std_logic
      );
  end component;

  signal clk : std_logic := '0';
  signal rst : std_logic;

begin

  MIPS_ins : MIPS port map(
    clk => clk,
    rst => rst);

  -- purpose: Reset generator
  RESET : process
  begin  -- process RESET
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait;
  end process RESET;

  clk <= not(clk) after 5 ns;

	


  end tb_mips_arch;

