library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity EU is
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
end EU;

architecture Behavioral of EU is

signal ALUin: std_logic_vector(15 downto 0);
signal ALUCtrl: std_logic_vector(2 downto 0);
signal temp: std_logic_vector(15 downto 0);

begin
    
BranchAddress <= PCNext + Ext_Imm;

-- MUX    
process(ALUSrc)
begin
    case(ALUSrc)is
        when '0' => ALUin <= ReadData2;
        when others => ALUin <= Ext_Imm;
    end case;
end process;
    
-- ALU Control
process(ALUOp, func)
begin
    case(ALUOp) is
        when "000" => ALUCtrl <= func;  -- R-Type
        when "001" => ALUCtrl <= "000"; -- ADDI does addition
        when "100" => ALUCtrl <= "001"; -- BEQ does subtraction
        when "101" => ALUCtrl <= "100"; -- ANDI
        when "110" => ALUCtrl <= "101"; -- ORI
        when others => ALUCtrl <= "XXX";
    end case;
end process;

-- ALU
process(ALUCtrl, ReadData1, ALUin)
begin
    case(ALUCtrl) is
        when "000" => temp <= ReadData1 + ALUin;
        when "001" => temp <= ReadData1 - ALUin;
        when "010" => temp <= ALUin(14 downto 0) & "0";
        when "011" => temp <= "0" & ALUin(15 downto 1);
        when "100" => temp <= ReadData1 and ALUin;
        when "101" => temp <= ReadData1 or ALUin;
        when "110" => temp <= ReadData1 xor ALUin;
        when "111" => temp <= ReadData1 sll conv_integer(ALUin);
    end case;
end process;
ALURes <= temp;

-- Zero
Zero <= '1' when temp = x"0000" else '0';

end Behavioral;
