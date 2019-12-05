library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity saqwdf is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0)
           );
end saqwdf;

architecture Behavioral of saqwdf is

component debouncer is
    Port (  btn : in std_logic_vector (4 downto 0);
            clk : in std_logic;
            enable : out std_logic_vector (4 downto 0));
end component;

component display is
    Port(
        clk : in std_logic;
        digit0 : in std_logic_vector (3 downto 0);
        digit1 : in std_logic_vector (3 downto 0);
        digit2 : in std_logic_vector (3 downto 0);
        digit3 : in std_logic_vector (3 downto 0);
        an : out std_logic_vector (3 downto 0);
        cat : out std_logic_vector (6 downto 0)
        );
end component;

component IFetch is
    port(
        clk: in std_logic;
        BranchAddress: in std_logic_vector(15 downto 0);
        JumpAddress: in std_logic_vector(15 downto 0);
        PCSrc: in std_logic;
        Jump: in std_logic;
        reset: in std_logic;
        WE: in std_logic;
        Instruction: out std_logic_vector(15 downto 0);
        PC: out std_logic_vector(15 downto 0)
        );
end component;

component ID is
    Port (
        clk: in std_logic;
        Instr: in std_logic_vector(15 downto 0);
        WD: in std_logic_vector(15 downto 0);
        RegDst: in std_logic;
        RegWrite: in std_logic;
        ExtOp: in std_logic;
        RD1: out std_logic_vector(15 downto 0);
        RD2: out std_logic_vector(15 downto 0);
        ExtImm: out std_logic_vector(15 downto 0);
        func: out std_logic_vector(2 downto 0);
        sa: out std_logic
        );
end component;

component CU is
    Port (
            instr: in std_logic_vector(2 downto 0);
            RegDst: out std_logic;
            ExtOp: out std_logic;
            ALUSrc: out std_logic;
            Branch: out std_logic;
            Jump: out std_logic;
            ALUOp: out std_logic_vector(2 downto 0);
            MemWrite: out std_logic;
            MemToReg: out std_logic;
            RegWrite: out std_logic
            );
end component;

component EU is
    Port(
        PCNext: in std_logic_vector(15 downto 0);
        ReadData1: in std_logic_vector(15 downto 0);
        ReadData2: in std_logic_vector(15 downto 0);
        Ext_Imm: in std_logic_vector(15 downto 0);
        sa:  in std_logic;
        func: in std_logic_vector(2 downto 0);
        
        ALUSrc: in std_logic;
        ALUOp: in std_logic_vector(2 downto 0);
        
        BranchAddress: out std_logic_vector(15 downto 0);
        ALURes: out std_logic_vector(15 downto 0);
        
        Zero: out std_logic
        );
end component;

component MU is
    Port (
        clk: in std_logic;
        MemWrite: in std_logic;
        ALUResIn: in std_logic_vector(15 downto 0);
        WriteData: in std_logic_vector(15 downto 0);
        MemData: out std_logic_vector(15 downto 0);
        ALUResOut: out std_logic_vector(15 downto 0)
     );
end component;

signal buttons : std_logic_vector (4 downto 0);
signal digits : std_logic_vector (15 downto 0);

signal rd1 : std_logic_vector (15 downto 0);
signal rd2 : std_logic_vector (15 downto 0);
signal ExtUnit: std_logic_vector (15 downto 0);
signal func: std_logic_vector (2 downto 0);
signal sa: std_logic;
signal rw: std_logic;
signal mw: std_logic;

signal instr : std_logic_vector (15 downto 0);
signal PCOut : std_logic_vector (15 downto 0);

signal RegDst: std_logic;
signal ExtOp: std_logic;
signal ALUSrc: std_logic;
signal Branch: std_logic;
signal Jump: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);
signal MemWrite: std_logic;
signal MemToReg: std_logic;
signal RegWrite: std_logic;

signal zero: std_logic;
signal ALUResIn: std_logic_vector(15 downto 0);
signal ALURes: std_logic_vector(15 downto 0);
signal MemData: std_logic_vector (15 downto 0);
signal IDUwr: std_logic_vector(15 downto 0);
signal pcsrc: std_logic;
signal jmpaddr: std_logic_vector(15 downto 0);
signal branchAddress: std_logic_vector(15 downto 0);

begin

MPG: debouncer port map (
        btn => btn, 
        clk => clk, 
        enable => buttons
        );
        
ssd: display port map (
        clk => clk, 
        digit0 => digits(3 downto 0),
        digit1 => digits(7 downto 4), 
        digit2 => digits(11 downto 8),
        digit3 => digits(15 downto 12),
        an => an,
        cat => cat
        );

instr_fetch: IFetch port map(
        clk => clk,
        BranchAddress => branchAddress,
        JumpAddress => jmpaddr,
        PCSrc => pcsrc,
        Jump => Jump,
        reset => buttons(0),
        WE => buttons(1),
        Instruction => instr,
        PC => PCOut
    );
    
instr_dec: ID port map (
        clk => clk,
        Instr => instr,
        WD => IDUwr,
        RegDst => RegDst,
        RegWrite => rw,
        ExtOp => ExtOp,
        RD1 => rd1,
        RD2 => rd2,
        ExtImm => ExtUnit,
        func => func,
        sa => sa
    );
        
control_unit: CU port map (
        instr => instr(15 downto 13),
        RegDst => RegDst,
        ExtOp => ExtOp,
        ALUSrc => ALUSrc,
        Branch => Branch,
        Jump => Jump,
        ALUOp => ALUOp,
        MemWrite => MemWrite,
        MemToReg => MemToReg,
        RegWrite => RegWrite
    );

execution_unit: EU port map (
        PCNext => PCOut,
        ReadData1 => rd1,
        ReadData2 => rd2,
        Ext_Imm => ExtUnit,
        sa => sa,
        func => func,
        
        ALUSrc => ALUSrc,
        ALUOp => ALUOp,
        
        BranchAddress => branchAddress,
        ALURes => ALUResIn,
        
        Zero => zero
    );

memory_unit: MU port map (
        clk => clk,
        MemWrite => MemWrite,
        ALUResIn => ALUResIn,
        WriteData => rd2,
        MemData => MemData,
        ALUResOut => ALURes
    );
    
rw <= RegWrite and buttons(1);
mw <= MemWrite and buttons(1);
IDUwr <= ALURes when MemToReg = '0' else MemData;
pcsrc <= Branch and zero;
jmpaddr <= "000" & instr(12 downto 0);

process(sw(7 downto 5))
begin
    case sw(7 downto 5) is
        when "000" => digits <= instr;
        when "001" => digits <= PCOut;
        when "010" => digits <= rd1;
        when "011" => digits <= rd2;
        when "100" => digits <= ExtUnit;
        when "101" => digits <= ALUResIn;
        when "110" => digits <= MemData;
        when "111" => digits <= IDUwr;
    end case;
end process;

led(15) <= RegDst;
led(14) <= ExtOp;
led(13) <= ALUSrc;
led(12) <= Branch;
led(11) <= Jump;
led(10 downto 8) <= ALUOp;
led(7) <= MemWrite;
led(6) <= MemToReg;
led(5) <= RegWrite;

end Behavioral;