module sine #(DIV_FACTOR = 1)
  (
    input clk,
    input rst,
    input [10:0] phase,
    output reg [15:0] dout
  );

  reg [9:0] div_cnt;
  reg [10:0] lut_cnt;


  reg [15:0] sine_lut [2047:0];

  initial
  begin
    $readmemh("sine/sine_lut.mem", sine_lut);
  end

  always @(posedge clk)
  begin
    if(!rst)
    begin
      if (div_cnt == DIV_FACTOR)
      begin
        lut_cnt <= lut_cnt + 1;
        div_cnt <= 1;
      end
      else
        div_cnt <= div_cnt + 1;
    end

    else
    begin
      lut_cnt <= 0;
      div_cnt <= 0;
    end
    dout <= sine_lut[lut_cnt + phase]; //  ^ 16'h8000;;

  end

endmodule
