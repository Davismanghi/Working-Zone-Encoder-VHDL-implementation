
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.03.2020 16:08:14
-- Design Name: 
-- Module Name: 10627074_10570485 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    port(
        i_clk: in STD_LOGIC;
        i_start: in STD_LOGIC;
        i_rst: in STD_LOGIC;
        i_data: in STD_LOGIC_VECTOR(7 downto 0);
        o_address: out STD_LOGIC_VECTOR(15 downto 0);
        o_done: out STD_LOGIC;
        o_en: out STD_LOGIC;
        o_we: out STD_LOGIC;
        o_data: out STD_LOGIC_VECTOR(7 downto 0)
        );
        
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

signal found, found_next : STD_LOGIC;
signal regoffset, regoffset_next: STD_LOGIC_VECTOR(3 downto 0);
signal regnumwz, regnumwz_next: STD_LOGIC_VECTOR(3 downto 0);
signal regwz, regwz_next: STD_LOGIC_VECTOR(7 downto 0);
signal regwzen, regwzen_next : STD_LOGIC;
signal regind, regind_next  : STD_LOGIC_VECTOR(7 downto 0);
signal reginden, reginden_next : STD_LOGIC;
--signal regwzwrote, regwzwrote_next: STD_LOGIC;

type state_type is (BEGINNING, WRITEADDR, WRITEWZANDCALC,WRITEMODIFIEDADDR, DONE);
signal state_reg, state_next : state_type;

signal o_done_next, o_en_next, o_we_next : std_logic := '0';
signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
signal o_address_next : std_logic_vector(15 downto 0) := "0000000000000000";

