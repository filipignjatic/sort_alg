library ieee;
use ieee.std_logic_1164.all;

entity top_tb is
end entity top_tb;

architecture beh of top_tb is
	signal clk_s: std_logic;
    signal rst_s: std_logic;
    
    signal ain_tvalid_s: std_logic;
    signal ain_tready_s: std_logic;
    signal ain_tdata_s:  std_logic_vector ( 15 downto 0);
    signal ain_tlast_s:std_logic;
    
    -- outputs
    signal aout_tvalid_s: std_logic;
    signal aout_tready_s: std_logic;
    signal aout_tdata_s:  std_logic_vector ( 15 downto 0);
    signal aout_tlast_s:  std_logic;
    
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
                    aout_tready_s <= '1';
                else
                    aout_tready_s <= '0';
                end if;
            end if;
        end process;
        
        stim_gen: process
        begin
        ain_tvalid_s <= '0';
        ain_tlast_s <= '0';
        rst_s <= '1';
        ain_tdata_s <= (others => '0');
        wait for 50 ns;
        rst_s <= '0';
        wait for 100ns;
        ain_tvalid_s <= '1';
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"C";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"5";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"4";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"8";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"2";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"A";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"9";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"4";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"8";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"2";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"A";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"9";
        ain_tdata_s (15 downto 4) <= (others => '0');
        wait until rising_edge(clk_s);
        ain_tdata_s (3 downto 0) <= x"1";
        ain_tdata_s (15 downto 4) <= (others => '0');
        ain_tlast_s <= '1';
        wait until rising_edge(clk_s);
        ain_tlast_s <= '0';
        ain_tvalid_s <= '0';
        wait;
        end process;
end architecture beh;
