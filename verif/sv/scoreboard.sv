`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`uvm_analysis_imp_decl(_ain)
`uvm_analysis_imp_decl(_aout)

class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)
  // Transaction items
  trans_item ain_clone;
  trans_item aout_clone;
  bit [15:0] data_in [$];
  bit [15:0] data_out [$];
  bit [15:0] tmp;
  // Events
  event ain_event;
  event aout_event;
  
  uvm_analysis_imp_ain #(trans_item, scoreboard) m_ain_aexport;
  uvm_analysis_imp_aout #(trans_item, scoreboard) m_aout_aexport;
  
  // constructor
  extern function new(string name, uvm_component parent);
  // build phase
  extern virtual function void build_phase(uvm_phase phase);
  // run phase
  extern virtual task run_phase(uvm_phase phase);
  // ain write
  extern virtual function void write_ain(trans_item t);
  // aout write
  extern virtual function void write_aout(trans_item t);
endclass : scoreboard

// constructor
function scoreboard::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

function void scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
  // ports
  m_ain_aexport = new("m_ain_aexport", this);
  m_aout_aexport = new("m_aout_aexport", this);
endfunction: build_phase


task scoreboard::run_phase(uvm_phase phase);
  super.run_phase(phase);
  forever begin
    @(ain_event);
      for(int i = 0; i < data_in.size()-1; i++) begin
	for(int j = 0; j < data_in.size()-1; j++) begin
	  if(data_in[j] < data_in[j+1]) begin
	    tmp = data_in[j+1];
	    data_in[j+1] = data_in[j];
	    data_in[j] = tmp;
	    tmp = 0;
	  end
	end
      end
    @(aout_event);
      foreach(aout_clone.aout_tdata[i])
	data_out.push_front(aout_clone.aout_tdata[i]);
	
    foreach(data_in[i])
       `uvm_info("DATA IN SCOREBOARD", $sformatf("DATA: %d\n", data_in[i]), UVM_HIGH)
    foreach(data_out[i])
       `uvm_info("DATA OUT SCOREBOARD", $sformatf("DATA: %d\n", data_out[i]), UVM_HIGH)
    assert_length_ain_aout: assert(data_out.size() == data_in.size());
    for(int i =0; i < data_out.size(); i++) begin
      check_sorted_data: assert(data_in[i] == data_out[i]);
    end
    data_in.delete();
    data_out.delete();
  end
endtask: run_phase

function void scoreboard::write_ain(trans_item t);
  bit [15:0] tmp = 0;
  $cast(ain_clone, t.clone());
  foreach(ain_clone.ain_tdata[i])
    data_in.push_front(ain_clone.ain_tdata[i]);
  ->ain_event;
endfunction : write_ain

function void scoreboard::write_aout(trans_item t);
   $cast(aout_clone, t.clone());
   ->aout_event;
endfunction : write_aout

`endif //WB2UART_SCOREBOARD_SV
