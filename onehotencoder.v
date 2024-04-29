module onehotencoder (
    input [5:0] set_index,
    input way,
    output [127:0] set_index_onehot,

);

assign set_index_onehot = (way) ? (128'b1 << set_index) << 64 : (128'b1 << set_index);

endmodule