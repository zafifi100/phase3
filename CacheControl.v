`default_nettype none

// TODO LIST
/* 6 - 64 decoder: block enable
 * 3 - 8 decoder: word enable
 * LRU logic
 * valid bit logic
 * miss address logic
 */

/*
 *TAG: 5-0: tag, bit 6: valid bit, bit 7: LRU bit
 */
module CacheControl(
  input wire clk, rst,
  input wire [15:0] curr_pc, // input to cache fsm
  input wire [15:0] dcache_data, // input data to dcache
  input wire [15:0] newdata, // new data to write to main mem and cache
  output wire [15:0] icache_out, dcache_out, // output data from each cache
  output wire fsm_busy
);
  // cache data to be written
  wire [15:0] idata_in, ddata_in;
  wire [5:0] imetadata0_in, dmetadata0_in, imetadata1_in, dmetadata1_in;

  // LRU and valid bit logic for caches
  wire iLRU0_bit, ivalid0_bit, iLRU1_bit, ivalid1_bit, dLRU0_bit, dLRU1_bit, dvalid0_bit, dvalid1_bit;

  // cache enables
  wire icache_en, dcache_en;
  wire icache_miss_detected, dcache_miss_detected;
  
  // cache FSM inputs / outputs
  wire write_data_array, write_tag_array, memory_data_valid;
  wire [15:0] memory_address;

  // instruction cache outputs
  wire [7:0] TagOut0_icache, TagOut1_icache;
  wire [15:0] DataOut0_icache, DataOut1_icache;

  // data cache outputs
  wire [7:0] TagOut0_dcache, TagOut1_dcache;
  wire [15:0] DataOut0_dcache, DataOut1_dcache;

  //memory outputs
  wire [15:0] MainMemOut;

  // assign miss address based on dcache or icache
  wire [15:0] miss_address;

  // instruction cache (TODO: Complete port hookups & check write enable doesnt need more)
  // Way 0 icache
  MetaDataArray imetarray0(.clk(clk), .rst(rst), .DataIn(imetadata0_in), .Write(write_tag_array), .BlockEnable(curr_pc[9:4]), .DataOut(TagOut0_icache));
  DataArray idatarray0(.clk(clk), .rst(rst), .DataIn(idata_in), .Write(write_data_array), .BlockEnable(curr_pc[9:4]), .WordEnable(memory_address[3:0]), .DataOut(DataOut0_icache));
  // Way 1 icache
  MetaDataArray imetarray1(.clk(clk), .rst(rst), .DataIn(imetadata1_in), .Write(write_tag_array), .BlockEnable(curr_pc[9:4]), .DataOut(TagOut1_icache));
  DataArray idatarray1(.clk(clk), .rst(rst), .DataIn(idata_in), .Write(write_data_array), .BlockEnable(curr_pc[9:4]), .WordEnable(memory_address[3:0]), .DataOut(DataOut1_icache));

  // data cache (TODO: Complete port hookups & check write enable doesnt need more)
  // Way 0 dcache
  MetaDataArray dmetarray0(.clk(clk), .rst(rst), .DataIn(dmetadata0_in), .Write(write_tag_array), .BlockEnable(curr_pc[9:4]), .DataOut(TagOut0_dcache));
  DataArray ddatarray0(.clk(clk), .rst(rst), .DataIn(ddata_in), .Write(write_data_array), .BlockEnable(curr_pc[9:4]), .WordEnable(memory_address[3:0]), .DataOut(DataOut0_dcache));
  // Way 1 dcache
  MetaDataArray dmetarray1(.clk(clk), .rst(rst), .DataIn(dmetadata1_in), .Write(write_tag_array), .BlockEnable(curr_pc[9:4]), .DataOut(TagOut1_dcache));
  DataArray ddatarray1(.clk(clk), .rst(rst), .DataIn(ddata_in), .Write(write_data_array), .BlockEnable(curr_pc[9:4]), .WordEnable(memory_address[3:0]), .DataOut(DataOut1_dcache));



  // cache FSM
  cache_fill_FSM(.clk(clk), .rst(rst), .miss_detected(icache_miss_detected | dcache_miss_detected), .miss_address(miss_address), .fsm_busy(fsm_busy), .write_data_array(write_data_array),
                 .write_tag_array(write_tag_array), .memory_address(memory_address), .memory_data_valid(memory_data_valid));

  
  // Determine cache miss (TODO: WHAT BITS TO CHECK FOR TAG)
  assign icache_miss_detected = ((curr_pc[15:10] === TagOut0_icache[5:0]) & TagOut0_icache[7]) || ((curr_pc[15:10] === TagOut1_icache[5:0]) & TagOut1_icache[7]) ||
                                ((curr_pc[15:10] === DataOut0_icache[5:0]) & TagOut0_icache[7])|| ((curr_pc[15:10] === DataOut1_icache[5:0]) & TagOut1_icache[7]);

  assign dcache_miss_detected = ((curr_pc[15:10] === TagOut0_dcache[5:0]) & TagOut0_dcache[7]) || ((curr_pc[15:10] === TagOut1_dcache[5:0]) & TagOut1_dcache[7]) ||
                                (curr_pc[15:10] === DataOut0_dcache[5:0]) & TagOut0_dcache[7]|| ((curr_pc[15:10] === DataOut1_dcache[5:0])& TagOut1_dcache[7]);

  
  // input data to be written to dcache
  assign ddata_in = MainMemOut;
  assign dmetadata0_in = {dLRU0_bit, dvalid0_bit, memory_address[15:10]};
  assign dmetadata1_in = {dLRU1_bit, dvalid1_bit, memory_address[15:10]};

  // input data to be written to icache
  assign idata_in = MainMemOut;
  assign imetadata0_in = {iLRU0_bit, ivalid0_bit, memory_address[15:10]};
  assign imetadata1_in = {iLRU1_bit, ivalid1_bit, memory_address[15:10]};

 
  // Memory module (TODO: WHAT IS DATA INPUT)
  memory4c mainmem(.data_out(MainMemOut), .data_in(), .addr(memory_address), .enable(icache_miss_detected | dcache_miss_detected), 
                   .wr(write_data_array), .clk(clk), .rst(rst), .data_valid(memory_data_valid));

endmodule


