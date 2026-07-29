
interface axi_interface(input logic clk,input logic rst);
  
  
//   logic w_en;
//   logic r_en;
  

// Write Address
  logic [3:0]  awid;
  logic [31:0] awaddr;
  logic [7:0]  awlen;
  logic [2:0]  awsize;
  logic [1:0]  awburst;
  logic        awvalid;
   logic        awready;

// Write Data
  logic [31:0] wdata;
  logic [3:0]  wstrb;
  logic        wlast;
  logic        wvalid;
   logic        wready;

// Write Response
  logic [3:0]  bid;
  logic [1:0]  bresp;
   logic        bvalid;
  logic        bready;

// Read Address
  logic [3:0]  arid;
  logic [31:0] araddr;
  logic [7:0]  arlen;
  logic [2:0]  arsize;
  logic [1:0]  arburst;
  logic        arvalid;
   logic        arready;

// Read Data
  logic [3:0]  rid;
  logic [31:0] rdata;
  logic [1:0]  rresp;
   logic        rlast;
   logic        rvalid;
  logic        rready;

  
  int is_check = 1;
  
/*
//for wrap burst 
//Bytes per Beat × Number of Beats

A WRAP burst wraps inside a region whose size is

Wrap Boundary = Number of Beats × Bytes per Beat  
this should be power of 2(wrap boundary)
 if not it is illegal
 
 */ 
  
  
 /* 
//for incr burst
Bytes per beat = 2^AWSIZE
Rule
The start address should be divisible by the number of bytes per beat.
Mathematically:
AWADDR % Bytes_per_beat == 0
*/
  
  logic [31:0] end_addr;

assign end_addr =
    awaddr + ((awlen + 1) << awsize) - 1;
  
  
  property four_k_check;
  @(posedge clk)
  disable iff(!rst)

  awvalid && awready
    |->
  (awaddr[31:12] == end_addr[31:12]);
endproperty
  
  
property awvalid_check;
  @(posedge clk) disable iff(!rst)
  awvalid && !awready |=> awvalid;
endproperty
  

property signal_stable;
  @(posedge clk) disable iff(!rst)
  awvalid && !awready |=> $stable({
  awaddr,
    awlen,
    awsize,
    awburst,
    awid
  
  
  });
