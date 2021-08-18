`ifndef TEST_SORT_ALG_SV
`define TEST_SORT_ALG_SV

// example test
class test_sort_alg extends test_base;
  
  // registration macro
  `uvm_component_utils(test_sort_alg)

  rand int num_data;
  rand int trans_num;
  
  // constructor
  extern function new(string name, uvm_component parent);
  // run phase
  extern virtual task run_phase(uvm_phase phase);
  // set default configuration
  extern function void set_default_configuration();
  
endclass : test_sort_alg

// constructor
function test_sort_alg::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


// run phase
task test_sort_alg::run_phase(uvm_phase phase);
  super.run_phase(phase);  
  phase.raise_objection(this);    
  `uvm_info(get_type_name(), "TEST STARTED", UVM_LOW)
  
  trans_num = $urandom_range(1, 5);
  
  fork: slave
  begin
      forever begin
	    if(!s_seq.randomize()) begin
	      `uvm_fatal(get_type_name(), "Failed to randomize.")
	    end
	    s_seq.start(m_top_env.m_uvc_env.m_slave_agent.m_sequencer);
      end
  end
  join_none
  
  for(int i = 0; i < trans_num; i ++) begin
    num_data = $urandom_range(2, 15);
    if(!m_seq.randomize() with {num_data_s == num_data;}) begin
      `uvm_fatal(get_type_name(), "Failed to randomize.")
    end
    m_seq.start(m_top_env.m_uvc_env.m_master_agent.m_sequencer);
    @(negedge m_top_env.m_uvc_env.m_slave_agent.m_vif.aout_tlast);
    #100us;
  end
  phase.drop_objection(this);    
  `uvm_info(get_type_name(), "TEST FINISHED", UVM_LOW)
endtask : run_phase

// set default configuration
function void test_sort_alg::set_default_configuration();
  super.set_default_configuration();
endfunction : set_default_configuration

`endif // TEST_SORT_ALG_SV
