`ifndef TEST_PKG_SV
`define TEST_PKG_SV

package test_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

// import UVC's packages
import uvc_pkg::*;

// import env package
// import uart_uvc_top_env_pkg::*;


`include "top_env_cfg.sv"
`include "top_env.sv"
// include tests
`include "test_base.sv"
`include "test_sort_alg.sv"
endpackage : test_pkg

`endif // TEST_PKG_SV
