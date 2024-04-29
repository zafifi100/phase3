module cache(
  input clk, rst,
  input write,
  input [7:0] DataIn, WordEnable,
  input [127:0] BlockEnable,
  output [7:0] TagOut,
  output [15:0] DataOut
);


  MetaDataArray metarray(.clk(clk), .rst(rst), .DataIn(DataIn), .Write(write), .BlockEnable(BlockEnable), .DataOut(TagOut));
  DataArray datarray(.clk(clk), .rst(rst), .DataIn(DataIn), .Write(write), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(DataOut));

endmodule

  

