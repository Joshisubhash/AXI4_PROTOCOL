

class axi_seq_item extends uvm_sequence_item;
  `uvm_object_utils(axi_seq_item)
  
   
  rand bit write;    
 
  rand bit [3:0]  awid;
  rand bit [31:0] awaddr;
  rand bit [7:0]  awlen;
  rand bit [2:0]  awsize;
  rand bit [1:0]  awburst;
 
  rand bit [31:0] wdata[];
  rand bit [3:0]  wstrb[];
  bit             wlast;   
 
  bit [3:0] bid;
  bit [1:0] bresp;
 
  rand bit [3:0]  arid;
  rand bit [31:0] araddr;
  rand bit [7:0]  arlen;
  rand bit [2:0]  arsize;
  rand bit [1:0]  arburst;
 
  bit [3:0]  rid;
  bit [31:0] rdata[];
  bit [1:0]  rresp[];
  bit rlast;

  bit expect_error;
  
  function new(string name="");
    super.new(name); 
    wdata = new[2];
    wdata[0] = 32'hDEADBEEF;
    wdata[1] = 32'hBEEFDEAD;
    wstrb = new[2];
    wstrb[0] = 4'hF;
    wstrb[1] = 4'hF;
    rdata = new[1];
    rdata[0] = 32'h0;
    rresp = new[1];
    rresp[0] = 2'b00;
  endfunction 

  
  constraint data_size {
    wdata.size() == awlen + 1;
    wstrb.size() == awlen + 1;
  }
   
  constraint wstrb_nonzero {
    foreach(wstrb[i]) {
      wstrb[i] != 0;
      wstrb[i] inside {4'h1, 4'h2, 4'h3, 4'h4, 4'h5, 4'h6, 4'h7,
                       4'h8, 4'h9, 4'hA, 4'hB, 4'hC, 4'hD, 4'hE, 4'hF};
    }
  }
   
  constraint addr_range {
   soft  awaddr inside {[0:32'hfff]};
      soft  araddr inside {[0:32'hfff]};
  }
   
  constraint aw_size {
    awsize == 2;
    arsize == 2;
  }
      
      constraint addr_alignment {
  soft  awaddr % (1 << awsize) == 0;
        soft  araddr % (1 << arsize) == 0;      
}
   
  constraint burst_types {
    awburst inside {0, 1, 2};
      arburst inside {0, 1, 2};
  }
   
  constraint awlen_range {
    awlen inside {[0:5]};
     arlen inside {[0:5]};
    
  }
   
  constraint wdata_values {
    foreach(wdata[i]) {
      wdata[i] inside {[32'h00000000:32'hFFFFFFFF]};
    }
  }
   
  function void post_randomize();
 
    if(wdata.size() != awlen + 1) begin
      wdata = new[awlen + 1];
      foreach(wdata[i]) wdata[i] = $urandom();
    end
     
    if(wstrb.size() != awlen + 1) begin
      wstrb = new[awlen + 1];
    end
     
    foreach(wstrb[i]) begin
      if(wstrb[i] == 0) begin
        wstrb[i] = 4'hF;
        `uvm_warning("SEQ_ITEM", $sformatf("wstrb[%0d] was 0, forced to 0xF", i))
      end
    end
     
    if(!write) begin
      if(rdata.size() != arlen + 1) begin
        rdata = new[arlen + 1];
      end
      if(rresp.size() != arlen + 1) begin
        rresp = new[arlen + 1];
      end
    end
  endfunction




    
  function string convert2string();
    string s;
    s = super.convert2string();
    $sformat(s, "%s\n write=%0d", s, write);
    if(write) begin
      $sformat(s, "%s\n AW: id=%0d addr=0x%0h len=%0d size=%0d burst=%0d", 
               s, awid, awaddr, awlen, awsize, awburst);
      $sformat(s, "%s\n W: data=", s);
      foreach(wdata[i]) begin
        $sformat(s, "%s 0x%0h", s, wdata[i]);
      end
      $sformat(s, "%s\n W: strb=", s);
      foreach(wstrb[i]) begin
        $sformat(s, "%s 0x%0h", s, wstrb[i]);
      end
    end else begin
      $sformat(s, "%s\n AR: id=%0d addr=0x%0h len=%0d size=%0d burst=%0d", 
               s, arid, araddr, arlen, arsize, arburst);
    end
    return s;
  endfunction
  
endclass
