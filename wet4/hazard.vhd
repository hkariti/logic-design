-- hazard handling
-- bubble on load : dont load new PC and insert an empty instruction
-- flush of instruction register on jump or branch
-- flush of exec register on branch

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.std_logic_unsigned.all;
entity Mips_Hazard is
  port(
-- in
	clk				: in std_logic;
  	rst				: in std_logic;
  	
  	opcode			: in std_logic_vector(5 downto 0);
  	branch			: in std_logic;
	execute_lw		: in std_logic;
	lw_reg_dst		: in std_logic_vector(4 downto 0);
	reg1			: in std_logic_vector(4 downto 0);
	reg1_valid		: in std_logic;
	reg2			: in std_logic_vector(4 downto 0);
	reg2_valid		: in std_logic;
-- out
  	bubble			: out std_logic;
  	decode_flush	: out std_logic;
	load_pc			: out std_logic;
  	empty_instr		: out std_logic);
end Mips_Hazard;

architecture bhv of Mips_Hazard is
signal 	jump			: std_logic;
signal 	lw_hazard		: std_logic;
begin
	lw_hazard <= '1' when ((execute_lw = '1') and (((reg1_valid = '1') and (reg1 = lw_reg_dst)) or
		((reg2_valid = '1') and (reg2 = lw_reg_dst)))) else '0';
	jump			<= '1' when (opcode(5 downto 0) = "000010") else '0';
	empty_instr <= '1' when ((rst = '1') or 
  		jump = '1' or branch = '1') else '0';

	decode_flush <= '1' when (branch = '1' or lw_hazard = '1') else '0';
	bubble <= lw_hazard;
	load_pc <= '0' when ((rst = '1' or lw_hazard = '1')) else '1';
end bhv;


