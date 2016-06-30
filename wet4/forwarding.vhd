-- forwarding unit
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.std_logic_unsigned.all;
entity Mips_Forwarding is
  port(
  -- from execute
  	forw1_reg		: in std_logic_vector(4 downto 0);
  	forw2_reg		: in std_logic_vector(4 downto 0);
  	exec_reg1_data	: in std_logic_vector(31 downto 0);
  	exec_reg2_data	: in std_logic_vector(31 downto 0);

  -- from memory stage
  	mem_dst_reg		: in std_logic_vector(4 downto 0);
  	mem_write_reg   : in std_logic;
	mem_alu_result	: in std_logic_vector(31 downto 0);

  -- from write back stage
  	wb_dst_reg		: in std_logic_vector(4 downto 0);
  	wb_write_reg   	: in std_logic;
	wb_data			: in std_logic_vector(31 downto 0);

-- out
	forw_data1	    : out std_logic_vector(31 downto 0);
	forw_data2	    : out std_logic_vector(31 downto 0));
end Mips_Forwarding;

architecture bhv of Mips_Forwarding is
signal reg1_zero : std_logic;  
signal reg2_zero : std_logic;
signal reg1_in_mem_stage : std_logic;
signal reg2_in_mem_stage : std_logic;
signal reg1_in_wb_stage : std_logic;
signal reg2_in_wb_stage : std_logic;
signal reg1_src_sel : std_logic_vector(2 downto 0);
signal reg2_src_sel : std_logic_vector(2 downto 0);

begin
  reg1_zero <= '1' when (forw1_reg = "00000") else '0';
  reg2_zero <= '1' when (forw2_reg = "00000") else '0';

  reg1_in_mem_stage <= '1' when (mem_write_reg = '1' and mem_dst_reg =
					   forw1_reg) else '0';

  reg2_in_mem_stage <= '1' when (mem_write_reg = '1' and mem_dst_reg =
					   forw2_reg) else '0';

  reg1_in_wb_stage <= '1' when (wb_write_reg = '1' and wb_dst_reg =
					   forw1_reg) else '0';

  reg2_in_wb_stage <= '1' when (wb_write_reg = '1' and wb_dst_reg =
					   forw2_reg) else '0';
  reg1_src_sel <= reg1_zero & reg1_in_mem_stage & reg1_in_wb_stage;
  reg2_src_sel <= reg2_zero & reg2_in_mem_stage & reg2_in_wb_stage;

  with reg1_src_sel select
	forw_data1 <= exec_reg1_data when "100", 
				  exec_reg1_data when "110", 
			      exec_reg1_data when "101", 
	              exec_reg1_data when "111", 
	              exec_reg1_data when "000", 
	 			  mem_alu_result when "010", 
	 			  mem_alu_result when "011",
				  wb_data        when "001",
				  (others => 'Z') when others;

  with reg2_src_sel select
	forw_data2 <= exec_reg2_data when "100", 
				  exec_reg2_data when "110", 
			      exec_reg2_data when "101", 
	              exec_reg2_data when "111", 
	              exec_reg2_data when "000", 
	 			  mem_alu_result when "010", 
	 			  mem_alu_result when "011",
				  wb_data        when "001",
				  (others => 'Z') when others;

end bhv;


