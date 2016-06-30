
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity Control is
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
    LoadByte : out std_logic;
	Reg1_Valid : out std_logic;
	Reg2_Valid : out std_logic;

    -- Inputs
    OpCode : in std_logic_vector( 5 downto 0 )
    );

end Control;


architecture bhv of Control is
signal opbits : std_logic_vector(5 downto 0);
begin  -- bhv

  process(OpCode)
  begin
    case OpCode is
      -- when R-TYPE
      when "000000"   => 
		opbits <= "010000";
	  -- when beq
      when "000100"   => 
		opbits <= "001000";
	  -- when jmp
	  when "000010"   =>
		opbits <= "000100";
	  -- when lw
      when "100011"   => 
		opbits <= "000010";
      -- when lb
      when "100000"   =>
        opbits <= "100010";
      -- when sw
      when "101011"   =>
		opbits <= "000001";

      when others =>
		opbits <= "000000";
	
    end case;
  end process;

  ALUSrc     <= opbits(0) or opbits(1);
  ALUOp      <= opbits(4) & opbits(3);   
  RegWrite   <= opbits(1) or opbits(4);
  RegDst     <= opbits(4);
  Jump       <= opbits(2);
  Branch     <= opbits(3);
  MemRead    <= opbits(1);
  MemWrite   <= opbits(0);
  MemtoReg   <= opbits(1);
  LoadWord   <= opbits(1);
  LoadByte   <= opbits(1) & opbits(5);
  Reg1_Valid <= opbits(4) or opbits(3) or opbits(1) or opbits(0);
  Reg2_Valid <= opbits(4) or opbits(3);
end bhv;
