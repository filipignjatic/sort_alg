`ifndef SORT_ALG_TOP_TB_SV
`define SORT_ALG_TOP_TB_SV

// define timescale
`timescale 1ns/1ns;


module sort_alg_top_tb;
  
  `include "uvm_macros.svh"  
  import uvm_pkg::*;
  
  // import test package
  import test_pkg::*;
      
  // signals
  reg reset_n;
  reg clock;
  
  uvc_interface uvc_interface_inst(clock, reset_n);
  
  // DUT instance
  
  sort_alg DUT(
    .clk(clock), 
    .rst(!reset_n),
    .ain_tvalid(uvc_interface_inst.ain_tvalid),
    .ain_tready(uvc_interface_inst.ain_tready),
    .ain_tdata(uvc_interface_inst.ain_tdata),
    .ain_tlast( uvc_interface_inst.ain_tlast),
    .aout_tvalid(uvc_interface_inst.aout_tvalid),
    .aout_tready(uvc_interface_inst.aout_tready),
    .aout_tdata(uvc_interface_inst.aout_tdata),
    .aout_tlast(uvc_interface_inst.aout_tlast)
  );
  
  // configure UVC's virtual interface in DB
  initial begin : config_if_block
    uvm_config_db#(virtual uvc_interface)::set(uvm_root::get(), "uvm_test_top.m_top_env.m_uvc_env.m_master_agent", "m_vif", uvc_interface_inst);
    uvm_config_db#(virtual uvc_interface)::set(uvm_root::get(), "uvm_test_top.m_top_env.m_uvc_env.m_slave_agent", "m_vif", uvc_interface_inst);
  end
    
  // define initial clock value and generate reset
  initial begin : clock_and_rst_init_block
    reset_n <= 1'b0;
    clock <= 1'b1;
    #500 reset_n <= 1'b1;
    #20 reset_n <= 1'b0;
    #20 reset_n <= 1'b1;
  end
  
  // generate clock
  always begin : clock_gen_block
    #50 clock <= ~clock;
  end
  
  // run test
  initial begin : run_test_block
    run_test();
  end
  
endmodule : sort_alg_top_tb

`endif // SORT_ALG_TOP_TB_SV
