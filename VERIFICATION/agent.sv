class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)
  
   axi_agent_config agent_config;
    
   axi_monitor monitor;
  
   axi_sequencer seqr;
  
   axi_driver driver;
  
//   axi_coverage coverage;
   virtual axi_interface vif;
  
  function new(string name="",uvm_component parent);
    super.new(name,parent);
    
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
     agent_config = axi_agent_config::type_id::create("agent_config", this);
      
    monitor = axi_monitor::type_id::create("monitor",this);
    
    
    if(!uvm_config_db #(virtual axi_interface)::get(this,"","vif",vif))begin
      `uvm_fatal("agent",$sformatf("could not find config db in agent"));
    end else begin
      agent_config.set_vif(vif);
    end
    
   
//     if(agent_config.get_active_passive() == UVM_ACTIVE)begin
      driver = axi_driver::type_id::create("driver",this);
      seqr = axi_sequencer::type_id::create("seqr",this);
//     end
    
  endfunction
  
  
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    monitor.agent_config = agent_config;
    
    if(agent_config.get_active_passive() == UVM_ACTIVE)begin
      driver.agent_config = agent_config;
      driver.seq_item_port.connect(seqr.seq_item_export);
    end
    
    
  endfunction
  
endclass
