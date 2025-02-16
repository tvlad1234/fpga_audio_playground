PROJ = fpga_audio_playground
TOPMODULE = top_reverb

VERILOG_SRC = i2s/i2s_tx.v i2s/i2s_rx.v dac/pdm.v sine/sine.v top/pll.v effects/reverb.v top/top_reverb.v top/top_sine_tx.v

SIM_TOP = tb_reverb
SIM_SRC = tb/tb_i2s.v tb/tb_reverb.v


include support/colorveri.mk
