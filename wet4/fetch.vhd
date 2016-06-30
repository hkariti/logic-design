-- fetch stage in pipeline mips
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.std_logic_unsigned.all;
entity Mips_Fetch is
  port(
  	clk				: in std_logic;
  	rst				: in std_logic;
  	
  	branch          : in std_logic;
  	branch_addr     : in std_logic_vector(31 downto 0);
  	jump		    : in std_logic;
  	jump_addr       : in std_logic_vector(31 downto 0);
  	PCLoad			: in std_logic;
  	empty_instr		: in std_logic;

  	new_pc			: out std_logic_vector(31 downto 0);
  	Instruction		: out std_logic_vector(31 downto 0));
end Mips_Fetch;

architecture bhv of Mips_Fetch is
  component Instr_Memory
	port(
	   rst   : in  std_logic;
	   clk   : in  std_logic;
	   addr  : in  std_logic_vector (31 downto 0);
	   d_out : out std_logic_vector (31 downto 0)
	 );
  end component;

  component Mux_2to1_xN
  port(
		sel   : in  std_logic;
		d_in1 : in  std_logic_vector(31 downto 0);
		d_in2 : in  std_logic_vector(31 downto 0);
		d_out : out std_logic_vector(31 downto 0));
  end component;



  -- from instruction memory to bubble mux
  signal orig_instr : std_logic_vector(31 downto 0);
  -- from PC register to add of 4
  signal PC_out : std_logic_vector(31 downto 0);
  
  -- PC from branch mux to PC register
  signal PC_in : std_logic_vector(31 downto 0);
  signal new_pc_int			: std_logic_vector(31 downto 0);
  
  -- from jump mux to branch mux
  signal jump_PC : std_logic_vector(31 downto 0);
  signal const_4 : std_logic_vector(31 downto 0);
  signal zeros : std_logic_vector(31 downto 0);

begin
  

	
  process(clk, rst)
  begin
    if(rst = '1') then
      PC_out   <= x"00400000";
    elsif(clk'event and clk = '1') then
      if(PCLoad = '1') then
        PC_out <= PC_in;
      end if;
    end if;
  end process;

	
	
	
	
	
	
  Mips_Instr_Memory : Instr_Memory
  port map(
	rst   => rst,
	clk   => clk,
	addr  => PC_out,
	d_out => orig_instr
  );

  jump_mux : Mux_2to1_xN
  port map
  (	
	sel    => jump,
	d_in1  => new_pc_int,
	d_in2  => jump_addr,
	d_out  => jump_pc);
 
  branch_mux : Mux_2to1_xN
  port map
  (	
	sel    => branch,
	d_in1  => jump_pc,
	d_in2  => branch_addr,
	d_out  => PC_in);

  bubble_mux : Mux_2to1_xN
  port map
  (	
	sel    => empty_instr,
	d_in1  => orig_instr,
	d_in2  => zeros,
	d_out  => Instruction);

  const_4 <= (2 => '1', others => '0');
  zeros <= (others => '0');
  
  
 

  
  
  new_pc_int <= PC_out + const_4;
  new_pc <= new_pc_int;

  
  
end bhv;

