
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

    -- Inputs
    OpCode : in std_logic_vector( 5 downto 0 )
    );

end Control;


architecture bhv of Control is
signal opbits : std_logic_vector(4 downto 0);
begin  -- bhv

  process(OpCode)
  begin
    case OpCode is
      -- when R-TYPE
      when "000000"   => 
		opbits <= "10000";
	  -- when beq
      when "000100"   => 
		opbits <= "01000";
	  -- when jmp
	  when "000010"   =>
		opbits <= "00100";
	  -- when lw
      when "100011"   => 
		opbits <= "00010";
	  -- when sw
      when "101011"   =>
		opbits <= "00001";
      -- when andi
      when "001100"   =>
        opbits <= "11001";
      when others =>
		opbits <= "00000";
    end case;
  end process;

  ALUSrc     <= opbits(0) or opbits(1);
  ALUOp      <= opbits(4) & opbits(3);   
  RegWrite   <= opbits(1) or opbits(4);
  RegDst     <= opbits(4) and (not (opbits(3)));
  Jump       <= opbits(2);
  Branch     <= opbits(3) and (not (opbits(4)));
  MemRead    <= opbits(1);
  MemWrite   <= opbits(0) and (opbits(3) nand opbits(4));
  MemtoReg   <= opbits(1);
end bhv;
