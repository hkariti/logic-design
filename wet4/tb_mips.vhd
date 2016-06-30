
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
library modelsim_lib;
use modelsim_lib.util.all;

entity tb_mips is
end tb_mips;

architecture tb_mips_arch of tb_mips is
  type Reg32Array is array (0 to 31) of std_logic_vector (31 downto 0);
  signal registers : Reg32Array;
 
  signal check : std_logic := '1';
  signal old_commands_err : std_logic := '0'; 
  
  
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

	
  --test process:
  process
    
    begin
      init_signal_spy("/tb_mips/mips_ins/mips_datapath/mips_decode_ins/register_file_ins/registers", "/registers"); 
      wait for 1000 ns;

	  
-- check old commands
      if( registers(8) /= x"00000002" ) then 
        old_commands_err <= '1';         
      end if;

      if( registers(9) /= x"00000001" ) then 
        old_commands_err <= '1';         
      end if;

      if( registers(10) /= x"00000000" ) then 
		old_commands_err <= '1';         
      end if;

      if( registers(11) /= x"00000003" ) then 
        old_commands_err <= '1';         
      end if;

      if( registers(12) /= x"00000002" ) then 
        old_commands_err <= '1';         
      end if;
	  
  
	  
	  
	  

	
	  wait for 50ns;
	  if (check = '1') then
		  --pass/fail
		  assert false report "Start Test..." severity NOTE;                  
		  if(old_commands_err = '1') then
			assert false report "Old commands test fail" severity ERROR;
		  else
			assert false report "Old commands test pass" severity NOTE;
		  end if;			
			
		 


		  
		  check <= '0';
	  end if;
    end process;


  end tb_mips_arch;

