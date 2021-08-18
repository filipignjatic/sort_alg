`ifndef BASIC_SEQ_SV
`define BASIC_SEQ_SV

class basic_seq extends uvm_sequence #(trans_item);
  
  // registration macro
  `uvm_object_utils(basic_seq)
  
  // sequencer pointer macro
  `uvm_declare_p_sequencer(uvc_sequencer)
  
  // fields
  rand int num_data_s;
  // constraints

  // constructor
  extern function new(string name = "basic_seq");
  // body task
  extern virtual task body();

endclass : basic_seq

// constructor
function basic_seq::new(string name = "basic_seq");
  super.new(name);
endfunction : new

// body task
task basic_seq::body();
  
  //--------------------------------------------------
  req = trans_item::type_id::create("req");
  
  start_item(req);
  
  if(!req.randomize() with {num_data == num_data_s;}) begin
    `uvm_fatal(get_type_name(), "Failed to randomize.")
  end  
  
  finish_item(req);

endtask : body

`endif // BASIC_SEQ_SV
