# TimeQuest constraints for synapse project
# Target clock: 50 MHz, period = 20 ns.

create_clock -name clk -period 20.000 [get_ports {clk}]

# Let Quartus/TimeQuest apply device-recommended clock uncertainty.
derive_clock_uncertainty

# rst_n is an asynchronous reset input, not a synchronous data path.
set_false_path -from [get_ports {rst_n}]
