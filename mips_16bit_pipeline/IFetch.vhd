library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity IFetch is
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
end IFetch;

architecture Behavioral of IFetch is

----------ROM Memory----------
type rom_type is array (0 to 255) of std_logic_vector(15 downto 0);
signal ROM: rom_type := (
                            b"000_001_010_011_0_000", -- 0 -- 0530 -- add $3, $1, $2
                            
                            b"000_000_0000000000", -- 1 -- addi $0, $0, 0 -- NoOp 
                            b"000_000_0000000000", -- 2 -- addi $0, $0, 0 -- NoOp 
                            
                            b"011_101_011_0000101", -- 3 -- 7585 -- sw $3, 5($4)
                            b"011_011_010_0001010",-- 4 -- 6D0A -- sw $2, 10($3)
                            
                            b"000_000_0000000000", -- 5 -- addi $0, $0, 0 -- NoOp 
                            b"000_000_0000000000", -- 6 -- addi $0, $0, 0 -- NoOp 
                            
                            b"010_011_001_0001010",-- 7 -- 4C8A -- lw $1, 10($3)
                            b"010_110_010_0000101",-- 8 -- 5905 -- lw $2, 5($6)
                            b"001_100_100_0000001",-- 9 -- 3201 -- addi $4, $4, 1
                            
                            b"000_000_0000000000", -- 10 -- addi $0, $0, 0 -- NoOp 
                            b"000_000_0000000000", -- 11 -- addi $0, $0, 0 -- NoOp 
                            
                            b"100_111_100_0000100",-- 12 -- 9E04 -- beg $4, $7, 4
                            
                            b"000_000_0000000000", -- 13 -- addi $0, $0, 0 -- NoOp 
                            b"000_000_0000000000", -- 14 -- addi $0, $0, 0 -- NoOp 
                            b"000_000_0000000000", -- 15 -- addi $0, $0, 0 -- NoOp  
                            
                            b"111_0000000000000",-- 16 -- E000 -- j 0

                            others=>x"0000" -- others
                        );

signal PCounter: std_logic_vector(15 downto 0);
signal BranchMUXOut: std_logic_vector(15 downto 0); -- can be pc+1 or branch address
signal JumpMUXOut: std_logic_vector(15 downto 0); -- can be branchMuxOut or jump address
signal PCPlus1: std_logic_vector(15 downto 0);

begin

   ----------Program counter----------
   process(clk, reset)
   begin
        if reset = '1' then
            PCounter <= x"0000";
        elsif rising_edge(clk) then
            if WE = '1' then
                PCounter <= JumpMUXOut;
            end if;
        end if;
   end process;
   
   ----------MUX Branch----------
   process(PCSrc, BranchAddress, PCPlus1)
   begin
        case(PCSrc) is
            when '0' => BranchMUXOut <= PCPlus1;
            when '1' => BranchMUXOut <= BranchAddress;
        end case;
    end process;
    
    ----------MUX Jump----------
    process(Jump, JumpAddress, BranchMUXOut)
    begin
        case(Jump) is
            when '0' => JumpMUXOut <= BranchMUXOut;
            when '1' => JumpMUXOut <= JumpAddress;
        end case;
    end process;
    
    Instruction <= ROM(conv_integer(PCounter));    
    PCPlus1 <= PCounter + 1;
    
    PC <= PCPlus1;
    
end Behavioral;