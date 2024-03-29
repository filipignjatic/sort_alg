library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
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
  signal data : data_array := (others => (others => '0'));
   -- States for FSM
  type state_type is (idle,collecting, collect_done, assign_first, assign_second, compare, swap_first_addr, swap_first_data, swap_second_addr, swap_second_data, increment, check, drive_tvalid,  drive_tdata);
  signal curr_state, next_state: state_type;
  -- Local signals
  signal cnt, tmp_counter, addr, i, j: std_logic_vector(9 downto 0) := (others => '0'); -- 10 bit to represent 1024 decima
  signal tmp_i, tmp_j, mem_data, out_mem_data: std_logic_vector(15 downto 0); -- Signals for temp values of data(i) and data(i+1)
  -- Local signals for driving data
  signal write_en, read_en, start_counter,  drive_done,transfer_tmp_i, transfer_tmp_j, cnt_check, tvalid_ready: std_logic;
   
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
            if(write_en = '1') then
                data(conv_integer(addr)) <= mem_data;
            end if;
            if(read_en = '1') then
                out_mem_data <= data(conv_integer(cnt));
            end if;
            if(transfer_tmp_i = '1') then
                tmp_i <= data(conv_integer(i));
            end if;
            if(transfer_tmp_j = '1') then
                tmp_j <= data(conv_integer(i+1));
            end if;
        end if;
    end process;
    
    COUNT: process(clk) is 
    begin
        if(rising_edge(clk)) then
            if(start_counter = '1') then
                cnt <= cnt + 1;
                tmp_counter <= tmp_counter + 1;
            end if;
            
            if(ain_tlast = '1' or drive_done = '1') then
                cnt <= (others => '0');
            end if;
            
            if(read_en = '1') then
                if(cnt < tmp_counter-1) then
                    cnt <= cnt + 1;
                    drive_done <= '0';
                else
                    drive_done <= '1';      
		    tmp_counter <= (others => '0');
                end if;
            end if;
            
            if(curr_state = idle) then
	      drive_done <= '0';
	    end if;
          end if;
    end process;
    
    
    INC_PROC: process(clk) is 
    begin
        if(rising_edge(clk)) then
            if(cnt_check = '1') then
                if(j /= tmp_counter-1) then
                    tvalid_ready <= '0';
                    i <= i + 1;
                    if(i = tmp_counter-2) then
                        i <= (others => '0');
                        j <= j + 1;
                    end if;
                else
                    j <= (others => '0');
                    tvalid_ready <= '1';
                end if;
            end if;
         end if;
    end process;
    
    FSM:process(curr_state, ain_tlast, ain_tvalid, drive_done, ain_tdata, tmp_i, tmp_j, cnt, i, aout_tready, tvalid_ready, out_mem_data) is
    begin
    aout_tvalid <= '0';
    read_en <= '0'; 
    write_en <= '0';
    transfer_tmp_j <= '0';
    transfer_tmp_i <= '0';
    start_counter <= '0';
    ain_tready <= '0';
    aout_tlast <= '0';
    mem_data <= (others => '0');
    aout_tdata <= (others => '0');
    addr <= (others => '0');
    cnt_check <= '0';
    case curr_state is
        when idle =>
            read_en <= '0';
            write_en <= '0';
            if(ain_tvalid = '1') then
                next_state <= collecting;
            else
                next_state <= idle;
            end if;
        when collecting =>
            if(ain_tlast = '1') then
                mem_data <= ain_tdata;
                addr <= cnt;
                next_state <= collect_done;
            else
                mem_data <= ain_tdata;
                addr <= cnt;
                next_state <= collecting;
            end if;
            start_counter <= '1';
            ain_tready <= '1';
            write_en <= '1';
        when collect_done =>
            next_state <= assign_first;
        when assign_first =>
           transfer_tmp_i <= '1';
           next_state <= assign_second;
        when assign_second =>
            transfer_tmp_j <= '1';
           next_state <= compare;
        when compare =>
            if(tmp_i > tmp_j) then
                next_state <= swap_first_addr;
            else
                next_state <= increment;
            end if;
        when swap_first_addr =>
            addr <= i+1;
            next_state <= swap_first_data;
        when swap_first_data =>
            addr <= i+1;
            mem_data <= tmp_i;
            write_en <= '1';
            next_state <= swap_second_addr;
        when swap_second_addr =>
            addr <= i;
            next_state <= swap_second_data;
        when swap_second_data =>
            addr <= i;
            mem_data <= tmp_j;
            write_en <= '1';
            next_state <= increment;
        when increment =>
            cnt_check <= '1';
            next_state <= check;
        when check =>
            if(tvalid_ready = '1') then
                next_state <= drive_tvalid;
                read_en <= '1';
            else
                next_state <= assign_first;
            end if;
        when drive_tvalid =>
            if(aout_tready = '1') then
                next_state <= drive_tdata;
                read_en <= '1';
            else
                next_state <= drive_tvalid;                            
            end if;
            aout_tvalid <= '1';
            aout_tdata <= out_mem_data;   
        when drive_tdata =>
            aout_tvalid <= '1';
            read_en <= '1';
            aout_tdata <= out_mem_data;
            if(drive_done = '1') then
                aout_tlast <= '1';
                next_state <= idle;
                read_en <= '0';
            else
                next_state <= drive_tdata;
            end if;
    end case;
    end process;
end rtl;
