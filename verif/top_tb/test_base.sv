`ifndef TEST_BASE_SV
`define TEST_BASE_SV

class test_base extends uvm_test;

  // registration macro
  `uvm_component_utils(test_base)

  // component instance
  top_env m_top_env;

  // configuration instance
  top_env_cfg m_cfg;

  // sequence
  basic_seq m_seq;
  basic_seq s_seq;
  
  // constructor
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  // end_of_elaboration phase
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  // set default configuration
  extern virtual function void set_default_configuration();

endclass : test_base

// constructor
function test_base::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

// build phase
function void test_base::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  // create component
  m_top_env = top_env::type_id::create("m_top_env", this);

  // create and set configuration
  m_cfg = top_env_cfg::type_id::create("m_cfg", this);
  set_default_configuration();

  // set configuration in DB
  uvm_config_db#(top_env_cfg)::set(this, "m_top_env", "m_cfg", m_cfg);

  // define verbosity
  uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
  
  // create sequence
  m_seq = basic_seq::type_id::create("m_seq", this);
  s_seq = basic_seq::type_id::create("s_seq", this);
endfunction : build_phase

// end_of_elaboration phase
function void test_base::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);

  // allow additional time before stopping
  uvm_test_done.set_drain_time(this, 10us);
endfunction : end_of_elaboration_phase

// set default configuration
function void test_base::set_default_configuration();
  // define default configuration
  m_cfg.m_uvc_cfg.has_master_agent = 1;
  m_cfg.m_uvc_cfg.has_slave_agent = 1;
  // master configuration
  m_cfg.m_uvc_cfg.m_master_agent_cfg.m_is_active = UVM_ACTIVE;
  m_cfg.m_uvc_cfg.m_master_agent_cfg.m_has_coverage = 1;

  // slave configuration
  m_cfg.m_uvc_cfg.m_slave_agent_cfg.m_is_active = UVM_ACTIVE;
  m_cfg.m_uvc_cfg.m_slave_agent_cfg.m_has_coverage = 1;
endfunction : set_default_configuration

`endif // TEST_BASE_SV
