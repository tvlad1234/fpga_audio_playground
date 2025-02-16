module i2s_tx #(parameter DIV_FACTOR = 3)
  (
    input sysclk, // system clock
    input rst, // reset
    input [15:0] din_left, // left channel sample
    input [15:0] din_right, // right channel sample
    output reg bclk, // bit clock output
    output reg wclk, // word clock output
    output reg dout // serial data output
  );

  reg [15:0] div_cnt;

  reg [15:0] reg_data;
  reg [3:0] bit_cnt;

  always @(posedge sysclk)
  begin
    if(!rst)
    begin
      if(div_cnt == DIV_FACTOR)
      begin
        div_cnt <= 1;
        if(bclk)
        begin
          if(bit_cnt == 0)
          begin
            if(wclk)
            begin
              wclk <= 0;
              reg_data <= din_left;
            end
            else
            begin
              wclk <= 1;
              reg_data <= din_right;
            end
          end
          else
          begin
            reg_data <= {reg_data[14:0], 1'b0};
          end
          bit_cnt <= bit_cnt + 1;
        end
        dout <= reg_data[15];
        bclk <= ~bclk;
      end
      else
        div_cnt <= div_cnt + 1;
    end
    else // reset logic
    begin
      reg_data <= 0;
      dout <= 0;
      bit_cnt <= 0;
      bclk <= 0;
      wclk <= 0;
      div_cnt <= 1;
    end
  end

endmodule
