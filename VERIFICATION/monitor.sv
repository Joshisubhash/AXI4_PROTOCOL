


class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)
  
  uvm_analysis_port #(axi_seq_item) ap;
  
  axi_agent_config agent_config;
  virtual axi_interface vif;
  
  function new(string name="",uvm_component parent);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual axi_interface)::get(null,"","vif",vif))begin
      `uvm_error("MONITOR","UVM CONFIG ERROR IN MONITOR")
    end
  endfunction
  
  task run_phase(uvm_phase phase);
  
    forever begin
     
      fork
      write_transaction(); 
      read_transaction();
      join
    
    end
  endtask
  
  
  
  
  
  task write_transaction();
   
    axi_seq_item item;
      item = axi_seq_item::type_id::create("item",this);
      
      `uvm_info("MONITOR","MONITOR IS STARTED",UVM_NONE)
      @(posedge vif.clk);
       
      while(!(vif.awready && vif.awvalid)) begin
        @(posedge vif.clk);
      end
       
      `uvm_info("MONITOR","MONITOR IS ENTERED ADDRESS CHANNEL AND SAMPLING ADDRESS SIGNALS",UVM_NONE)
      
      // Capture AW channel signals
      item.awaddr = vif.awaddr;
      item.awlen = vif.awlen;
      item.awsize = vif.awsize;
      item.awburst = vif.awburst;
      item.awid = vif.awid;
      
      `uvm_info("MONITOR", $sformatf("AW: addr=0x%0h, len=%0d, size=%0d, burst=%0d, id=%0d", 
                 item.awaddr, item.awlen, item.awsize, item.awburst, item.awid), UVM_NONE)
       
      item.wdata = new[item.awlen + 1];
      item.wstrb = new[item.awlen + 1];
       
      item.wlast = 0;
      
      for(int i = 0; i <= item.awlen; i = i + 1) begin
         
        while(!(vif.wready && vif.wvalid)) begin
          @(posedge vif.clk);
        end
        
        // Capture the data beat
        item.wdata[i] = vif.wdata;
        item.wstrb[i] = vif.wstrb; 
        if(i == item.awlen) begin
          item.wlast = vif.wlast;   
        end
        
        `uvm_info("MONITOR", $sformatf("W beat[%0d]: data=0x%0h, strb=0x%0h, last=%0d", 
                   i, vif.wdata, vif.wstrb, vif.wlast), UVM_DEBUG)
         
        @(posedge vif.clk);
      end
       
      while(!(vif.bvalid && vif.bready)) begin
        @(posedge vif.clk);
      end
       
      item.bresp = vif.bresp;
      item.bid = vif.bid;  
      
      `uvm_info("MONITOR", $sformatf("B: resp=%0d, id=%0d", vif.bresp, vif.bid), UVM_DEBUG)
       
      ap.write(item);
    
    
    
    
    
    
    
    
    
    
    
  endtask
  
  
  
  
  
  task read_transaction();
     
    
    
    axi_seq_item item;
    item = axi_seq_item::type_id::create("item",this);
      
    `uvm_info("MONITOR","MONITOR READ IS STARTED",UVM_NONE)
    @(posedge vif.clk);
      
     
    while(!(vif.arready && vif.arvalid)) begin
        @(posedge vif.clk);
      end
      
      
//          @(posedge vif.clk);
//       end
//     begin  
//     $display("T=%0t arvalid=%b arready=%b", $time, vif.arvalid, vif.arready);
//     end
      `uvm_info("MONITOR","MONITOR IS ENTERED ADDRESS CHANNEL AND SAMPLING ADDRESS SIGNALS",UVM_NONE)
      
      // Capture AW channel signals
      item.araddr = vif.araddr;
      item.arlen = vif.arlen;
      item.arsize = vif.arsize;
      item.arburst = vif.arburst;
      item.arid = vif.arid;
      
      `uvm_info("MONITOR", $sformatf("AW: addr=0x%0h, len=%0d, size=%0d, burst=%0d, id=%0d", 
                 item.araddr, item.arlen, item.arsize, item.arburst, item.arid), UVM_NONE)
       
    item.rdata = new[item.arlen + 1];
  item.rresp = new[item.arlen + 1];
          
      
      item.rlast = 0;
      
    for(int i = 0; i <= item.arlen; i = i + 1) begin
        // Wait for a valid data beat
      while(!(vif.rready && vif.rvalid)) begin
          @(posedge vif.clk);
        end
        
        // Capture the data beat
      item.rdata[i] = vif.rdata;
    item.rresp[i] = vif.rresp;
      
            
      if(i == item.arlen) begin
          item.rlast = vif.rlast;   
        end
        
        `uvm_info("MONITOR", $sformatf("W beat[%0d]: data=0x%0h, last=%0d", 
                   i, vif.rdata, vif.rlast), UVM_DEBUG)
        
        // Move to next clock edge
        @(posedge vif.clk);
      end
      
    
    
    ap.write(item); 
    
  endtask
  
  
  
  
  
  
  
  
  
  
  
endclass

