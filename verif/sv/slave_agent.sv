`ifndef SLAVE_AGENT_SV
`define SLAVE_AGENT_SV

class slave_agent extends uvm_agent;
  
  // registration macro
  `uvm_component_utils(slave_agent)
  
  // analysis port
  uvm_analysis_port #(trans_item) m_aport;
    
  // virtual interface reference
  virtual interface uvc_interface m_vif;
      
  // configuration reference
  agent_cfg m_cfg;
  
  // components instances
  slave_monitor m_monitor;
  slave_driver m_driver;
  uvc_sequencer m_sequencer;
  slave_cov m_cov;
  // constructor
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  // connect phase
  extern virtual function void connect_phase(uvm_phase phase);
  // print configuration
  extern virtual function void print_cfg();

endclass : slave_agent

// constructor
function slave_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

// build phase
function void slave_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  // create ports
  m_aport = new("m_aport", this);
  
  // get interface
  if(!uvm_config_db#(virtual uvc_interface)::get(this, "", "m_vif", m_vif)) begin
    `uvm_fatal(get_type_name(), "Failed to get virtual interface from config DB!")
  end
  
  // get configuration
  if(!uvm_config_db #(agent_cfg)::get(this, "", "m_cfg", m_cfg)) begin
    `uvm_fatal(get_type_name(), "Failed to get configuration object from config DB!")
  end else begin
    print_cfg();
  end
    
  // create components
  if (m_cfg.m_is_active == UVM_ACTIVE) begin
    m_driver = slave_driver::type_id::create("m_driver", this);
    m_sequencer = uvc_sequencer::type_id::create("m_sequencer", this);
  end
  m_monitor = slave_monitor::type_id::create("m_monitor", this);
  if (m_cfg.m_has_coverage == 1) begin
     m_cov = slave_cov::type_id::create("m_cov", this);
  end  
endfunction : build_phase

// connect phase
function void slave_agent::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  
  // connect ports
  if (m_cfg.m_is_active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
  m_monitor.m_aport.connect(m_aport);
  if (m_cfg.m_has_coverage == 1) begin
    m_monitor.m_aport.connect(m_cov.analysis_export);
  end
  
  // assign interface
  if (m_cfg.m_is_active == UVM_ACTIVE) begin
    m_driver.m_vif = m_vif;
  end
  m_monitor.m_vif = m_vif;
  
  // assign configuration
  if (m_cfg.m_is_active == UVM_ACTIVE) begin    
    m_driver.m_cfg = m_cfg;
    m_sequencer.m_cfg = m_cfg;
  end
  m_monitor.s_cfg = m_cfg;
  if (m_cfg.m_has_coverage == 1) begin
    m_cov.m_cfg = m_cfg;
  end
endfunction : connect_phase

// print configuration
function void slave_agent::print_cfg();
  `uvm_info(get_type_name(), $sformatf("Configuration: \n%s", m_cfg.sprint()), UVM_HIGH)
endfunction : print_cfg

`endif // SLAVE_AGENT_SV
