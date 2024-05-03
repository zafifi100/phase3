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

  // Decode logic
  wire [63:0] iblockenable, dblockenable; // blockenable one hot encoded
  wire [7:0] iwordenableinstur, dwordenableinstur; // word enable one hot encoded
  wire [6:0] iwordenablemiss, dwordenablemiss; //word enable one hot encoded (miss)
  wire [6:0] iwordenable, dwordenable; //Actuall wordenable to be used based on a miss or hit

  //Proccesor input
  decoder3_8 iworddecoder(.decode_in(curr_pc[3:1]), .decode_out(iwordenableinstur));
  decoder3_8 dworddecoder(.decode_in(dcache_data[3:1]), .decode_out(dwordenableinstur));

  //The block should be the same on a hit and miss since the adress is the same as the missadress
  //Only word offsets change
  decoder6_64 iblockdecoder(.decode_in(curr_pc[9:4]), .decode_out(iblockenable));
  decoder6_64 dblockdecoder(.decode_in(dcache_data[9:4]), .decode_out(dblockenable));

  //Memory input on a miss
  decoder3_8 iworddecodermiss(.decode_in(miss_address[3:1]), .decode_out(iwordenablemiss));
  decoder3_8 dworddecodermiss(.decode_in(miss_address[3:1]), .decode_out(dwordenablemiss));

  //Detmining which word enable to use
  assign iwordenable = (icache_miss_detected) ? iwordenablemiss : iwordenableinstur;
  assign dwordenable = (dcache_miss_detected) ? dwordenablemiss : iwordenablemiss;

  //TODO: Need logic to determine what way to write to when we have a hit on a save word or miss and we need  to write the data one of the data blocks.

  // instruction cache (TODO: Complete port hookups & check write enable doesnt need more)
  // Way 0 icache
  MetaDataArray imetarray0(.clk(clk), .rst(rst), .DataIn(imetadata0_in), .Write(write_tag_array), .BlockEnable(iblockenable), .DataOut(TagOut0_icache));
  DataArray idatarray0(.clk(clk), .rst(rst), .DataIn(idata_in), .Write(write_data_array), .BlockEnable(iblockenable), .WordEnable(iwordenable), .DataOut(DataOut0_icache));
  // Way 1 icache
  MetaDataArray imetarray1(.clk(clk), .rst(rst), .DataIn(imetadata1_in), .Write(write_tag_array), .BlockEnable(iblockenable), .DataOut(TagOut1_icache));
  DataArray idatarray1(.clk(clk), .rst(rst), .DataIn(idata_in), .Write(write_data_array), .BlockEnable(iblockenable), .WordEnable(iwordenable), .DataOut(DataOut1_icache));

  // data cache (TODO: Complete port hookups & check write enable doesnt need more)
  // Way 0 dcache
  MetaDataArray dmetarray0(.clk(clk), .rst(rst), .DataIn(dmetadata0_in), .Write(write_tag_array), .BlockEnable(dblockenable), .DataOut(TagOut0_dcache));
  DataArray ddatarray0(.clk(clk), .rst(rst), .DataIn(ddata_in), .Write(write_data_array), .BlockEnable(dblockenable), .WordEnable(dwordenable), .DataOut(DataOut0_dcache));
  // Way 1 dcache
  MetaDataArray dmetarray1(.clk(clk), .rst(rst), .DataIn(dmetadata1_in), .Write(write_tag_array), .BlockEnable(dblockenable), .DataOut(TagOut1_dcache));
  DataArray ddatarray1(.clk(clk), .rst(rst), .DataIn(ddata_in), .Write(write_data_array), .BlockEnable(dblockenable), .WordEnable(dwordenable), .DataOut(DataOut1_dcache));



  // cache FSM
  cache_fill_FSM(.clk(clk), .rst(rst), .miss_detected(icache_miss_detected | dcache_miss_detected), .miss_address(miss_address), .fsm_busy(fsm_busy), .write_data_array(write_data_array),
                 .write_tag_array(write_tag_array), .memory_address(memory_address), .memory_data_valid(memory_data_valid));

  
  // Determine cache miss (TODO: WHAT BITS TO CHECK FOR TAG)
  wire[1:0] icache_hit_miss = ((curr_pc[15:10] === TagOut0_icache[5:0]) & TagOut0_icache[7]) ? 1'b00 : 

  assign icache_miss_detected = ((curr_pc[15:10] === TagOut0_icache[5:0]) & TagOut0_icache[7]) || ((curr_pc[15:10] === TagOut1_icache[5:0]) & TagOut1_icache[7]) ||
                                ((curr_pc[15:10] === DataOut0_icache[5:0]) & TagOut0_icache[7])|| ((curr_pc[15:10] === DataOut1_icache[5:0]) & TagOut1_icache[7]);

  assign dcache_miss_detected = ((curr_pc[15:10] === TagOut0_dcache[5:0]) & TagOut0_dcache[7]) || ((curr_pc[15:10] === TagOut1_dcache[5:0]) & TagOut1_dcache[7]) ||
                                (curr_pc[15:10] === DataOut0_dcache[5:0]) & TagOut0_dcache[7]|| ((curr_pc[15:10] === DataOut1_dcache[5:0])& TagOut1_dcache[7]);

  
  //Valid bit logic
  // Valid bit is set to 0 when the process starts up it sets it 1 when there are misses in the cache.

  assign dvalid0_bit = (dcache_miss_detected & ~dLRU0_bit) ? 1'b1 : dvalid0_bit;
  assign dvalid1_bit = (dcache_miss_detected & ~dLRU1_bit) ? 1'b1 : dvalid1_bit;

  assign ivalid0_bit = (icache_miss_detected & ~iLRU0_bit) ? 1'b1 : ivalid0_bit;
  assign ivalid1_bit = (icache_miss_detected & ~iLRU1_bit) ? 1'b1 : ivalid1_bit;

  // input data to be written to dcache
  assign ddata_in = MainMemOut;
  assign dmetadata0_in = {dLRU0_bit, dvalid0_bit, memory_address[15:10]};
  assign dmetadata1_in = {dLRU1_bit, dvalid1_bit, memory_address[15:10]};

  // input data to be written to icache
  assign idata_in = MainMemOut;
  assign imetadata0_in = {iLRU0_bit, ivalid0_bit, memory_address[15:10]};
  assign imetadata1_in = {iLRU1_bit, ivalid1_bit, memory_address[15:10]};

 
  // Memory module (TODO: WHAT IS DATA INPUT) ///Contention
  memory4c mainmem(.data_out(MainMemOut), .data_in(), .addr(memory_address), .enable(icache_miss_detected | dcache_miss_detected), 
                   .wr(write_data_array), .clk(clk), .rst(rst), .data_valid(memory_data_valid));

