`default_nettype none

module uart #(parameter BAUD_DIV = 128)
  (
    input i_clk, // clock
    input i_rst, // reset

    output [2:0] status, // status register [rx available, rx error, tx ready]
    input i_ack, // status ack (clears rx avail and rx error)
    input i_tx_go, // tx go

    input [7:0] i_tx_data,
    output [7:0] o_rx_data,

    output o_tx,
    input i_rx
  );

  wire rx, rx_avail, rx_err, tx_ready;

  assign status = {rx_avail, rx_err, tx_ready};

  rx #(.BAUD_DIV(BAUD_DIV)) u_rx (i_clk, i_rst, i_rx, i_ack, o_rx_data, rx_err, rx_avail);
  tx #(.BAUD_DIV(BAUD_DIV)) u_tx (i_clk, i_rst, i_tx_go, i_tx_data, o_tx, tx_ready);

endmodule
