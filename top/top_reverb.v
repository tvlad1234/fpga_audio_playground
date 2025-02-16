module top_reverb(
    input i_clk, // 25MHz clock input
    input nrst, // Active-low reset button

    // I2S input
    input bclk,
    input wclk,
    input di,

    // PDM outputs
    output left_pdm_out,
    output right_pdm_out,

    // Enable button for the reverb effect
    input effect_button
  );

  wire effect_enable = ~effect_button;
  wire rst = ~nrst; // Active-high reset signal

  // Signals coming from the I2S receiver
  wire [15:0] rx_left, rx_right, left_error, right_error;
  reg [15:0] unsigned_left, unsigned_right;
  wire sample_received;

  // convert signed I2S samples to unsigned
  always @(posedge pll_clk)
  begin
    unsigned_left <= rx_left ^ 16'h8000;
    unsigned_right <= rx_right ^ 16'h8000;
  end

  reg [15:0] reverb_samp_left, reverb_samp_right;
  reg [15:0] out_sample_left, out_sample_right;

  always @(posedge pll_clk)
  begin
    if(effect_enable)
    begin
      out_sample_left <= reverb_samp_left;
      out_sample_right <= reverb_samp_right;
    end
    else
    begin
      out_sample_left <= unsigned_left;
      out_sample_right <= unsigned_right;
    end
  end

  // PLL to get 70MHz from the 25MHz on-board clock
  wire pll_clk, pll_locked;
  pll mypll(i_clk, pll_clk, pll_locked);

  // I2S receiver
  i2s_rx rx(pll_clk, rst, bclk, wclk, di, rx_left, rx_right, sample_received);

  // Effects
  reverb #(.FIFO_LENGTH(2100)) left_reverb (pll_clk, rst, sample_received, unsigned_left, reverb_samp_left);
  reverb #(.FIFO_LENGTH(2100)) right_reverb (pll_clk, rst, sample_received, unsigned_right, reverb_samp_right);

  // PDM modulators
  // divide 70MHz by 11 to get approx 128x oversampling for 48kHz audio
  pdm #(.DIV_FACTOR(11)) left_pdm(pll_clk, rst, sample_received, out_sample_left, left_pdm_out, left_error);
  pdm #(.DIV_FACTOR(11)) right_pdm(pll_clk, rst, sample_received, out_sample_right, right_pdm_out, right_error);

endmodule
