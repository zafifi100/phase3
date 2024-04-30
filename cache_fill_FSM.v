`default_nettype none

module cache_fill_FSM(
    input wire clk, rst_n,           
    input wire miss_detected, // active high when tag match logic detects a miss
    input wire [15:0] miss_address, // address that missed the cache
    output wire fsm_busy, // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    output wire write_data_array, // write enable to cache data array to signal when filling with memory_data
    output wire write_tag_array, // write enable to cache tag array to signal when all words are filled in to data array
    output wire [15:0] memory_address, // address to read from memory
    input wire memory_data_valid // active high indicates valid data returning on memory bus
);

  wire state, next_state;
  wire [3:0] chunk_inc, chunk_count;

  dff stateff(.q(state), .d(next_state), .wen(1'b1), .clk(clk), .rst(~rst_n));

  dff chunkff[3:0](.q(chunk_count), .d(chunk_inc), .wen(memory_data_valid), .clk(clk), .rst(~rst_n));
  full_adder_1bit chunkadd[3:0](.A(chunk_count), .B(4'b0010), .cin(1'b0), .cout(), .sum(chunk_inc));

  add addradd(.Sum(memory_address), .Ovfl(), .A(miss_address & 16'hFFF0), .B({12'h000, chunk_count}), .sub(1'b0));


  assign next_state = (miss_detected & ~state) ? 1'b1 :
                      ((chunk_count === 8'h11) && state) ? 1'b0 :
                       1'b1;

  assign write_data_array = (state & memory_data_valid) ? 1'b1 : 1'b0;

  assign write_tag_array = (state && (chunk_count === 8'h11)) ? 1'b1 : 1'b0;

  assign fsm_busy = state;

endmodule
