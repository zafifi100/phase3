module forwardunit (
    input EX_MEM_Regwrite, MEM_WB_Regwrite, ReadIn,
    input [3:0] EX_MEM_RegisterRd, ID_EX_RegisterRs,  ID_EX_RegisterRt, MEM_WB_RegisterRd, EX_MEM_RegisterRs, 
    output [1:0] ForwardA,
    output [1:0] ForwardB,
    output ForwardMem
);


//Assigning Forward A and B
assign ForwardA = (EX_MEM_Regwrite & EX_MEM_RegisterRd == ID_EX_RegisterRs) ? 2'b10 :
			(MEM_WB_Regwrite & MEM_WB_RegisterRd == ID_EX_RegisterRs) ? 2'b01 : 2'b00;
assign ForwardB = (EX_MEM_Regwrite & EX_MEM_RegisterRd == ID_EX_RegisterRt) ? 2'b10 :
			(MEM_WB_Regwrite & MEM_WB_RegisterRd == ID_EX_RegisterRt) ? 2'b01 : 2'b00;

/// MEM-MEM Forwarding
assign ForwardMem = (MEM_WB_Regwrite & (MEM_WB_RegisterRd == EX_MEM_RegisterRs)) ? 1'b1 : 1'b0;

endmodule