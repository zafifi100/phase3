module IF_ID_PipelineReg (
    input clk, rst, enable_stall, hlt_in,
    input [15:0] pc, instr,
    output hlt_out,
    output [15:0] pc_out, instr_out
);


dff_16 pc_ff(.q(pc_out), .d(pc), .clk(clk), .rst(rst), .wen(enable_stall));
dff_16 instrr(.clk(clk), .q(instr_out), .d(instr), .rst(rst), .wen(enable_stall));
dff hltff(.clk(clk), .rst(rst), .wen(enable_stall), .q(hlt_out), .d(hlt_in));

endmodule