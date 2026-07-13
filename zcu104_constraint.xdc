# ==============================================================================
# CLOCK CONSTRAINTS
# ==============================================================================
set_property PACKAGE_PIN F23 [get_ports clk_p]
set_property IOSTANDARD LVDS [get_ports clk_p]

set_property PACKAGE_PIN E23 [get_ports clk_n]
set_property IOSTANDARD LVDS [get_ports clk_n]

# Create the timing constraint anchored to the positive pin
create_clock -period 8.000 -name sys_clk [get_ports clk_p]

# ==============================================================================
# RESET CONSTRAINTS
# ==============================================================================
# Using the CPU Reset Button (SW20) - Active High on the physical board layout.
# This matches your logic: 'rst = ~clk_rst' (when button is pressed, clk_rst=1, rst=0)
set_property PACKAGE_PIN M11 [get_ports clk_rst]
set_property IOSTANDARD LVCMOS18 [get_ports clk_rst]

# ==============================================================================
# UART CONSTRAINTS (USB-to-UART Bridge via FT4232)
# ==============================================================================
# On the ZCU104, the PL-accessible UART pins route through the USB-UART interface.

# uart_rxd: FPGA receives data from the Host PC's TX line
set_property PACKAGE_PIN A20 [get_ports rx]
set_property IOSTANDARD LVCMOS18 [get_ports rx]

# uart_txd: FPGA transmits data to the Host PC's RX line
set_property PACKAGE_PIN C19 [get_ports tx]
set_property IOSTANDARD LVCMOS18 [get_ports tx]

# ==============================================================================
# CONFIGURATION VOLTAGE CONSTRAINTS
# ==============================================================================
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]