begin
    process (i_clk, i_rst) 
    begin
        if (i_rst = '1') then
        
            found <= '0';
            regoffset <= "0000";
            regnumwz <= "0000";
            regwz <= "10000000";
			regind <= "00000000";
			reginden <= '0'; --1
			regwzen <= '0';  --1
			--regwzwrote <= '0';
			
			state_reg <= BEGINNING;
			
        elsif (i_clk'event and i_clk='1') then
            o_done <= o_done_next;
            o_en <= o_en_next;
            o_we <= o_we_next;
            o_data <= o_data_next;
            o_address <= o_address_next;
            regnumwz <= regnumwz_next;
            found <= found_next;
            regind <= regind_next;
            reginden <= reginden_next;
			regwzen <= regwzen_next;
			regoffset <= regoffset_next;
			regwz <= regwz_next;
			--regwzwrote <= regwzwrote_next;
			 
            state_reg <= state_next;
        end if;
    end process;
    
    process(state_reg, i_data, i_start, reginden, regind, regwzen, regwz, regnumwz, regoffset, found)
    begin
        --regwzwrote_next <= '0'; --
        found_next <= '0';
        o_done_next <= '0';
        o_en_next <= '0';
        o_we_next <= '0';
        o_data_next <= "00000000";
        o_address_next <= "0000000000000000";
        regnumwz_next <= "0000";
        regind_next <= "00000000";
        reginden_next <= '0';
	    regwzen_next <= '0';
	    regoffset_next <= "0000";
        regwz_next <= "10000000";
        
        state_next <= state_reg;
        
        case state_reg is
            when BEGINNING =>
                if (i_start = '1') then
                    regnumwz_next <= "0000";
                    o_we_next <= '0';
                    o_en_next <= '1';
                    o_address_next <= "0000000000001000";  
                    reginden_next <= '1';
                    if(reginden = '1') then
                        state_next <= WRITEADDR; 
                    end if;     
                end if;
                
            when WRITEADDR =>
                o_en_next <= '1';                   --per eliminare abbassamento enable
                reginden_next <= '1';
                if(reginden = '1') then
                    regind_next <= i_data;
                    regwzen_next <= '1';
                    if(regwzen = '1') then
                        o_we_next <= '0';
                        o_en_next <= '1';
                        o_address_next <= "0000000000000000"; --1
                        reginden_next <= '1'; --
                        regnumwz_next <= "0000";
                        regind_next <= regind;
                        state_next <= WRITEWZANDCALC;
                    end if;
                end if;
                
            when WRITEWZANDCALC =>
            regwzen_next <= '1';
                if(regwzen = '1' and reginden = '0') then
                    --regwzwrote_next <= '1';
                    regwz_next <= i_data;
                end if;
                if(regwz - regind = "00000000") then
                    --if(regwzwrote = '1') then
                    o_address_next <= "0000000000001001";
                    found_next <= '1';
                    regnumwz_next <= regnumwz - "0010"; -- -0001
                    regoffset_next <= "0001";
                    o_we_next <= '0';  
                    o_en_next <= '1';
                    state_next <= WRITEMODIFIEDADDR;
                    --end if;
                    
                elsif((regwz + "00000001") - regind = "00000000") then
                    --if(regwzwrote = '1') then
                    o_address_next <= "0000000000001001";
                    found_next <= '1';
                    regnumwz_next <= regnumwz - "0010";
                    regoffset_next <= "0010";
                    o_we_next <= '0';   
                    o_en_next <= '1';
                    state_next <= WRITEMODIFIEDADDR;
                    --end if;
                
                elsif((regwz + "00000010") - regind = "00000000") then
                    --if(regwzwrote = '1') then
                    o_address_next <= "0000000000001001";
                    found_next <= '1';
                    regnumwz_next <= regnumwz - "0010";
                    regoffset_next <= "0100";
                    o_we_next <= '0';   
                    o_en_next <= '1';
                    state_next <= WRITEMODIFIEDADDR;
                    --end if;
                
                elsif((regwz + "00000011") - regind = "00000000") then
                    --if(regwzwrote = '1') then
                    o_address_next <= "0000000000001001";
                    found_next <= '1';
                    regnumwz_next <= regnumwz - "0010";
                    regoffset_next <= "1000";
                    o_we_next <= '0';      
                    o_en_next <= '1';
                    state_next <= WRITEMODIFIEDADDR;
                    --end if;
                else
                    o_en_next <= '1';                  
                    if(regnumwz = "1001") then     --1000
                        found_next <= '0';
                        o_we_next <= '0'; 
                        o_address_next <= "0000000000001001";
                        regind_next <= regind;
                        state_next <= WRITEMODIFIEDADDR;
                    else
                        if(state_next /= WRITEMODIFIEDADDR) then
                        o_we_next <= '0';      
                        --if(reginden = '0' and regwzen = '1') then                  --
                        regnumwz_next <= regnumwz + "0001";                                         
                        o_address_next <= "000000000000"&(regnumwz + "0001");        --0010
                        --end if;                                                    --
                       
            --            if(regnumwz_next = "001") then
            --                o_address_next <= "0000000000000001";
            --            elsif(regnumwz_next = "010") then
            --                o_address_next <= "0000000000000010";
            --            elsif(regnumwz_next = "011") then
            --                o_address_next <= "0000000000000011";
            --            elsif(regnumwz_next = "100") then
            --               o_address_next <= "0000000000000100";
            --            elsif(regnumwz_next = "101") then
            --                o_address_next <= "0000000000000101";
            --            elsif(regnumwz_next = "110") then
            --                o_address_next <= "0000000000000110";
            --           elsif(regnumwz_next = "111") then
            --               o_address_next <= "0000000000000111";
            --           end if;
                        regind_next <= regind;
                        state_next <= WRITEWZANDCALC;
                        end if;
                    end if;
                end if;
                
            when WRITEMODIFIEDADDR =>
                o_we_next <= '1';
                o_en_next <= '1';
                o_address_next <= "0000000000001001";
                if(found = '0') then
                    o_data_next <= regind;
                elsif(found = '1') then
                    o_data_next <= '1'&(regnumwz(2 downto 0))&regoffset; --regnumwz - "001"
                end if;
                if(i_start = '1') then
                    state_next <= DONE;
                end if;
                
             when DONE =>
                o_done_next <= '1';
                found_next <= '0';
                regoffset_next <= "0000";
                regnumwz_next <= "0000";
                regwz_next <= "10000000";
		        regind_next <= "00000000";
		        reginden_next <= '0';
		        regwzen_next <= '0';
		        if(i_start = '0') then
		            o_done_next <= '0';
                    state_next <= BEGINNING;
                else
                    state_next <= DONE;
                end if;
                
        end case;
    end process;

end Behavioral;
