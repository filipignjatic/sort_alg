`ifndef UVC_SEQUENCER_SV
`define UVC_SEQUENCER_SV

class uvc_sequencer extends uvm_sequencer #(trans_item);
  
  // registration macro
  `uvm_component_utils(uvc_sequencer)
    
  // configuration reference
  agent_cfg m_cfg;
  
  // constructor    
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  
endclass : uvc_sequencer

// constructor
function uvc_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

// build phase
function void uvc_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

`endif // UVC_SEQUENCER_SV
