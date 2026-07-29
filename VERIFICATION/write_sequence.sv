


class axi_wr_seq extends uvm_sequence#(axi_seq_item);
  `uvm_object_utils(axi_wr_seq)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  task body();
    axi_seq_item item;
    
    `uvm_info("SEQ","body entered",UVM_NONE)
    
    repeat(3) begin
      item = axi_seq_item::type_id::create("item");
      
      start_item(item);
      `uvm_info("SEQ","after start_item",UVM_NONE)
      
      // Randomize with constraints
      assert(item.randomize with {
        write == 1;
        awaddr inside {[32'h0:32'hfff]};
        awburst inside {0, 1, 2};
        awlen == 1;
        // Note: wstrb constraints are in the item class
      });
      
      // Debug print
      `uvm_info("SEQ", $sformatf("Transaction:\n%s", item.convert2string()), UVM_DEBUG)
      
      finish_item(item);
      `uvm_info("SEQ","after finish_item",UVM_NONE)
    end
  endtask
endclass