endproperty
  
  
//legal burst type
property legal_burst;
  @(posedge clk) disable iff(!rst)
  awvalid |-> (awburst inside {2'b00,2'b01,2'b10})
  
endproperty
  
//No duplicate transactions
property wrap_burst;
  @(posedge clk) disable iff(!rst)
  (awvalid && (awburst == 2'b10)) |-> (awlen inside {8'd1,8'd3,8'd7,8'd15})
endproperty
  
//addr alinment
  
property aw_2_byte;
   @(posedge clk) disable iff(!rst)
  awvalid && awready && (awsize == 3'd1) |-> (awaddr[0] == 0)
endproperty
  
property aw_4_byte;
   @(posedge clk) disable iff(!rst)
  awvalid && awready && (awsize == 3'd2) |-> (awaddr[1:0] == 0)
endproperty
  
property aw_8_byte;
   @(posedge clk) disable iff(!rst)
  awvalid && awready && (awsize == 3'd3) |-> (awaddr[2:0] == 0)
endproperty
  
property aw_channel_no_unknown;
    @(posedge clk)
    disable iff(!rst)

    awvalid
    |->
    !$isunknown({
        awvalid,
        awready,
        awaddr,
        awlen,
        awsize,
        awburst,
        awid
    });
endproperty

assert property(awvalid_check);
assert property(signal_stable);
assert property(legal_burst);
assert property(wrap_burst);
  assert property(aw_2_byte);
  assert property(aw_4_byte);
    assert property(aw_8_byte);
assert property(aw_channel_no_unknown);
  
  
  assert property(awvalid_check)
else
  $error("[%0t] AWVALID protocol violation: AWVALID deasserted before AWREADY.", $time);

assert property(signal_stable)
else
  $error("[%0t] AW Channel violation: Address/control signals changed while AWVALID=1 and AWREADY=0.", $time);

assert property(legal_burst)
else
  $error("[%0t] Illegal AWBURST value: AWBURST=%0d.", $time, awburst);

assert property(wrap_burst)
else
  $error("[%0t] Illegal WRAP burst length: AWLEN=%0d. Allowed values are 1, 3, 7, and 15.", $time, awlen);

assert property(aw_2_byte)
else
  $error("[%0t] 2-byte alignment violation: AWADDR=0x%08h, AWSIZE=%0d.", $time, awaddr, awsize);

assert property(aw_4_byte)
else
  $error("[%0t] 4-byte alignment violation: AWADDR=0x%08h, AWSIZE=%0d.", $time, awaddr, awsize);

assert property(aw_8_byte)
else
  $error("[%0t] 8-byte alignment violation: AWADDR=0x%08h, AWSIZE=%0d.", $time, awaddr, awsize);

assert property(aw_channel_no_unknown)
else
  $error("[%0t] AW Channel contains X/Z values. AWVALID=%b AWREADY=%b AWADDR=%h AWLEN=%0d AWSIZE=%0d AWBURST=%0d AWID=%0d",
         $time, awvalid, awready, awaddr, awlen, awsize, awburst, awid);
 
  

  
property wvalid_check;
  @(posedge clk) disable iff(!rst)
  wvalid && !wready |=> wvalid;
endproperty
  
  

  
property w_signal_stable;
  @(posedge clk) disable iff(!rst)
  awvalid && !awready |=> $stable({
  	wlast,
    wstrb,
    wdata
  	
  });
endproperty
  

  
 
property w_channel_no_unknown;
    @(posedge clk)
    disable iff(!rst)

    awvalid
    |->
    !$isunknown({
       	wlast,
    wstrb,
    wdata
  	 
    });
endproperty
  
  assert property(wvalid_check);
    assert property(w_signal_stable);
      assert property(w_channel_no_unknown);
      
      
property bvalid_check;
  
  @(posedge clk) disable iff(!rst)
  bvalid && !bready |=> bvalid;
  
endproperty
  
  
property bresp_legal;
  @(posedge clk) disable iff(!rst)
  bvalid |-> (bresp inside {2'b00,2'b01,2'b10,2'b11});
  
endproperty
  
  
property b_channel_stable;
  @(posedge clk) disable iff(!rst)
  bvalid && !bready |-> $stable({
  	bid,
    bresp
    
  });
  
  
endproperty
        

 
property b_channel_no_unknown;
    @(posedge clk)
    disable iff(!rst)

    awvalid
    |->
    !$isunknown({
       bresp,
      bid
  	 
    });
endproperty
  
  
  assert property(bvalid_check);
  assert property(bresp_legal);
  assert property(b_channel_stable);
    assert property(b_channel_no_unknown); 
      
//  property four_k_check;
//   @(posedge clk) disable iff(!rst)
//   awvalid && awready |->
//     ((awaddr[11:0] + ((awlen + 1) << awsize)) <= 12'd4096);
// endproperty

assert property(four_k_check)
else begin
  $error("[%0t] AXI 4KB Boundary Violation! AWADDR=0x%08h AWLEN=%0d AWSIZE=%0d AWBURST=%0d",
         $time, awaddr, awlen, awsize, awburst);
end 
      
      
      
      
 
  
property arvalid_check;
  @(posedge clk) disable iff(!rst)
  arvalid && !arready |=> arvalid;
endproperty
  

property ar_signal_stable;
  @(posedge clk) disable iff(!rst)
  arvalid && !arready |=> $stable({
  araddr,
    arlen,
    arsize,
    arburst,
    arid
  
  
  });
endproperty
  
  
//legal burst type
property ar_legal_burst;
  @(posedge clk) disable iff(!rst)
  arvalid |-> (arburst inside {2'b00,2'b01,2'b10})
  
endproperty
  
//No duplicate transactions
property ar_wrap_burst;
  @(posedge clk) disable iff(!rst)
  (arvalid && (arburst == 2'b10)) |-> (arlen inside {8'd1,8'd3,8'd7,8'd15})
endproperty
  
//addr alinment
  
property ar_2_byte;
   @(posedge clk) disable iff(!rst)
  arvalid && arready && (arsize == 3'd1) |-> (araddr[0] == 0)
endproperty
  
property ar_4_byte;
   @(posedge clk) disable iff(!rst)
  arvalid && arready && (arburst == 2'b10) && (arburst == 2'b10) && (arsize == 3'd2) |-> (araddr[1:0] == 0)
endproperty
  
property ar_8_byte;
   @(posedge clk) disable iff(!rst)
  arvalid && arready && (arsize == 3'd3) |-> (araddr[2:0] == 0)
endproperty
  
property ar_channel_no_unknown;
    @(posedge clk)
    disable iff(!rst)

    awvalid
    |->
    !$isunknown({
        arvalid,
        arready,
        araddr,
        arlen,
        arsize,
        arburst,
        arid
    });
endproperty

      assert property(arvalid_check);
      assert property(ar_signal_stable);
      assert property(ar_legal_burst);
     assert property(ar_wrap_burst);
     assert property(ar_2_byte);
     assert property(ar_4_byte);
      assert property(ar_8_byte);
       assert property(ar_channel_no_unknown);
  

  

  
property rvalid_check;
  @(posedge clk) disable iff(!rst)
  rvalid && !rready |=> rvalid;
endproperty
  
  

  
property r_signal_stable;
  @(posedge clk) disable iff(!rst)
  awvalid && !awready |=> $stable({
  	rdata,
    rid,
    rresp,
    rlast
   
  	
  });
endproperty
  

  
 
property r_channel_no_unknown;
    @(posedge clk)
    disable iff(!rst)

    awvalid
    |->
    !$isunknown({
        	rdata,
    rid,
    rresp,
    rlast
   
  	 
    });
endproperty
  
        assert property(rvalid_check);
          assert property(r_signal_stable);
             assert property(r_channel_no_unknown);
       
      
      
      
      
      
  
      
        
endinterface
