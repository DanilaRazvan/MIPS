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
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           
           rx : in STD_LOGIC;
           tx : out STD_LOGIC
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
        WA: in std_logic_vector(2 downto 0);
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

--LAB 11
component Tx_fsm is
    Port (
            CLK : in STD_LOGIC;
            RST : in STD_LOGIC;
            BAUD_EN : in STD_LOGIC;
            TX_DATA : in STD_LOGIC_VECTOR (7 downto 0);
            TX_EN : in STD_LOGIC;
            TX_RDY : out STD_LOGIC;
            TX : out STD_LOGIC
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

signal IF_ID: std_logic_vector(31 downto 0);
signal ID_EX: std_logic_vector(82 downto 0);
signal EX_MEM: std_logic_vector(55 downto 0);
signal MEM_WB: std_logic_vector(36 downto 0);

signal WriteAddress: std_logic_vector(2 downto 0);

--LAB 11
--signal baud_en: std_logic;
--signal tx_en: std_logic;
--signal baud_counter: std_logic_vector(13 downto 0) := (others => '0');
--signal tx_rdy: std_logic;

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
        BranchAddress => EX_MEM(51 downto 36),
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
        Instr => IF_ID(15 downto 0),
        WD => IDUwr,
        WA => MEM_WB(2 downto 0),
        RegWrite => rw,
        ExtOp => ExtOp,
        RD1 => rd1,
        RD2 => rd2,
        ExtImm => ExtUnit,
        func => func,
        sa => sa
    );
        
control_unit: CU port map (
        instr => IF_ID(15 downto 13),
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
        PCNext => ID_EX(73 downto 58),
        ReadData1 => ID_EX(57 downto 42),
        ReadData2 => ID_EX(41 downto 26),
        Ext_Imm => ID_EX(25 downto 10),
        sa => ID_EX(0),
        func => ID_EX(9 downto 7),
        
        ALUSrc => ID_EX(75),
        ALUOp => ID_EX(78 downto 76),
        
        BranchAddress => branchAddress,
        ALURes => ALUResIn,
        
        Zero => zero
    );

memory_unit: MU port map (
        clk => clk,
        MemWrite => mw,
        ALUResIn => EX_MEM(34 downto 19),
        WriteData => EX_MEM(18 downto 3),
        MemData => MemData,
        ALUResOut => ALURes
    );

--IF/ID
process(clk)
begin
    if(clk'event and clk = '1') then
        if(buttons(1) = '1') then
            IF_ID(31 downto 16) <= PCOut;
            IF_ID(15 downto 0) <= instr;
        end if;
    end if;
end process;

--ID/EX
process(clk)
begin
    if(clk'event and clk = '1') then
        if(buttons(1) = '1') then
            ID_EX(82) <= RegWrite; --WB
            ID_EX(81) <= MemToReg;
            ID_EX(80) <= MemWRite; --MEM
            ID_EX(79) <= Branch;
            ID_EX(78 downto 76) <= ALUOp; --EX
            ID_EX(75) <= ALUSrc;
            ID_EX(74) <= RegDst;
            ID_EX(73 downto 58) <= IF_ID(31 downto 16); --pc+1
            ID_EX(57 downto 42) <= rd1; --rd1
            ID_EX(41 downto 26) <= rd2; --rd2
            ID_EX(25 downto 10) <= ExtUnit; --ext_unit
            ID_EX(9 downto 7) <= func; --funct
            ID_EX(6 downto 4) <= IF_ID(9 downto 7); --rt
            ID_EX(3 downto 1) <= IF_ID(6 downto 4); --rd
            ID_EX(0) <= sa; --sa
        end if;
    end if;
end process;

-- MUX
process(ID_EX(74), ID_EX(6 downto 4), ID_EX(3 downto 1))
begin
    case (ID_EX(74)) is
        when '0' => WriteAddress <= ID_EX(6 downto 4);
        when '1' => WriteAddress <= ID_EX(3 downto 1);
    end case;
end process;

--EX/MEM
process(clk)
begin
    if(clk'event and clk = '1') then
        if(buttons(1) = '1') then
            EX_MEM(55) <= ID_EX(82);
            EX_MEM(54) <= ID_EX(81);
            EX_MEM(53) <= ID_EX(80);
            EX_MEM(52) <= ID_EX(79);
            EX_MEM(51 downto 36) <= branchAddress;
            EX_MEM(35) <= zero;
            EX_MEM(34 downto 19) <= ALUResIn;
            EX_MEM(18 downto 3) <= ID_EX(41 downto 26);
            EX_MEM(2 downto 0) <= WriteAddress;
        end if;
    end if;
end process;

--MEM/WB
process(clk)
begin
    if(clk'event and clk = '1') then
        if(buttons(1) = '1') then
            MEM_WB(36) <= EX_MEM(55);
            MEM_WB(35) <= EX_MEM(54);
            MEM_WB(34 downto 19) <= MemData;
            MEM_WB(18 downto 3) <= ALURes;
            MEM_WB(2 downto 0) <= EX_MEM(2 downto 0);
        end if;
    end if;
end process;

    
rw <= MEM_WB(36) and buttons(1);
mw <= EX_MEM(53) and buttons(1);
IDUwr <= MEM_WB(18 downto 3) when MEM_WB(35) = '0' else MEM_WB(34 downto 19);
pcsrc <= EX_MEM(52) and EX_MEM(35);
jmpaddr <= "000" & IF_ID(12 downto 0);

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


-- LAB11 --

--process(clk)
--begin
--    if(rising_edge(clk)) then
--        if(baud_counter = "10100010110000") then
--            baud_counter <= "00000000000000";
--            baud_en <= '1';
--        else
--            baud_en <= '0';
--            baud_counter <= baud_counter + 1;
--        end if;
--    end if;
--end process;

--process(clk, baud_en, buttons(1))
--begin
--    if(rising_edge(clk)) then
--        if(buttons(1) = '1') then
--            tx_en <= '1';
--        end if;
        
--        if(baud_en = '1') then
--            tx_en <= '0';
--        end if;
--    end if;
--end process;

--label1: tx_fsm port map (
--        CLK => clk,
--        RST => '0',
--        BAUD_EN => baud_en,
--        TX_DATA => sw(7 downto 0),
--        TX_EN => tx_en,
--        TX_RDY => tx_rdy,
--        TX => tx
--);

end Behavioral;