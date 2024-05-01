`default_nettype none

// TODO LIST
/* Data inputs to caches
 * word enable logic
 * what bits are checked from tagout for miss detected logic
 * memory contention
 * LRU 
 * add decoders and one hots for enables
 */
module CacheControl(
  input wire clk, rst,
  input wire [15:0] miss_address, curr_pc, // input to cache fsm
  input wire [15:0] dcache_data, // input data to dcache
  input wire [15:0] newdata, // new data to write to main mem and cache
  output wire [15:0] icache_out, dcache_out, // output data from each cache
  output wire fsm_busy
);
  // cache data to be written
  wire [5:0] idata_in, ddata_in;

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


  // instruction cache (TODO: Complete port hookups & check write enable doesnt need more)
  // Way 0 icache
  MetaDataArray imetarray0(.clk(clk), .rst(rst), .DataIn(memory_address[15:10]), .Write(write_tag_array), .BlockEnable(curr_pc[9:4]), .DataOut(TagOut0_icache));
  DataArray idatarray0(.clk(clk), .rst(rst), .DataIn(idata_in), .Write(write_data_array), .BlockEnable(curr_pc[9:4]), .WordEnable(memory_address[3:0]), .DataOut(DataOut0_icache));
  // Way 1 icache
  MetaDataArray imetarray1(.clk(clk), .rst(rst), .DataIn(), .Write(write_tag_array), .BlockEnable(curr_pc[9:4]), .DataOut(TagOut1_icache));
  DataArray idatarray1(.clk(clk), .rst(rst), .DataIn(idata_in), .Write(write_data_array), .BlockEnable(curr_pc[9:4]), .WordEnable(memory_address[3:0]), .DataOut(DataOut1_icache));

  // data cache (TODO: Complete port hookups & check write enable doesnt need more)
  // Way 0 dcache
  MetaDataArray dmetarray0(.clk(clk), .rst(rst), .DataIn(), .Write(write_tag_array), .BlockEnable(curr_pc[9:4]), .DataOut(TagOut0_dcache));
  DataArray ddatarray0(.clk(clk), .rst(rst), .DataIn(ddata_in), .Write(write_data_array), .BlockEnable(curr_pc[9:4]), .WordEnable(memory_address[3:0]), .DataOut(DataOut0_dcache));
  // Way 1 dcache
  MetaDataArray dmetarray1(.clk(clk), .rst(rst), .DataIn(), .Write(write_tag_array), .BlockEnable(curr_pc[9:4]), .DataOut(TagOut1_dcache));
  DataArray ddatarray1(.clk(clk), .rst(rst), .DataIn(ddata_in), .Write(write_data_array), .BlockEnable(curr_pc[9:4]), .WordEnable(memory_address[3:0]), .DataOut(DataOut1_dcache));



  // cache FSM
  cache_fill_FSM(.clk(clk), .rst(rst), .miss_detected(icache_miss_detected | dcache_miss_detected), .miss_address(miss_address), .fsm_busy(fsm_busy), .write_data_array(write_data_array),
                 .write_tag_array(write_tag_array), .memory_address(memory_address), .memory_data_valid(memory_data_valid));

  
  // Determine cache miss (TODO: WHAT BITS TO CHECK FOR TAG)
  assign icache_miss_detected = (curr_pc[15:10] === TagOut0_icache[5:0]) || (curr_pc[15:10] === TagOut1_icache[5:0]) ||
                                (curr_pc[15:10] === DataOut0_icache[5:0]) || (curr_pc[15:10] === DataOut1_icache[5:0]);

  assign dcache_miss_detected = (curr_pc[15:10] === TagOut0_dcache[5:0]) || (curr_pc[15:10] === TagOut1_dcache[5:0]) ||
                                (curr_pc[15:10] === DataOut0_dcache[5:0]) || (curr_pc[15:10] === DataOut1_dcache[5:0]);

  
  // input data to be written to dcache
  assign ddata_in = dcache_data;

  // input data to be written to icache
  assign idata_in = MainMemOut;

 
  // Memory module (TODO: WHAT IS DATA INPUT)
  memory4c mainmem(.data_out(MainMemOut), .data_in(), .addr(memory_address), .enable(icache_miss_detected | dcache_miss_detected), 
                   .wr(write_data_array), .clk(clk), .rst(rst), .data_valid(memory_data_valid));

endmodule

