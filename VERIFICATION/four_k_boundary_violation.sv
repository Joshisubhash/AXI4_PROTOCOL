class axi_four_k_violation_seq extends uvm_sequence#(axi_seq_item);
  `uvm_object_utils(axi_four_k_violation_seq)
  
  
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
        item.awaddr == 32'hfff;
       
        
      });
    
     item.expect_error = 1;
    
    finish_item(item);
    
  end
      
  endtask

  
  
endclass
