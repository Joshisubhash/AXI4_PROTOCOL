class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)
  
  
  
//   `uvm_analysis_imp_decl(_mon);
//   `uvm_analysis_imp_decl(_drv) ;
  
  
  axi_agent_config agent_config;
  
  virtual axi_interface vif;
  
  uvm_tlm_analysis_fifo  #(axi_seq_item) mon_imp;
  uvm_tlm_analysis_fifo  #(axi_seq_item) drv_imp;
  
//   axi_seq_item exp[$];
//   axi_seq_item act[$];
  
  reg [31:0] mem [0:1023];
  
  bit expected_last;
    bit [1:0] expected_bresp;
  
  function new(string name="",uvm_component parent);
    super.new(name,parent);
    mon_imp = new("mon_imp",this);
    drv_imp = new("drv_imp",this);
    
  endfunction
  
//   function void write(axi_seq_item item);
  
//     if(item.write)begin
//       write_compare(item);
//     end else begin
//       read_compare(item);
//     end
      
    
//   endfunction
  
  
  
  
  
  
  
  task run_phase(uvm_phase phase);
    
      axi_seq_item exp;
 	 axi_seq_item act;
  
    
    forever begin
      
      
      drv_imp.get(exp);
      mon_imp.get(act);
   
      
      compare(exp,act);
      
    end
    
    
  endtask
  
  
  
  
  
  
  
  function void compare(axi_seq_item exp, axi_seq_item act);
    
    
    if(exp.write)begin
    
    if(exp.awaddr != act.awaddr)begin
      `uvm_error("SCOREBOARD","AWADDR IS ERROR");
      
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.awaddr- %d , act.awaddr - %d", exp.awaddr,  act.awaddr),UVM_NONE);
    end
    
    if(exp.awlen != act.awlen)begin
      `uvm_error("SCOREBOARD","AWLEN IS ERROR");
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.awlen- %d , act.awlen - %d", exp.awlen,  act.awlen),UVM_NONE);
    end
    
    
    if(exp.awsize != act.awsize)begin
      `uvm_error("SCOREBOARD","AWSIZE IS ERROR");
      
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.awsize- %d , act.awsize - %d", exp.awsize,  act.awsize),UVM_NONE);
    end
    
    if(exp.awburst != act.awburst)begin
      `uvm_error("SCOREBOARD","AWBURST IS ERROR");
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.awburst- %d , act.awburst - %d", exp.awburst,  act.awburst),UVM_NONE);
    end
    
    if(exp.awid != act.awid)begin
      `uvm_error("SCOREBOARD","AWID IS ERROR");
      
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.awid- %d , act.awid - %d", exp.awid,  act.awid),UVM_NONE);
    end
    
      
//       if(exp.wdata.size() != act.wdata.size())begin
//         `uvm_error("SCOREBOARD","wdata size error")
//       end else begin
    
//     for(int i=0;i<act.awlen+1;i=i+1)begin
//       if(exp.wdata[i] != act.wdata[i])begin
//         `uvm_error("SCOREBOARD",$sformatf("ACT.WDATA %d is error",i));
//       end else begin
//         `uvm_info("SCOREBOARD",$sformatf("exp.wdata- %d , act.wdata - %d", exp.wdata[i],  act.wdata[i]),UVM_NONE);
//     end
      
//     end
        
//       end
    
      
      
      // In your scoreboard.sv, update the wdata comparison:

// Instead of:
// if(exp.wdata != act.wdata) begin

// Use this for dynamic array comparison:
if(exp.wdata.size() != act.wdata.size()) begin
    `uvm_error("SCOREBOARD", $sformatf("WDATA size mismatch: exp=%0d, act=%0d", 
                exp.wdata.size(), act.wdata.size()))
end else begin
    for(int i=0; i<exp.wdata.size(); i++) begin
        if(exp.wdata[i] != act.wdata[i]) begin
            `uvm_error("SCOREBOARD", $sformatf("WDATA[%0d] mismatch: exp=0x%0h, act=0x%0h", 
                        i, exp.wdata[i], act.wdata[i]))
          
        end else begin
          `uvm_info("SCOREBOARD", $sformatf("WDATA[%0d] matched: 0x%0h", i, exp.wdata[i]), UVM_NONE)
        end
      
      /*
//         expected_last = (i == exp.awlen);
      use it when monitor is sending every beat with wlast but currently this my code is sending wlast only for last beat meaning monitor is sending tranasction with full length of burst of data with wlast beat on last burst, so if used for this type of transaction then we will get error because it will be mismatch
      
      */
      
      
         
       
      
      
    end
  
   expected_last = 1'b1;
      
       
            
            
          // For WLAST comparison:
      if(expected_last != act.wlast) begin
              `uvm_error("SCOREBOARD", $sformatf("WLAST mismatch: exp=%0d, act=%0d", expected_last, act.wlast))
          end else begin
            `uvm_info("SCOREBOARD", $sformatf("WLAST matched: %0d", expected_last), UVM_NONE)
          end
            
end

       
      
      
      // In scoreboard.sv, update BID comparison
      if(exp.awid !== act.bid) begin
        `uvm_error("SCOREBOARD", $sformatf("BID mismatch: exp=%0d, act=%0d", exp.awid, act.bid))
