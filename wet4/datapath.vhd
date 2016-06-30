
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Datapath is
  port(
    rst : in std_logic;
    clk : in std_logic);

end Datapath;

-- purpose: put all the components together
architecture bhv of Datapath is

  component Mips_Fetch 
	port(
	   clk				: in std_logic;
	   rst				: in std_logic;

	   branch   	   	: in std_logic;
	   branch_addr  	: in std_logic_vector(31 downto 0);
	   jump			    : in std_logic;
	   jump_addr       	: in std_logic_vector(31 downto 0);
	   PCLoad			: in std_logic;
	   empty_instr		: in std_logic;

	   new_pc			: out std_logic_vector(31 downto 0);
	   Instruction		: out std_logic_vector(31 downto 0));
  end component;

  component Mips_Decode 
	port(
	  clk				: in std_logic;
	  rst				: in std_logic;
	  
	  new_pc_in			: in std_logic_vector(31 downto 0);
	  instruction		: in std_logic_vector(31 downto 0);
	  flush				: in std_logic;
	  RegWrite_in		: in std_logic;
	  WriteReg			: in std_logic_vector(4 downto 0);
	  WriteData			: in std_logic_vector(31 downto 0);
	  bubble			: in std_logic;

	  Reg1_Valid      : out std_logic;
	  Reg2_Valid      : out std_logic;
	  LoadWord	    	: out std_logic;
	  Branch		    : out std_logic;
	  Jump		    	: out std_logic;
	  jump_addr       	: out std_logic_vector(31 downto 0);
	  ReadData1   	    : out std_logic_vector(31 downto 0);
	  reg1_num			: out std_logic_vector(4 downto 0);
	  ReadData2     	: out std_logic_vector(31 downto 0);
	  reg2_num			: out std_logic_vector(4 downto 0);
	  new_pc_out		: out std_logic_vector(31 downto 0);
	  instruction_ofs	: out std_logic_vector(15 downto 0);
	  MemRead			: out std_logic;
	  MemWrite			: out std_logic;
	  MemtoReg			: out std_logic;
	  ALUCtrl			: out std_logic_vector(2 downto 0);
	  ALUSrcB			: out std_logic;
	  RegWrite			: out std_logic;
	  -- use register 0 when there is no need to write
	  WriteReg_out		: out std_logic_vector(4 downto 0);
	  Opcode_out		: out std_logic_vector(5 downto 0));
  end component;

  component Mips_Execute
	port(
	   clk				: in std_logic;
	   rst				: in std_logic;

	-- data from decode unit
	   branch_instr    	: in std_logic;	
	   ReadData1_in    	: in std_logic_vector(31 downto 0);
	   reg1_num_in		: in std_logic_vector(4 downto 0);
	   ReadData2_in    	: in std_logic_vector(31 downto 0);
	   reg2_num_in		: in std_logic_vector(4 downto 0);
	   LoadWord	   	: in std_logic;

	   new_pc			: in std_logic_vector(31 downto 0);
	   instruction_ofs	: in std_logic_vector(15 downto 0);
	   MemRead_in		: in std_logic;
	   RegWrite_in		: in std_logic;
	   MemWrite_in		: in std_logic;
	   MemtoReg_in		: in std_logic;
	   ALUCtrl			: in std_logic_vector(2 downto 0);
	   ALUSrcB			: in std_logic;
	-- use register 0 when there is no need to write
	   RegDst_in		: in std_logic_vector(4 downto 0);	

	-- data from forwarding unit
	   forw_data1	    : in std_logic_vector(31 downto 0);
	   forw_data2	    : in std_logic_vector(31 downto 0);

	-- out
 -- to forwarding unit
	   ReadData1_out 	: out std_logic_vector(31 downto 0);
	   reg1_num_out		: out std_logic_vector(4 downto 0);
	   ReadData2_out 	: out std_logic_vector(31 downto 0);
	   reg2_num_out		: out std_logic_vector(4 downto 0);

	-- to memory unit
	   RegDst_out		: out std_logic_vector(4 downto 0);	
	   MemRead_out		: out std_logic;
	   MemWrite_out		: out std_logic;
	   MemtoReg_out		: out std_logic;
	   ALU_result		: out std_logic_vector(31 downto 0);
	   ReadData2_forw_out   : out std_logic_vector(31 downto 0);
	   RegWrite_out		: out std_logic;

	-- to fetch unit
	   Branch			: out std_logic;
	   Branch_Addr		: out std_logic_vector(31 downto 0);
	   	-- to hazard unit
 	   LoadWord_out   	: out std_logic);

  end component;

  component Mips_Memory_Stage
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
	   ReadData2_in		: in std_logic_vector(31 downto 0);
	   RegWrite_in		: in std_logic;

	-- out
	   RegDst_out		: out std_logic_vector(4 downto 0);	
	   MemtoReg_out		: out std_logic;
	   MemData			: out std_logic_vector(31 downto 0);
	   RegWrite_out		: out std_logic;
	   ALU_result_out	: out std_logic_vector(31 downto 0));
  end component;
  
  component Mips_WriteBack
	port(
	   clk				: in std_logic;
	   rst				: in std_logic;
	-- in
	   reg_dst_in		: in std_logic_vector(4 downto 0);	
	   mem_to_reg_in	: in std_logic;
	   mem_data			: in std_logic_vector(31 downto 0);
	   alu_result_in	: in std_logic_vector(31 downto 0);
	   RegWrite_in		: in std_logic;
	-- out
	   write_data		: out std_logic_vector(31 downto 0);
	   write_reg_addr	: out std_logic_vector(4 downto 0);	
	   write_reg		: out std_logic);
  end component;
  
  component Mips_Hazard
	port(
		-- in
		clk				: in std_logic;
		rst				: in std_logic;

		opcode			: in std_logic_vector(5 downto 0);
		branch			: in std_logic;
		execute_lw		: in std_logic;
		lw_reg_dst		: in std_logic_vector(4 downto 0);

		reg1			: in std_logic_vector(4 downto 0);
		reg1_valid		: in std_logic;
		reg2			: in std_logic_vector(4 downto 0);
		reg2_valid		: in std_logic;

	-- out
	  bubble			: out std_logic;
	   decode_flush		: out std_logic;
	   load_pc			: out std_logic;
	   empty_instr		: out std_logic);
  end component;
  
  component Mips_Forwarding
	port(
	-- from execute
	   forw1_reg		: in std_logic_vector(4 downto 0);
	   forw2_reg		: in std_logic_vector(4 downto 0);
	   exec_reg1_data	: in std_logic_vector(31 downto 0);
	   exec_reg2_data	: in std_logic_vector(31 downto 0);

	-- from memory stage
	   mem_dst_reg		: in std_logic_vector(4 downto 0);
	   mem_write_reg   	: in std_logic;
	   mem_alu_result	: in std_logic_vector(31 downto 0);

	-- from write back stage
	   wb_dst_reg		: in std_logic_vector(4 downto 0);
	   wb_write_reg   	: in std_logic;
	   wb_data			: in std_logic_vector(31 downto 0);

	-- out
	   forw_data1	    : out std_logic_vector(31 downto 0);
	   forw_data2	    : out std_logic_vector(31 downto 0));
  end component;

  signal exec_branch : std_logic;
  signal exec_fetch_branch_addr : std_logic_vector(31 downto 0);
  signal decode_jump : std_logic;
  signal decode_fetch_jump_addr : std_logic_vector(31 downto 0);
  signal hazard_fetch_pc_load : std_logic;
  signal hazard_fetch_empty_instr : std_logic;

  signal fetch_decode_new_pc : std_logic_vector(31 downto 0);
  signal fetch_decode_instruction : std_logic_vector(31 downto 0);
  signal hazard_decode_flush : std_logic;
  signal hazard_decode_bubble : std_logic;
  signal wb_decode_regwrite: std_logic;
  signal wb_decode_writereg : std_logic_vector(4 downto 0);
  signal wb_decode_writedata: std_logic_vector(31 downto 0);
  signal decode_hazard_opcode : std_logic_vector(5 downto 0);
  signal decode_exec_readdata1: std_logic_vector(31 downto 0);
  signal decode_exec_reg1_num : std_logic_vector(4 downto 0);
  signal decode_exec_readdata2: std_logic_vector(31 downto 0);
  signal decode_exec_reg2_num : std_logic_vector(4 downto 0);
  signal decode_exec_new_pc : std_logic_vector(31 downto 0);
  signal decode_exec_instr_ofs : std_logic_vector(15 downto 0);
  signal decode_exec_jump_instr : std_logic;
  signal decode_exec_memread: std_logic;
  signal decode_exec_memwrite : std_logic;
  signal decode_exec_memtoreg : std_logic;
  signal decode_exec_aluctrl : std_logic_vector(2 downto 0);
  signal decode_exec_alusrcb : std_logic;
  signal decode_exec_regwrite : std_logic;
  signal decode_exec_writereg : std_logic_vector(4 downto 0);
  signal decode_exec_branch_instr : std_logic;
  signal decode_exec_loadword : std_logic;
  signal decode_reg1_valid : std_logic;
  signal decode_reg2_valid : std_logic;

  signal forw_exec_forw_data1: std_logic_vector(31 downto 0);
  signal forw_exec_forw_data2: std_logic_vector(31 downto 0);

  signal exec_forw_readdata1: std_logic_vector(31 downto 0);
  signal exec_forw_reg1_num : std_logic_vector(4 downto 0);
  signal exec_forw_readdata2: std_logic_vector(31 downto 0);
  signal exec_forw_reg2_num : std_logic_vector(4 downto 0);

  signal exec_mem_regdst : std_logic_vector(4 downto 0);
  signal exec_mem_memread: std_logic;
  signal exec_mem_memwrite : std_logic;
  signal exec_mem_memtoreg : std_logic;
  signal exec_mem_alu_result: std_logic_vector(31 downto 0);
  signal exec_mem_readdata2_forw : std_logic_vector(31 downto 0);
  signal exec_mem_regwrite : std_logic;
  signal exec_lw : std_logic;

  signal mem_wb_regdst : std_logic_vector(4 downto 0);
  signal mem_wb_memtoreg : std_logic;
  signal mem_wb_alu_result: std_logic_vector(31 downto 0);
  signal mem_wb_memdata : std_logic_vector(31 downto 0);
  signal mem_wb_regwrite : std_logic;
