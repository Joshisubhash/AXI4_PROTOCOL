`timescale 1ns / 1ps




module DP_RAM #(
parameter data_width = 32,
parameter addr_width = 32,
parameter depth = 1024,

parameter id = 4,

parameter len = 8,
parameter size = 3,
parameter burst = 2,
parameter resp = 2

)(

input clk,
input rst,


//port A
input wire a_w_en,
input wire a_r_en,


input [(data_width/8)-1:0] ram_wstrb,
input [addr_width-1:0] a_addr,
input [data_width - 1:0] a_w_data,

output reg [data_width-1:0] a_r_data,



//port B

input wire b_w_en,
input wire b_r_en,

input [addr_width-1:0] b_addr,
input [data_width - 1:0] b_w_data,

output reg [data_width-1:0] b_r_data


);







reg [data_width-1:0]mem[0:depth-1];


always @(posedge clk)begin

if (rst)begin
a_r_data <= 0;
b_r_data <= 0;
end else begin

if(a_w_en && b_w_en && (a_addr == b_addr))begin
$error("collsion");
end else begin

if(a_w_en)begin
//mem[a_addr] <= a_w_data;


                     if(ram_wstrb[0])
                       mem[a_addr >> 2][7:0] <= a_w_data[7:0];
                    
                    if(ram_wstrb[1])
                        mem[a_addr >> 2][15:8] <= a_w_data[15:8];
                    
                    if(ram_wstrb[2])
                        mem[a_addr >> 2][23:16] <= a_w_data[23:16];
                    
                    if(ram_wstrb[3])
                        mem[a_addr >> 2][31:24] <= a_w_data[31:24];
                                        
               


end 

if(a_r_en) begin
a_r_data <= mem[a_addr];
end



if(b_w_en)begin
//mem[b_addr] <= b_w_data;


                    if(ram_wstrb[0])
                       mem[b_addr >> 2][7:0] <= b_w_data[7:0];
                    
                    if(ram_wstrb[1])
                        mem[b_addr >> 2][15:8] <= b_w_data[15:8];
                    
                    if(ram_wstrb[2])
                        mem[b_addr >> 2][23:16] <= b_w_data[23:16];
                    
                    if(ram_wstrb[3])
                        mem[b_addr >> 2][31:24] <= b_w_data[31:24];
                                        
               









end 

if(b_r_en) begin
b_r_data <= mem[b_addr];
end



end

end

end

endmodule





module aw_fifo#(
parameter width = 32,
parameter depth = 16,
parameter ptr_width = 5,
parameter addr_width = 32,

parameter id = 4,

parameter len = 8,
parameter size = 3,
parameter burst = 2,
parameter resp = 2



)(
input clk,
input rst,

input wire w_en,
input wire r_en,

//input [width-1:0]w_data,

input [id-1:0]awid,
input [addr_width-1:0]awaddr,
input [len-1:0]awlen,
input [size-1:0]awsize,
input [burst-1:0]awburst,
input awvalid,



//output reg [width-1:0]r_data,


output reg [id-1:0]out_awid,
output reg [addr_width-1:0]out_awaddr,
output reg [len-1:0]out_awlen,
output reg [size-1:0]out_awsize,
output reg [burst-1:0]out_awburst,
output reg out_awvalid,












output wire full,
output wire empty

);



typedef struct packed { 
logic [id-1:0]             local_awid;
logic [addr_width-1:0] local_awaddr;
logic [len-1:0]local_awlen;
logic [size-1:0]local_awsize;
logic [burst-1:0]local_awburst;
logic local_awvalid;



}aw_req_t;








 aw_req_t mem[0:depth-1]; 
 
 
reg [ptr_width-1:0] wptr;
reg [ptr_width-1:0] rptr;

assign empty = (wptr == rptr);
assign full = (wptr[ptr_width-1] != rptr[ptr_width-1] && wptr[ptr_width-2:0] == rptr[ptr_width-2:0]);


always @(posedge clk)begin

if(rst)begin
//r_data <= 0;
wptr <= 0;
rptr <= 0;
end else begin
if(w_en && !full)begin
//mem[wptr[ptr_width-2:0]] <= w_data;
mem[wptr[ptr_width-2:0]].local_awid <= awid;
mem[wptr[ptr_width-2:0]].local_awaddr <= awaddr;
mem[wptr[ptr_width-2:0]].local_awlen <= awlen;
mem[wptr[ptr_width-2:0]].local_awsize <= awsize;
mem[wptr[ptr_width-2:0]].local_awburst <= awburst;
mem[wptr[ptr_width-2:0]].local_awvalid <= awvalid;
 





wptr <= wptr + 1'b1;
end 

if(r_en && !empty) begin
//r_data <= mem[rptr[ptr_width-2:0]];


  out_awid <= mem[rptr[ptr_width-2:0]].local_awid ;   
  out_awaddr <=  mem[rptr[ptr_width-2:0]].local_awaddr;   
  out_awlen <=  mem[rptr[ptr_width-2:0]].local_awlen;
  out_awsize <=  mem[rptr[ptr_width-2:0]].local_awsize;    
  out_awburst <= mem[rptr[ptr_width-2:0]].local_awburst;  
  out_awvalid <= mem[rptr[ptr_width-2:0]].local_awvalid; 
 


 


rptr <= rptr + 1'b1; 
end 

end


end

endmodule














module ar_fifo#(
parameter width = 32,
parameter depth = 16,
parameter ptr_width = 5,
parameter addr_width = 32,

parameter id = 4,

parameter len = 8,
parameter size = 3,
parameter burst = 2,
parameter resp = 2



)(
input clk,
input rst,

input wire w_en,
input wire r_en,




input [addr_width-1:0] araddr, 
input [id-1:0] arid,
 

input [len-1:0] arlen,
input [size-1:0] arsize,
input [burst-1:0] arburst,

input arvalid,

 



//read data


output reg [id-1:0]out_arid,
output reg [addr_width-1:0]out_araddr,
output reg [len-1:0]out_arlen,
output reg [size-1:0]out_arsize,
output reg [burst-1:0]out_arburst,
output reg out_arvalid,









output wire full,
output wire empty

);





typedef struct packed { 
logic [id-1:0]             local_arid;
logic [addr_width-1:0] local_araddr;
logic [len-1:0]local_arlen;
logic [size-1:0]local_arsize;
logic [burst-1:0]local_arburst;
logic local_arvalid;



}ar_req_t;





 ar_req_t mem[0:depth-1];
 
 
reg [ptr_width-1:0] wptr;
reg [ptr_width-1:0] rptr;

assign empty = (wptr == rptr);
assign full = (wptr[ptr_width-1] != rptr[ptr_width-1] && wptr[ptr_width-2:0] == rptr[ptr_width-2:0]);


always @(posedge clk)begin

if(rst)begin
//r_data <= 0;
wptr <= 0;
rptr <= 0;
end else begin
if(w_en && !full)begin
//mem[wptr[ptr_width-2:0]] <= w_data;
mem[wptr[ptr_width-2:0]].local_arid <= arid;
mem[wptr[ptr_width-2:0]].local_araddr <= araddr;
mem[wptr[ptr_width-2:0]].local_arlen <= arlen;
mem[wptr[ptr_width-2:0]].local_arsize <= arsize;
mem[wptr[ptr_width-2:0]].local_arburst <= arburst;
mem[wptr[ptr_width-2:0]].local_arvalid <= arvalid;
 





wptr <= wptr + 1'b1;
end 

if(r_en && !empty) begin
//r_data <= mem[rptr[ptr_width-2:0]];


  out_arid <= mem[rptr[ptr_width-2:0]].local_arid ;   
  out_araddr <=  mem[rptr[ptr_width-2:0]].local_araddr;   
  out_arlen <=  mem[rptr[ptr_width-2:0]].local_arlen;
  out_arsize <=  mem[rptr[ptr_width-2:0]].local_arsize;    
  out_arburst <= mem[rptr[ptr_width-2:0]].local_arburst;  
  out_arvalid <= mem[rptr[ptr_width-2:0]].local_arvalid; 
 


 


rptr <= rptr + 1'b1; 
end 

end


end

endmodule









/*

module write_fsm #(

parameter id = 4,
parameter addr_width = 32,
parameter data_width = 32,
parameter len = 8,
parameter size = 3,
parameter burst = 2,
parameter resp = 2

)(

input clk,
input rst,

input [id-1:0]awid,
input [addr_width-1:0]awaddr,
input [len-1:0]awlen,
input [size-1:0]awsize,
input [burst-1:0]awburst,
input awvalid,

output wire awready,

input [(data_width/8)-1:0]wstrb,
input [data_width-1:0] wdata,
input wlast,
input wvalid,
output wire wready,

output reg [id-1:0] bid,
output reg [resp -1 :0]bresp,

input bready,

output wire bvalid,





output wire[addr_width-1:0] ram_w_addr,
output    wire              ram_we,
output wire [data_width-1:0] ram_wdata,
output wire [(data_width/8)-1:0] ram_wstrb


);


typedef enum reg[2:0]{
idel = 0,
//wait_w_addr = 1,
wait_w_data = 1,
//sample_data = 3,
//send_b_resp = 4,
wait_b_resp = 2

}state_t;


state_t state;

reg [len-1:0] local_awlen;  
 reg [size-1:0] local_awsize;  
 reg [burst-1:0] local_awburst;
 reg [addr_width-1:0]local_awaddr;
 
  reg [addr_width-1:0]start_addr;
   wire [addr_width-1:0]end_addr;

reg [addr_width-1:0] wrap_base;
wire [addr_width-1:0] next_addr;
wire [addr_width-1:0]wrap_size;

reg [data_width-1:0] local_wdata;
reg local_wlast;                  
reg local_wvalid;                 

reg local_bready;

reg [len-1:0]brst_cnt;

reg [id-1:0]local_awid;





assign awready = (state == idel);
assign wready  = (state == wait_w_data);
assign bvalid  = (state == wait_b_resp);




assign end_addr = start_addr + ((1 << awsize)*(awlen+1)) - 1;


      assign wrap_size = (1 << local_awsize) * (local_awlen + 1);
//      assign  wrap_base = (local_awaddr / wrap_size) * wrap_size;             
      assign  next_addr = local_awaddr + (1 << local_awsize);
                
 

assign ram_w_addr = local_awaddr >> 2;
assign ram_wdata = wdata;
assign ram_we = (state == wait_w_data) && wvalid && wready;
assign ram_wstrb = wstrb;


//reg [31:0] mem [0:1023];

always @(posedge clk)begin
if (rst)begin
state <= idel;
brst_cnt <= 0;
//awready  <= 0;
//wready   <= 0;
//bvalid   <= 0;
bid <= 0;
bresp    <= 0;
local_awaddr <= 0;

local_awlen    <= 0;
local_awsize   <= 0;
local_awburst  <= 0;
//local_wdata    <= 0;
local_awid     <= 0;


end else begin


                  
    

case(state)
idel : begin
//        awready <= 1;
        if(awvalid && awready)begin
        state <= wait_w_data;
        local_awaddr <= awaddr;
        start_addr <= awaddr;
        local_awlen <= awlen;
        local_awsize <= awsize;
        local_awburst <= awburst;
        local_awid <= awid;
        brst_cnt <= 0;
        
        
//        wrap_base <= (local_awaddr / wrap_size) * wrap_size; 
        // DONT  USE local_addr here as it might update in next cycle, so we might get wrong wrap_base
        wrap_base <= (awaddr / wrap_size) * wrap_size; 
        
        end else begin
        state <= idel;
        
        end


      

        end 
 
 
wait_w_data : begin
//                 awready <= 0;
//                 wready <= 1;


            if(start_addr[31:12] == end_addr[31:12])begin
                if(wvalid && wready)begin
                
                //                when accessing your Verilog memory, you must convert that byte address into a word index. that why  >> 2
                 
               
               if(local_awburst == 0)begin
               

                                        
               
               
                brst_cnt <= brst_cnt + 1'b1;
                
                if(brst_cnt == local_awlen)begin
                bid <= local_awid;
                if(wlast)begin
                state <= wait_b_resp;
                 bresp <= 2'b00;
                end else begin
                 bresp <= 2'b10;
                  state <= wait_b_resp;
                end
               
                end else begin
                state <= wait_w_data;
                 
                end




                end else if(local_awburst == 1)begin

                 local_awaddr <= local_awaddr + (1 << local_awsize);
                brst_cnt <= brst_cnt + 1'b1;
                
                if(brst_cnt == local_awlen)begin
                bid <= local_awid;
                if(wlast)begin
                state <= wait_b_resp;
                 bresp <= 2'b00;
                end else begin
                 bresp <= 2'b10;
                  state <= wait_b_resp;
                end
               
                end else begin
                state <= wait_w_data;
                 
                end
                
                
                
                
                
                
                
                
                
                end
                
                else if(local_awburst == 2)begin
                
                
                
              
                if(next_addr >= wrap_size + wrap_base)begin
                local_awaddr <= wrap_base;
                end else begin
                local_awaddr <= next_addr;
                end
                
                 brst_cnt <= brst_cnt + 1'b1;
                
                if(brst_cnt == local_awlen)begin
                bid <= local_awid;
                if(wlast)begin
                state <= wait_b_resp;
                 bresp <= 2'b00;
                end else begin
                 bresp <= 2'b10;
                  state <= wait_b_resp;
                end
               
                end else begin
                state <= wait_w_data;
                 
                end
                
                
                
                end 
                //end of wrap burst transfer
                
                
                


               end
             
               end else begin
                 bresp <= 2'b10;
                bid   <= local_awid; // tag the response with the right transaction ID
        state <= wait_b_resp;  
        
//        state <= wait_b_resp is the one line that matters most it's what makes bvalid (= state==wait_b_resp) finally assert, 
//        so B channel handshake can happen and the master gets its response instead of the bus hanging forever.
        
               end
                end
                
 
                                
wait_b_resp : begin

                if(bready && bvalid)begin
                state <= idel;
                end else begin
                state <= wait_b_resp;
                
                end
                end

endcase



end



end






endmodule





*/





module write_fsm #(
    parameter id = 4,
    parameter addr_width = 32,
    parameter data_width = 32,
    parameter len = 8,
    parameter size = 3,
    parameter burst = 2,
    parameter resp = 2
)(
    input clk,
    input rst,
    input [id-1:0] awid,
    input [addr_width-1:0] awaddr,
    input [len-1:0] awlen,
    input [size-1:0] awsize,
    input [burst-1:0] awburst,
    input awvalid,
    output wire awready,
    input [(data_width/8)-1:0] wstrb,
    input [data_width-1:0] wdata,
    input wlast,
    input wvalid,
    output wire wready,
    output reg [id-1:0] bid,
    output reg [resp-1:0] bresp,
    input bready,
    output wire bvalid,
    output wire[addr_width-1:0] ram_w_addr,
    output wire ram_we,
    output wire [data_width-1:0] ram_wdata,
    output wire [(data_width/8)-1:0] ram_wstrb
);

typedef enum reg[2:0] {
    IDLE = 0,
    WAIT_W_DATA = 1,
    WAIT_B_RESP = 2,
    WAIT_B_RESP_ERROR = 3  // <-- NEW STATE for error cases
} state_t;

state_t state;

reg [len-1:0] local_awlen;  
reg [size-1:0] local_awsize;  
reg [burst-1:0] local_awburst;
reg [addr_width-1:0] local_awaddr;
reg [addr_width-1:0] start_addr;
wire [addr_width-1:0] end_addr;
reg [addr_width-1:0] wrap_base;
wire [addr_width-1:0] next_addr;
wire [addr_width-1:0] wrap_size;
reg [len-1:0] brst_cnt;
reg [id-1:0] local_awid;
reg error_occurred;  // <-- NEW flag

assign awready = (state == IDLE);
assign wready  = (state == WAIT_W_DATA);
assign bvalid  = (state == WAIT_B_RESP || state == WAIT_B_RESP_ERROR);

assign end_addr = start_addr + ((1 << awsize)*(awlen+1)) - 1;
assign wrap_size = (1 << local_awsize) * (local_awlen + 1);
assign next_addr = local_awaddr + (1 << local_awsize);

assign ram_w_addr = local_awaddr >> 2;
assign ram_wdata = wdata;
assign ram_we = (state == WAIT_W_DATA) && wvalid && wready && !error_occurred;
assign ram_wstrb = wstrb;
  
//   always @(posedge clk) begin
//     $display("[%0t] state=%0d awvalid=%b awready=%b wvalid=%b wready=%b",
//              $time,
//              state,
//              awvalid,
//              awready,
//              wvalid,
//              wready);
// end

always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        brst_cnt <= 0;
        bid <= 0;
        bresp <= 0;
        local_awaddr <= 0;
        local_awlen <= 0;
        local_awsize <= 0;
        local_awburst <= 0;
        local_awid <= 0;
        error_occurred <= 0;
    end else begin
        case(state)
            IDLE : begin
                if(awvalid && awready) begin
                    state <= WAIT_W_DATA;
                    local_awaddr <= awaddr;
                    start_addr <= awaddr;
                    local_awlen <= awlen;
                    local_awsize <= awsize;
                    local_awburst <= awburst;
                    local_awid <= awid;
                    brst_cnt <= 0;
                    error_occurred <= 0;
                    wrap_base <= (awaddr / wrap_size) * wrap_size;
                end
            end
 
            WAIT_W_DATA : begin
                // Check for 4KB boundary violation first
                if(start_addr[31:12] != end_addr[31:12]) begin
                    error_occurred <= 1;
//                     state <= WAIT_B_RESP_ERROR;
                    bresp <= 2'b10; // SLVERR
                    bid <= local_awid;
                  
                  
                  if(wvalid && wready) begin
                    // Process this data beat
                    if(local_awburst == 2'b01) begin
                        local_awaddr <= local_awaddr + (1 << local_awsize);
                    end else if(local_awburst == 2'b10) begin
                        if(next_addr >= wrap_size + wrap_base)
                            local_awaddr <= wrap_base;
                        else
                            local_awaddr <= next_addr;
                    end
                    // For FIXED burst (2'b00), address stays same
                    
                    brst_cnt <= brst_cnt + 1;
                    
                    if(brst_cnt == local_awlen) begin
                        // This is the last beat
                        if(wlast) begin
                            // Correct: wlast asserted on last beat
//                             state <= WAIT_B_RESP;
                           state <= WAIT_B_RESP_ERROR;
//                             bresp <= 2'b00; // OKAY
                            bid <= local_awid;
                        end else begin
                            // ERROR: wlast not asserted on last beat
                            state <= WAIT_B_RESP_ERROR;
                            bresp <= 2'b10; // SLVERR
                            bid <= local_awid;
                        end
                    end else begin
                        // More beats to come
                        state <= WAIT_W_DATA;
//                        state <= WAIT_B_RESP_ERROR;
                    end
                end
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                end else if(wvalid && wready) begin
                    // Process this data beat
                    if(local_awburst == 2'b01) begin
                        local_awaddr <= local_awaddr + (1 << local_awsize);
                    end else if(local_awburst == 2'b10) begin
                        if(next_addr >= wrap_size + wrap_base)
                            local_awaddr <= wrap_base;
                        else
                            local_awaddr <= next_addr;
                    end
                    // For FIXED burst (2'b00), address stays same
                    
                    brst_cnt <= brst_cnt + 1;
                    
                    if(brst_cnt == local_awlen) begin
                        // This is the last beat
                        if(wlast) begin
                            // Correct: wlast asserted on last beat
                            state <= WAIT_B_RESP;
                            bresp <= 2'b00; // OKAY
                            bid <= local_awid;
                        end else begin
                            // ERROR: wlast not asserted on last beat
                            state <= WAIT_B_RESP_ERROR;
                            bresp <= 2'b10; // SLVERR
                            bid <= local_awid;
                        end
                    end else begin
                        // More beats to come
                        state <= WAIT_W_DATA;
                    end
                end
            end

            WAIT_B_RESP : begin
                if(bready && bvalid) begin
                    state <= IDLE;
                end
            end
            
            WAIT_B_RESP_ERROR : begin
                if(bready && bvalid) begin
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule

















//rvalid issue why are asserting rvalid before data is ready?

//module read_fsm#(
//parameter addr_depth = 1024,
//parameter addr_width = 32,
//parameter data_width = 32,
//parameter len = 8,
//parameter size = 4,
//parameter burst = 2,
//parameter resp=2,
//parameter id = 4

//)(

//input clk,
//input rst,

////read address

//input [addr_width-1:0] araddr, 
//input [id-1:0] arid,
//output reg [id-1:0] rid,

//input [len-1:0] arlen,
//input [size-1:0] arsize,
//input [burst-1:0] arburst,

//input arvalid,

//output wire arready,



////read data


//output reg [data_width-1:0] rdata,
//output reg                   rvalid,
//output reg                      rlast,
//output reg [resp-1:0]       rresp,
//input                       rready,



//output wire [addr_width-1:0] ram_r_addr,
//output wire ram_ren


//);




//typedef enum reg [2:0]{
//idel = 0,
////send_r_addr = 1,
//send_r_data = 1
////settle_idle = 2

//}state_t;

//state_t state;

////reg [addr_width-1:0]rd_addr;
////reg [len-1:0] rd_arlen;
////reg [size-1:0] rd_arsize;
////reg [burst-1:0] rd_burst;

////reg [len-1:0] brst_cnt;


////reg [id-1:0] local_arid;

////reg [addr_width-1:0]wrap_base;


////wire [addr_width-1:0]next_addr;
////wire [addr_width-1:0]wrap_size;
////wire [addr_width-1:0]end_addr;
////reg [addr_width-1:0]start_addr;






//// Replace with 2 slot version:
//reg [addr_width-1:0] rd_addr    [1:0];
//reg [len-1:0]        rd_arlen   [1:0];
//reg [size-1:0]       rd_arsize  [1:0];
//reg [burst-1:0]      rd_burst   [1:0];
//reg [len-1:0]        brst_cnt   [1:0];
//reg [id-1:0]         local_arid [1:0];
//reg [addr_width-1:0] wrap_base  [1:0];
//reg [addr_width-1:0] start_addr [1:0];
//reg                  slot_valid [1:0];



//assign ram_r_addr = rd_addr >> 2;
//assign ram_ren = (state == send_r_data);



//assign next_addr = rd_addr + (1 << rd_arsize);

//assign wrap_size = (1 << rd_arsize) * (rd_arlen + 1);

//assign end_addr = start_addr + ((1 << rd_arsize) * (rd_arlen + 1)) - 1;

////localparam addr_len = $clog2(addr_width);
//reg [data_width-1:0]mem[0:addr_depth-1];

//assign arready = (state == idel);

//always @(posedge clk) begin

//if(rst)begin
// brst_cnt <= 0;
//rresp <= 2'b00;
//rvalid <= 0;
//rlast <= 0;

//state <= idel;
//end else begin
//case(state)
//idel : begin
       
////      arready <= 1;
//       if(arready && arvalid)begin
//        rd_addr <= araddr;
//        start_addr <= araddr;
//       rd_arlen <= arlen;
//       rd_arsize <= arsize;
//       rd_burst <= arburst;
//       local_arid <= arid;
       
//       wrap_base <= (araddr / wrap_size) * wrap_size;
       
//       rlast <= 0;
//brst_cnt <= 0;
//       rvalid <= 1;
//       state <= send_r_data;
//       end
//       end
       
       
// send_r_data : begin
////                arready <= 0;
                
////                if(rlast)begin
////                state <= settle_idle;
//                if(rvalid && rready && rlast) begin
//                   state <= idel;
//                   rlast <= 0;
//                   brst_cnt <= 0;
//                   rvalid <= 0;
//                end 
                
//                else if(rvalid && rready) begin
               
//               rid <= local_arid;
               
//               if(start_addr[31:12] == end_addr[31:12])begin
               
//                if(rd_burst == 2'b00)begin
//                if(brst_cnt <= rd_arlen)begin
                
                
                 
//                 //addr decoder check
//                if((rd_addr >> 2) >= addr_depth) begin
//                rdata <= 0;
//                rlast <= 1;
//                rresp <= 2'b11; // DECERR
//                end else begin
//                 rresp <= 2'b00;
//                  rdata <= mem[rd_addr >> 2];
//                 brst_cnt <= brst_cnt + 1'b1;
//                 end
////                 if(brst_cnt == rd_arlen - 1)begin
//                   if(brst_cnt == rd_arlen)begin
//                 rlast <= 1;
//                 end
//                end else begin
//                brst_cnt <= 0;
//                end
//                end else if(rd_burst == 2'b01)begin
//                if (brst_cnt <= rd_arlen)begin 
                
//                if((rd_addr >> 2) >= addr_depth) begin
//                rdata <= 0;
//                rlast <= 1;
//                rresp <= 2'b11; // DECERR
//                end else begin
//                 rd_addr <= rd_addr + (1 << rd_arsize);
//                  rdata <= mem[rd_addr >> 2];
//                brst_cnt <= brst_cnt + 1'b1;
//                 rresp <= 2'b00;
//                 end
////                if(brst_cnt == rd_arlen - 1)begin
//                if(brst_cnt == rd_arlen)begin
//                 rlast <= 1;
//                 end
                 
//                end else begin
//                brst_cnt <= 0;
//                end
//                end else if(rd_burst == 2'b10)begin
//                 if (brst_cnt <= rd_arlen)begin 
                
//                if((rd_addr >> 2) >= addr_depth) begin
//                rdata <= 0;
//                rlast <= 1;
//                rresp <= 2'b11; // DECERR
//                end else begin
//                rdata <= mem[rd_addr >> 2];
//                 brst_cnt <= brst_cnt + 1'b1;
//                if(next_addr >= wrap_size + wrap_base)begin
//                rd_addr <= wrap_base;
                 
//                 rresp <= 2'b00;
//                end else begin
                
//                 rd_addr <= next_addr;
//                 rresp <= 2'b00;
//                end
                
//                 end
////                if(brst_cnt == rd_arlen - 1)begin
//                if(brst_cnt == rd_arlen)begin
//                 rlast <= 1;
//                 end
                 
//                end else begin
//                brst_cnt <= 0;
//                end
                
                
                
                
                
//                end else begin
//                rresp  <= 2'b10;
//                rlast  <= 1;
//                rdata  <= 0;
//               rvalid <= 1;
//                end
                
                
                
//                end
                
                
                
                
              
//                end                
//                end
                
////   settle_idle : begin
////                  if(rlast && rvalid && rready)begin
////                  rlast <= 0;
////                  rvalid <= 0;
////                  brst_cnt <= 0;
////                  state <= idel;
////                  end
////                  end
       

//endcase

//end

//end


//endmodule







//module read_fsm#(
//parameter addr_depth = 1024,
//parameter addr_width = 32,
//parameter data_width = 32,
//parameter len = 8,
//parameter size = 3,
//parameter burst = 2,
//parameter resp=2,
//parameter id = 4

//)(

//input clk,
//input rst,

////read address

//input [addr_width-1:0] araddr, 
//input [id-1:0] arid,
//output reg [id-1:0] rid,

//input [len-1:0] arlen,
//input [size-1:0] arsize,
//input [burst-1:0] arburst,

//input arvalid,

//output wire arready,



////read data

////   output reg [id-1:0]rid;
//output reg [data_width-1:0] rdata,
//output reg                   rvalid,
//output reg                      rlast,
//output reg [resp-1:0]       rresp,
//input                       rready,



////output wire [addr_width-1:0] ram_r_addr,
////output wire ram_ren



//// Instead of internal mem
//// data comes from outside (RAM1 and RAM2)

//input [data_width-1:0] ram_rdata_0,  // from RAM1 slot 0
//input [data_width-1:0] ram_rdata_1,  // from RAM2 slot 1

//output wire [addr_width-1:0] ram_r_addr_0,
//output wire                  ram_ren_0,
//output wire [addr_width-1:0] ram_r_addr_1,
//output wire                  ram_ren_1




//);







//// Slot registers
//reg [addr_width-1:0] rd_addr    [1:0];
//reg [len-1:0]        rd_arlen   [1:0];
//reg [size-1:0]       rd_arsize  [1:0];
//reg [burst-1:0]      rd_burst   [1:0];
//reg [id-1:0]         local_arid [1:0];
//reg [addr_width-1:0] wrap_base  [1:0];
//reg [addr_width-1:0] start_addr [1:0];
//reg [len-1:0]        brst_cnt   [1:0];
//reg                  slot_valid [1:0];



//// Free slot
//reg                  free_slot;

//// Combinational per slot
//wire [addr_width-1:0] next_addr [1:0];
//wire [addr_width-1:0] wrap_size [1:0];
//wire [addr_width-1:0] end_addr  [1:0];

//// Response buffer
//typedef struct packed {
//    logic [id-1:0]         rid;
//    logic [data_width-1:0] rdata;
//    logic [resp-1:0]       rresp;
//    logic                  rlast;
//    logic                  valid;
//} rd_resp_t;





//rd_resp_t resp_buf_0 [3:0];  // slot 0 buffer
//rd_resp_t resp_buf_1 [3:0];  // slot 1 buffer

//reg [1:0] wptr_0;
//reg [1:0] rptr_0;

//reg [1:0] wptr_1;
//reg [1:0] rptr_1;




//// Add these:
//assign next_addr[0] = rd_addr[0] + (1 << rd_arsize[0]);
//assign next_addr[1] = rd_addr[1] + (1 << rd_arsize[1]);

//assign wrap_size[0] = (1 << rd_arsize[0]) * (rd_arlen[0] + 1);
//assign wrap_size[1] = (1 << rd_arsize[1]) * (rd_arlen[1] + 1);

//assign end_addr[0]  = start_addr[0] + ((1 << rd_arsize[0]) * (rd_arlen[0] + 1)) - 1;
//assign end_addr[1]  = start_addr[1] + ((1 << rd_arsize[1]) * (rd_arlen[1] + 1)) - 1;




 
// // ----------------------------------------
//// Slot State Definition
//// ----------------------------------------
//typedef enum reg [1:0] {
//    SLOT_IDLE    = 2'b00,
//    SLOT_READING = 2'b01,
//    SLOT_DONE    = 2'b10
//} slot_state_t;

//slot_state_t slot_state [1:0];






//// Assign RAM address per slot
//assign ram_r_addr_0 = rd_addr[0] >> 2;
//assign ram_r_addr_1 = rd_addr[1] >> 2;

//assign ram_ren_0 = (slot_state[0] == SLOT_READING);
//assign ram_ren_1 = (slot_state[1] == SLOT_READING);



 
 
// always_comb begin
// if(!slot_valid[0])begin
//    free_slot = 0;
//  end  else 
//      free_slot = 1;
  
 
// end
 
 
 
 
 
 
 
 
// assign arready = !(slot_valid[0] && slot_valid[1]);
 








//always @(posedge clk) begin
//    if(rst) begin
////        slot_state[0] <= SLOT_IDLE;

//   slot_valid[0]  <= 0;
//        slot_valid[1]  <= 0;
//        slot_state[0]  <= SLOT_IDLE;    // add
//        slot_state[1]  <= SLOT_IDLE;    // add

//wptr_0 <= 0;
//rptr_0 <= 0;
//wptr_1 <= 0;
//rptr_1 <= 0;

//resp_buf_0[0].valid <= 0;
//resp_buf_0[1].valid <= 0;
//resp_buf_0[2].valid <= 0;
//resp_buf_0[3].valid <= 0;

//resp_buf_1[0].valid <= 0;
//resp_buf_1[1].valid <= 0;
//resp_buf_1[2].valid <= 0;
//resp_buf_1[3].valid <= 0;



//    end else begin
//      case(slot_state[0])

//SLOT_IDLE : begin
//    if(arvalid && arready) begin
//        rd_addr    [free_slot] <= araddr;
//        start_addr [free_slot] <= araddr;
//        rd_arlen   [free_slot] <= arlen;
//        rd_arsize  [free_slot] <= arsize;
//        rd_burst   [free_slot] <= arburst;
//        local_arid [free_slot] <= arid;
//        brst_cnt   [free_slot] <= 0;
//        slot_valid [free_slot] <= 1;
//       wrap_base[free_slot] <= (araddr / wrap_size[free_slot]) * wrap_size[free_slot];
//        slot_state [free_slot] <= SLOT_READING;
//    end
//end


//SLOT_READING : begin

//    if(start_addr[0][31:12] != end_addr[0][31:12]) begin

//        resp_buf_0[wptr_0].rdata <= 0;
//        resp_buf_0[wptr_0].rresp <= 2'b10; // SLVERR
//        resp_buf_0[wptr_0].rid   <= local_arid[0];
//        resp_buf_0[wptr_0].rlast <= 1;
//        resp_buf_0[wptr_0].valid <= 1;

//        wptr_0 <= wptr_0 + 1;

//        slot_state[0] <= SLOT_DONE;

//    end
//    else begin

//        if((rd_addr[0] >> 2) >= addr_depth) begin

//            resp_buf_0[wptr_0].rdata <= 0;
//            resp_buf_0[wptr_0].rresp <= 2'b11; // DECERR

//        end
//        else begin

//            resp_buf_0[wptr_0].rdata <= ram_rdata_0;
//            resp_buf_0[wptr_0].rresp <= 2'b00; // OKAY

//        end

//        resp_buf_0[wptr_0].rid   <= local_arid[0];
//        resp_buf_0[wptr_0].rlast <= (brst_cnt[0] == rd_arlen[0]);
//        resp_buf_0[wptr_0].valid <= 1;

//        wptr_0 <= wptr_0 + 1;

//        brst_cnt[0] <= brst_cnt[0] + 1;

//        if(rd_burst[0] == 2'b00) begin
//            // FIXED
//        end
//        else if(rd_burst[0] == 2'b01) begin

//            rd_addr[0] <= rd_addr[0] + (1 << rd_arsize[0]);

//        end
//        else if(rd_burst[0] == 2'b10) begin

//            if(next_addr[0] >= wrap_size[0] + wrap_base[0])
//                rd_addr[0] <= wrap_base[0];
//            else
//                rd_addr[0] <= next_addr[0];

//        end

//        if(brst_cnt[0] == rd_arlen[0]) begin
//            slot_state[0] <= SLOT_DONE;
//        end

//    end

//end


//SLOT_DONE : begin

//    if(!resp_buf_0[rptr_0].valid) begin
//        slot_state[0] <= SLOT_IDLE;
//        slot_valid[0] <= 0;
//    end

//end

//endcase
        
        
        
        
        
     
//case(slot_state[1])
//    SLOT_IDLE : begin end

//    SLOT_READING : begin
//        if(start_addr[1][31:12] != end_addr[1][31:12]) begin
//            resp_buf_1[wptr_1].rdata <= 0;
//            resp_buf_1[wptr_1].rresp <= 2'b10;
//            resp_buf_1[wptr_1].rid   <= local_arid[1];
//            resp_buf_1[wptr_1].rlast <= 1;
//            resp_buf_1[wptr_1].valid <= 1;
//            wptr_1                   <= wptr_1 + 1;
//            slot_state[1]            <= SLOT_DONE;
//        end else begin
//            if((rd_addr[1] >> 2) >= addr_depth) begin
//                resp_buf_1[wptr_1].rdata <= 0;
//                resp_buf_1[wptr_1].rresp <= 2'b11;
//            end else begin
//                resp_buf_1[wptr_1].rdata <= ram_rdata_1;
//                resp_buf_1[wptr_1].rresp <= 2'b00;
//            end
//            resp_buf_1[wptr_1].rid   <= local_arid[1];
//            resp_buf_1[wptr_1].rlast <= (brst_cnt[1] == rd_arlen[1]);
//            resp_buf_1[wptr_1].valid <= 1;
//            wptr_1                   <= wptr_1 + 1;
//            brst_cnt[1]              <= brst_cnt[1] + 1;

//            if(rd_burst[1] == 2'b00) begin
//                // FIXED
//            end else if(rd_burst[1] == 2'b01) begin
//                rd_addr[1] <= rd_addr[1] + (1 << rd_arsize[1]);
//            end else if(rd_burst[1] == 2'b10) begin
//                if(next_addr[1] >= wrap_size[1] + wrap_base[1])
//                    rd_addr[1] <= wrap_base[1];
//                else
//                    rd_addr[1] <= next_addr[1];
//            end

//            if(brst_cnt[1] == rd_arlen[1]) begin
//                slot_state[1] <= SLOT_DONE;
//            end
//        end
//    end

//    SLOT_DONE : begin
//        if(!resp_buf_1[rptr_1].valid) begin
//            slot_state[1] <= SLOT_IDLE;
//            slot_valid[1] <= 0;
//        end
//    end
//endcase
        
        
        
        
        
        
        
        
        
        
        
//    end
//end





//always @(posedge clk) begin
//    if(rst) begin
//        rvalid <= 0;
//    end else begin
//        if(rvalid && rready && rlast) begin
//            rvalid <= 0;
//        end

//        if(rready || !rvalid) begin
//            if(resp_buf_0[rptr_0].valid) begin
//                rdata  <= resp_buf_0[rptr_0].rdata;
//                rid    <= resp_buf_0[rptr_0].rid;
//                rresp  <= resp_buf_0[rptr_0].rresp;
//                rlast  <= resp_buf_0[rptr_0].rlast;
//                rvalid <= 1;
//                resp_buf_0[rptr_0].valid <= 0;
//                rptr_0 <= rptr_0 + 1;

//            end else begin
//                rvalid <= 0;
//            end
            
//             if(resp_buf_1[rptr_1].valid) begin
//                rdata  <= resp_buf_1[rptr_1].rdata;
//                rid    <= resp_buf_1[rptr_1].rid;
//                rresp  <= resp_buf_1[rptr_1].rresp;
//                rlast  <= resp_buf_1[rptr_1].rlast;
//                rvalid <= 1;
//                resp_buf_1[rptr_1].valid <= 0;
//                rptr_1 <= rptr_1 + 1;

//            end else begin
//                rvalid <= 0;
//            end
//        end
//    end
//end








//endmodule




//// read fsm with round robin arbitater
//module read_fsm#(
//parameter addr_depth = 1024,
//parameter addr_width = 32,
//parameter data_width = 32,
//parameter len = 8,
//parameter size = 3,
//parameter burst = 2,
//parameter resp=2,
//parameter id = 4

//)(

//input clk,
//input rst,

////read address

//input [addr_width-1:0] araddr, 
//input [id-1:0] arid,
//output reg [id-1:0] rid,

//input [len-1:0] arlen,
//input [size-1:0] arsize,
//input [burst-1:0] arburst,

//input arvalid,

//output wire arready,



////read data

////   output reg [id-1:0]rid;
//output reg [data_width-1:0] rdata,
//output reg                   rvalid,
//output reg                      rlast,
//output reg [resp-1:0]       rresp,
//input                       rready,



////output wire [addr_width-1:0] ram_r_addr,
////output wire ram_ren



//// Instead of internal mem
//// data comes from outside (RAM1 and RAM2)

//input [data_width-1:0] ram_rdata_0,  // from RAM1 slot 0
//input [data_width-1:0] ram_rdata_1,  // from RAM2 slot 1

//output wire [addr_width-1:0] ram_r_addr_0,
//output wire                  ram_ren_0,
//output wire [addr_width-1:0] ram_r_addr_1,
//output wire                  ram_ren_1




//);







//// Slot registers
//reg [addr_width-1:0] rd_addr    [1:0];
//reg [len-1:0]        rd_arlen   [1:0];
//reg [size-1:0]       rd_arsize  [1:0];
//reg [burst-1:0]      rd_burst   [1:0];
//reg [id-1:0]         local_arid [1:0];
//reg [addr_width-1:0] wrap_base  [1:0];
//reg [addr_width-1:0] start_addr [1:0];
//reg [len-1:0]        brst_cnt   [1:0];
//reg                  slot_valid [1:0];

//// Free slot
//reg                  free_slot;

//// Combinational per slot
//wire [addr_width-1:0] next_addr [1:0];
//wire [addr_width-1:0] wrap_size [1:0];
//wire [addr_width-1:0] end_addr  [1:0];

//// Response buffer
//typedef struct packed {
//    logic [id-1:0]         rid;
//    logic [data_width-1:0] rdata;
//    logic [resp-1:0]       rresp;
//    logic                  rlast;
//    logic                  valid;
//} rd_resp_t;





//rd_resp_t resp_buf_0 [3:0];  // slot 0 buffer
//rd_resp_t resp_buf_1 [3:0];  // slot 1 buffer

//reg [1:0] wptr_0;
//reg [1:0] rptr_0;

//reg [1:0] wptr_1;
//reg [1:0] rptr_1;




//// Add these:
//assign next_addr[0] = rd_addr[0] + (1 << rd_arsize[0]);
//assign next_addr[1] = rd_addr[1] + (1 << rd_arsize[1]);

//assign wrap_size[0] = (1 << rd_arsize[0]) * (rd_arlen[0] + 1);
//assign wrap_size[1] = (1 << rd_arsize[1]) * (rd_arlen[1] + 1);

//assign end_addr[0]  = start_addr[0] + ((1 << rd_arsize[0]) * (rd_arlen[0] + 1)) - 1;
//assign end_addr[1]  = start_addr[1] + ((1 << rd_arsize[1]) * (rd_arlen[1] + 1)) - 1;




 
// // ----------------------------------------
//// Slot State Definition
//// ----------------------------------------
//typedef enum reg [1:0] {
//    SLOT_IDLE    = 2'b00,
//    SLOT_READING = 2'b01,
//    SLOT_CAPTURE_DATA = 2'b10,
//    SLOT_DONE    = 2'b11
    
//} slot_state_t;

//slot_state_t slot_state [1:0];




//reg rr_turn;
//reg r_lock;
//reg active_slot;

//// Assign RAM address per slot
//assign ram_r_addr_0 = rd_addr[0] >> 2;
//assign ram_r_addr_1 = rd_addr[1] >> 2;

//assign ram_ren_0 = (slot_state[0] == SLOT_READING);
//assign ram_ren_1 = (slot_state[1] == SLOT_READING);



 
 
// always_comb begin
// if(!slot_valid[0])begin
//    free_slot = 0;
//  end  else 
//      free_slot = 1;
  
 
// end
 
 
 
 
 
 
 
 
// assign arready = !(slot_valid[0] && slot_valid[1]);
 








//always @(posedge clk) begin
//    if(rst) begin
////        slot_state[0] <= SLOT_IDLE;

//   slot_valid[0]  <= 0;
//        slot_valid[1]  <= 0;
//        slot_state[0]  <= SLOT_IDLE;    // add
//        slot_state[1]  <= SLOT_IDLE;    // add

//wptr_0 <= 0;
//rptr_0 <= 0;
//wptr_1 <= 0;
//rptr_1 <= 0;

//resp_buf_0[0].valid <= 0;
//resp_buf_0[1].valid <= 0;
//resp_buf_0[2].valid <= 0;
//resp_buf_0[3].valid <= 0;

//resp_buf_1[0].valid <= 0;
//resp_buf_1[1].valid <= 0;
//resp_buf_1[2].valid <= 0;
//resp_buf_1[3].valid <= 0;



//    end else begin
//      case(slot_state[0])

//SLOT_IDLE : begin
//    if(arvalid && arready) begin
//        rd_addr    [free_slot] <= araddr;
//        start_addr [free_slot] <= araddr;
//        rd_arlen   [free_slot] <= arlen;
//        rd_arsize  [free_slot] <= arsize;
//        rd_burst   [free_slot] <= arburst;
//        local_arid [free_slot] <= arid;
//        brst_cnt   [free_slot] <= 0;
//        slot_valid [free_slot] <= 1;
//       wrap_base[free_slot] <= (araddr / wrap_size[free_slot]) * wrap_size[free_slot];
//        slot_state [free_slot] <= SLOT_READING;
//    end
//end


//SLOT_READING : begin

//    if(start_addr[0][31:12] != end_addr[0][31:12]) begin

//        resp_buf_0[wptr_0].rdata <= 0;
//        resp_buf_0[wptr_0].rresp <= 2'b10; // SLVERR
//        resp_buf_0[wptr_0].rid   <= local_arid[0];
//        resp_buf_0[wptr_0].rlast <= 1;
//        resp_buf_0[wptr_0].valid <= 1;

//        wptr_0 <= wptr_0 + 1;

//        slot_state[0] <= SLOT_DONE;

//    end
//    else begin

//        if((rd_addr[0] >> 2) >= addr_depth) begin

//            resp_buf_0[wptr_0].rdata <= 0;
//            resp_buf_0[wptr_0].rresp <= 2'b11; // DECERR

//        end
//        else begin

////            resp_buf_0[wptr_0].rdata <= ram_rdata_0;
////            resp_buf_0[wptr_0].rresp <= 2'b00; // OKAY
//        slot_state[0] <= SLOT_CAPTURE_DATA;

//        end

////        resp_buf_0[wptr_0].rid   <= local_arid[0];
////        resp_buf_0[wptr_0].rlast <= (brst_cnt[0] == rd_arlen[0]);
////        resp_buf_0[wptr_0].valid <= 1;

////        wptr_0 <= wptr_0 + 1;

////        brst_cnt[0] <= brst_cnt[0] + 1;

////        if(rd_burst[0] == 2'b00) begin
////            // FIXED
////        end
////        else if(rd_burst[0] == 2'b01) begin

////            rd_addr[0] <= rd_addr[0] + (1 << rd_arsize[0]);

////        end
////        else if(rd_burst[0] == 2'b10) begin

////            if(next_addr[0] >= wrap_size[0] + wrap_base[0])
////                rd_addr[0] <= wrap_base[0];
////            else
////                rd_addr[0] <= next_addr[0];

////        end

////        if(brst_cnt[0] == rd_arlen[0]) begin
////            slot_state[0] <= SLOT_DONE;
////        end
       
//    end

//end


//SLOT_CAPTURE_DATA : begin

//            resp_buf_0[wptr_0].rdata <= ram_rdata_0;
//            resp_buf_0[wptr_0].rresp <= 2'b00; // OKAY
            
            
//        resp_buf_0[wptr_0].rid   <= local_arid[0];
//        resp_buf_0[wptr_0].rlast <= (brst_cnt[0] == rd_arlen[0]);
//        resp_buf_0[wptr_0].valid <= 1;
 
        
//        wptr_0 <= wptr_0 + 1;

//        brst_cnt[0] <= brst_cnt[0] + 1;


//        if(brst_cnt[0] == rd_arlen[0]) begin
//            slot_state[0] <= SLOT_DONE;
//        end else begin
//        slot_state[0] <= SLOT_READING;
//        end
        
        
//          if(rd_burst[0] == 2'b00) begin
//            // FIXED
//        end
//        else if(rd_burst[0] == 2'b01) begin

//            rd_addr[0] <= rd_addr[0] + (1 << rd_arsize[0]);

//        end
//        else if(rd_burst[0] == 2'b10) begin

//            if(next_addr[0] >= wrap_size[0] + wrap_base[0])
//                rd_addr[0] <= wrap_base[0];
//            else
//                rd_addr[0] <= next_addr[0];

//        end


//end

//SLOT_DONE : begin

//    if(!resp_buf_0[rptr_0].valid) begin
//        slot_state[0] <= SLOT_IDLE;
//        slot_valid[0] <= 0;
//    end

//end

//endcase
        
        
        
        
        
     
//case(slot_state[1])
//    SLOT_IDLE : begin end

//    SLOT_READING : begin
//        if(start_addr[1][31:12] != end_addr[1][31:12]) begin
//            resp_buf_1[wptr_1].rdata <= 0;
//            resp_buf_1[wptr_1].rresp <= 2'b10;
//            resp_buf_1[wptr_1].rid   <= local_arid[1];
//            resp_buf_1[wptr_1].rlast <= 1;
//            resp_buf_1[wptr_1].valid <= 1;
//            wptr_1                   <= wptr_1 + 1;
//            slot_state[1]            <= SLOT_DONE;
//        end else begin
//            if((rd_addr[1] >> 2) >= addr_depth) begin
//                resp_buf_1[wptr_1].rdata <= 0;
//                resp_buf_1[wptr_1].rresp <= 2'b11;
//            end else begin
////                resp_buf_1[wptr_1].rdata <= ram_rdata_1;
////                resp_buf_1[wptr_1].rresp <= 2'b00;
//                slot_state[1] <= SLOT_CAPTURE_DATA;
//            end
////            resp_buf_1[wptr_1].rid   <= local_arid[1];
////            resp_buf_1[wptr_1].rlast <= (brst_cnt[1] == rd_arlen[1]);
////            resp_buf_1[wptr_1].valid <= 1;
////            wptr_1                   <= wptr_1 + 1;
////            brst_cnt[1]              <= brst_cnt[1] + 1;

////            if(rd_burst[1] == 2'b00) begin
////                // FIXED
////            end else if(rd_burst[1] == 2'b01) begin
////                rd_addr[1] <= rd_addr[1] + (1 << rd_arsize[1]);
////            end else if(rd_burst[1] == 2'b10) begin
////                if(next_addr[1] >= wrap_size[1] + wrap_base[1])
////                    rd_addr[1] <= wrap_base[1];
////                else
////                    rd_addr[1] <= next_addr[1];
////            end

////            if(brst_cnt[1] == rd_arlen[1]) begin
////                slot_state[1] <= SLOT_DONE;
////            end
//        end
//    end
    
    
// SLOT_CAPTURE_DATA : begin
 
//            resp_buf_1[wptr_1].rid   <= local_arid[1];
//            resp_buf_1[wptr_1].rlast <= (brst_cnt[1] == rd_arlen[1]);
//            resp_buf_1[wptr_1].valid <= 1;
//            wptr_1                   <= wptr_1 + 1;
//            brst_cnt[1]              <= brst_cnt[1] + 1;

//            if(rd_burst[1] == 2'b00) begin
//                // FIXED
//            end else if(rd_burst[1] == 2'b01) begin
//                rd_addr[1] <= rd_addr[1] + (1 << rd_arsize[1]);
//            end else if(rd_burst[1] == 2'b10) begin
//                if(next_addr[1] >= wrap_size[1] + wrap_base[1])
//                    rd_addr[1] <= wrap_base[1];
//                else
//                    rd_addr[1] <= next_addr[1];
//            end
 
//            if(brst_cnt[1] == rd_arlen[1]) begin
//                slot_state[1] <= SLOT_DONE;
//            end
 
 
// end

//    SLOT_DONE : begin
//        if(!resp_buf_1[rptr_1].valid) begin
//            slot_state[1] <= SLOT_IDLE;
//            slot_valid[1] <= 0;
//        end
//    end
//endcase
        
        
        
        
        
        
        
        
        
        
        
//    end
//end





//always @(posedge clk) begin
//    if(rst) begin
//        rvalid <= 0;
//        r_lock <= 0;
//         active_slot <= 0;
//         rr_turn     <= 0;
//    end else begin
//        if(rvalid && rready && rlast) begin
//            rvalid <= 0;
//            r_lock <= 0;
//            rr_turn <= ~active_slot;
//        end

//        if(rready || !rvalid) begin
        
//        if(!r_lock)begin
        
//        if(rr_turn == 0)begin
//            if(resp_buf_0[rptr_0].valid) begin
//                rdata  <= resp_buf_0[rptr_0].rdata;
//                rid    <= resp_buf_0[rptr_0].rid;
//                rresp  <= resp_buf_0[rptr_0].rresp;
//                rlast  <= resp_buf_0[rptr_0].rlast;
//                rvalid <= 1;
//                resp_buf_0[rptr_0].valid <= 0;
//                rptr_0 <= rptr_0 + 1;
//                r_lock <= 1;
//                active_slot <= 0;
//            end else begin 
//             if(resp_buf_1[rptr_1].valid) begin
//                rdata  <= resp_buf_1[rptr_1].rdata;
//                rid    <= resp_buf_1[rptr_1].rid;
//                rresp  <= resp_buf_1[rptr_1].rresp;
//                rlast  <= resp_buf_1[rptr_1].rlast;
//                rvalid <= 1;
//                resp_buf_1[rptr_1].valid <= 0;
//                rptr_1 <= rptr_1 + 1;
//                r_lock <= 1;
//                active_slot <= 1;
//                end           
//            end  
//            end else begin
//             if(resp_buf_1[rptr_1].valid) begin
//                rdata  <= resp_buf_1[rptr_1].rdata;
//                rid    <= resp_buf_1[rptr_1].rid;
//                rresp  <= resp_buf_1[rptr_1].rresp;
//                rlast  <= resp_buf_1[rptr_1].rlast;
//                rvalid <= 1;
//                resp_buf_1[rptr_1].valid <= 0;
//                rptr_1 <= rptr_1 + 1;
//                r_lock <= 1;
//                active_slot <= 1;
//            end
             
//            else begin
//              if(resp_buf_0[rptr_0].valid) begin
//                rdata  <= resp_buf_0[rptr_0].rdata;
//                rid    <= resp_buf_0[rptr_0].rid;
//                rresp  <= resp_buf_0[rptr_0].rresp;
//                rlast  <= resp_buf_0[rptr_0].rlast;
//                rvalid <= 1;
//                resp_buf_0[rptr_0].valid <= 0;
//                rptr_0 <= rptr_0 + 1;
//                r_lock <= 1;
//                active_slot <= 0;
//            end 
            
            
//            end
            
//             end
            
            
            
            
            
//      end else begin
      
//      if(active_slot == 0) begin
//       if(resp_buf_0[rptr_0].valid) begin
//                rdata  <= resp_buf_0[rptr_0].rdata;
//                rid    <= resp_buf_0[rptr_0].rid;
//                rresp  <= resp_buf_0[rptr_0].rresp;
//                rlast  <= resp_buf_0[rptr_0].rlast;
//                rvalid <= 1;
//                resp_buf_0[rptr_0].valid <= 0;
//                rptr_0 <= rptr_0 + 1;
//            end
//      end  else begin
       
       
//       if(resp_buf_1[rptr_1].valid) begin
//                rdata  <= resp_buf_1[rptr_1].rdata;
//                rid    <= resp_buf_1[rptr_1].rid;
//                rresp  <= resp_buf_1[rptr_1].rresp;
//                rlast  <= resp_buf_1[rptr_1].rlast;
//                rvalid <= 1;
//                resp_buf_1[rptr_1].valid <= 0;
//                rptr_1 <= rptr_1 + 1;

//            end
      
      
      
      
//      end 
      
//      end
            
             
            
            
            
            
            
            
            
            
//     end       
            
            
            
            
            
            
  







//    end
//end








//endmodule








 
module read_fsm#(
parameter addr_depth = 1024,
parameter addr_width = 32,
parameter data_width = 32,
parameter len = 8,
parameter size = 3,
parameter burst = 2,
parameter resp=2,
parameter id = 4,
parameter NUM_SLOTS = 2,
parameter BUF_DEPTH = 4,
parameter QUEUE_DEPTH = 8
)(

input clk,
input rst,

//read address

input [addr_width-1:0] araddr, 
input [id-1:0] arid,
output reg [id-1:0] rid,

input [len-1:0] arlen,
input [size-1:0] arsize,
input [burst-1:0] arburst,

input arvalid,

output wire arready,



//read data

//   output reg [id-1:0]rid;
output reg [data_width-1:0] rdata,
output reg                   rvalid,
output reg                      rlast,
output reg [resp-1:0]       rresp,
input                       rready,



//output wire [addr_width-1:0] ram_r_addr,
//output wire ram_ren



// Instead of internal mem
// data comes from outside (RAM1 and RAM2)

input [data_width-1:0] ram_rdata_0,  // from RAM1 slot 0
input [data_width-1:0] ram_rdata_1,  // from RAM2 slot 1

output wire [addr_width-1:0] ram_r_addr_0,
output wire                  ram_ren_0,
output wire [addr_width-1:0] ram_r_addr_1,
output wire                  ram_ren_1




);

 



// Free slot
reg                  free_slot;

// Combinational per slot
reg [addr_width-1:0] next_addr [1:0];
reg [addr_width-1:0] wrap_size [1:0];
reg [addr_width-1:0] end_addr  [1:0];

// Response buffer
typedef struct packed {
    logic [id-1:0]         rid;
    logic [data_width-1:0] rdata;
    logic [resp-1:0]       rresp;
    logic                  rlast;
    logic                  valid;
} rd_resp_t;



logic [$clog2(NUM_SLOTS)-1:0] selected_slot;
logic                         slot_found;
 
rd_resp_t resp_buf[NUM_SLOTS][BUF_DEPTH];
 


logic [1:0] wptr[NUM_SLOTS];
logic [1:0] rptr[NUM_SLOTS];


integer j;

 

 always_comb begin
     for(j=0;j<NUM_SLOTS;j=j+1) begin
       next_addr[j] = slot[j].addr + (1 << slot[j].arsize);
       wrap_size[j] = (1 << slot[j].arsize) * (slot[j].arlen + 1);
      end_addr[j]  = slot[j].start_addr + ((1 << slot[j].arsize) * (slot[j].arlen + 1)) - 1;
     end

 end
 // ----------------------------------------
// Slot State Definition
// ----------------------------------------
typedef enum reg [1:0] {
    SLOT_IDLE    = 2'b00,
    SLOT_READING = 2'b01,
    SLOT_CAPTURE_DATA = 2'b10,
    SLOT_DONE    = 2'b11
    
} slot_state_t;
  
// slot_state_t state_t;



typedef struct packed {

    logic valid;

    logic [addr_width-1:0] addr;
    logic [addr_width-1:0] start_addr;
    logic [addr_width-1:0] wrap_base;

    logic [len-1:0]   arlen;
    logic [size-1:0]  arsize;
    logic [burst-1:0] arburst;
    logic [id-1:0]    arid;

    logic [len-1:0] beat_cnt;

    slot_state_t state;

} rd_slot_t;

rd_slot_t slot[NUM_SLOTS];


reg rr_turn;
reg r_lock;
reg active_slot;

////// Assign RAM address per slot
//assign ram_r_addr_0 = slot[0].addr >> 2;
//assign ram_r_addr_1 = slot[1].addr >> 2;

//assign ram_ren_0 = (slot[0].state == SLOT_READING);
//assign ram_ren_1 = (slot[1].state == SLOT_READING);


// same decode rule the write path already uses
wire slot_wants_bank1 [NUM_SLOTS];
genvar gi;
generate
  for (gi = 0; gi < NUM_SLOTS; gi = gi + 1) begin : bank_decode
    assign slot_wants_bank1[gi] = ((slot[gi].addr >> 2) >= 1024);
  end
endgenerate


wire slot0_req_b0 = (slot[0].state==SLOT_READING) && !slot_wants_bank1[0];
wire slot1_req_b0 = (slot[1].state==SLOT_READING) && !slot_wants_bank1[1];
wire slot0_req_b1 = (slot[0].state==SLOT_READING) &&  slot_wants_bank1[0];
wire slot1_req_b1 = (slot[1].state==SLOT_READING) &&  slot_wants_bank1[1];

wire slot0_grant_b0 = slot0_req_b0;
wire slot1_grant_b0 = slot1_req_b0 && !slot0_req_b0;   // slot0 wins ties on bank0

wire slot1_grant_b1 = slot1_req_b1;
wire slot0_grant_b1 = slot0_req_b1 && !slot1_req_b1;   // slot1 wins ties on bank1

assign ram_r_addr_0 = slot0_grant_b0 ? (slot[0].addr>>2) : (slot[1].addr>>2);
assign ram_ren_0    = slot0_grant_b0 || slot1_grant_b0;

assign ram_r_addr_1 = slot1_grant_b1 ? (slot[1].addr>>2) : (slot[0].addr>>2);
assign ram_ren_1    = slot1_grant_b1 || slot0_grant_b1;

wire slot_granted [NUM_SLOTS];
assign slot_granted[0] = slot0_grant_b0 || slot0_grant_b1;
assign slot_granted[1] = slot1_grant_b0 || slot1_grant_b1;


typedef struct packed {

    logic valid;
    logic [id-1:0]   arid;
    logic [addr_width-1:0] araddr;
    logic [7:0]            arlen;
    logic [2:0]            arsize;
    logic [1:0]            arburst;

} ar_req_t;

ar_req_t ar_queue[QUEUE_DEPTH];

logic [$clog2(QUEUE_DEPTH)-1:0] q_wr_ptr;
logic [$clog2(QUEUE_DEPTH)-1:0] q_rd_ptr;
logic [$clog2(QUEUE_DEPTH+1)-1:0] q_count;
 
 
 
 
  
assign arready = (q_count < QUEUE_DEPTH); 

integer i,m,n;
 always @(posedge clk) begin
    $display("[%0t] READ_FSM: slot0_state=%s, slot1_state=%s, arvalid=%b, arready=%b, rvalid=%b, rready=%b, rlast = %b, valid=%0d, q_count=%0d",
             $time,
             slot[0].state.name(),
             slot[1].state.name(),
             arvalid,
             arready,
             rvalid,
             rready,
             rlast,
                 ar_queue[q_rd_ptr].valid,
             q_count);
end

always @(posedge clk) begin
    if(rst) begin
 for(i=0;i<NUM_SLOTS;i=i+1) begin
slot[i].valid      <= 0;
slot[i].state      <= SLOT_IDLE;
slot[i].beat_cnt   <= 0;
slot[i].addr       <= '0;
slot[i].start_addr <= '0;
slot[i].wrap_base  <= '0;
slot[i].arid       <= '0;
slot[i].arlen      <= '0;
slot[i].arsize     <= '0;
slot[i].arburst    <= '0;
        end

   q_wr_ptr <= 0;
        q_rd_ptr <= 0;
        q_count  <= 0;
        
        // ============================================================
        // CRITICAL FIX: Initialize ALL queue entries
        // ============================================================
        for(int k=0; k<QUEUE_DEPTH; k=k+1) begin
            ar_queue[k].valid   <= 1'b0;
            ar_queue[k].arid    <= '0;
            ar_queue[k].araddr  <= '0;
            ar_queue[k].arlen   <= '0;
            ar_queue[k].arsize  <= '0;
            ar_queue[k].arburst <= '0;
        end
        
        // Initialize response buffers
      for(m=0; m<NUM_SLOTS; m=m+1) begin
        for(n=0; n<BUF_DEPTH; n=n+1) begin
          resp_buf[m][n].valid <= 0;
            end
        end
        
        // Initialize response pointers
        wptr[0] <= 0;
        wptr[1] <= 0;
        rptr[0] <= 0;
        rptr[1] <= 0;
        
        rr_turn <= 0;
        r_lock <= 0;
        rvalid <= 0;
        active_slot <= 0;

    end else begin
     
         if(arvalid && arready) begin
    ar_queue[q_wr_ptr].valid   <= 1'b1;
    ar_queue[q_wr_ptr].arid    <= arid;
    ar_queue[q_wr_ptr].araddr  <= araddr;
    ar_queue[q_wr_ptr].arlen   <= arlen;
    ar_queue[q_wr_ptr].arsize  <= arsize;
    ar_queue[q_wr_ptr].arburst <= arburst;

    q_wr_ptr <= q_wr_ptr + 1;
    q_count  <= q_count + 1;


    end
        
    for(i=0;i<NUM_SLOTS;i++) begin
    case(slot[i].state)
    
SLOT_IDLE : begin
   
end




SLOT_READING : begin

   if(slot[i].start_addr[31:12] != end_addr[i][31:12]) begin

    resp_buf[i][wptr[i]].rdata <= 0;
    resp_buf[i][wptr[i]].rresp <= 2'b10;
    resp_buf[i][wptr[i]].rid   <= slot[i].arid;
    resp_buf[i][wptr[i]].rlast <= 1;
    resp_buf[i][wptr[i]].valid <= 1;

    wptr[i] <= wptr[i] + 1;

    slot[i].state <= SLOT_DONE;

end
    else begin

if((slot[i].addr >> 2) >= (addr_depth * 2)) begin   // or a dedicated TOTAL_DEPTH param //flag hard coded
          resp_buf[i][wptr[i]].rdata <= 0;
          resp_buf[i][wptr[i]].rresp <= 2'b11;
          resp_buf[i][wptr[i]].rid   <= slot[i].arid;   
            resp_buf[i][wptr[i]].rlast <= 1;               
            resp_buf[i][wptr[i]].valid <= 1;               
            wptr[i] <= wptr[i] + 1;                        
            slot[i].state <= SLOT_DONE;     

        end
        else begin
 if(slot_granted[i]) begin
    slot[i].state <= SLOT_CAPTURE_DATA;
end
    
        end
 
       
    end

end


   SLOT_CAPTURE_DATA : begin

      $display("[%0t] SLOT[%0d] CAPTURE: beat_cnt=%0d, arlen=%0d, rlast=%0d", 
             $time, i, slot[i].beat_cnt, slot[i].arlen, 
             (slot[i].beat_cnt == slot[i].arlen));
    
     
     
//    resp_buf[i][wptr[i]].rdata <= rdata[i];
if(slot_wants_bank1[i])
    resp_buf[i][wptr[i]].rdata <= ram_rdata_1;
else
    resp_buf[i][wptr[i]].rdata <= ram_rdata_0;

    resp_buf[i][wptr[i]].rresp <= 2'b00;               // OKAY
    resp_buf[i][wptr[i]].rid   <= slot[i].arid;
    resp_buf[i][wptr[i]].rlast <= (slot[i].beat_cnt == slot[i].arlen);
    resp_buf[i][wptr[i]].valid <= 1'b1;

    wptr[i] <= wptr[i] + 1;
    slot[i].beat_cnt <= slot[i].beat_cnt + 1;

    case(slot[i].arburst)

        2'b00: begin
            // FIXED
        end

        2'b01: begin
            // INCR
            slot[i].addr <= slot[i].addr + (1 << slot[i].arsize);
        end

        2'b10: begin
            // WRAP
            if(next_addr[i] >= (wrap_size[i] + slot[i].wrap_base))
                slot[i].addr <= slot[i].wrap_base;
            else
                slot[i].addr <= next_addr[i];
        end

        default: begin
        end

    endcase

    if(slot[i].beat_cnt == slot[i].arlen)
        slot[i].state <= SLOT_DONE;
    else
        slot[i].state <= SLOT_READING;

end
   
      
      
// SLOT_DONE : begin

//     if(!resp_buf[i][rptr[i]].valid) begin
//         slot[i].state <= SLOT_IDLE;
//         slot[i].valid <= 1'b0;
//     end

// end

      
      SLOT_DONE : begin
    // Wait for response buffer to be fully drained
    // Check if the response buffer at rptr[i] is valid
    if(!resp_buf[i][rptr[i]].valid) begin
        // Check if all entries have been drained
        if(wptr[i] == rptr[i]) begin
            $display("[%0t] SLOT[%0d] All entries drained, going IDLE", $time, i);
            slot[i].state <= SLOT_IDLE;
            slot[i].valid <= 1'b0;
            slot[i].beat_cnt <= 0;
        end
    end else begin
        $display("[%0t] SLOT[%0d] Still waiting: wptr=%0d, rptr=%0d, valid=%0d", 
                 $time, i, wptr[i], rptr[i], resp_buf[i][rptr[i]].valid);
    end
end
      
      
      
      
      
      
      
      
//    SLOT_CAPTURE_DATA : begin
//     $display("[%0t] SLOT[%0d] CAPTURE: beat_cnt=%0d, arlen=%0d, next_beat=%0d", 
//              $time, i, slot[i].beat_cnt, slot[i].arlen, slot[i].beat_cnt + 1);
    
//     // Determine if this is the last beat BEFORE any assignments
//     if(slot[i].beat_cnt == slot[i].arlen) begin
//         // This is the last beat
//         $display("[%0t] SLOT[%0d] LAST BEAT! Setting rlast=1", $time, i);
        
//         // Capture data from RAM with rlast=1
//         if(slot_wants_bank1[i])
//             resp_buf[i][wptr[i]].rdata <= ram_rdata_1;
//         else
//             resp_buf[i][wptr[i]].rdata <= ram_rdata_0;
            
//         resp_buf[i][wptr[i]].rresp <= 2'b00;
//         resp_buf[i][wptr[i]].rid   <= slot[i].arid;
//         resp_buf[i][wptr[i]].rlast <= 1'b1;  // Explicitly set to 1
//         resp_buf[i][wptr[i]].valid <= 1'b1;
        
//         // Move to DONE state
//         slot[i].state <= SLOT_DONE;
        
//     end else begin
//         // Not the last beat
//         $display("capture not last beat - [%0t] SLOT[%0d] NOT LAST BEAT: beat_cnt=%0d, arlen=%0d", 
//                  $time, i, slot[i].beat_cnt, slot[i].arlen);
        
//         // Capture data from RAM with rlast=0
//         if(slot_wants_bank1[i])
//             resp_buf[i][wptr[i]].rdata <= ram_rdata_1;
//         else
//             resp_buf[i][wptr[i]].rdata <= ram_rdata_0;
            
//         resp_buf[i][wptr[i]].rresp <= 2'b00;
//         resp_buf[i][wptr[i]].rid   <= slot[i].arid;
//         resp_buf[i][wptr[i]].rlast <= 1'b0;  // Explicitly set to 0
//         resp_buf[i][wptr[i]].valid <= 1'b1;
        
//         // Stay in READING state for next beat
//         slot[i].state <= SLOT_READING;
        
//         // Update address for next beat
//         case(slot[i].arburst)
//             2'b01: begin
//                 slot[i].addr <= slot[i].addr + (1 << slot[i].arsize);
//             end
//             2'b10: begin
//                 if(next_addr[i] >= (wrap_size[i] + slot[i].wrap_base))
//                     slot[i].addr <= slot[i].wrap_base;
//                 else
//                     slot[i].addr <= next_addr[i];
//             end
//         endcase
//     end
    
//     // Now increment pointers and beat count
//     wptr[i] <= wptr[i] + 1;
//     slot[i].beat_cnt <= slot[i].beat_cnt + 1;
// end

// SLOT_DONE : begin
//     // Wait for response buffer to be fully drained
//     // Check if the response buffer at rptr[i] is valid
//     // If valid, we need to wait for it to be drained
//     if(!resp_buf[i][rptr[i]].valid) begin
//         // Also check if there are no more valid entries in the buffer
//         // For safety, check if wptr == rptr (all entries drained)
//         if(wptr[i] == rptr[i]) begin
//             slot[i].state <= SLOT_IDLE;
//             slot[i].valid <= 1'b0;
//             // Reset beat count for next transaction
//             slot[i].beat_cnt <= 0;
//         end
//     end
// end
      
      
      
      
   

    endcase



  end     
        
        
        for(int i=0; i<NUM_SLOTS; i++) begin

    if(slot[i].state == SLOT_IDLE &&
       q_count != 0 &&
       ar_queue[q_rd_ptr].valid) begin

        slot[i].addr       <= ar_queue[q_rd_ptr].araddr;
        slot[i].start_addr <= ar_queue[q_rd_ptr].araddr;
        slot[i].arid       <= ar_queue[q_rd_ptr].arid;
        slot[i].arlen      <= ar_queue[q_rd_ptr].arlen;
        slot[i].arsize     <= ar_queue[q_rd_ptr].arsize;
        slot[i].arburst    <= ar_queue[q_rd_ptr].arburst;

        slot[i].beat_cnt   <= 0;
        slot[i].valid      <= 1'b1;
        slot[i].state      <= SLOT_READING;

        ar_queue[q_rd_ptr].valid <= 1'b0;

        q_rd_ptr <= q_rd_ptr + 1;
        q_count  <= q_count - 1;

    end

end
        
        
        
        
    end
end



logic slot0_valid;
logic slot1_valid;

assign slot0_valid = resp_buf[0][rptr[0]].valid;
assign slot1_valid = resp_buf[1][rptr[1]].valid;

always_comb begin

    slot_found    = 0;
    selected_slot = 0;

    //----------------------------------
    // Only Slot0 ready
    //----------------------------------

    if(slot0_valid && !slot1_valid) begin

        selected_slot = 0;
        slot_found = 1;

    end

    //----------------------------------
    // Only Slot1 ready
    //----------------------------------

    else if(!slot0_valid && slot1_valid) begin

        selected_slot = 1;
        slot_found = 1;

    end

    //----------------------------------
    // Both ready
    //----------------------------------

    else if(slot0_valid && slot1_valid) begin

        slot_found = 1;

        if(rr_turn == 0)
            selected_slot = 0;
        else
            selected_slot = 1;

    end

end





// always @(posedge clk) begin
//     if(rst) begin
//         rvalid <= 0;
//         r_lock <= 0;
//          active_slot <= 0;
//          rr_turn     <= 0;
//     end else begin
    
      
    
    
//         if(rvalid && rready && rlast) begin
//             rvalid <= 0;
//             r_lock <= 0;
//             rr_turn <= ~active_slot;
//         end

//         if(rready || !rvalid) begin
        
//         if(!r_lock)begin
        
         
//                 if(slot_found) begin

//                   $display("slot found - [%0t] OUTPUT: slot=%0d, rptr=%0d, rlast=%0d, valid=%0d", 
//              $time, selected_slot, rptr[selected_slot], 
//              resp_buf[selected_slot][rptr[selected_slot]].rlast,
//              resp_buf[selected_slot][rptr[selected_slot]].valid);
    
                  
                  
//                     rdata  <= resp_buf[selected_slot][rptr[selected_slot]].rdata;
//                     rid    <= resp_buf[selected_slot][rptr[selected_slot]].rid;
//                     rresp  <= resp_buf[selected_slot][rptr[selected_slot]].rresp;
//                     rlast  <= resp_buf[selected_slot][rptr[selected_slot]].rlast;

//                     rvalid <= 1;

//                     resp_buf[selected_slot][rptr[selected_slot]].valid <= 0;

//                     rptr[selected_slot] <= rptr[selected_slot] + 1;

//                     r_lock <= 1;
//                     active_slot <= selected_slot;

//                 end
         
         
         
         
//         end
            
            
            
            
            
//       end else begin
      
     
      
      
      
//       end 
      
          
            
//   end


 
// end


  
  always @(posedge clk) begin
    if(rst) begin
        rvalid <= 0;
        r_lock <= 0;
        active_slot <= 0;
        rr_turn <= 0;
    end else begin
        // Clear r_lock after each beat is accepted
        if(rvalid && rready) begin
            rvalid <= 0;
            r_lock <= 0;
            // Only update rr_turn on last beat
            if(rlast) begin
                rr_turn <= ~active_slot;
            end
        end

        if(rready || !rvalid) begin
            if(!r_lock) begin
                if(slot_found) begin
                    $display("slot found - [%0t] OUTPUT: slot=%0d, rptr=%0d, rlast=%0d, valid=%0d", 
                             $time, selected_slot, rptr[selected_slot], 
                             resp_buf[selected_slot][rptr[selected_slot]].rlast,
                             resp_buf[selected_slot][rptr[selected_slot]].valid);
                    
                    // Output the data
                    rdata  <= resp_buf[selected_slot][rptr[selected_slot]].rdata;
                    rid    <= resp_buf[selected_slot][rptr[selected_slot]].rid;
                    rresp  <= resp_buf[selected_slot][rptr[selected_slot]].rresp;
                    rlast  <= resp_buf[selected_slot][rptr[selected_slot]].rlast;
                    rvalid <= 1;
                    
                    // Clear the valid flag for this entry
                    resp_buf[selected_slot][rptr[selected_slot]].valid <= 0;
                    
                    // Advance rptr to the next beat
                    rptr[selected_slot] <= rptr[selected_slot] + 1;
                    
                    r_lock <= 1;
                    active_slot <= selected_slot;
                end
            end
        end
    end
end




endmodule








module top_axi #(
parameter width = 32,
parameter depth = 16,
parameter ptr_width = 5,
parameter addr_width = 32,
parameter data_width = 32,
parameter id = 4,

parameter len = 8,
parameter size = 3,
parameter burst = 2,
parameter resp = 2

)(

input clk,
input rst,

//input wire w_en,
//input wire r_en,

//input [width-1:0]w_data,

input [id-1:0]awid,
input [addr_width-1:0]awaddr,
input [len-1:0]awlen,
input [size-1:0]awsize,
input [burst-1:0]awburst,
input awvalid,


output wire awready,

input [(data_width/8)-1:0] wstrb,
input [data_width-1:0]  wdata,
input                   wlast,
input                   wvalid,
output wire             wready,







input bready,

output reg [id-1:0] bid,
output reg [resp -1 :0]bresp,

output wire bvalid,










 
//read address

input [addr_width-1:0] araddr, 
input [id-1:0] arid,
output reg [id-1:0] rid,

input [len-1:0] arlen,
input [size-1:0] arsize,
input [burst-1:0] arburst,

input arvalid,

output wire arready,



//read data


output reg [data_width-1:0] rdata,
output reg rvalid,
output reg rlast,
output reg [resp-1:0]rresp,
input rready






);






wire aw_fifo_wen;
wire aw_fifo_ren;

wire ar_fifo_wen;
wire ar_fifo_ren;



assign aw_fifo_wen = awvalid && awready;
assign ar_fifo_wen = arvalid && arready;



 
//output reg [width-1:0]r_data,
 wire [(data_width/8)-1:0] ram_wstrb;

wire [id-1:0]               top_out_awid;
wire [addr_width-1:0]       top_out_awaddr;
wire [len-1:0]              top_out_awlen;
wire [size-1:0]             top_out_awsize;
wire [burst-1:0]            top_out_awburst;
wire                        top_out_awvalid;



wire [id-1:0]               top_out_arid;
wire [addr_width-1:0]       top_out_araddr;
wire [len-1:0]              top_out_arlen;
wire [size-1:0]             top_out_arsize;
wire [burst-1:0]            top_out_arburst;
wire                        top_out_arvalid;



wire [addr_width-1:0] ram_w_addr;
wire ram_wen;
wire [data_width-1:0] ram_wdata;


wire [addr_width-1:0] ram_r_addr;
wire ram_ren;


//  wire aw_full;
//  wire aw_empty;


//  wire ar_full;
//  wire ar_empty;



 wire   [data_width-1:0] ram_rdata_0;
  wire   [addr_width-1:0] ram_r_addr_0;
  wire   ram_ren_0;
  
   wire [data_width-1:0] ram_rdata_1;
  wire   [addr_width-1:0] ram_r_addr_1;
  wire    ram_ren_1;



wire sel_ram0;
wire sel_ram1;

assign sel_ram0 = (ram_w_addr < 1024);
assign sel_ram1 = (ram_w_addr >= 1024);


//assign  awready = !aw_full;
//assign arready = !ar_full;




//assign aw_fifo_ren = !aw_empty;
//assign ar_fifo_ren = !ar_empty;

//aw_fifo write_fifo(



//.clk(clk),
//.rst(rst),


//.w_en(aw_fifo_wen),
//.r_en(aw_fifo_ren),


//.awid   (awid),  
//.awaddr (awaddr), 
//.awlen  (awlen),
//.awsize (awsize),
//.awburst    (awburst),
//.awvalid    (awvalid),


// .out_awid(top_out_awid)   ,
// .out_awaddr(top_out_awaddr), 
// .out_awlen(top_out_awlen),
// .out_awsize(top_out_awsize),
// .out_awburst(top_out_awburst),
// .out_awvalid(top_out_awvalid),


//.full(aw_full),
//.empty(aw_empty)



//);





//write_fsm write(

//.clk(clk),
//.rst(rst),


//.awid       (top_out_awid),  
//.awaddr     (top_out_awaddr), 
//.awlen      (top_out_awlen),
//.awsize     (top_out_awsize),
//.awburst    (top_out_awburst),
//.awvalid    (top_out_awvalid),
//  .awready(awready),
  
  
//.wstrb      (wstrb),
// .wdata(wdata),
// .wlast(wlast),
// .wvalid(wvalid),
// .wready(wready),
 
// .bready(bready),
// .bid(bid),
// .bresp(bresp),
// .bvalid(bvalid),
 

//.ram_w_addr(ram_w_addr),
//.ram_we(ram_wen),
//. ram_wdata(ram_wdata),
//.ram_wstrb(ram_wstrb)



//);



write_fsm write(
    .clk(clk),
    .rst(rst),

    .awid   (awid),      // straight from top-level port, not top_out_awid
    .awaddr (awaddr),
    .awlen  (awlen),
    .awsize (awsize),
    .awburst(awburst),
    .awvalid(awvalid),
    .awready(awready),   // write_fsm's own internal assign now drives the top port — single driver

    .wstrb  (wstrb),
    .wdata  (wdata),
    .wlast  (wlast),
    .wvalid (wvalid),
    .wready (wready),

    .bready (bready),
    .bid    (bid),
    .bresp  (bresp),
    .bvalid (bvalid),

    .ram_w_addr(ram_w_addr),
    .ram_we    (ram_wen),
    .ram_wdata (ram_wdata),
    .ram_wstrb (ram_wstrb)
);





//ar_fifo read_fifo(



//.clk(clk),
//.rst(rst),


//.w_en(ar_fifo_wen),
//.r_en(ar_fifo_ren),


//.arid   (arid),  
//.araddr (araddr), 
//.arlen  (arlen),
//.arsize (arsize),
//.arburst    (arburst),
//.arvalid    (arvalid),
 

// .out_arid(top_out_arid)   ,
// .out_araddr(top_out_araddr), 
// .out_arlen(top_out_arlen),
// .out_arsize(top_out_arsize),
// .out_arburst(top_out_arburst),
// .out_arvalid(top_out_arvalid),


//.full(ar_full),
//.empty(ar_empty)



//);


read_fsm read(
    .clk(clk), .rst(rst),
    .arid(arid), .araddr(araddr), .arlen(arlen),
    .arsize(arsize), .arburst(arburst), .arvalid(arvalid),
    .arready(arready),   // read_fsm's own internal assign now drives the top port — single driver
    .rid(rid), .rdata(rdata), .rvalid(rvalid), .rlast(rlast), .rresp(rresp), .rready(rready),
    .ram_rdata_0(ram_rdata_0), .ram_r_addr_0(ram_r_addr_0), .ram_ren_0(ram_ren_0),
    .ram_rdata_1(ram_rdata_1), .ram_r_addr_1(ram_r_addr_1), .ram_ren_1(ram_ren_1)
);




 


//read_fsm read(



//.clk(clk),
//.rst(rst),


//.arid       (top_out_arid),  
//.araddr     (top_out_araddr), 
//.arlen      (top_out_arlen),
//.arsize     (top_out_arsize),
//.arburst    (top_out_arburst),
//.arvalid    (top_out_arvalid),
//  .arready(arready),

//.rid(rid),
//.rdata(rdata) ,
//.rvalid(rvalid),
//.rlast(rlast),
//.rresp(rresp),
//.rready (rready),


//.ram_rdata_0(ram_rdata_0),
//.ram_r_addr_0(ram_r_addr_0), 
//.ram_ren_0(ram_ren_0), 

//.ram_rdata_1(ram_rdata_1), 
//.ram_r_addr_1(ram_r_addr_1),  
//.ram_ren_1(ram_ren_1)



//);







DP_RAM ram0(
  
  .clk(clk),
  .rst(rst),


.a_w_en(ram_wen && sel_ram0),
.a_r_en(ram_ren_0),
 
.a_addr(ram_w_addr),
.a_w_data(ram_wdata),

.a_r_data(),


.b_addr(ram_r_addr_0),
.b_w_data(),
 .b_w_en(),  
.b_r_data(ram_rdata_0),

  .b_r_en(ram_ren_0),

  .ram_wstrb(ram_wstrb)


);
 
 
 
 
 

DP_RAM ram1(

  .clk(clk),
  .rst(rst),
  
  
.a_w_en(ram_wen & sel_ram1),
.a_r_en(ram_ren_1),
 
.a_addr(ram_w_addr),
.a_w_data(ram_wdata),

.a_r_data(),
 .b_w_en(),  

.b_addr(ram_r_addr_1),
.b_w_data(),
.b_r_en(ram_ren_1),
  .b_r_data(ram_rdata_1),

  .ram_wstrb(ram_wstrb)




);
 




endmodule















