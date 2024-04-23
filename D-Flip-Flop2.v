module dff_2 (
    input clk, rst, wen,
    input [1:0] d,
    output [1:0] q
);

dff ff[1:0](.q(q), .d(d), .wen(wen), .clk(clk), .rst(rst));

endmodule
