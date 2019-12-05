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
                            b"000_100_011_010_0_000", -- 0 - 11A0 - add
                            b"000_100_011_010_0_001", -- 1 - 11A1 - sub
                            b"000_000_100_010_1_010", -- 2 - 022A - sll
                            b"000_000_100_010_1_011", -- 3 - 022B - srl
                            b"000_100_011_010_0_100", -- 4 - 11A4 - and
                            b"000_100_011_010_0_101", -- 5 - 11A5 - or
                            b"000_011_100_010_0_110", -- 6 - 0E26 - xor
                            b"000_011_100_010_0_111", -- 7 - 0E27 - sllv
                            
                            b"001_011_010_0000001", -- 8 - 2D01 - addi
                            b"010_011_101_0000001", -- 9 - 4E81 - lw
                            b"011_010_100_0000001", -- 10 - 6A01 - sw
                            b"100_011_010_0000001", -- 11 - 8D01 - beq
                            b"101_011_010_0000001", -- 12 - AD01 - andi
                            b"110_011_010_0000010", -- 13 - CD02 - ori
                            
                            b"111_0000000000011", -- 14 - E003 - jump
                            
                            others=>x"ABCD" -- others
                            );

signal PCounter: std_logic_vector(15 downto 0):= BranchAddress;
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
            when others => BranchMUXOut <= x"0000";
        end case;
    end process;
    
    ----------MUX Jump----------
    process(Jump, JumpAddress, BranchMUXOut)
    begin
        case(Jump) is
            when '0' => JumpMUXOut <= BranchMUXOut;
            when '1' => JumpMUXOut <= JumpAddress;
            when others => JumpMUXOut <= x"0000";
        end case;
    end process;
    
    Instruction <= ROM(conv_integer(PCounter(7 downto 0)));    
    PCPlus1 <= PCounter + '1';
    
    PC <= PCPlus1;
    
end Behavioral;