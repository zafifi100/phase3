module EX_MEM_PipelineReg(
  input clk, rst,
  input MemWrite, MemRead, MemtoReg, PCS, WriteReg, HLT,
  input [3:0] rt, rs, rd,
  output [3:0] rt_out, rs_out, rd_out,
  input [15:0] Prev_ALU_Out, DataIn, PC, Instruction, Address,
  output [15:0] Curr_ALU_Out, WriteData, PC_out, Instruction_out, Address_out,
  output prop_MemWrite, prop_MemRead, prop_MemtoReg, prop_PCS, WriteReg_Out, HLT_Out
);

  dff_16 pc_ff(.q(PC_out), .d(PC), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 memaddr_ff(.q(Curr_ALU_Out), .d(Prev_ALU_Out), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 writedata_ff(.q(WriteData), .d(DataIn), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 instructionff(.q(Instruction_out), .d(Instruction), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 addressff(.q(Address_out), .d(Address), .clk(clk), .rst(rst), .wen(1'b1));

  dff_4 rtff(.q(rt_out), .d(rt), .clk(clk), .rst(rst), .wen(1'b1));
  dff_4 rsff(.q(rs_out), .d(rs), .clk(clk), .rst(rst), .wen(1'b1));
  dff_4 rdff(.q(rd_out), .d(rd), .clk(clk), .rst(rst), .wen(1'b1));

  dff memwrite_ff(.q(prop_MemWrite), .d(MemWrite), .clk(clk), .rst(rst), .wen(1'b1));
  dff memread_ff(.q(prop_MemRead), .d(MemRead), .clk(clk), .rst(rst), .wen(1'b1));
  dff memtoreg_ff(.q(prop_MemtoReg), .d(MemtoReg), .clk(clk), .rst(rst), .wen(1'b1));
  dff pcs_ff(.q(prop_PCS), .d(PCS), .clk(clk), .rst(rst), .wen(1'b1));
  dff writereg_ff(.q(WriteReg_Out), .d(WriteReg), .clk(clk), .rst(rst), .wen(1'b1));
  dff hlt_ff(.q(HLT_Out), .d(HLT), .clk(clk), .rst(rst), .wen(1'b1));

endmodule
