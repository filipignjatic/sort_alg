`ifndef UVC_CFG_SV
`define UVC_CFG_SV

class uvc_cfg extends uvm_object;

  // agents configurations
  agent_cfg m_master_agent_cfg;
  agent_cfg m_slave_agent_cfg;
  
  // uvc configuration fields
  int has_master_agent;
  int has_slave_agent;
  
  // registration macro
  `uvm_object_utils_begin(uvc_cfg)
    `uvm_field_object(m_master_agent_cfg, UVM_ALL_ON)
    `uvm_field_object(m_slave_agent_cfg, UVM_ALL_ON)
    `uvm_field_int(has_master_agent, UVM_ALL_ON)
    `uvm_field_int(has_slave_agent, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // constructor   
  extern function new(string name = "uvc_cfg");
    
endclass : uvc_cfg

// constructor
function uvc_cfg::new(string name = "uvc_cfg");
  super.new(name);

  // create agents configurations
  m_master_agent_cfg = agent_cfg::type_id::create("m_master_agent_cfg");
  m_slave_agent_cfg = agent_cfg::type_id::create("m_slave_agent_cfg");
endfunction : new

`endif // UVC_CFG_SV
