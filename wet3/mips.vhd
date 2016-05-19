library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity MIPS is
  port(
    rst : in std_logic;
    clk : in std_logic
    );

end MIPS;

-- purpose: put all the components together
architecture str of MIPS is

  component Datapath 
	port(
	   rst : in std_logic;
	   clk : in std_logic;

	-- Inputs
	   Instruction : in std_logic_vector( 31 downto 0 );
	   PC          : in std_logic_vector( 31 downto 0 );

	-- Outputs
	   NewPC       : out std_logic_vector( 31 downto 0 )
  );

  end component;

  component RegisterN
	port(
	   rst   : in  std_logic;
	   clk   : in  std_logic;
	   d_in  : in  std_logic_vector(31 downto 0);
	   d_out : out std_logic_vector(31 downto 0));
  end component;

  component Instr_Memory
	port(
	   rst   : in  std_logic;
	   clk   : in  std_logic;
	   addr  : in  std_logic_vector (31 downto 0);
	   d_out : out std_logic_vector (31 downto 0)
	 );
  end component;

signal PC_in : std_logic_vector(31 downto 0);
signal PC_out : std_logic_vector(31 downto 0);
signal Instruction : std_logic_vector(31 downto 0);

begin  -- bhv


process( clk, rst )
	
  begin
  
	if (rst = '1') then
		PC_out <= x"00400000";
	elsif ( clk'event and clk = '1') then
		PC_out <= PC_in;
	end if;	
end process;

  
  Mips_Datapath : Datapath
  port map(
	rst    => rst,
	clk    => clk,

	-- Inputs
   Instruction => Instruction,
   PC          => PC_out,

	-- Outputs
   NewPC       => PC_in
  );

  Mips_Instr_Memory : Instr_Memory
  port map(
	rst   => rst,
	clk   => clk,
	addr  => PC_out,
	d_out => Instruction
  );
end str;

