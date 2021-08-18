`ifndef UVC_PKG_SV
`define UVC_PKG_SV

package uvc_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "agent_cfg.sv"
`include "uvc_cfg.sv"
`include "trans_item.sv"
`include "master_driver.sv"
`include "slave_driver.sv"
`include "uvc_sequencer.sv"
// `include "slave_sequencer.sv"
`include "slave_monitor.sv"
`include "master_monitor.sv"
`include "master_agent.sv"
`include "slave_agent.sv"
`include "uvc_env.sv"
`include "scoreboard.sv"
`include "basic_seq.sv"

endpackage : uvc_pkg

`include "uvc_interface.sv"

`endif // UVC_PKG_SV
