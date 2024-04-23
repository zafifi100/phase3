module dff_3 (
    input clk, rst, wen,
    input [2:0] d,
    output [2:0] q
);

dff ff[2:0](.q(q), .d(d), .wen(wen), .clk(clk), .rst(rst));

endmodule
