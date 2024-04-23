module MEM_WB_PipelineReg(
  input clk, rst,
  input MemtoReg, PCS, WriteReg, HLT,
  input [3:0] rd,
  output [3:0] rd_out,
  input [15:0] Prev_MemData,
  input [15:0] Prev_AluOut, Instruction,
  input [15:0] PC, 
  output [15:0] PC_out,
  output [15:0] Curr_Memdata,
  output [15:0] Curr_AluOut, Instuction_Out,
  output prop_MemtoReg, prop_PCS, WriteReg_Out, HLT_Out
);

  dff_16 readdata_ff(.q(Curr_Memdata), .d(Prev_MemData), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 aluout_ff(.q(Curr_AluOut), .d(Prev_AluOut), .clk(clk), .rst(rst), .wen(1'b1));
  dff memtoreg_ff(.q(prop_MemtoReg), .d(MemtoReg), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 pc_ff(.q(PC_out), .d(PC), .clk(clk), .rst(rst), .wen(1'b1));
  dff pcs_ff(.q(prop_PCS), .d(PCS), .clk(clk), .rst(rst), .wen(1'b1));
  dff regwrite_ff(.q(WriteReg_Out), .d(WriteReg), .clk(clk), .rst(rst), .wen(1'b1));
  dff hlt_ff(.q(HLT_Out), .d(HLT), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 instructionff(.q(Instuction_Out), .d(Instruction), .clk(clk), .rst(rst), .wen(1'b1));
  dff_4 rdff(.q(rd_out), .d(rd), .clk(clk), .rst(rst), .wen(1'b1));


endmodule

