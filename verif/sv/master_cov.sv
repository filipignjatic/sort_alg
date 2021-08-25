`ifndef MASTER_COV_SV
`define MASTER_COV_SV

class master_cov extends uvm_subscriber #(trans_item);
  
  // registration macro
  `uvm_component_utils(master_cov)
  
  // configuration reference
  agent_cfg m_cfg;
  
  trans_item m_item;
  
    // covergroup
  covergroup ain_tdata_cg with function sample (int queue_index);
    option.per_instance = 1;
    cover_data_i: coverpoint m_item.ain_tdata[queue_index] {
    option.auto_bin_max = 16;
   }
  endgroup : ain_tdata_cg
  // constructor
  extern function new(string name, uvm_component parent);
  // analysis implementation port function
  extern virtual function void write(trans_item t);

endclass : master_cov

// constructor
function master_cov::new(string name, uvm_component parent);
  super.new(name, parent);
  ain_tdata_cg = new();
  ain_tdata_cg.set_inst_name("m_ain_tdata");
endfunction : new

// analysis implementation port function
function void master_cov::write(trans_item t);
  $cast(m_item, t.clone());
  foreach(m_item.ain_tdata[i]) ain_tdata_cg.sample(i);
endfunction : write

`endif // MASTER_COV_SV
