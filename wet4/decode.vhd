-- decode stage in pipeline mips
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.std_logic_unsigned.all;
entity Mips_Decode is
  port(
  	clk				: in std_logic;
  	rst				: in std_logic;
  	
	new_pc_in		: in std_logic_vector(31 downto 0);
  	instruction		: in std_logic_vector(31 downto 0);
  	flush			: in std_logic;
  	RegWrite_in		: in std_logic;
  	WriteReg		: in std_logic_vector(4 downto 0);
  	WriteData		: in std_logic_vector(31 downto 0);
	bubble			: in std_logic;
	
	Reg1_Valid      : out std_logic;
	Reg2_Valid      : out std_logic;
 	LoadWord	   	: out std_logic;
	Branch		    : out std_logic;
  	Jump		    : out std_logic;
  	jump_addr       : out std_logic_vector(31 downto 0);
  	ReadData1       : out std_logic_vector(31 downto 0);
	reg1_num		: out std_logic_vector(4 downto 0);
  	ReadData2       : out std_logic_vector(31 downto 0);
	reg2_num		: out std_logic_vector(4 downto 0);
	new_pc_out		: out std_logic_vector(31 downto 0);
  	instruction_ofs	: out std_logic_vector(15 downto 0);
	MemRead			: out std_logic;
	MemWrite		: out std_logic;
	MemtoReg		: out std_logic;
	ALUCtrl			: out std_logic_vector(2 downto 0);
  	ALUSrcB			: out std_logic;
  	RegWrite		: out std_logic;
	-- use register 0 when there is no need to write
	WriteReg_out	: out std_logic_vector(4 downto 0);
  	Opcode_out		: out std_logic_vector(5 downto 0));
end Mips_Decode;

architecture bhv of Mips_Decode is 
  component Register_File
    port(
      rst       : in  std_logic;
      clk       : in  std_logic;
      RegWrite  : in  std_logic;
      ReadReg1  : in  std_logic_vector(4 downto 0);
      ReadReg2  : in  std_logic_vector(4 downto 0);
      WriteReg  : in  std_logic_vector(4 downto 0);
      WriteData : in  std_logic_vector(31 downto 0);
      ReadData1 : out std_logic_vector(31 downto 0);
      ReadData2 : out std_logic_vector(31 downto 0));
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

  component Control
	port(
	   rst : in std_logic;
	   clk : in std_logic;

	-- Outputs
	   ALUSrc   : out std_logic;
	   ALUOp    : out std_logic_vector( 1 downto 0 );
	   RegWrite : out std_logic;
	   Jump     : out std_logic;
	   Branch   : out std_logic;
	   RegDst   : out std_logic;
	   MemRead  : out std_logic;
	   MemWrite : out std_logic;
	   MemtoReg : out std_logic;
	   LoadWord : out std_logic;
	   Reg1_Valid : out std_logic;
	   Reg2_Valid : out std_logic;

	-- Inputs
	   OpCode : in std_logic_vector( 5 downto 0 )
    );
  end component;

  component ALUControl
	port(
	-- Inputs
	   ALUOp : in std_logic_vector( 1 downto 0 );
	   funct : in std_logic_vector( 5 downto 0 );

	-- Outputs        
	   ALUCtrl : out std_logic_vector( 2 downto 0 ));
  end component;

  -- From control to alu control
signal ALUOp          : std_logic_vector( 1 downto 0 );

-- latched signals from input
signal instruction_lat	: std_logic_vector(31 downto 0);
signal new_pc_lat		: std_logic_vector(31 downto 0);

-- instrucion after flush mux
signal instr_flushed        : std_logic_vector(31 downto 0);

-- from control to destination register mux
signal RegDst	        : std_logic;

signal ReadData1_reg	: std_logic_vector(31 downto 0);
signal ReadData2_reg	: std_logic_vector(31 downto 0);

signal zeros	        : std_logic_vector(31 downto 0);

signal funct          : std_logic_vector(5 downto 0);
signal OpCode         : std_logic_vector(5 downto 0);
signal ALUSrcB_not_flushed   : std_logic;
signal ALUOp_not_flushed     : std_logic_vector( 1 downto 0 );
signal RegWrite_not_flushed  : std_logic;
signal Jump_not_flushed      : std_logic;
signal Branch_not_flushed    : std_logic;
signal RegDst_not_flushed    : std_logic;
signal MemRead_not_flushed   : std_logic;
signal MemWrite_not_flushed  : std_logic;
signal MemtoReg_not_flushed  : std_logic;
signal LoadWord_not_flushed  : std_logic;
signal Reg1_Valid_not_flushed : std_logic;
signal Reg2_Valid_not_flushed : std_logic;

