module top_sine_tx(
    input i_clk,
    input nrst,
    output out_bclk,
    output out_wclk,
    output out_data
  );

  wire [15:0] data_left, data_right;

  wire rst = ~nrst;

  // 440 Hz sine, divide by 28 to get approx. 440Hz at 25Mhz
  sine #(.DIV_FACTOR(28)) sine_left (i_clk, rst, 0, data_left);
  sine #(.DIV_FACTOR(28)) sine_right (i_clk, rst, 511, data_right);

  i2s_tx #(.DIV_FACTOR(8)) tx(i_clk, rst, data_left, data_right, out_bclk, out_wclk, out_data); // divide by 8 for approx 48kHz at 25MHz

endmodule
