`ifndef MASTER_MONITOR_SV
`define MASTER_MONITOR_SV

class master_monitor extends uvm_monitor;

  // registration macro
  `uvm_component_utils(master_monitor)

  // analysis port
  uvm_analysis_port #(trans_item) m_aport;

  // virtual interface reference
  virtual interface uvc_interface m_vif;

  agent_cfg m_cfg;
  agent_cfg s_cfg;

  // monitor item
  trans_item item, clone_item;

  // constructor
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  // run phase
  extern virtual task run_phase(uvm_phase phase);
  // handle reset
  extern virtual task handle_reset();
  // collect item
  extern virtual task collect_item();
  // period of one character duration

endclass : master_monitor

// constructor
function master_monitor::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

// build phase
function void master_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // create port
  m_aport = new("m_aport", this);

  // create item
  item = trans_item::type_id::create("item", this);
endfunction : build_phase

task master_monitor::run_phase(uvm_phase phase);
  super.run_phase(phase);
  forever begin
    fork : run_phase_fork_block
      begin
        handle_reset();
      end
      begin
        collect_item();
      end
    join_any // run_phase_fork_block
    disable fork;
  end
endtask : run_phase

// handle reset
task master_monitor::handle_reset();
    // wait reset assertion
    @(m_vif.reset_n iff m_vif.reset_n == 0);
    item.ain_tdata.delete();
    `uvm_info(get_type_name(), "Reset asserted.", UVM_HIGH)
endtask : handle_reset

// collect item
task master_monitor::collect_item();
  // wait until reset is de-asserted
  wait (m_vif.reset_n);
  `uvm_info(get_type_name(), "Reset de-asserted. Starting to collect items...", UVM_HIGH)
    forever begin
      @(m_vif.ain_tready && m_vif.ain_tvalid);
      while(m_vif.ain_tready == 1'b1 && m_vif.ain_tvalid == 1'b1) begin
	item.ain_tdata.push_back(m_vif.ain_tdata);
	@(posedge m_vif.clock);
      end
      `uvm_info(get_type_name(), $sformatf("Item collected: \n%s", item.sprint()), UVM_HIGH)
      $cast(clone_item, item);
      m_aport.write(clone_item);
      item.ain_tdata.delete();
    end
endtask : collect_item

`endif // MASTER_MONITOR_SV
