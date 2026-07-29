class axi_incr_burst_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_incr_burst_seq)
    
      bit flag;
  
  function new(string name="");
    super.new(name);
  endfunction
  
  task body();
     axi_seq_item item;
   
    
    repeat(3) begin
    item = axi_seq_item::type_id::create("item");
    
    start_item(item);
    
      flag = $urandom_range(0,1);
    
      assert(item.randomize() with {
      
        item.write == 1;
        item.awburst == 1;
//         item.awaddr with inside {[32'h0:32'hfff]};
        
        if(flag)
          item.awaddr % (1 << awsize) == 0;
        else 
          item.awaddr % (1 << awsize) != 0;
        
        
        item.awlen > 0;
        
        
      });
    
    
    
    finish_item(item);
    
    end
      
      
  endtask

  
  
endclass
