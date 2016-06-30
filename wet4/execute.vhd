-- decode stage in pipeline mips
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.std_logic_unsigned.all;
entity Mips_Execute is
  port(
  	clk				: in std_logic;
  	rst				: in std_logic;
  
  -- data from decode unit
	branch_instr    : in std_logic;	
	ReadData1_in    : in std_logic_vector(31 downto 0);
	reg1_num_in		: in std_logic_vector(4 downto 0);
  	ReadData2_in    : in std_logic_vector(31 downto 0);
	reg2_num_in		: in std_logic_vector(4 downto 0);
 	LoadWord	   	: in std_logic;

	new_pc			: in std_logic_vector(31 downto 0);
  	instruction_ofs	: in std_logic_vector(15 downto 0);
	MemRead_in		: in std_logic;
	RegWrite_in		: in std_logic;
	MemWrite_in		: in std_logic;
	MemtoReg_in		: in std_logic;
	ALUCtrl		: in std_logic_vector(2 downto 0);
  	ALUSrcB			: in std_logic;
	-- use register 0 when there is no need to write
	RegDst_in		: in std_logic_vector(4 downto 0);	

	-- data from forwarding unit
	forw_data1	    : in std_logic_vector(31 downto 0);
	forw_data2	    : in std_logic_vector(31 downto 0);

-- out
    -- to forwarding unit
  	ReadData1_out 	: out std_logic_vector(31 downto 0);
	reg1_num_out	: out std_logic_vector(4 downto 0);
  	ReadData2_out 	: out std_logic_vector(31 downto 0);
	reg2_num_out	: out std_logic_vector(4 downto 0);

    -- to memory unit
	RegDst_out		: out std_logic_vector(4 downto 0);	
	MemRead_out		: out std_logic;
	MemWrite_out	: out std_logic;
	MemtoReg_out	: out std_logic;
	ALU_result		: out std_logic_vector(31 downto 0);
  	ReadData2_forw_out   : out std_logic_vector(31 downto 0);
	RegWrite_out	: out std_logic;

  	-- to fetch unit
	Branch			: out std_logic;
	Branch_Addr		: out std_logic_vector(31 downto 0);

	-- to hazard unit
 	LoadWord_out   	: out std_logic);
end Mips_Execute;

architecture bhv of Mips_Execute is 
  
  component ALU
    port(
      ctrl  : in  std_logic_vector(2 downto 0);
      d_in1 : in  std_logic_vector(31 downto 0);
      d_in2 : in  std_logic_vector(31 downto 0);
      d_out : out std_logic_vector(31 downto 0);
      Zero  : out std_logic);
  end component;

  component Sign_extend
    port(
      d_in  : in  std_logic_vector(15 downto 0);
      d_out : out std_logic_vector(31 downto 0));
  end component;

  component Shift_left_2
    generic(
      WIDTH :     integer := 32);
    port(
      d_in  : in  std_logic_vector((WIDTH - 1) downto 0);
      d_out : out std_logic_vector((WIDTH - 1) downto 0));
  end component;

  component Mux_2to1_xN
    generic (
      WIDTH :     integer := 32);
    port(
      sel   : in  std_logic;
      d_in1 : in  std_logic_vector((WIDTH - 1) downto 0);
      d_in2 : in  std_logic_vector((WIDTH - 1) downto 0);
      d_out : out std_logic_vector((WIDTH - 1) downto 0));
  end component;


signal zeros	        : std_logic_vector(31 downto 0);
-- latched signals from decode stage 
signal	branch_instr_lat	:  std_logic;	
signal	ReadData1_lat   	:  std_logic_vector(31 downto 0);
signal	reg1_num_lat		:  std_logic_vector(4 downto 0);
signal 	ReadData2_lat  		:  std_logic_vector(31 downto 0);
signal	reg2_num_lat		:  std_logic_vector(4 downto 0);
signal 	instruction_ofs_lat	:  std_logic_vector(15 downto 0);
signal	MemRead_lat			:  std_logic;
signal	MemWrite_lat		:  std_logic;
signal	MemtoReg_lat		:  std_logic;
signal	ALUCtrl_lat			:  std_logic_vector(2 downto 0);
signal 	ALUSrcB_lat			:  std_logic;
signal	RegDst_lat			:  std_logic_vector(4 downto 0);
signal 	RegWrite_lat			:  std_logic;
signal 	LoadWord_lat			:  std_logic;
signal	new_pc_lat			:  std_logic_vector(31 downto 0);