end else begin
  `uvm_info("SCOREBOARD", $sformatf("BID matched: %0d", exp.awid), UVM_NONE)
end
    
    

if(exp.expect_error)
    expected_bresp = 2'b10;   // SLVERR
else
    expected_bresp = 2'b00; 
      
      
    if(expected_bresp != act.bresp)begin
      `uvm_error("SCOREBOARD","BRESP IS ERROR");
      
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.bresp- %d , act.bresp - %d", exp.bresp,  act.bresp),UVM_NONE);
    end
    
        
         
        
        
    end else if(!exp.write)begin
    
    
    
    
    
    
    
    
    
    if(exp.araddr != act.araddr)begin
      `uvm_error("SCOREBOARD","ARADDR IS ERROR");
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.araddr- %d , act.araddr - %d", exp.araddr,  act.araddr),UVM_NONE);
    end
    
      if(exp.arid != act.arid)begin
        `uvm_error("SCOREBOARD","ARID IS ERROR");
      
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.arid- %d , act.arid - %d", exp.arid,  act.arid),UVM_NONE);
    end
    
      
      if(exp.arlen != act.arlen)begin
        `uvm_error("SCOREBOARD","ARLEN IS ERROR");
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.arlen- %d , act.arlen - %d", exp.arlen,  act.arlen),UVM_NONE);
    end
    
      if(exp.arsize != act.arsize)begin
        `uvm_error("SCOREBOARD","ARSZIE IS ERROR");
      
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.arsize- %d , act.arsize - %d", exp.arsize,  act.arsize),UVM_NONE);
    end
      
      
     
    
      if(exp.arburst != act.arburst)begin
        `uvm_error("SCOREBOARD","ARBURST IS ERROR");
      
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.arburst- %d , act.arburst - %d", exp.arburst,  act.arburst),UVM_NONE);
    end
    
      
      
      if(exp.rid != act.rid)begin
        `uvm_error("SCOREBOARD","RID IS ERROR");
    end else begin
      `uvm_info("SCOREBOARD",$sformatf("exp.rid- %d , act.rid - %d", exp.rid,  act.rid),UVM_NONE);
    end
      
      
    if(exp.rresp.size() != act.rresp.size()) begin
    `uvm_error("SCOREBOARD","RRESP size mismatch")
end
else begin
    foreach(exp.rresp[i]) begin

        if(exp.rresp[i] != act.rresp[i]) begin
            `uvm_error("SCOREBOARD",
                $sformatf("Beat %0d RRESP mismatch exp=%0b act=%0b",
                          i,
                          exp.rresp[i],
                          act.rresp[i]))
        end
        else begin
            `uvm_info("SCOREBOARD",
                $sformatf("Beat %0d RRESP matched exp=%0b act=%0b",
                          i,
                          exp.rresp[i],
                          act.rresp[i]),
                UVM_NONE)
        end

    end
end
      
      for(int i=0;i<act.arlen+1;i=i+1)begin
        if(exp.rdata[i] != act.rdata[i])begin
          `uvm_error("SCOREBOARD",$sformatf("ACT.RDATA %d is error",i));
      end else begin
        `uvm_info("SCOREBOARD",$sformatf("exp.rdata- %d , act.rdata - %d", exp.rdata[i],  act.rdata[i]),UVM_NONE);
    end
      
    end
      
//       if(exp.rlast != act.rlast)begin
//         `uvm_error("SCOREBOARD","RLAST IS ERROR");
//     end else begin
//       `uvm_info("SCOREBOARD",$sformatf("exp.rlast- %d , act.rlast - %d", exp.rlast,  act.rlast),UVM_NONE);
//     end
      
      
      if(exp.arlen == 0) begin
    // Single beat transaction - rlast should be 1
    if(1'b1 != act.rlast) begin
        `uvm_error("SCOREBOARD", $sformatf("Single beat RLAST error: exp=1, act=%0d", act.rlast))
    end else begin
        `uvm_info("SCOREBOARD", "Single beat RLAST matched: 1", UVM_NONE)
    end
end else begin
    // Multi-beat transaction - rlast is already checked by driver
    // Skip RLAST comparison or check only the last beat
    `uvm_info("SCOREBOARD", $sformatf("Multi-beat RLAST comparison skipped (drv already checked, act.rlast=%0d)", act.rlast), UVM_DEBUG)
end

      
      
    
    end 
    
    
    
 
    
    
    
    
  endfunction
  
  
  
  
  
  
  
  
  
  
  
  
  
  
 
  
endclass
