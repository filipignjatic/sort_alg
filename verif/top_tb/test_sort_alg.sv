`ifndef TEST_SORT_ALG_SV
`define TEST_SORT_ALG_SV

// example test
class test_sort_alg extends test_base;
  
  // registration macro
  `uvm_component_utils(test_sort_alg)
  
    //
  rand int num_data;
  rand int trans_num;
    
    covergroup master_num_data;
    option.per_instance = 1;
    cover_number_of_data_per_transaction : coverpoint num_data {
      bins one_hundred = {[0:100]};
      bins two_hundred = {[101:200]};
      bins three_hundred = {[201:300]};
      bins four_hundred = {[301:400]};
      bins five_hundred = {[401:500]};
      bins six_hundred = {[501:600]};
      bins seven_hundred = {[601:700]};
      bins eight_hundred = {[701:800]};
      bins nine_hundred = {[801:900]};
      bins one_thousend = {[901:1023]};
    }
  endgroup : master_num_data
  
  // constructor
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  // run phase
  extern virtual task run_phase(uvm_phase phase);
  // set default configuration
  extern function void set_default_configuration();
  
endclass : test_sort_alg

// constructor
function test_sort_alg::new(string name, uvm_component parent);
  super.new(name, parent);
  master_num_data = new();
  master_num_data.set_inst_name("m_master_num_data");
endfunction : new

// build phase
function void test_sort_alg::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

// run phase
task test_sort_alg::run_phase(uvm_phase phase);
  super.run_phase(phase);  
  phase.raise_objection(this);    
  `uvm_info(get_type_name(), "TEST STARTED", UVM_LOW)
  
  trans_num = $urandom_range(1, 50);
  #1us;
	
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
    num_data = $urandom_range(2, 1023);
    master_num_data.sample();
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