-- from ALU indicating the result is zero (for beq command)
signal Zero           : std_logic;

-- output of sign extender
signal sign_extended  : std_logic_vector(31 downto 0);
-- output of 32 bit shifter
signal shifted_left_2 : std_logic_vector(31 downto 0);

-- inputs to ALU
signal ALU_in2        : std_logic_vector(31 downto 0);
begin
process(clk, rst)
  begin
	if(rst = '1') then
		branch_instr_lat	<= '0'; 
		ReadData1_lat   	<= (others => '0'); 
		reg1_num_lat		<= (others => '0'); 
		ReadData2_lat  		<= (others => '0'); 
		reg2_num_lat		<= (others => '0'); 
		new_pc_lat			<= (others => '0'); 
		instruction_ofs_lat	<= (others => '0'); 
		MemRead_lat			<= '0'; 
		MemWrite_lat		<= '0'; 
		MemtoReg_lat		<= '0'; 
		ALUCtrl_lat			<= (others => '0'); 
		ALUSrcB_lat			<= '0'; 
		RegDst_lat			<= (others => '0'); 
		RegWrite_lat		<= '0'; 
		LoadWord_lat		<= '0'; 
	else
	  if(clk'event and clk = '1') then
		branch_instr_lat	<= branch_instr;
		ReadData1_lat   	<= ReadData1_in;
		reg1_num_lat		<= reg1_num_in; 
		ReadData2_lat  		<= ReadData2_in;
		reg2_num_lat		<= reg2_num_in;
		new_pc_lat			<= new_pc;
		instruction_ofs_lat	<= instruction_ofs;
		MemRead_lat			<= MemRead_in;
		MemWrite_lat		<= MemWrite_in;
		MemtoReg_lat		<= MemtoReg_in;
		ALUCtrl_lat			<= ALUCtrl;
		ALUSrcB_lat			<= ALUSrcB;
		RegDst_lat			<= RegDst_in;
		RegWrite_lat		<= RegWrite_in;
		LoadWord_lat		<= LoadWord;
	  end if;
	end if;
  end process;

  Sign_extend_ins : Sign_extend
    port map(
      d_in  => instruction_ofs_lat,
      d_out => sign_extended);

  Shift_left_2_ins : Shift_left_2
    port map(
      d_in  => sign_extended,
      d_out => shifted_left_2);

  ALUSrcB_MUX : Mux_2to1_xN
    port map(
      sel   => ALUSrcB_lat,
      d_in1 => forw_data2,
      d_in2 => sign_extended,
      d_out => ALU_in2);

  ALU_ins : ALU
    port map(
      ctrl  => ALUCtrl_lat,
      d_in1 => forw_data1,
      d_in2 => ALU_in2,
      d_out => ALU_result,
      Zero  => Zero );

  Branch       <= branch_instr_lat and Zero;
  Branch_Addr(31 downto 0) <= shifted_left_2(31 downto 0) + new_pc_lat(31 downto 0);
  RegDst_out   <= RegDst_lat;
  -- to memory unit
  MemRead_out  <= MemRead_lat;
  MemWrite_out <= MemWrite_lat;
  MemtoReg_out <= MemtoReg_lat;
  -- to forwarding unit
  ReadData1_out <= ReadData1_lat;
  reg1_num_out  <= reg1_num_lat;
  ReadData2_out <= ReadData2_lat;
  reg2_num_out  <= reg2_num_lat;
  
  ReadData2_forw_out <= forw_data2;
  RegWrite_out  <= RegWrite_lat;
  LoadWord_out  <= LoadWord_lat;

  zeros <= (others => '0');
end bhv;


