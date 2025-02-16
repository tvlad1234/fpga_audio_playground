module reverb #(FIFO_LENGTH = 500)
  (
    input clk,
    input rst,
    input samp_clk,
    input [15:0] in_samp,
    output reg [15:0] out_samp
  );

  localparam state_reset = 4'd0;
  localparam state_clearing = 4'd1;
  localparam state_idle = 4'd2;
  localparam state_shifting = 4'd3;

  reg [3:0] current_state;

  reg [15:0] fifo [0:FIFO_LENGTH - 1];
  reg[15:0] mem_ptr;
  integer i;

  always @(posedge clk)
  begin
    if(!rst)
    begin
      case (current_state)

        state_reset: 
        begin
          mem_ptr <= 0;
          out_samp <= 0;
          current_state <= state_clearing;
        end

        state_clearing:
        begin
          if(mem_ptr < FIFO_LENGTH)
          begin
            fifo[mem_ptr] <= 0;
            mem_ptr <= mem_ptr + 1;
            current_state <= state_clearing;
          end
          else
            current_state <= state_idle;
        end

        state_idle:
        begin
          if(samp_clk)
          begin
            mem_ptr <= FIFO_LENGTH - 2;
            current_state <= state_shifting;
            out_samp <= (in_samp  >> 1) + (fifo[FIFO_LENGTH - 1] >> 1);
            fifo[0] <= out_samp ;
          end
          else
            current_state <= state_idle;
        end

        state_shifting:
        begin
          fifo[mem_ptr + 1] <= fifo[mem_ptr];
          mem_ptr <= mem_ptr - 1;

          if(mem_ptr == 0)
            current_state <= state_idle;
          else
            current_state <= state_shifting;
        end

        default:
          current_state <= state_reset;

      endcase
    end

    else
      current_state <= state_reset;

  end


endmodule
