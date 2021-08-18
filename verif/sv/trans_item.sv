`ifndef TRANS_ITEM_SV
`define TRANS_ITEM_SV

class trans_item extends uvm_sequence_item;
  
  // item fields
  rand int num_data;
  rand bit [15:0] ain_tdata[$];
  rand bit [15:0] aout_tdata [$];
  // registration macro    
  `uvm_object_utils_begin(trans_item)
    `uvm_field_int(num_data, UVM_ALL_ON)
    `uvm_field_queue_int(ain_tdata, UVM_ALL_ON)
    `uvm_field_queue_int(aout_tdata, UVM_ALL_ON)
  `uvm_object_utils_end
  
  // constructor  
  extern function new(string name = "trans_item");
  
endclass : trans_item

// constructor
function trans_item::new(string name = "trans_item");
  super.new(name);
endfunction : new

`endif // TRANS_ITEM_SV