begin 
  process(clk, rst)
  begin
	if(rst = '1') then
	  new_pc_lat		<= (others => '0');	  
	  instruction_lat	<= (others => '0');
	else
	  if(clk'event and clk = '1') then
      --		new_pc_lat		<= new_pc_in; -- deleted
		if (bubble = '1') then
			instruction_lat	<= instruction_lat;
			new_pc_lat		<= new_pc_lat; -- added
		else
			instruction_lat	<= instruction;
			new_pc_lat		<= new_pc_in; -- added
		end if;
	  end if;
	end if;
  end process;

  WriteReg_MUX : Mux_2to1_xN
    generic map(
      WIDTH => 5)
    port map(
      sel   => RegDst,
      d_in1 => instr_flushed(20 downto 16),
      d_in2 => instr_flushed(15 downto 11),
      d_out => WriteReg_out);

  Flush_MUX : Mux_2to1_xN
    generic map(
      WIDTH => 32)
    port map(
      sel   => flush,
      d_in1 => instruction_lat,
      d_in2 => zeros,
      d_out => instr_flushed);

  Register_File_ins : Register_File
    port map(
      rst       => rst,
      clk       => clk,
      RegWrite  => RegWrite_in,
      ReadReg1  => instr_flushed(25 downto 21),
      ReadReg2  => instr_flushed(20 downto 16),
      WriteReg  => WriteReg,
      WriteData => WriteData,
      ReadData1 => ReadData1_reg,
      ReadData2 => ReadData2_reg );

  Mips_Control : Control 
	port map(
	   rst => rst,
	   clk => clk,

	-- Outputs
	   ALUSrc   => ALUSrcB_not_flushed,
	   ALUOp    => ALUOp_not_flushed,
	   RegWrite => RegWrite_not_flushed,
	   Jump     => Jump_not_flushed,
	   Branch   => Branch_not_flushed,
	   RegDst   => RegDst_not_flushed,
	   MemRead  => MemRead_not_flushed,
	   MemWrite => MemWrite_not_flushed,
	   MemtoReg => MemtoReg_not_flushed,
	   LoadWord => LoadWord_not_flushed,
	   Reg1_Valid => Reg1_Valid,
	   Reg2_Valid => Reg2_Valid,

	-- Inputs
	   OpCode   => OpCode
    );

  ALUContr : ALUControl
	port map(
	-- Inputs
	   ALUOp => ALUOp,
	   funct => funct,

	-- Outputs        
	   ALUCtrl => ALUCtrl);

	new_pc_out <= new_pc_lat;
	OpCode <= instruction_lat(31 downto 26);
	Opcode_out <= instruction_lat(31 downto 26);
	jump_addr <= new_pc_lat(31 downto 28) & instr_flushed(25 downto 0) & "00";
	reg1_num <= instruction_lat(25 downto 21);
	reg2_num <= instruction_lat(20 downto 16);
	funct <= instr_flushed(5 downto 0);
	instruction_ofs <= instr_flushed(15 downto 0);

	ReadData1 <= WriteData when ((RegWrite_in = '1') and (instr_flushed(25
			  downto 21) = WriteReg) and not (WriteReg(4 downto 0) = "00000"))
			else ReadData1_reg;
		
	ReadData2 <= WriteData when ((RegWrite_in = '1') and (instr_flushed(20
			  downto 16) = WriteReg) and not (WriteReg(4 downto 0) = "00000"))
			else ReadData2_reg;
	zeros <= (others => '0');

 	LoadWord <= LoadWord_not_flushed when (flush = '0') else '0';
	Branch	 <= Branch_not_flushed when (flush = '0') else '0';
  	Jump	 <= Jump_not_flushed when (flush = '0') else '0';
	MemRead	 <= MemRead_not_flushed when (flush = '0') else '0';
	MemWrite <= MemWrite_not_flushed when (flush = '0') else '0';
	MemtoReg <= MemtoReg_not_flushed when (flush = '0') else '0';
  	ALUSrcB	 <= ALUSrcB_not_flushed when (flush = '0') else '0';
  	RegWrite <= RegWrite_not_flushed when (flush = '0') else '0';
  	ALUOp <= ALUOp_not_flushed when (flush = '0') else "00";
  	RegDst <= RegDst_not_flushed when (flush = '0') else '0';

end bhv;


