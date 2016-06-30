
-- 2 to 1 mux with N-bit output
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.std_logic_unsigned.all;
entity Mips_WriteBack is
  port(
  	clk				: in std_logic;
  	rst				: in std_logic;
-- in
	reg_dst_in		: in std_logic_vector(4 downto 0);	
	mem_to_reg_in	: in std_logic;
	mem_data		: in std_logic_vector(31 downto 0);
	alu_result_in	: in std_logic_vector(31 downto 0);
	RegWrite_in		: in std_logic;
-- out
	write_data		: out std_logic_vector(31 downto 0);
	write_reg_addr	: out std_logic_vector(4 downto 0);	
	write_reg		: out std_logic);
end Mips_WriteBack;

architecture bhv of Mips_WriteBack is

signal	reg_dst_lat		: std_logic_vector(4 downto 0);	
signal	mem_to_reg_lat	: std_logic;
signal	regwrite_lat	: std_logic;
signal	mem_data_lat	: std_logic_vector(31 downto 0);
signal	alu_result_lat	: std_logic_vector(31 downto 0);

begin
  process(clk, rst)
	begin
	if(rst = '1') then
	  reg_dst_lat		<= (others => '0');	  
	  mem_to_reg_lat	<= '0';
	  mem_data_lat  	<= (others => '0');
	  alu_result_lat	<= (others => '0');
	  regwrite_lat		<= '0';
	else
	  if(clk'event and clk = '1') then
		reg_dst_lat		<= reg_dst_in;
		mem_to_reg_lat	<= mem_to_reg_in;
		mem_data_lat  	<= mem_data;
		alu_result_lat	<= alu_result_in;
		regwrite_lat	<= RegWrite_in;
	  end if;
	end if;
  end process;

  with mem_to_reg_lat select
	write_data <= mem_data_lat when '1', 
		  alu_result_lat when others;

  write_reg <= regwrite_lat;

  write_reg_addr <= reg_dst_lat;
end bhv;


