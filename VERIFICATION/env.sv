class axi_environment extends uvm_env;
  
  `uvm_component_utils(axi_environment)
  
  axi_agent agt;
  axi_scoreboard score;
  
  
  function new(string name="", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   
    agt = axi_agent::type_id::create("agt",this);
    score = axi_scoreboard::type_id::create("score",this);
    
    
    
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
//     agt.monitor.ap.connect(score.mon_imp);
//     agt.driver.drv_port.connect(score.drv_imp);
    
    
    agt.monitor.ap.connect(score.mon_imp.analysis_export);
    agt.driver.drv_port.connect(score.drv_imp.analysis_export);
    
    
  endfunction
  
  
endclass
