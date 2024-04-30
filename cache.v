module cache (
  input clk, rst, WriteEnable0, WriteEnable1, MetaDataWriteEnable0, MetaDataWriteEnable1,
  input [15:0] DataIn0, DataIn1,
  input [7:0] MetaDataIn0, MetaDataIn1,
  input [63:0] BlockEnable,
  input [7:0] WordEnable,
  output [15:0] Dataout0, Dataout1,
  output [7:0] MetaDataOut0, MetaDataOut1
);

//module DataArray(input clk, input rst, input [15:0] DataIn, input Write, input [63:0] BlockEnable, input [7:0] WordEnable, output [15:0] DataOut);
DataArray dataarray0(.clk(clk), .rst(rst), .DataIn(DataIn0), .Write(WriteEnable0), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(Dataout0));
DataArray dataarray1(.clk(clk), .rst(rst), .DataIn(DataIn1), .Write(WriteEnable1), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(Dataout1));

//module MetaDataArray(input clk, input rst, input [7:0] DataIn, input Write, input [63:0] BlockEnable, output [7:0] DataOut);
MetaDataArray metadataarray0(.clk(clk), .rst(rst), .DataIn(MetaDataIn0), .Write(MetaDataWriteEnable0), .BlockEnable(BlockEnable), .DataOut(MetaDataOut0));
MetaDataArray metadataarray0(.clk(clk), .rst(rst), .DataIn(MetaDataIn1), .Write(MetaDataWriteEnable1), .BlockEnable(BlockEnable), .DataOut(MetaDataOut1));

endmodule