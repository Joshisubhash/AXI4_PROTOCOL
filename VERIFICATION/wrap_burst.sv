class axi_wrap_burst_seq extends uvm_sequence#(axi_seq_item);
  `uvm_object_utils(axi_wrap_burst_seq)
  
  
  function new(string name="");
    super.new(name);
  endfunction
  
  task body();
     axi_seq_item item;
   
    
    repeat(3) begin
    item = axi_seq_item::type_id::create("item");
    
    start_item(item);
    
      assert(item.randomize() with {
      
        item.write == 1;
        item.awburst == 2;
        item.awaddr inside {[32'h0:32'hfff]};
        item.awlen inside {1,3,7,15};
        
        
      });
    
    
    
    finish_item(item);
    
    end
      
      
  endtask

  
  
endclass
