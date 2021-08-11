library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity top_tb is
end entity top_tb;

architecture beh of top_tb is
    -- Clock and reset local signals
	signal clk_s: std_logic;
    signal rst_s: std_logic;
    
    -- Local signals for counter and decrement
    signal data_signal: std_logic_vector(15 downto 0) := "0000000000111111";
    signal counter: std_logic_vector(9 downto 0) := (others => '0');
    
    -- Inputs
    signal ain_tvalid_s: std_logic;
    signal aout_tready_s: std_logic;
    signal ain_tdata_s:  std_logic_vector ( 15 downto 0);
    signal ain_tlast_s:std_logic;
    
    -- outputs
    signal aout_tvalid_s: std_logic;
    signal ain_tready_s: std_logic;
    signal aout_tdata_s:  std_logic_vector ( 15 downto 0);
    signal aout_tlast_s:  std_logic;
    signal num_trans: std_logic_vector(9 downto 0);
    
    begin
    	dut: entity work.sort_alg(rtl)
        	port map( 
            	clk => clk_s,
                rst => rst_s, 
                ain_tvalid => ain_tvalid_s,
                ain_tready => ain_tready_s,
                ain_tdata => ain_tdata_s,
                ain_tlast => ain_tlast_s,
                aout_tvalid => aout_tvalid_s,
                aout_tready => aout_tready_s,
                aout_tdata => aout_tdata_s,
                aout_tlast => aout_tlast_s);
                
       	clk_gen: process
        begin
        	clk_s <= '0', '1' after 25 ns;
        	wait for 50 ns;
        end process;
        
        tready_send: process(clk_s)
        begin
            if(rising_edge(clk_s)) then
                if(aout_tvalid_s = '1') then
                    if(aout_tlast_s = '1') then
                        aout_tready_s <= '0';
                     else
                        aout_tready_s <= '1';
                    end if;
                else
                    aout_tready_s <= '0';
                end if;
            end if;
        end process;
        
        rst_gen: process
        begin
            rst_s <= '1', '0' after 100ns;
            wait;
        end process;
        
        
        
        decrement:process(clk_s) is
        begin
            if(rising_edge(clk_s)) then
                if(counter >= X"1" and ain_tvalid_s = '1') then
                    data_signal <= data_signal - 1;
                if(data_signal = X"0") then
                    data_signal <= X"00FF";
                end if;
                end if;
            end if;
        end process;
        
        stim_gen: process(clk_s) is
        begin
            if(rising_edge(clk_s)) then
                if(counter = X"0") then
                    ain_tvalid_s <= '0';
                    ain_tlast_s <= '0';
                    ain_tdata_s <= (others => '0');
                    counter <= counter + 1;
                elsif(counter = x"1") then
                    ain_tvalid_s <= '1';
                    counter <= counter + 1;
                elsif(counter < X"100" and counter > X"1") then
                    counter <= counter + 1;
                    ain_tdata_s <= data_signal;
                elsif(counter = X"100") then
                    counter <= counter + 1;
                    ain_tdata_s <= data_signal;
                    ain_tlast_s <= '1';
                else
                    ain_tvalid_s <= '0';
                    ain_tlast_s <= '0';
                end if;
            end if;
        end process;
end architecture beh;
