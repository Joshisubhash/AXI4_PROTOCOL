class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)
  
  axi_environment env;
  virtual axi_interface vif;
  function new(string name="", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env = axi_environment :: type_id::create("env",this);
    if(!uvm_config_db#(virtual axi_interface)::get(null,"","vif",vif))begin
      `uvm_error("TEST","UVM CONFIG DB ERROR")
    end
  endfunction
  
  
//   task run_phase(uvm_phase phase);
    
  
//       axi_wr_seq seq;
//       seq = axi_wr_seq::type_id::create("seq",this);
   
      
//       phase.raise_objection(this);
    
    
   
//       seq.start(env.agt.seqr);
//       #200;
      
//       phase.drop_objection(this);
      
      
      
    
    
//   endtask
  
  
  task run_phase(uvm_phase phase);

  phase.raise_objection(this);

  `uvm_info("TEST", "================ AXI TEST STARTED ================", UVM_LOW)

 

    begin
      
      
      axi_wr_seq seq;
      seq = axi_wr_seq::type_id::create("seq");
      
      `uvm_info("TEST", "Starting axi_wr_seq", UVM_LOW)

      seq.start(env.agt.seqr);

      `uvm_info("TEST", "===========================================================================Completed axi_wr_seq==========================================================================================", UVM_LOW)
    end

    begin
      
      axi_fixed_seq seq_fixed;
      seq_fixed = axi_fixed_seq::type_id::create("seq_fixed");
      
      
      `uvm_info("TEST", "Starting axi_fixed_seq", UVM_LOW)

      seq_fixed.start(env.agt.seqr);

      `uvm_info("TEST", "==============================================================================Completed axi_fixed_seq==========================================================================================", UVM_LOW)
    end

    begin
      
      
      axi_incr_burst_seq seq_incr;
      seq_incr = axi_incr_burst_seq::type_id::create("seq_incr");
      
      
      `uvm_info("TEST", "Starting axi_incr_burst_seq", UVM_LOW)

      seq_incr.start(env.agt.seqr);

      `uvm_info("TEST", "===================================================================================Completed axi_incr_burst_seq=============================================================================", UVM_LOW)
    end

    begin
      
         axi_wrap_burst_seq seq_wrap;
      seq_wrap = axi_wrap_burst_seq::type_id::create("seq_wrap");
     
      
      `uvm_info("TEST", "Starting axi_wrap_burst_seq", UVM_LOW)

    seq_wrap.start(env.agt.seqr);

      `uvm_info("TEST", "===================================================================================Completed axi_wrap_burst_seq=================================================================================", UVM_LOW)
    end

    begin
      
      
      axi_addr_decoder_error_seq seq_addr_err;
      seq_addr_err = axi_addr_decoder_error_seq::type_id::create("seq_addr_err");
      
      `uvm_info("TEST", "Starting axi_addr_decoder_error_seq", UVM_LOW)

      seq_addr_err.start(env.agt.seqr);

      `uvm_info("TEST", "====================================================================================Completed axi_addr_decoder_error_seq============================================================================", UVM_LOW)
    end

    begin
      
      
      axi_four_k_violation_seq seq_4k;
      seq_4k = axi_four_k_violation_seq::type_id::create("seq_4k");
      
      
      `uvm_info("TEST", "Starting axi_four_k_violation_seq", UVM_LOW)

      seq_4k.start(env.agt.seqr);

      `uvm_info("TEST", "======================================================================================Completed axi_four_k_violation_seq==================================================================================", UVM_LOW)
    end
 
    
    
    begin
      axi_rd_seq seq;
      seq = axi_rd_seq::type_id::create("seq");
      
      seq.start(env.agt.seqr);
    end

  `uvm_info("TEST", "================ ALL SEQUENCES COMPLETED ================", UVM_LOW)

  phase.drop_objection(this);

endtask
  
  
  
  
endclass
