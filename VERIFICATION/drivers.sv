class axi_driver extends uvm_driver#(axi_seq_item);
  `uvm_component_utils(axi_driver)
  axi_seq_item item;
  
  virtual axi_interface vif;
  axi_agent_config agent_config;
  
  uvm_analysis_port#(axi_seq_item) drv_port;
  
  
  function new(string name="", uvm_component parent);
    super.new(name,parent);
    drv_port = new("drv_port",this);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual axi_interface)::get(null,"","vif",vif))begin
      `uvm_error("DRIVER","UVM CONFIG DB ERROR")
    end
    
  endfunction
  
  task run_phase(uvm_phase phase);
//     super.run_phase(phase);
//     vif = agent_config.get_vif();
    
    // Control
//   vif.w_en    <= 0;
//   vif.r_en    <= 0;

  // Write Address Channel
  vif.awid    <= 0;
  vif.awaddr  <= 0;
  vif.awlen   <= 0;
  vif.awsize  <= 0;
  vif.awburst <= 0;
  vif.awvalid <= 0;

  // Write Data Channel
  vif.wdata   <= 0;
  vif.wstrb   <= 0;
  vif.wlast   <= 0;
  vif.wvalid  <= 0;

  // Write Response Channel
  vif.bready  <= 0;

  // Read Address Channel
  vif.arid    <= 0;
  vif.araddr  <= 0;
  vif.arlen   <= 0;
  vif.arsize  <= 0;
  vif.arburst <= 0;
  vif.arvalid <= 0;

  // Read Data Channel
  vif.rready  <= 0;

    
    @(posedge vif.clk);
    
    
      `uvm_info("DRIVER","run_phase started",UVM_NONE)
    
    forever begin
       `uvm_info("DRIVER","waiting item",UVM_NONE)
      
      seq_item_port.get_next_item(item);
      
         
      
      if(item.write)begin
      write_drive_transaction(item);
      end else begin
        read_drive_transaction(item);
      end
      
      drv_port.write(item);
      
      seq_item_port.item_done();
      
        `uvm_info("DRIVER","got item",UVM_NONE)
      
    end
    
    
  endtask
  
 
  task write_drive_transaction(axi_seq_item item); 
    `uvm_info("DRIVER","Starting WRITE transaction",UVM_NONE)
    `uvm_info("DRIVER",
        $sformatf("AWID=%0d AWADDR=0x%08h AWLEN=%0d AWSIZE=%0d AWBURST=%0d",
                  item.awid,item.awaddr,item.awlen,item.awsize,item.awburst),
        UVM_NONE)
 
    vif.awid    <= item.awid;
    vif.awaddr  <= item.awaddr;
    vif.awlen   <= item.awlen;
    vif.awsize  <= item.awsize;
    vif.awburst <= item.awburst;
    vif.awvalid <= 1;

    `uvm_info("DRIVER","Waiting for AW handshake...",UVM_NONE)

    // Wait for AWREADY
    while(!vif.awready) begin
        @(posedge vif.clk);
    end

    `uvm_info("DRIVER","AW handshake completed",UVM_NONE)
 
     @(posedge vif.clk);   
     @(posedge vif.clk);  
    vif.awvalid <= 0;
 
    @(posedge vif.clk);
    
    for(int i=0;i<=item.awlen;i++) begin

        vif.wdata <= item.wdata[i];
        vif.wstrb <= item.wstrb[i];
        vif.wlast <= (i==item.awlen);
        vif.wvalid <= 1;

        `uvm_info("DRIVER",
        $sformatf("Sending Beat %0d/%0d DATA=0x%08h STRB=0x%0h LAST=%0b",
                  i,
                  item.awlen,
                  item.wdata[i],
                  item.wstrb[i],
                  (i==item.awlen)),
        UVM_NONE)
 
        while(!vif.wready) begin
          @(posedge vif.clk); 
            vif.wvalid <= 1;
            vif.wdata  <= item.wdata[i];
            vif.wstrb  <= item.wstrb[i];
            vif.wlast  <= (i==item.awlen);
            
            $display("[%0t] WVALID=%b WREADY=%b WLAST=%b STATE?",
                     $time,
                     vif.wvalid,
                     vif.wready,
                     vif.wlast);
        end

        // Complete the handshake
        @(posedge vif.clk);
        vif.wvalid <= 0;
        
        `uvm_info("DRIVER",
        $sformatf("Beat %0d accepted",i),
        UVM_NONE);
    end
 
    vif.wvalid <= 0;
    vif.wlast  <= 0;
 
    vif.bready <= 1;

    `uvm_info("DRIVER","Waiting for B response...",UVM_NONE)

    while(!vif.bvalid) begin
        @(posedge vif.clk);
        vif.bready <= 1;
    end
     
    
    if(vif.bresp==2'b00)
        `uvm_info("DRIVER","BRESP = OKAY",UVM_NONE)
    else
        `uvm_error("DRIVER",
        $sformatf("BRESP ERROR : %0b",vif.bresp))

    @(posedge vif.clk);
    vif.bready <= 0;

     `uvm_info("DRIVER","WRITE transaction completed",UVM_NONE) 
endtask
  
  
  
  task read_drive_transaction(axi_seq_item item);
    
       
    `uvm_info("DRIVER","read transaction started",UVM_NONE)
      
    `uvm_info("DRIVER",
              $sformatf("ARID=%0d ARADDR=0x%08h ARLEN=%0d ARSIZE=%0d ARBURST=%0d",
                  item.arid,item.araddr,item.arlen,item.arsize,item.arburst),
        UVM_NONE)

    
    
    vif.arid    <= item.arid;
    vif.araddr <= item.araddr;
    vif.arlen <= item.arlen;
    vif.arsize <= item.arsize;
    vif.arburst <= item.arburst;
    vif.arvalid <= 1;
    
    
    
    while(!vif.arready)begin
      @(posedge vif.clk);
    end
     
    
    vif.rready <= 1;
    
    for(int i=0;i<item.arlen+1;i=i+1)begin
      @(posedge vif.clk);
    while(!vif.rvalid)begin
      @(posedge vif.clk);
    end
    if(vif.rresp != 2'b00)begin
      `uvm_fatal("DRIVER","read resp error")
    end
      
      if(i==item.arlen)begin
        if(!vif.rlast)begin
          `uvm_error("DRVIER","RLAST ERROR")
        end
      end else begin
        if(vif.rlast)begin
          `uvm_error("DRIVER","unexpected rlast error")
        end
      end
      
    end
    
    
//     do begin
//       @(posedge vif.clk);
//        while(!vif.rvalid)begin
//       @(posedge vif.clk);
//     end
//     if(vif.rresp != 2'b00)begin
//       `uvm_fatal("DRIVER","read resp error")
//     end 
      
      
//     end while(!rlast)
     
     
   vif.arvalid <= 0;
    vif.rready <= 0;
    
    `uvm_info("DRIVER","read transaction ended",UVM_NONE)
    
    
  endtask
  
  
endclass
