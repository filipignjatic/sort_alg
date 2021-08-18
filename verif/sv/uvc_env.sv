`ifndef UVC_ENV_SV
`define UVC_ENV_SV

class uvc_env extends uvm_env;
  
  // registration macro
  `uvm_component_utils(uvc_env)
  
  // configuration instance
  uvc_cfg m_cfg;

  // agents instances
  master_agent m_master_agent;
  slave_agent m_slave_agent;
  
  // constructor
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  
endclass : uvc_env

// constructor
function uvc_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

// build phase
function void uvc_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  // get configuration
  if(!uvm_config_db #(uvc_cfg)::get(this, "", "m_cfg", m_cfg)) begin
    `uvm_fatal(get_type_name(), "Failed to get configuration object from config DB!")
  end 

  // set agents configurations
  if(m_cfg.has_master_agent == 1)
    uvm_config_db#(agent_cfg)::set(this, "m_master_agent", "m_cfg", m_cfg.m_master_agent_cfg);
  if(m_cfg.has_slave_agent == 1)
    uvm_config_db#(agent_cfg)::set(this, "m_slave_agent", "m_cfg", m_cfg.m_slave_agent_cfg); 
  
  // create agents
  if(m_cfg.has_master_agent == 1)
    m_master_agent = master_agent::type_id::create("m_master_agent", this);
  if(m_cfg.has_slave_agent == 1)
    m_slave_agent =  slave_agent::type_id::create("m_slave_agent", this);
 
  
endfunction : build_phase

`endif // UVC_ENV_SV
