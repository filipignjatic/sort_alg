`ifndef SLAVE_COV_SV
`define SLAVE_COV_SV

class slave_cov extends uvm_subscriber #(trans_item);
  
  // registration macro
  `uvm_component_utils(slave_cov)
  
  // configuration reference
  agent_cfg m_cfg;
  
  trans_item m_item;
  
  // coverage groups
  covergroup slave_data_number_cg;
    option.per_instance = 1;
    cover_number_of_data_per_transaction : coverpoint m_item.num_data {
      option.auto_bin_max = 16;
    }
  endgroup : slave_data_number_cg
  
  covergroup aout_tdata_cg with function sample (int queue_index);
    option.per_instance = 1;
    cover_data_i: coverpoint m_item.aout_tdata[queue_index] {
    option.auto_bin_max = 16;
   }
  endgroup : aout_tdata_cg
  // constructor
  extern function new(string name, uvm_component parent);
  // analysis implementation port function
  extern virtual function void write(trans_item t);

endclass : slave_cov

// constructor
function slave_cov::new(string name, uvm_component parent);
  super.new(name, parent);
  slave_data_number_cg = new();
  aout_tdata_cg = new();
  slave_data_number_cg.set_inst_name("m_slave_data_number_cg");
  aout_tdata_cg.set_inst_name("m_aout_tdata_cg");
endfunction : new

// analysis implementation port function
function void slave_cov::write(trans_item t);
  $cast(m_item, t.clone());
  slave_data_number_cg.sample();
  foreach(m_item.aout_tdata[i]) aout_tdata_cg.sample(i);
endfunction : write

`endif // SLAVE_COV_SV
