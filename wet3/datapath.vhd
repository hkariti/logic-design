
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Datapath is
  port(
    rst : in std_logic;
    clk : in std_logic;

    -- Inputs
  	Instruction : in std_logic_vector( 31 downto 0 );
    PC          : in std_logic_vector( 31 downto 0 );

    -- Outputs
    NewPC       : out std_logic_vector( 31 downto 0 )
    );

end Datapath;

-- purpose: put all the components together
architecture bhv of Datapath is

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

  component Mux_2to1_xN
    generic (
      WIDTH :     integer := 32);
    port(
      sel   : in  std_logic;
      d_in1 : in  std_logic_vector((WIDTH - 1) downto 0);
      d_in2 : in  std_logic_vector((WIDTH - 1) downto 0);
      d_out : out std_logic_vector((WIDTH - 1) downto 0));
  end component;

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

  component Control is 
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

	-- Inputs
	   OpCode : in std_logic_vector( 5 downto 0 )
    );
  end component;

  component ALUControl is
	port(
	-- Inputs
	   ALUOp : in std_logic_vector( 1 downto 0 );
	   funct : in std_logic_vector( 5 downto 0 );

	-- Outputs        
	   ALUCtrl : out std_logic_vector( 2 downto 0 ));
  end component;

-- PC + 4
signal PC_inc         : std_logic_vector(31 downto 0);
-- branch_addr
signal Branch_Addr    : std_logic_vector(31 downto 0);
-- branched addr after branch mux
signal PC_Branched    : std_logic_vector(31 downto 0);
-- data read from Memory, connect to input of Registers file
signal MemData        : std_logic_vector(31 downto 0);
-- output from mux to write data line on reg32
signal WriteData      : std_logic_vector(31 downto 0);
-- out from mux, register to write to on big RF
signal WriteReg       : std_logic_vector(4 downto 0);
-- outputs of the reg32
signal ReadData1      : std_logic_vector(31 downto 0);
signal ReadData2      : std_logic_vector(31 downto 0);
-- output of sign extender
signal sign_extended  : std_logic_vector(31 downto 0);
-- output of 32 bit shifter
signal shifted_left_2 : std_logic_vector(31 downto 0);
-- inputs to ALU
signal ALU_in1        : std_logic_vector(31 downto 0);
signal ALU_in2        : std_logic_vector(31 downto 0);
-- out of ALU
signal ALU_result     : std_logic_vector(31 downto 0);
-- calc the addr to jump to
signal JumpAddr       : std_logic_vector(31 downto 0);
-- input to PC, out of last mux
--  signal PC_in          : std_logic_vector(31 downto 0);
  
signal const_4        : std_logic_vector(31 downto 0);
signal const_X        : std_logic_vector(31 downto 0);

signal funct          : std_logic_vector(5 downto 0);
signal OpCode         : std_logic_vector(5 downto 0);

signal Zero           : std_logic;
-- From control to memory
signal MemRead        : std_logic;
signal MemWrite       : std_logic;
-- From control to writedata mux
signal MemtoReg       : std_logic;
-- From control to writereg mux
signal RegDst         : std_logic;
-- From control to registers file
signal RegWrite       : std_logic;
-- From control to branch mux
signal Branch         : std_logic;
-- From control to jump mux
signal Jump           : std_logic;
-- From control to alusrcb mux
signal ALUSrcB        : std_logic;
-- From alu control to alu
signal ALUCtrl        : std_logic_vector(2 downto 0);
-- From control to alu control
signal ALUOp          : std_logic_vector( 1 downto 0 );
-- and between branch and zero
signal Branch_and_Zero: std_logic;

begin  -- bhv


  -- put everything together:: 
  MEM : Memory
    port map (
      rst   => rst,
      clk   => clk,
      rd    => MemRead,
      wr    => MemWrite,
      addr  => ALU_result,
      d_in  => ReadData2,
      d_out => MemData);

  WriteData_MUX : Mux_2to1_xN
    port map(
      sel   => MemtoReg,
      d_in1 => ALU_result,
      d_in2 => MemData,
      d_out => WriteData);

  WriteReg_MUX : Mux_2to1_xN
    generic map(
      WIDTH => 5)
    port map(
      sel   => RegDst,
      d_in1 => Instruction(20 downto 16),
      d_in2 => Instruction(15 downto 11),
      d_out => WriteReg);

  Register_File_ins : Register_File
    port map(
      rst       => rst,
      clk       => clk,
      RegWrite  => RegWrite,
      ReadReg1  => Instruction(25 downto 21),
      ReadReg2  => Instruction(20 downto 16),
      WriteReg  => WriteReg,
      WriteData => WriteData,
      ReadData1 => ReadData1,
      ReadData2 => ReadData2 );

  Sign_extend_ins : Sign_extend
    port map(
      d_in  => Instruction(15 downto 0),
      d_out => sign_extended);

  Shift_left_2_ins : Shift_left_2
    port map(
      d_in  => sign_extended,
      d_out => shifted_left_2);

  Branch_MUX : Mux_2to1_xN
    port map(
      sel   => Branch_and_Zero,
      d_in1 => PC_inc,
      d_in2 => Branch_Addr,
      d_out => PC_branched);

  Jump_MUX : Mux_2to1_xN
    port map(
      sel   => Jump,
      d_in1 => PC_branched,
      d_in2 => JumpAddr(31 downto 0),
      d_out => NewPC);

  ALUSrcB_MUX : Mux_2to1_xN
    port map(
      sel   => ALUSrcB,
      d_in1 => ReadData2,
      d_in2 => sign_extended,
      d_out => ALU_in2);

  ALU_ins : ALU
    port map(
      ctrl  => ALUCtrl,
      d_in1 => ReadData1,
      d_in2 => ALU_in2,
      d_out => ALU_result,
      Zero  => Zero );

  Mips_Control : Control 
	port map(
	   rst => rst,
	   clk => clk,

	-- Outputs
	   ALUSrc   => ALUSrcB,
	   ALUOp    => ALUOp,
	   RegWrite => RegWrite,
	   Jump     => Jump,
	   Branch   => Branch,
	   RegDst   => RegDst,
	   MemRead  => MemRead,
	   MemWrite => MemWrite,
	   MemtoReg => MemtoReg,

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


  const_4 <= (2 => '1', others => '0');
  const_X <= (others => 'X');

  OpCode                <= Instruction(31 downto 26);
  funct                 <= Instruction(5 downto 0);
  PC_inc                <= PC(31 downto 0) + const_4;
  JumpAddr(31 downto 0) <= PC_inc(31 downto 28) & Instruction(25 downto 0) & "00";

  Branch_and_Zero       <= Branch and Zero;
  Branch_Addr(31 downto 0) <= shifted_left_2(31 downto 0) + PC_inc(31 downto 0);
end bhv;












