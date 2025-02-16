/*
  Testbench for the reverb effect
*/

`timescale 1ns / 1ps

module tb_reverb;

  reg clk, rst, samp_clk;

  wire [15:0] reverb_out;
  reg [15:0] impulse, input_sample;

  reverb #(.FIFO_LENGTH(20)) dut_reverb (clk, rst, samp_clk, input_sample, reverb_out);

  always #2.5 clk = ~clk; // 200 MHz

  // sample at 96kHz
  always #20833 input_sample = impulse;
  always #10416.5
  begin
    samp_clk = 1;
    #2.5 samp_clk = 0;
  end

  initial
  begin

    $dumpfile("tb_reverb.vcd");
    $dumpvars(0,tb_reverb);

    clk = 0;
    rst = 0;
    samp_clk = 0;
    input_sample = 0;
    impulse = 0;

    #2 rst = 1;
    #5 rst = 0;

    #10416.5 impulse = 65535;
    #10416.5 impulse = 0;

    #5000000 $finish;

  end

endmodule
