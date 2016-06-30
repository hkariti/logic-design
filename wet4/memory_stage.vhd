
-- 2 to 1 mux with N-bit output
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.std_logic_unsigned.all;
entity Mips_Memory_Stage is
  port(
  	clk				: in std_logic;
  	rst				: in std_logic;
  
-- in
    -- from execute unit
	RegDst_in		: in std_logic_vector(4 downto 0);	
	MemRead_in		: in std_logic;
	MemWrite_in		: in std_logic;
	MemtoReg_in		: in std_logic;
	ALU_result_in	: in std_logic_vector(31 downto 0);
  	ReadData2_in	: in std_logic_vector(31 downto 0);
	RegWrite_in		: in std_logic;

-- out
	RegDst_out		: out std_logic_vector(4 downto 0);	
	MemtoReg_out	: out std_logic;
	MemData			: out std_logic_vector(31 downto 0);
	RegWrite_out	: out std_logic;
	ALU_result_out	: out std_logic_vector(31 downto 0));
end Mips_Memory_Stage;

architecture bhv of Mips_Memory_Stage is

  component Memory
    port(
      rst   : in  std_logic;
      clk   : in  std_logic;
      rd    : in  std_logic;
      wr    : in  std_logic;
      addr  : in  std_logic_vector (31 downto 0);
      d_in  : in  std_logic_vector (31 downto 0);
      d_out : out std_logic_vector (31 downto 0)
      );
  end component;

signal ReadData2_lat  		: std_logic_vector(31 downto 0);
signal ALU_result_lat  		: std_logic_vector(31 downto 0);
signal MemRead_lat			: std_logic;
signal MemWrite_lat			: std_logic;
signal MemtoReg_lat			: std_logic;
signal RegDst_lat			: std_logic_vector(4 downto 0);
signal RegWrite_lat			: std_logic;

begin

  process(clk, rst)
  begin
	if(rst = '1') then
		ReadData2_lat  		<= (others => '0'); 
		MemRead_lat			<= '0'; 
		MemWrite_lat		<= '0'; 
		MemtoReg_lat		<= '0'; 
		RegDst_lat			<= (others => '0'); 
		RegWrite_lat		<= '0'; 
		ALU_result_lat			<= (others => '0'); 
	else
	  if(clk'event and clk = '1') then
		ReadData2_lat  		<= ReadData2_in;
		MemRead_lat			<= MemRead_in;
		MemWrite_lat		<= MemWrite_in;
		MemtoReg_lat		<= MemtoReg_in;
		RegDst_lat			<= RegDst_in;
		RegWrite_lat		<= RegWrite_in;
		ALU_result_lat		<= ALU_result_in;
	  end if;
	end if;
  end process;

  MEM : Memory
    port map (
      rst   => rst,
      clk   => clk,
      rd    => MemRead_lat,
      wr    => MemWrite_lat,
      addr  => ALU_result_lat,
      d_in  => ReadData2_lat,
      d_out => MemData);

	RegDst_out		<= RegDst_lat;
	MemtoReg_out	<= MemtoReg_lat;
	ALU_result_out	<= ALU_result_lat;
	RegWrite_out	<= RegWrite_lat;
end bhv;


