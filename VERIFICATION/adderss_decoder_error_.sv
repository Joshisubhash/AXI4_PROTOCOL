class axi_addr_decoder_error_seq extends uvm_sequence#(axi_seq_item);
  `uvm_object_utils(axi_addr_decoder_error_seq)
  
  
  function new(string name="");
    super.new(name);
  endfunction
  
  task body();
     axi_seq_item item;
   
    
    for(int i=0;i<3;i++) begin
    item = axi_seq_item::type_id::create("item");
    
    start_item(item);
    
      assert(item.randomize() with {
      
        item.write == 1;
        item.awburst == i;
        !(item.awaddr inside {[32'h0:32'hfff]});
        
        
      });
    
    
    
    finish_item(item);
    
    end
      
      
  endtask

  
  
endclass
