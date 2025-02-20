/*
  Example which generates two sine waves on PDM outputs, with the frequency and phase shift set over UART (see the sine_controller program)

  Pin mappings: 
    Pushbutton: reset
    J2-2: PDM output, left channel
    J3-2: PDM output, right channel
    J4-2: UART RX, 9600 baud
*/

`default_nettype none

module top_sine_pdm_uart(
    input i_clk,
    input nrst,

    input uart_rx,

    output left_pdm_out,
    output right_pdm_out
  );

  reg rst;

  always @(posedge i_clk)
  begin
    rst <= ~nrst;
  end

  // Control registers
  reg [15:0] sine_div_factor, sine_phase;

  localparam reg_sine_div = 8'd1;
  localparam reg_phase = 8'd2;

  wire cmd_en; // command enable
  wire [15:0] cmd_data; // command data register
  wire [7:0] cmd_addr; // command address register

  // UART command interface
  localparam baudrate = 9600; // baud rate
  localparam clock_freq = 25000000; // input clock frequency in Hz

  command_rx #(.BAUD_DIV(clock_freq / baudrate)) cmd(i_clk, rst, uart_rx, cmd_en, cmd_addr, cmd_data);

  always @(posedge i_clk)
  begin
    if(!rst)
    begin
      if (cmd_en)
      begin
        case (cmd_addr)
          reg_sine_div :
            sine_div_factor <= cmd_data;
          reg_phase :
            sine_phase <= cmd_data;
          default:
          begin
            sine_div_factor <= sine_div_factor;
            sine_phase <= sine_phase;
          end
        endcase
      end
    end
    else
    begin
      sine_div_factor <= 1;
      sine_phase <= 0;
    end

  end

  // Sine generator
  wire [15:0] sine_left, sine_right, left_pdm_error, right_pdm_error;

  // 440 Hz sine, divide by 28 to get approx. 440Hz at 25Mhz
  sine sine_gen_left (i_clk, rst, sine_div_factor, 0, sine_left);
  sine sine_gen_right (i_clk, rst, sine_div_factor,  sine_phase[10:0] , sine_right);

  // Sampler
  reg sample_received;
  reg [15:0] out_sample_left, out_sample_right;

  localparam samp_div = 130;
  reg [15:0] samp_cnt;

  always @(posedge i_clk)
  begin
    if(!rst)
    begin
      if(samp_cnt == samp_div)
      begin
        samp_cnt <= 1;
        sample_received <= 1;
        out_sample_left <= sine_left;
        out_sample_right <= sine_right;
      end
      else
      begin
        sample_received <= 0;
        samp_cnt <= samp_cnt + 1;
      end
    end
    else
    begin
      samp_cnt <= 1;
      sample_received <= 0;
    end
  end

  // PDM modulators
  // no division for 128x oversampling for 192kHz at 25MHz
  pdm #(.DIV_FACTOR(1)) left_pdm(i_clk, rst, sample_received, out_sample_left, left_pdm_out, left_pdm_error);
  pdm #(.DIV_FACTOR(1)) right_pdm(i_clk, rst, sample_received, out_sample_right, right_pdm_out, right_pdm_error);


endmodule
