class axi_fixed_seq extends uvm_sequence#(axi_seq_item);
  `uvm_object_utils(axi_fixed_seq)
  
  
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
        item.awburst == 0;
        item.awaddr inside {[32'h0:32'hfff]};
        item.awlen > 0;
        
        
      });
    
    
    
    finish_item(item);
    
    end
      
      
  endtask

  
  
endclass
