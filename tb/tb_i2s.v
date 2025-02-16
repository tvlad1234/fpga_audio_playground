/*
  Testbench for the I2S transmitter and receiver
    - Transmitter send out two 90deg phase shifted 440Hz sine waves at approx. 48kHz
    - Receiver ~receives~ them 
*/

`timescale 1ns / 1ps

module tb_i2s;

  reg tx_clk, tx_rst, rx_clk, rx_rst;

  wire [15:0] tx_left, tx_right, sine_left, sine_right, rx_left,  rx_right;
  wire [10:0] phase_left = 0;
  wire [10:0] phase_right = 511;

  wire tx_bclk, tx_wclk, tx_do, rx_bclk, rx_wclk, rx_di, rx_rec_clk;

  assign tx_left = sine_left;
  assign tx_right = sine_right;
  assign rx_bclk = tx_bclk;
  assign rx_wclk = tx_wclk;
  assign rx_di = tx_do;

  // 440 Hz sine, divide by 28 to get approx. 440Hz at 25Mhz
  sine #(.DIV_FACTOR(28)) dut_sine_left (tx_clk, tx_rst, phase_left, sine_left);
  sine #(.DIV_FACTOR(28)) dut_sine_right (tx_clk, tx_rst, phase_right, sine_right);

  // I2S transmitter and receiver
  i2s_tx #(.DIV_FACTOR(8)) dut_tx(tx_clk, tx_rst, tx_left, tx_right, tx_bclk, tx_wclk, tx_do); // divide by 8 for approx 48kHz at 25MHz
  i2s_rx dut_rx(rx_clk, rx_rst, rx_bclk, rx_wclk, rx_di, rx_left, rx_right, rx_rec_clk);

  always #20 tx_clk = ~tx_clk; // 25 MHz (as on the Colorlight board)
  always #20 rx_clk = ~rx_clk; // 25 MHz

  initial
  begin

    $dumpfile("tb_i2s.vcd");
    $dumpvars(0,tb_i2s);

    tx_rst <= 0;
    tx_clk <= 0;

    rx_rst <= 0;
    rx_clk <= 0;

    #2 rx_rst <= 1;
    #2 rx_rst <= 0;

    #60 tx_rst <= 1;
    #60 tx_rst <= 0;

    #4540000 $finish; // 2 periods of the 440HZ sine

  end

endmodule
