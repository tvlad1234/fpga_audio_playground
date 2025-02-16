module pdm #(parameter NBITS = 16, parameter DIV_FACTOR = 3)
  (
    input clk,
    input rst,
    input samp_clk,
    input [NBITS-1:0] din,
    output reg dout,
    output reg [NBITS-1:0] error
  );

  localparam OUT_MAX = 2**NBITS - 1;
  reg [NBITS-1:0] din_reg;
  reg [NBITS-1:0] current_out;

  reg [7:0] div_cnt;

  always@(*)
  begin
    if(dout)
      current_out = OUT_MAX;
    else
      current_out = 0;
  end

  always @(posedge clk)
  begin

    if(!rst)
    begin
      if (samp_clk)
        din_reg <= din;

      if(div_cnt == DIV_FACTOR)
      begin
        div_cnt <= 1;

        error <= error + current_out - din_reg;

        if(din_reg > error)
          dout <= 1;
        else
          dout <= 0;
      end
      else
        div_cnt <= div_cnt + 1;
    end

    // reset logic
    else
    begin
      error <= 0;
      dout <= 0;
      din_reg <= 0;
      div_cnt <= 1;
    end


  end


endmodule
