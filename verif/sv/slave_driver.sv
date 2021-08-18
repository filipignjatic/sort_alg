`ifndef SLAVE_DRIVER_SV
`define SLAVE_DRIVER_SV

class slave_driver extends uvm_driver #(trans_item);
  
  // registration macro
  `uvm_component_utils(slave_driver)
  
  // virtual interface reference
  virtual interface uvc_interface m_vif;
  
  // configuration reference
  agent_cfg m_cfg;
  
  
  // request item
  REQ m_req;
  // constructor
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  // run phase
  extern virtual task run_phase(uvm_phase phase);
  // process item
  extern virtual task process_item(trans_item item);
  // handle reset
  extern virtual task handle_reset();
  
endclass : slave_driver

// constructor
function slave_driver::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

// build phase
function void slave_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

// run phase
task slave_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);

  // init signals
  m_vif.aout_tready = 1'b0;
  
  @(posedge m_vif.reset_n);
  forever begin
    fork : run_phase_fork_block
      begin
        handle_reset();
      end
      begin
	seq_item_port.get_next_item(m_req);
	process_item(m_req);
	seq_item_port.item_done();
      end
    join_any // run_phase_fork_block
    disable fork;
  end
endtask : run_phase

// handle reset
task slave_driver::handle_reset();
    // wait reset assertion
    @(m_vif.reset_n iff m_vif.reset_n == 0);
    `uvm_info(get_type_name(), "Reset asserted.", UVM_HIGH)
endtask : handle_reset

// process item
task slave_driver::process_item(trans_item item);
  // print item
  `uvm_info(get_type_name(), $sformatf("Item to be driven: \n%s", item.sprint()), UVM_HIGH)
  // wait until reset is de-asserted
  wait (m_vif.reset_n);
  
  // Driving data
  @(posedge m_vif.aout_tvalid);
  @(posedge m_vif.clock);
    m_vif.aout_tready = 1'b1;
  while(m_vif.aout_tlast == 0 && m_vif.aout_tvalid == 1) begin
    item.aout_tdata.push_back(m_vif.aout_tdata);
    @(posedge m_vif.clock);
  end
  m_vif.aout_tready = 1'b0;
  
  
endtask : process_item


`endif // SLAVE_DRIVER_SV
