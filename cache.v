module cache (
  input clk, rst, cacheRead, cacheWrite,
  input [15:0] address, data_in,
  input metawrite, datawrite,
  output miss,
  output [15:0] data_out
);

  //Wires for holding the address bits
  wire [5:0] tag_bits, set_bits;
  wire [3:0] block_offset_bits;

  //Wires for block and word
  wire [63:0] blockenable;
  wire [7:0] wordenable;

  //Wires for the meta data array
  wire [7:0] metaout0, metaout1; //This is the one used for comparing
  wire [7:0] metain0, metain1;
  
  //Keeps track of the hit and miss stuff
  wire way0hit, way1hit;

  //Cache output
  wire [15:0] data_out0, data_out1;

  //split the bits
  assign tag_bits = address[15:10];
  assign set_index = address[9:4];
  assign block_offset_bits = address[3:1];

  //decode the set/block
  decoder6_64 blockdecoder(.decode_in(set_bits), .decode_out(blockenable));
  //decode the word
  decoder3_8 worddecoder(.decode_in(block_offset_bits), .decode_out(wordenable)); 

  //check for a hit or a miss
  assign way0hit = ((tag_bits === metaout0[5:0]) & metaout0[6]) ? 1'b1 : 1'b0;
  assign way1hit = ((tag_bits === metaout1[5:0]) & metaout1[6]) ? 1'b1 : 1'b0;
  assign miss = way0hit | way1hit;

  //if there is a miss and we need to evict or no data in cache assign to way0.
  assign evict = ((metaout0[7] === 1'b1) & miss) ? 1'b1 : ((metaout1[7] === 1'b1) & miss) ? 1'b0 : 1'b0; 

  //calculate the new meata data in.
  assign metain0 = (way0hit) ? {1'b1, 1'b1, tag_bits} : 
                   (way1hit) ? {1'b0, metaout0[6], metaout0[5:0]} :
                   (miss & ~evict) ? {1'b1, 1'b1, tag_bits} : 
                   7'bz;  //condition should not hit
                
  assign metain1 = (way1hit) ? {1'b1, 1'b1, tag_bits} : 
                   (way0hit) ? {1'b0, metaout1[6], metaout1[5:0]} :
                   (miss & evict) ? {1'b1, 1'b1, tag_bits} : 
                   7'bz; //condition should not hit

  


  // Way 0 icache
  MetaDataArray metarray0(.clk(clk), .rst(rst), .DataIn(metain0), .Write(way0hit), .BlockEnable(blockenable), .DataOut(metaout0));
  DataArray datarray0(.clk(clk), .rst(rst), .DataIn(data_in), .Write(cacheWrite), .BlockEnable(blockenable), .WordEnable(wordenable), .DataOut(data_out0));

  // Way 1 icache
  MetaDataArray metarray1(.clk(clk), .rst(rst), .DataIn(metain1), .Write(way1hit), .BlockEnable(blockenable), .DataOut(metaout1));
  DataArray datarray1(.clk(clk), .rst(rst), .DataIn(data_in), .Write(cacheWrite), .BlockEnable(blockenable), .WordEnable(wordenable), .DataOut(data_out1));


  assign data_out = (way0hit) ? data_out0 : data_out1;

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
  output [63:0] decode_out
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