endmodule


module decoder3_8 (
  input [2:0] decode_in,
  output [7:0] decode_out
);
  assign decode_out = (decode_in == 3'b000) ? 8'b00000001 :
             (decode_in == 3'b001) ? 8'b00000010 :
             (decode_in == 3'b010) ? 8'b00000100 :
             (decode_in == 3'b011) ? 8'b00001000 :
             (decode_in == 3'b100) ? 8'b00010000 :
             (decode_in == 3'b101) ? 8'b00100000 :
             (decode_in == 3'b110) ? 8'b01000000 :
             8'b11111111;
  
endmodule


module decoder6_64 (
  input [5:0] decode_in,
  output [63:0] decode_out,
);

  wire [63:0] b0, b1, b2, b3, b4, b5, b6;

  assign b0 = 128'b1;
  assign b1 = decode_in[0] ? (b0 << 1) : b0;
  assign b2 = decode_in[1] ? (b1 << 2) : b1;
  assign b3 = decode_in[2] ? (b2 << 4) : b2;
  assign b4 = decode_in[3] ? (b3 << 8) : b3;
  assign b5 = decode_in[4] ? (b4 << 16) : b4;
  assign b6 = decode_in[5] ? (b5 << 32) : b5;
  assign decode_out = b6;

endmodule