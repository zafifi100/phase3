module  ID_EX_PipelineReg (
    input clk, rst, ReadIn, WriteReg, PCS, MemtoReg, MemRead, MemWrite, HLT,
    input [1:0] AluSrc1, AluSrc2,
    input [3:0] AluOp, rs, rt, rd,
    input [15:0] ReadData1, ReadData2, Instruction, PC,
    output ReadIn_out, WriteReg_out, PCS_out, MemtoReg_out, MemRead_out, MemWrite_out, HLT_out,
    output [1:0] AluSrc1_out, AluSrc2_out,
    input [3:0] AluOp_out,
    output [3:0] rs_out, rt_out, rd_out,
    output [15:0] ReadData1_out, ReadData2_out, Instruction_out, PC_out
);


dff_2 alusrc1ff(.q(AluSrc1_out), .d(AluSrc1), .clk(clk), .rst(rst), .wen(1'b1));
dff_2 alusrc2ff(.q(AluSrc2_out), .d(AluSrc2), .clk(clk), .rst(rst), .wen(1'b1));
dff_4 aluopff(.q(AluOp_out), .d(AluOp), .clk(clk), .rst(rst), .wen(1'b1));

dff_4 rsff(.q(rs_out), .d(rs), .clk(clk), .rst(rst), .wen(1'b1));
dff_4 rtpff(.q(rt_out), .d(rt), .clk(clk), .rst(rst), .wen(1'b1));
dff_4 rdff(.q(rd_out), .d(rd), .clk(clk), .rst(rst), .wen(1'b1));

dff readinff(.q(ReadIn_out), .d(ReadIn), .clk(clk), .rst(rst), .wen(1'b1));
dff writeregff(.q(WriteReg_out), .d(WriteReg), .clk(clk), .rst(rst), .wen(1'b1));
dff pcsff(.q(PCS_out), .d(PCS), .clk(clk), .rst(rst), .wen(1'b1));
dff memtoregff(.q(MemtoReg_out), .d(MemtoReg), .clk(clk), .rst(rst), .wen(1'b1));
dff memreadff(.q(MemRead_out), .d(MemRead), .clk(clk), .rst(rst), .wen(1'b1));
dff memwriteff(.q(MemWrite_out), .d(MemWrite), .clk(clk), .rst(rst), .wen(1'b1));
dff hltff(.q(HLT_out), .d(HLT), .clk(clk), .rst(rst), .wen(1'b1));

dff_16 readdata1ff(.q(ReadData1_out), .d(ReadData1), .clk(clk), .rst(rst), .wen(1'b1));
dff_16 readdata2ff(.q(ReadData2_out), .d(ReadData2), .clk(clk), .rst(rst), .wen(1'b1));
dff_16 instructionff(.q(Instruction_out), .d(Instruction), .clk(clk), .rst(rst), .wen(1'b1));
dff_16 pc_ff(.q(PC_out), .d(PC), .clk(clk), .rst(rst), .wen(1'b1));

    
endmodule