begin  -- bhv

  -- put everything together:: 
  Mips_Fetch_ins : Mips_Fetch 
	port map(
	   clk				=> clk,
	   rst				=> rst,

	   branch   	   	=> exec_branch,
	   branch_addr  	=> exec_fetch_branch_addr,
	   jump			    => decode_jump,
	   jump_addr       	=> decode_fetch_jump_addr,
	   PCLoad			=> hazard_fetch_pc_load,
	   empty_instr		=> hazard_fetch_empty_instr,

	   new_pc			=> fetch_decode_new_pc,
	   Instruction		=> fetch_decode_instruction);

  Mips_Decode_ins : Mips_Decode 
	port map(
	  clk				=> clk,
	  rst				=> rst,
	  
	  new_pc_in			=> fetch_decode_new_pc,
	  instruction		=> fetch_decode_instruction,
	  flush				=> hazard_decode_flush,
	  RegWrite_in		=> wb_decode_regwrite,
	  WriteReg			=> wb_decode_writereg,
	  WriteData			=> wb_decode_writedata,
	  bubble            => hazard_decode_bubble,
	  	
	  Reg1_Valid        => decode_reg1_valid,
   	  Reg2_Valid        => decode_reg2_valid, 
 	  LoadWord	   	    => decode_exec_loadword,

	  Branch		    => decode_exec_branch_instr,
	  Jump		    	=> decode_jump,
	  jump_addr       	=> decode_fetch_jump_addr,
	  ReadData1   	    => decode_exec_readdata1,
	  reg1_num			=> decode_exec_reg1_num,
	  ReadData2     	=> decode_exec_readdata2,
	  reg2_num			=> decode_exec_reg2_num,
	  new_pc_out		=> decode_exec_new_pc,
	  instruction_ofs	=> decode_exec_instr_ofs,
	  MemRead			=> decode_exec_memread,
	  MemWrite			=> decode_exec_memwrite,
	  MemtoReg			=> decode_exec_memtoreg,
	  ALUCtrl			=> decode_exec_aluctrl,
	  ALUSrcB			=> decode_exec_alusrcb,
	  RegWrite			=> decode_exec_regwrite,
	  Opcode_out		=> decode_hazard_opcode,
	  -- use register 0 when there is no need to write
	  WriteReg_out		=> decode_exec_writereg);

  Mips_Execute_ins : Mips_Execute
	port map(
	   clk				=> clk,
	   rst				=> rst,

	-- data from decode unit
	   branch_instr    	=> decode_exec_branch_instr,	
	   ReadData1_in    	=> decode_exec_readdata1,
	   reg1_num_in		=> decode_exec_reg1_num,
	   ReadData2_in    	=> decode_exec_readdata2,
	   reg2_num_in		=> decode_exec_reg2_num,
	   LoadWord         => decode_exec_loadword,

	   new_pc			=> decode_exec_new_pc,
	   instruction_ofs	=> decode_exec_instr_ofs,
	   MemRead_in		=> decode_exec_memread,
	   RegWrite_in		=> decode_exec_regwrite,
	   MemWrite_in		=> decode_exec_memwrite,
	   MemtoReg_in		=> decode_exec_memtoreg,
	   ALUCtrl			=> decode_exec_aluctrl,
	   ALUSrcB			=> decode_exec_alusrcb,
	-- use register 0 when there is no need to write
	   RegDst_in		=> decode_exec_writereg,	

	-- data from forwarding unit
	   forw_data1	    => forw_exec_forw_data1,
	   forw_data2	    => forw_exec_forw_data2,

	-- out
 -- to forwarding unit
	   ReadData1_out 	=> exec_forw_readdata1,
	   reg1_num_out		=> exec_forw_reg1_num,
	   ReadData2_out 	=> exec_forw_readdata2,
	   reg2_num_out		=> exec_forw_reg2_num,

	-- to memory unit
	   RegDst_out		=> exec_mem_regdst,	
	   MemRead_out		=> exec_mem_memread,
	   MemWrite_out		=> exec_mem_memwrite,
	   MemtoReg_out		=> exec_mem_memtoreg,
	   ALU_result		=> exec_mem_alu_result,
	   ReadData2_forw_out   => exec_mem_readdata2_forw,
	   RegWrite_out		=> exec_mem_regwrite,

	-- to fetch unit
	   Branch			=> exec_branch,
	   Branch_Addr		=> exec_fetch_branch_addr,
	-- to hazard
	   LoadWord_out    => exec_lw);

  Mips_Memory_Stage_ins : Mips_Memory_Stage
	port map(
	   clk				=> clk,
	   rst				=> rst,

	-- in
 -- from execute unit
	   RegDst_in		=> exec_mem_regdst,	
	   MemRead_in		=> exec_mem_memread,
	   MemWrite_in		=> exec_mem_memwrite,
	   MemtoReg_in		=> exec_mem_memtoreg,
	   ALU_result_in	=> exec_mem_alu_result,
	   ReadData2_in		=> exec_mem_readdata2_forw,
	   RegWrite_in		=> exec_mem_regwrite,

	-- out
	   RegDst_out		=> mem_wb_regdst,	
	   MemtoReg_out		=> mem_wb_memtoreg,
	   MemData			=> mem_wb_memdata,
	   RegWrite_out		=> mem_wb_regwrite,
	   ALU_result_out	=> mem_wb_alu_result);
  
  Mips_WriteBack_ins : Mips_WriteBack
	port map(
	   clk				=> clk,
	   rst				=> rst,
	-- in
	   reg_dst_in		=> mem_wb_regdst,	
	   mem_to_reg_in	=> mem_wb_memtoreg,
	   mem_data			=> mem_wb_memdata,
	   alu_result_in	=> mem_wb_alu_result,
	   RegWrite_in		=> mem_wb_regwrite,
	-- out
	   write_data		=> wb_decode_writedata,
	   write_reg_addr	=> wb_decode_writereg,	
	   write_reg		=> wb_decode_regwrite);
  
  Mips_Hazard_ins : Mips_Hazard
	port map(
	-- in
	   clk				=> clk,
	   rst				=> rst,

	   opcode			=> decode_hazard_opcode,
	   branch			=> exec_branch,
	   execute_lw		=> exec_lw,
	   lw_reg_dst		=> exec_mem_regdst,
	   reg1			    => decode_exec_reg1_num,
	   reg1_valid		=> decode_reg1_valid,
       reg2				=> decode_exec_reg2_num,
       reg2_valid		=> decode_reg2_valid,

	-- out
		bubble          => hazard_decode_bubble,
	   decode_flush		=> hazard_decode_flush,
	   load_pc			=> hazard_fetch_pc_load,
	   empty_instr		=> hazard_fetch_empty_instr);
  
  Mips_Forwarding_ins : Mips_Forwarding
	port map(
	-- from execute
	   forw1_reg		=> exec_forw_reg1_num,
	   forw2_reg		=> exec_forw_reg2_num,
	   exec_reg1_data	=> exec_forw_readdata1,
	   exec_reg2_data	=> exec_forw_readdata2,

	-- from memory stage
	   mem_dst_reg		=> mem_wb_regdst,
	   mem_write_reg   	=> mem_wb_regwrite,
	   mem_alu_result	=> mem_wb_alu_result,

	-- from write back stage
	   wb_dst_reg		=> wb_decode_writereg,
	   wb_write_reg   	=> wb_decode_regwrite,
	   wb_data			=> wb_decode_writedata,

	-- out
	   forw_data1	    => forw_exec_forw_data1,
	   forw_data2	    => forw_exec_forw_data2);
end bhv;












