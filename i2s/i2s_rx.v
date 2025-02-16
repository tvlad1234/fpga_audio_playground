module i2s_rx(
    input sysclk, // system clock
    input rst, // reset
    input bclk, // bit clock input
    input wclk, // word clock output
    input din, // serial data input
    output reg[15:0] do_left, // left channel received data
    output reg [15:0] do_right, // right channel received data
    output reg rec_clk // L+R samples received clock output (rises when L+R packet has been received)
  );

  reg samp_bclk, samp_wclk, samp_din;
  reg samp_bclk_d, samp_wclk_d, samp_din_d;

  reg prev_bclk, prev_wclk;
  reg bclk_rising, bclk_falling, wclk_rising, wclk_falling;
  reg [15:0] datareg, datareg_rot;

  integer i; // used to rotate datareg


  always @(posedge sysclk)
  begin
    // edge detect for the clocks
    bclk_rising <= (!prev_bclk && samp_bclk);
    bclk_falling <= (prev_bclk && !samp_bclk);
    wclk_rising <= (!prev_wclk && samp_wclk);
    wclk_falling <= (prev_wclk && !samp_wclk);
  end

  always @(posedge sysclk)
  begin

    // double flopping to ensure proper clock domain crossing
    samp_bclk_d <= bclk;
    samp_bclk <= samp_bclk_d;
    samp_wclk_d <= wclk;
    samp_wclk <= samp_wclk_d;
    samp_din_d <= din;
    samp_din <= samp_din_d;

    if(!rst)
    begin

      if(bclk_falling)
      begin
        datareg <= {samp_din, datareg[15:1]};
      end

      else if(bclk_rising)
      begin
        if(wclk_rising)
        begin
          datareg <= 0;
          do_left <= datareg_rot;
          rec_clk <= 1;
        end
        else if (wclk_falling)
        begin
          datareg <= 0;
          do_right <= datareg_rot;
        end
        prev_wclk <= samp_wclk;
      end

      if(rec_clk)
        rec_clk <= 0;

      // rotate the data register
      for (integer i=0; i<=15; i++)
        datareg_rot[i] <= datareg[15-i];

      prev_bclk <= samp_bclk;

    end
    else // reset logic
    begin
      do_left <= 0;
      do_right <= 0;
      datareg_rot <= 0;
      datareg <= 0;
      prev_bclk <= 0;
      prev_wclk <= 0;
      rec_clk <= 0;
    end

  end



endmodule
