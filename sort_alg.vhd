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
  signal data : data_array := (others => (others => '0'));
   -- States for FSM
  type state_type is (idle,drive_tready, collect_done, assign_first, assign_second, compare, swap_first_addr, swap_first_data, swap_second_addr, swap_second_data, check, increment, drive_tvalid,  drive_tdata);
  signal curr_state, next_state: state_type;
  -- Local signals
  signal i, j: integer := 0; -- Increment integers
  signal counter, addr: integer range 0 to 1023; -- field for number of transactions
  signal tmp_i, tmp_j, mem_data: std_logic_vector(15 downto 0); -- Signals for temp values of data(i) and data(i+1)
  -- Local signals for driving data
  signal write_en, read_en, start_counter,  drive_done: std_logic;
   
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
            if(write_en = '1') then
                data(addr) <= mem_data;
            -- driving data
            elsif(read_en = '1') then
                aout_tdata <= data(counter);
            end if;
        end if;
    end process;
    
    COUNT: process(clk) is 
    begin
        if(rising_edge(clk)) then
            if(start_counter = '1') then
                counter <= counter + 1;
            end if;
            
            if(ain_tlast = '1') then -- Block for decrement counter for one, makeing it right
                counter <= counter - 1;
            end if;
            
            if(read_en = '1') then
                if(counter /= 0) then
                    counter <= counter -1;
                else
                    drive_done <= '1';
                end if;
            end if;
        end if;
    end process;
      
    
    FSM:process(curr_state, ain_tlast, ain_tvalid, drive_done, ain_tdata) is
    begin
    case curr_state is
        when idle =>
            aout_tlast <= '0';
            aout_tvalid <= '0';
            tmp_i <= (others => '0');
            tmp_j <= (others => '0');
            read_en <= '0';
            write_en <= '0';
            if(ain_tvalid = '1') then
                next_state <= drive_tready;
            end if;
        when drive_tready =>
            if(ain_tlast = '1') then
                mem_data <= ain_tdata;
                start_counter <= '0';
                next_state <= collect_done;
            else
                write_en <= '1';
                ain_tready <= '1';
                mem_data <= ain_tdata;
                addr <= counter;
                start_counter <= '1';
                next_state <= drive_tready;
            end if;
        when collect_done =>
                ain_tready <= '0';
                write_en <= '0';
                next_state <= assign_first;
        when assign_first =>
           tmp_i <= data(i);
           next_state <= assign_second;
        when assign_second =>
           tmp_j <= data(i+1);
           next_state <= compare;
        when compare =>
            if(tmp_i < tmp_j) then
                next_state <= swap_first_addr;
            else
                next_state <= increment;
            end if;
        when swap_first_addr =>
            addr <= i+1;
            next_state <= swap_first_data;
        when swap_first_data =>
            mem_data <= tmp_i;
            write_en <= '1';
            next_state <= swap_second_addr;
        when swap_second_addr =>
            addr <= i;
            write_en <= '0';
            next_state <= swap_second_data;
        when swap_second_data =>
            mem_data <= tmp_j;
            write_en <= '1';
            next_state <= increment;
        when increment =>
            write_en <= '0';
            if(j /= counter-2) then
                i <= i+1;
                next_state <= check;
            else
                next_state <= drive_tvalid;
            end if;
            if(i = counter-2) then
                j <= j+1;
            end if;
        when check =>
                if(i = counter-1) then
                    i <= 0;
                    next_state <= assign_first;
                else
                    next_state <= assign_first;
                end if;
        when drive_tvalid =>
            aout_tvalid <= '1';
            next_state <= drive_tdata;
        when drive_tdata =>
            read_en <= '1';
            if(drive_done = '1') then
                aout_tlast <= '1';
                next_state <= idle;
            else
                next_state <= drive_tdata;
            end if;
    end case;
    end process;
end rtl;
