library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity sort_alg is

  port (
    rst : in std_logic;
    clk      : in std_logic;
 
    -- Inputs
    ain_tvalid   : in  std_logic;
    aout_tready  : in std_logic;
    ain_tdata 	 : in  std_logic_vector(15 downto 0);
    ain_tlast    : in  std_logic;
 
    -- Outputs
   	aout_tvalid  : out std_logic;
    ain_tready	 : out  std_logic;
    aout_tdata   : out std_logic_vector(15 downto 0);
    aout_tlast   : out std_logic
    );
end sort_alg;
 
architecture rtl of sort_alg is
  -- Memory
  type data_array is array (0 to 1023) of std_logic_vector(15 downto 0); -- max number of transactions is 1024
  signal data, sort_data : data_array := (others => (others => '0'));
   -- States for FSM
  type state_type is (idle,drive_tready, collect_done, transfer, increment_t, assign, compare, check, increment, drive_tvalid,  drive_tdata); -- need to be edited
  signal curr_state, next_state: state_type;
  -- Local signals
  signal i, j, d, x: integer := 0; -- Increment integers
  signal count: integer range 0 to 1023; -- field for number of transactions
  signal tmp_i, tmp_j, mem_data: std_logic_vector(15 downto 0); -- Signals for temp values of data(i) and data(i+1)
  -- Local signals for driving data
  signal write_en, drive_done: std_logic;
   
  begin
  
  
  
    FSM_PROC:process(clk, rst) is
    begin
        if(rst = '1') then
            curr_state <= idle;
        elsif(rising_edge(clk)) then
            curr_state <= next_state;
        end if;
    end process;
    
  	MEMORY_PROC:process(clk) is 
    begin
        if(rising_edge(clk)) then
            -- collecting data
            if(write_en = '1' and ain_tlast = '0') then
                data(count) <= mem_data;
                count <= count + 1;
                drive_done <= '0';
            end if;
            -- driving data
            if(write_en = '0' and aout_tready = '1') then
                   if(d /= count-1) then
                       aout_tdata <= data(d);
                       d <= d + 1;
                       drive_done <= '0';
                   else
                        aout_tdata <= data(d);
                        drive_done <= '1';
                   end if; 
            end if;
        end if;
    end process;
    
    
     process(curr_state, ain_tdata, ain_tlast, ain_tvalid, drive_done) is
    begin
    case curr_state is
        when idle =>
            aout_tlast <= '0';
            aout_tvalid <= '0';
            tmp_i <= (others => '0');
            tmp_j <= (others => '0');
            sort_data <= (others => (others => '0'));
            if(ain_tvalid = '1') then
                next_state <= drive_tready;
            end if;
        when drive_tready =>
                ain_tready <= '1';
                next_state <= collecting;
        when collecting =>
            if(ain_tlast = '1') then
                next_state <= collect_done;
            else
              mem_data <= ain_tdata;
              write_en <= '1';
              next_state <= collecting;
        when collect_done =>
                ain_tready <= '0';
                write_en <= '0';
                next_state <= assign_first;
        when assign_first =>
           tmp_i <= sort_data(i);
           next_state <= assign_second;
        when assign_second =>
           tmp_j <= sort_data(i+1);
        when compare =>
            if(tmp_i > tmp_j) then
              swap <= '1';
                sort_data(i+1) <= tmp_i;
                sort_data(i) <= tmp_j;
                next_state <= swap_temp_i;
            else
               swap <= '0';
                next_state <= increment;
            end if;
        when swap_temp_i =>
             mem_state <= temp_i;
             next_state <= swap_temp_j;
        when swap_temp_j =>
             mem_state <= temp_j;
        when increment =>
            if(j /= count-2) then
                i <= i+1;
                next_state <= check;
            else
                next_state <= drive_tvalid;
            end if;
            if(i = count-2) then
                j <= j+1;
            end if;
        when check =>
                if(i = count-1) then
                    i <= 0;
                    next_state <= assign;
                else
                    next_state <= assign;
                end if;
        when drive_tvalid =>
            aout_tvalid <= '1';
            next_state <= drive_tdata;
        when drive_tdata =>
            if(drive_done = '1') then
                next_state <= idle;
                aout_tlast <= '1';
            end if;
    end case;
    end process;
end rtl;
