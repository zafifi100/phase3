module PC_reg(
    input clk, rst, 
    input [15:0] D, 
    input enable_stall,
    output [15:0] q
);

dff ff[15:0](.q(q), .d(D), .wen(enable_stall), .clk(clk), .rst(rst));

endmodule


