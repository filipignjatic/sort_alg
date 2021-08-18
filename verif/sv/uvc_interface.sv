`ifndef UVC_INTERFACE_SV
`define UVC_INTERFACE_SV

interface uvc_interface(input clock, input reset_n);
  
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  
  // signals
  logic ain_tready;
  logic ain_tvalid;
  logic [15:0] ain_tdata;
  logic ain_tlast;
  logic aout_tready;
  logic aout_tvalid;
  logic aout_tlast;
  bit [15:0] aout_tdata;
  
  // ain_tvalid and ain_tready handshake
  ain_handshake: assert property (@(posedge clock) disable iff(!reset_n) $rose(ain_tvalid) |=> $rose(ain_tready));
  // check falling edges of ain_tvalid an ain_tready when happend falling edge of ain_tlast
  ain_tlast_low_tvalid_low_tready_low: assert property (@(posedge clock) disable iff(!reset_n) $fell(ain_tlast) |=> $past($fell(ain_tvalid) && $fell(ain_tready)));
  // aout_tvalid and aout_tready handshake
  aout_handshake: assert property (@(posedge clock) disable iff(!reset_n) $rose(aout_tvalid) |=> $rose(aout_tready));
  // check falling edges of aout_tvalid an aout_tready when happend falling edge of aout_tlast
  aout_tvalid_and_tready_low: assert property (@(posedge clock) disable iff(!reset_n) $fell(aout_tlast) |=> $past($fell(aout_tvalid) && $fell(aout_tready)));
  
endinterface : uvc_interface

`endif // UVC_INTERFACE_SV
