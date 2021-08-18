`ifndef TOP_ENV_SV
`define TOP_ENV_SV

class top_env extends uvm_env;
  
  // registration macro
  `uvm_component_utils(top_env)

  // configuration reference
  top_env_cfg m_cfg;
    
  // component instance
  uvc_env m_uvc_env;
  scoreboard m_scoreboard;
  
  // constructor
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  // connect phase
  extern virtual function void connect_phase(uvm_phase phase);  
endclass : top_env

// constructor
function top_env::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

// build phase
function void top_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  // get configuration
  if(!uvm_config_db #(top_env_cfg)::get(this, "", "m_cfg", m_cfg)) begin
    `uvm_fatal(get_type_name(), "Failed to get configuration object from config DB!")
  end

  // set configuration
  uvm_config_db#(uvc_cfg)::set(this, "m_uvc_env", "m_cfg", m_cfg.m_uvc_cfg);

  // create component
  m_uvc_env = uvc_env::type_id::create("m_uvc_env", this);
  
  // create scoreboard
  m_scoreboard = scoreboard::type_id::create("m_scoreboard", this);
  
endfunction : build_phase

//connect phasae
function void top_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  // Connection between monitors and scoreboard
  m_uvc_env.m_master_agent.m_aport.connect(m_scoreboard.m_ain_aexport);
  m_uvc_env.m_slave_agent.m_aport.connect(m_scoreboard.m_aout_aexport);
endfunction : connect_phase


`endif // TOP_ENV_SV
