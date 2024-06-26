module memorycontrol (
    input clk, rst,
    input [15:0] iaddress, daddress,
    input [15:0] idata_in, ddata_in,
    input MemtoReg, MemWrite,
    output [15:0] icachedataout, dcachedataout
    output IF_Stall, MEM_Stall
);
// need to figure out cache write enables, hook up in cpu

//cache (
//   input clk, rst, cacheRead, cacheWrite,
//   input [15:0] address, data_in,
//   output miss,
//   output [15:0] data_out
// );

wire fsm_busy;
wire icache_miss_detected;
wire dcache_miss_detected;
wire write_data_array;
wire write_tag_array;
wire memory_data_valid;
wire [15:0] miss_address;
wire [15:0] idata_out, ddata_out 
wire [15:0] icacheadress, dcacheadress;
wire [15:0] memory_out;
wire [15:0] idatacachein;
wire [15:0] ddatacachein;
wire [15:0] memory_address;


cache icache(.clk(clk), .rst(rst), .cacheRead(1'b1), .cacheWrite(), .address(icacheadress), .data_in(idatacachein), .miss(icache_miss_detected), .data_out(idata_out));
cache dcache(.clk(clk), .rst(rst), .cacheRead(MemtoReg), .cacheWrite(MemWrite), .address(dcacheadress), .data_in(ddatacachein), .miss(dcache_miss_detected), .data_out(ddata_out));

assign IF_Stall = icache_miss_detected;
assign MEM_Stall = dcache_miss_detected;

assign icacheadress = (fsm_busy === 1'b1) ? memory_address : iaddress;
assign dcacheadress = (fsm_busy === 1'b1) ? memory_address : daddress; 

assign miss_address = (icache_miss_detected) ? iaddress : daddress;

cache_fill_FSM cacheFSM(.clk(clk), .rst(rst), .miss_detected(icache_miss_detected | dcache_miss_detected), .miss_address(miss_address), .fsm_busy(fsm_busy), .write_data_array(write_data_array),
                 .write_tag_array(write_tag_array), .memory_address(memory_address), .memory_data_valid(memory_data_valid));

//if its a miss write to the instruction cache from memory or else just write whats already there.
assign idatacachein = (icache_miss_detected) ? memory_out : idata_out;
//if its a miss write to the instruction cache from memory or else if its a store word then write to cache
assign ddatacachein = (dcache_miss_detected) ? memory_out : (MemWrite) ? ddata_in : ddata_out;
 
memory4c mainmem(.data_out(memory_out), .data_in(), .addr(memory_address), .enable(icache_miss_detected | dcache_miss_detected | MemWrite), 
                 .wr(MemWrite), .clk(clk), .rst(rst), .data_valid(memory_data_valid));
    
endmodule