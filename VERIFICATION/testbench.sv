// Code your testbench here
// or browse Examples




`include "uvm_macros.svh"
import uvm_pkg::*;
  
//   import uvm_pkg ::*;
 
 
  `include "seq_item.sv"
  `include "write_sequence.sv"
	`include "read_sequence.sv"
  `include "fixed_sequence.sv"
 `include "incr_burst.sv"
 `include "wrap_burst.sv"
 `include "addr_decoder_error.sv"
 `include "four_k_boundary_violation.sv"
  `include "sequencer.sv"
  `include "agent_config.sv"
  `include "driver.sv"
  `include "monitor.sv"
//   `include "coverage.sv"
  `include "scoreboard.sv"
  `include "agent.sv"
  `include "env.sv" 
  `include "test.sv"
    `include "interface.sv"

  






module tb;

  
  
  
  logic clk;
  logic rst;
  
  
  
  axi_interface vif(clk,rst);
  
  
  
  top_axi top(
  
    .clk(clk),
    .rst(rst),
    
//     .w_en(vif.w_en),
//     .r_en(vif.r_en),
  
    .awid(vif.awid),
    .awaddr(vif.awaddr),
    .awlen(vif.awlen),
    .awsize(vif.awsize),
    .awburst(vif.awburst),
    .awvalid(vif.awvalid),
    
    .awready(vif.awready),
  
    .wstrb(vif.wstrb),
    .wdata(vif.wdata),
    .wlast(vif.wlast),
    .wvalid(vif.wvalid),
    
    .wready(vif.wready),
    
    
    .bready(vif.bready),
    .bid(vif.bid),
    .bresp(vif.bresp),
    
    .bvalid(vif.bvalid),
    
    
    .araddr(vif.araddr),
    .arid(vif.arid),
    .arlen(vif.arlen),
    .arsize(vif.arsize),
    .arburst(vif.arburst),
    .arvalid(vif.arvalid),
    
    
    .arready(vif.arready),
    
    .rid(vif.rid),
    .rdata(vif.rdata),
    .rvalid(vif.rvalid),
    .rlast(vif.rlast),
    .rresp(vif.rresp),
    
    .rready(vif.rready)
    
    
  );
  
  initial begin
    clk = 0;
    rst = 1;
    #45;
    rst = 0;
  end
  
  always #10 clk = ~clk;
  
 
  initial begin
    uvm_config_db#(virtual axi_interface)::set(null,"*","vif",vif);
    
  end
  
  initial begin
    run_test("axi_test");
  end
  
  
  
endmodule
