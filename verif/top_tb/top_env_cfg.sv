`ifndef TOP_ENV_CFG_SV
`define TOP_ENV_CFG_SV

class top_env_cfg extends uvm_object;
    
  // UVC configuration
  uvc_cfg m_uvc_cfg;
  
  // registration macro
  `uvm_object_utils_begin(top_env_cfg)
    `uvm_field_object(m_uvc_cfg, UVM_ALL_ON)
  `uvm_object_utils_end
    
  // constructor
  extern function new(string name = "top_env_cfg");
  
endclass : top_env_cfg

// constructor
function top_env_cfg::new(string name = "top_env_cfg");
  super.new(name);
  
  // create UVC configuration
  m_uvc_cfg = uvc_cfg::type_id::create("m_uvc_cfg");
endfunction : new

`endif // TOP_ENV_CFG_SV
