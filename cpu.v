`default_nettype none

module cpu(clk, rst_n, hlt, pc);

input wire clk, rst_n;
output wire hlt; 
output wire [15:0] pc;


// Signals
wire [15:0] curr_pc, next_pc, branch_addr, PC_out, ntaken, instr;
wire hlt_in, IF_HLT;
wire [2:0] flags;
wire ov;
wire enable_stall;
wire [15:0] IF_PC, IF_instr; 

// Signals
wire ReadIn, WriteReg, PCS, MemtoReg, MemRead, MemWrite, B, BR, HLT, Error, Flush;
wire [1:0] AluSrc1, AluSrc2;
wire [15:0] ALU_In1, ALU_In2;
wire [15:0] LHBorLLB;
wire [15:0] AluOut;
wire [15:0] DstData;
wire [3:0] AluOp;
wire [3:0] ReadRegister1, ReadRegister2, DstReg;
wire [2:0] flags_out, ccc;
wire isbranch;

wire ID_Read_In, ID_WriteReg, ID_PCS, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_HLT;
wire [1:0] ID_AluSrc1, ID_AluSrc2;
wire [3:0] ID_AluOp;
wire [15:0] ID_ReadData1, ID_ReadData2, ID_Instruction, ID_PC;
wire [15:0] imm_sign;
wire [15:0] address, EX_address;
wire [15:0] EX_ALU_Out, EX_DataIn;
wire [15:0] ReadData1, ReadData2;
wire [3:0] ID_Rs, ID_Rt, ID_Rd;

wire EX_MemWrite, EX_MemRead, EX_MemtoReg, EX_PCS, EX_WriteReg, EX_HLT;
wire [15:0] EX_PC, EX_Instruction;
wire [3:0] EX_Rt, EX_Rs, EX_Rd;
wire [15:0] MEM_DataOut;
wire [15:0] MEM_AluOut;
wire [15:0] memDataOut;
wire [15:0] MEM_PC, MEM_Instruction;
wire MEM_MemtoReg, MEM_PCS, MEM_WriteReg, MEM_HLT;
wire [3:0] MEM_Rd;

wire [1:0] ForwardA, ForwardB;
wire ForwardMem;

wire flag_en;
assign flag_en = (ID_Instruction[15:12] === 4'b0000 || ID_Instruction[15:12] === 4'b0001 || ID_Instruction[15:12] === 4'b0010 ||  
                  ID_Instruction[15:12] === 4'b0100 || ID_Instruction[15:12] === 4'b0101 || ID_Instruction[15:12] === 4'b0110) ? 1'b1 : 1'b0;


//////////////////////////////////////////////////////// Instruction Fetch /////////////////////////////////////////////////////////
assign next_pc = (B & isbranch) ? PC_out : ntaken;
assign branch_addr = (BR & isbranch) ? ReadData1 : next_pc;
assign pc = curr_pc;
assign hlt_in = &instr[15:12] & ~Flush;

// PC REG
PC_reg pcReg(.clk(clk), .rst(~rst_n), .D(branch_addr), .enable_stall(~hlt_in & ~enable_stall), .q(curr_pc));

// MEM FETCH
memory1c fetch(.data_out(instr), .data_in(16'h0000), .addr(curr_pc), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));

//PC inc
add ntakenadd(.Sum(ntaken), .Ovfl(ov), .A(curr_pc), .B(16'h0002), .sub(1'b0));

// FLAG REG
flag_register flag_reg(.clk(clk), .rst(~rst_n), .en(flag_en), .D(flags), .q(flags_out));

// IF/ID Pipeline
IF_ID_PipelineReg ifidpipeline(.clk(clk), .rst(~rst_n), .enable_stall(~enable_stall), .hlt_in(hlt_in), .pc(curr_pc), .instr((Flush) ? 16'h4000 : instr), .pc_out(IF_PC), .instr_out(IF_instr), .hlt_out(IF_HLT));


/////////////////////////////////////////////////////// Instruction Decode ///////////////////////////////////////////////////////
control control1(.Opcode(IF_instr[15:12]), .ReadIn(ReadIn), .WriteReg(WriteReg), .PCS(PCS), .AluSrc1(AluSrc1), .AluSrc2(AluSrc2), .MemtoReg(MemtoReg), .MemRead(MemRead), .MemWrite(MemWrite), .B(B), .BR(BR), .HLT(HLT), .AluOp(AluOp), .Error(Error));

assign ReadRegister1 = (ReadIn | MemWrite) ? IF_instr[11:8] : IF_instr[7:4]; //rs
assign ReadRegister2 = (MemWrite | MemRead) ? IF_instr[7:4] : IF_instr[3:0]; //rt
assign DstReg = IF_instr[11:8];

RegisterFile regfile(.clk(clk), .rst(~rst_n), .SrcReg1(ReadRegister1), .SrcReg2(ReadRegister2), .DstReg(MEM_Rd), .WriteReg(MEM_WriteReg), .DstData(DstData), .SrcData1(ReadData1), .SrcData2(ReadData2));

hazarddetection haz(.BR(BR), .EX_MemRead(EX_MemRead), .MemWrite(MemWrite), .MEM_Opcode(EX_Instruction[15:12]), .EX_Rt(EX_Rt), .ID_Rs(ID_Rs), .enable_stall(enable_stall));

//PC CONTROL
PC_control pc_log(.C(IF_instr[11:9]), .I(IF_instr[8:0]), .F(flags_out), .PC_in(IF_PC), .PC_out(PC_out), .B(B), .BR(BR), .isbranch(isbranch), .Flush(Flush));
assign ccc = IF_instr[11:9];

//may need to do more than just this logic in genearl
ID_EX_PipelineReg idexpipeline(.clk(clk), .rst(~rst_n), .ReadIn(ReadIn), .WriteReg(WriteReg), .PCS(PCS), .MemtoReg(MemtoReg), .MemRead(MemRead), .MemWrite(MemWrite), .HLT(IF_HLT), .AluSrc1(AluSrc1), .AluSrc2(AluSrc2), 
		   .AluOp(AluOp), .rs(ReadRegister1), .rt(ReadRegister2), .rd(DstReg), .ReadData1(ReadData1), .ReadData2(ReadData2), .Instruction(IF_instr), .PC(IF_PC), 
		   .ReadIn_out(ID_Read_In), .WriteReg_out(ID_WriteReg), .PCS_out(ID_PCS), .MemtoReg_out(ID_MemtoReg), .MemRead_out(ID_MemRead), .MemWrite_out(ID_MemWrite), 
                   .AluSrc1_out(ID_AluSrc1), .AluSrc2_out(ID_AluSrc2), .AluOp_out(ID_AluOp), .ReadData1_out(ID_ReadData1), .ReadData2_out(ID_ReadData2), 
                   .rs_out(ID_Rs), .rt_out(ID_Rt), .rd_out(ID_Rd), .Instruction_out(ID_Instruction), .PC_out(ID_PC), .HLT_out(ID_HLT));




////////////////////////////////////////////Execution Stage////////////////////////////////////////////
wire [15:0] forward_ALU_IN1, forward_ALU_IN2;
assign forward_ALU_IN1 = (ForwardA === 2'b10) ? EX_ALU_Out : (ForwardA === 2'b01) ? DstData : ID_ReadData1;
assign forward_ALU_IN2 = (ForwardB === 2'b10) ? EX_ALU_Out : (ForwardB === 2'b01) ? DstData : ID_ReadData2;

assign imm_sign = {{12{ID_Instruction[3]}}, ID_Instruction[3:0]} << 1;
add add01(.Sum(address), .Ovfl(), .A(forward_ALU_IN2 & 16'hFFFE), .B(imm_sign), .sub(1'b0));

assign ALU_In1 = (ID_AluSrc1 === 2'b00) ? forward_ALU_IN1 :
                 (ID_AluSrc1 === 2'b01) ? forward_ALU_IN1 & 16'hFF00 :  
                 (ID_AluSrc1 === 2'b10) ? forward_ALU_IN1 & 16'h00FF :
                  forward_ALU_IN1;
                  
assign ALU_In2 = (ID_AluSrc2 === 2'b00) ? forward_ALU_IN2 : 
                 (ID_AluSrc2 === 2'b01) ? ID_Instruction[3:0] :
                 (ID_AluSrc2 === 2'b10) ?  address:
                 ((((ID_AluSrc2 === 2'b11) & ID_Read_In & ID_Instruction[12])) ? ID_Instruction[7:0] << 8 : ID_Instruction[7:0]);

wire [15:0] temp_alu_out;

ALU alu(.ALU_In1(ALU_In1), .ALU_In2(ALU_In2), .Opcode(ID_AluOp), .ALU_Out(temp_alu_out), .flags(flags));

assign AluOut = temp_alu_out;


///////////////Fowarding Unit////////////////////////////////////////////////
forwardunit fu(.EX_MEM_Regwrite(EX_WriteReg), .MEM_WB_Regwrite(MEM_WriteReg), .ReadIn(ID_Read_In), .EX_MEM_RegisterRd(EX_Rd), .ID_EX_RegisterRs(ID_Rs), 
               .ID_EX_RegisterRt(ID_Rt), .MEM_WB_RegisterRd(MEM_Rd), .EX_MEM_RegisterRs(EX_Rs), .ForwardA(ForwardA), .ForwardB(ForwardB), .ForwardMem(ForwardMem));



EX_MEM_PipelineReg exmempipline(.clk(clk), .rst(~rst_n), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead), .MemtoReg(ID_MemtoReg), .rt(ID_Rt), .rt_out(EX_Rt), .rs(ID_Rs), .rs_out(EX_Rs), .rd(ID_Rd), .rd_out(EX_Rd), .HLT(ID_HLT), .Instruction(ID_Instruction), .Address(address), .Address_out(EX_address),
                           .PCS(ID_PCS), .PC(ID_PC), .WriteReg(ID_WriteReg), .Prev_ALU_Out(AluOut), .DataIn(forward_ALU_IN1), .Curr_ALU_Out(EX_ALU_Out), .WriteData(EX_DataIn), .prop_MemWrite(EX_MemWrite), 
                           .prop_MemRead(EX_MemRead), .prop_MemtoReg(EX_MemtoReg), .prop_PCS(EX_PCS), .PC_out(EX_PC), .WriteReg_Out(EX_WriteReg), .HLT_Out(EX_HLT), .Instruction_out(EX_Instruction));



////////////////////////////////////////////Memory Stage////////////////////////////////////////////
wire [15:0] forward_Mem_Data = (ForwardMem) ? DstData : EX_DataIn;
memory1c mem(.data_out(memDataOut), .data_in(forward_Mem_Data), .addr(EX_address), .enable(1'b1), .wr(EX_MemWrite), .clk(clk), .rst(~rst_n));

MEM_WB_PipelineReg memwbpipeline(.clk(clk), .rst(~rst_n), .PCS(EX_PCS), .MemtoReg(EX_MemtoReg), .Prev_MemData(memDataOut), .PC(EX_PC), .HLT(EX_HLT), .Instruction(EX_Instruction),
                                .Prev_AluOut(EX_ALU_Out), .WriteReg(EX_WriteReg), .Curr_Memdata(MEM_DataOut), .Curr_AluOut(MEM_AluOut), .rd(EX_Rd), .rd_out(MEM_Rd),
                                .prop_MemtoReg(MEM_MemtoReg), .prop_PCS(MEM_PCS), .PC_out(MEM_PC), .WriteReg_Out(MEM_WriteReg), .HLT_Out(MEM_HLT), .Instuction_Out(MEM_Instruction));



/////////////////////////////////WriteBack/////////////////////////////////////
wire [15:0] PCS_data;
add pcsadd(.Sum(PCS_data), .Ovfl(), .A(MEM_PC), .B(16'h0002), .sub(1'b0));
assign DstData = (MEM_PCS) ? PCS_data : 
                 (MEM_MemtoReg) ? MEM_DataOut : 
                  MEM_AluOut;


assign hlt = MEM_HLT;



endmodule
