#clock
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sys_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports sys_clk]

#clock
#ck_rst, enable when zero
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN C2 [get_ports rst]

#set_false_path -from [get_port rst] -to [all_registers]

# program over LED3/T10
set_property IOSTANDARD LVCMOS33 [get_ports over]
set_property PACKAGE_PIN T10 [get_ports over]

# program succeed LED2/T9
set_property IOSTANDARD LVCMOS33 [get_ports succ]
set_property PACKAGE_PIN T9 [get_ports succ]

# cpu halt LED1/J5
set_property IOSTANDARD LVCMOS33 [get_ports halted_ind]
set_property PACKAGE_PIN J5 [get_ports halted_ind]

# uart enable SW3/A10
set_property IOSTANDARD LVCMOS33 [get_ports uart_debug_pin]
set_property PACKAGE_PIN A10 [get_ports uart_debug_pin]

## uart tx
#set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]
#set_property PACKAGE_PIN D10 [get_ports uart_tx_pin]

## uart rx
#set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]
#set_property PACKAGE_PIN A9 [get_ports uart_rx_pin]

# uart tx JD1/D4
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]
set_property PACKAGE_PIN D4 [get_ports uart_tx_pin]

# uart rx JD2/D3
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]
set_property PACKAGE_PIN D3 [get_ports uart_rx_pin]

# GPIO0 LED0 / H5
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
set_property PACKAGE_PIN H5 [get_ports {gpio[0]}]

# GPIO1 SW0 / A8
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
set_property PACKAGE_PIN A8 [get_ports {gpio[1]}]

## JTAG TCK  JD9/H2
#set_property IOSTANDARD LVCMOS33 [get_ports jtag_TCK]
#set_property PACKAGE_PIN H2 [get_ports jtag_TCK]

##create_clock -name jtag_clk_pin -period 300 [get_ports {jtag_TCK}];
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK]
##set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF]

## JTAG TMS   JD10/G2
#set_property IOSTANDARD LVCMOS33 [get_ports jtag_TMS]
#set_property PACKAGE_PIN G2 [get_ports jtag_TMS]

## JTAG TDI  JD7/E2
#set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDI]
#set_property PACKAGE_PIN E2 [get_ports jtag_TDI]

## JTAG TDO   JD8/D2
#set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDO]
#set_property PACKAGE_PIN D2 [get_ports jtag_TDO]

# SPI MISO  CK_MISO/G1
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]
set_property PACKAGE_PIN G1 [get_ports spi_miso]

# SPI MOSI  CK_MOSI/H1
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
set_property PACKAGE_PIN H1 [get_ports spi_mosi]

# SPI SS   CK_SS/C1
set_property IOSTANDARD LVCMOS33 [get_ports spi_ss]
set_property PACKAGE_PIN C1 [get_ports spi_ss]

# SPI CLK  CK_SCK/F1
set_property IOSTANDARD LVCMOS33 [get_ports spi_clk]
set_property PACKAGE_PIN F1 [get_ports spi_clk]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

create_generated_clock -name clk -source [get_ports sys_clk] -divide_by 2 [get_pins clk_wiz_0_inst/clk_out1]
