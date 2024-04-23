/*module hazarddetection (
    input ID_EX_MemRead,  IF_ID_MemWrite, 
    input [3:0] ID_EX_RegisterRd, IF_ID_RegisterRs, IF_ID_RegisterRt,
    output enable_stall
);

assign enable_stall = (ID_EX_MemRead & (ID_EX_RegisterRd != 4'b0000) & ((ID_EX_RegisterRd == IF_ID_RegisterRs) | ((ID_EX_RegisterRd == IF_ID_RegisterRt) & (~IF_ID_MemWrite))));

endmodule
*/

module hazarddetection(
    input BR, EX_MemRead, MemWrite,
    input [3:0] MEM_Opcode, EX_Rt, ID_Rs,
    output enable_stall
);

  // load-to-use stall
  // flag stall (flag instr happening immediately before branch)
  assign flag_stall = (BR) ? ((MEM_Opcode === 4'b0000 | MEM_Opcode === 4'b0001 | 
                               MEM_Opcode === 4'b0010 | MEM_Opcode === 4'b0100 | 
                               MEM_Opcode === 4'b0101 | MEM_Opcode === 4'b0110)) : 1'b0;
 
  assign load_to_use = (EX_MemRead && (EX_Rt != 4'b0000) && (EX_Rt === ID_Rs)) && (EX_MemRead && (EX_Rt != 4'b0000) && (EX_Rt == ID_Rs) && (~MemWrite));

  assign enable_stall = (flag_stall | load_to_use);

endmodule
