#clock
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sys_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports sys_clk]

#clock
#ck_rst, enable when zero
set_property IOSTANDARD LVCMOS33 [get_ports rst_ext_i]
set_property PACKAGE_PIN C2 [get_ports rst_ext_i]

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

# JTAG TCK  JD9/H2
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TCK]
set_property PACKAGE_PIN H2 [get_ports jtag_TCK]

#create_clock -name jtag_clk_pin -period 300 [get_ports {jtag_TCK}];
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF]

# JTAG TMS   JD10/G2
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TMS]
set_property PACKAGE_PIN G2 [get_ports jtag_TMS]

# JTAG TDI  JD7/E2
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDI]
set_property PACKAGE_PIN E2 [get_ports jtag_TDI]

# JTAG TDO   JD8/D2
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDO]
set_property PACKAGE_PIN D2 [get_ports jtag_TDO]

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

create_clock -period 1000.000 -name jtag_pin_TCK -waveform {0.000 500.000} [get_ports -filter { NAME =~  "*TCK*" && DIRECTION == "IN" }]
#set_property CLOCK_DEDICATED_ROUTE TRUE [get_ports -filter { NAME =~  "*TCK*" && DIRECTION == "IN" }]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF]
set_clock_groups -asynchronous -group [get_clocks sys_clk_pin] -group [get_clocks *TCK*]


set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[9]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[12]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[4]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[30]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[22]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[23]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[15]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[23]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[5]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[29]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[30]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[13]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[0]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[7]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[10]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[19]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[2]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[14]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[13]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[31]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[28]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[8]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[14]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[3]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_sel_o[2]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[11]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[15]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[27]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[3]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[9]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[4]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[12]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[6]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[9]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[21]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[0]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[1]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[3]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[7]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[21]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[22]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[24]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[6]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[1]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[5]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[20]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[31]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[18]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[13]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[6]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[1]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[17]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[18]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[20]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[25]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[26]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[28]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[5]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[2]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[7]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[17]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[27]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[31]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[2]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[12]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[28]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[8]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[10]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[19]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[16]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[25]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[8]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[10]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[4]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[26]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[16]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[30]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[24]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[29]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_wdata_o[11]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_sel_o[1]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[11]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_rdata_i[29]}]
set_property MARK_DEBUG false [get_nets {u_jtag_top/u_jtag_dm/dm_mem_addr_o[0]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_wiz_0_inst/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {bus_arbiter_inst/next_master_state[0]} {bus_arbiter_inst/next_master_state[1]} {bus_arbiter_inst/next_master_state[2]} {bus_arbiter_inst/next_master_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {bus_arbiter_inst/s0_data_i[0]} {bus_arbiter_inst/s0_data_i[1]} {bus_arbiter_inst/s0_data_i[2]} {bus_arbiter_inst/s0_data_i[3]} {bus_arbiter_inst/s0_data_i[4]} {bus_arbiter_inst/s0_data_i[5]} {bus_arbiter_inst/s0_data_i[6]} {bus_arbiter_inst/s0_data_i[7]} {bus_arbiter_inst/s0_data_i[8]} {bus_arbiter_inst/s0_data_i[9]} {bus_arbiter_inst/s0_data_i[10]} {bus_arbiter_inst/s0_data_i[11]} {bus_arbiter_inst/s0_data_i[12]} {bus_arbiter_inst/s0_data_i[13]} {bus_arbiter_inst/s0_data_i[14]} {bus_arbiter_inst/s0_data_i[15]} {bus_arbiter_inst/s0_data_i[16]} {bus_arbiter_inst/s0_data_i[17]} {bus_arbiter_inst/s0_data_i[18]} {bus_arbiter_inst/s0_data_i[19]} {bus_arbiter_inst/s0_data_i[20]} {bus_arbiter_inst/s0_data_i[21]} {bus_arbiter_inst/s0_data_i[22]} {bus_arbiter_inst/s0_data_i[23]} {bus_arbiter_inst/s0_data_i[24]} {bus_arbiter_inst/s0_data_i[25]} {bus_arbiter_inst/s0_data_i[26]} {bus_arbiter_inst/s0_data_i[27]} {bus_arbiter_inst/s0_data_i[28]} {bus_arbiter_inst/s0_data_i[29]} {bus_arbiter_inst/s0_data_i[30]} {bus_arbiter_inst/s0_data_i[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {bus_arbiter_inst/master_state[0]} {bus_arbiter_inst/master_state[1]} {bus_arbiter_inst/master_state[2]} {bus_arbiter_inst/master_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {bus_arbiter_inst/s0_wem[0]} {bus_arbiter_inst/s0_wem[1]} {bus_arbiter_inst/s0_wem[2]} {bus_arbiter_inst/s0_wem[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {bus_arbiter_inst/slave_state[0]} {bus_arbiter_inst/slave_state[1]} {bus_arbiter_inst/slave_state[2]} {bus_arbiter_inst/slave_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {bus_arbiter_inst/s0_data_o[0]} {bus_arbiter_inst/s0_data_o[1]} {bus_arbiter_inst/s0_data_o[2]} {bus_arbiter_inst/s0_data_o[3]} {bus_arbiter_inst/s0_data_o[4]} {bus_arbiter_inst/s0_data_o[5]} {bus_arbiter_inst/s0_data_o[6]} {bus_arbiter_inst/s0_data_o[7]} {bus_arbiter_inst/s0_data_o[8]} {bus_arbiter_inst/s0_data_o[9]} {bus_arbiter_inst/s0_data_o[10]} {bus_arbiter_inst/s0_data_o[11]} {bus_arbiter_inst/s0_data_o[12]} {bus_arbiter_inst/s0_data_o[13]} {bus_arbiter_inst/s0_data_o[14]} {bus_arbiter_inst/s0_data_o[15]} {bus_arbiter_inst/s0_data_o[16]} {bus_arbiter_inst/s0_data_o[17]} {bus_arbiter_inst/s0_data_o[18]} {bus_arbiter_inst/s0_data_o[19]} {bus_arbiter_inst/s0_data_o[20]} {bus_arbiter_inst/s0_data_o[21]} {bus_arbiter_inst/s0_data_o[22]} {bus_arbiter_inst/s0_data_o[23]} {bus_arbiter_inst/s0_data_o[24]} {bus_arbiter_inst/s0_data_o[25]} {bus_arbiter_inst/s0_data_o[26]} {bus_arbiter_inst/s0_data_o[27]} {bus_arbiter_inst/s0_data_o[28]} {bus_arbiter_inst/s0_data_o[29]} {bus_arbiter_inst/s0_data_o[30]} {bus_arbiter_inst/s0_data_o[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {bus_arbiter_inst/next_slave_state[0]} {bus_arbiter_inst/next_slave_state[1]} {bus_arbiter_inst/next_slave_state[2]} {bus_arbiter_inst/next_slave_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 32 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {bus_arbiter_inst/s0_addr_o[0]} {bus_arbiter_inst/s0_addr_o[1]} {bus_arbiter_inst/s0_addr_o[2]} {bus_arbiter_inst/s0_addr_o[3]} {bus_arbiter_inst/s0_addr_o[4]} {bus_arbiter_inst/s0_addr_o[5]} {bus_arbiter_inst/s0_addr_o[6]} {bus_arbiter_inst/s0_addr_o[7]} {bus_arbiter_inst/s0_addr_o[8]} {bus_arbiter_inst/s0_addr_o[9]} {bus_arbiter_inst/s0_addr_o[10]} {bus_arbiter_inst/s0_addr_o[11]} {bus_arbiter_inst/s0_addr_o[12]} {bus_arbiter_inst/s0_addr_o[13]} {bus_arbiter_inst/s0_addr_o[14]} {bus_arbiter_inst/s0_addr_o[15]} {bus_arbiter_inst/s0_addr_o[16]} {bus_arbiter_inst/s0_addr_o[17]} {bus_arbiter_inst/s0_addr_o[18]} {bus_arbiter_inst/s0_addr_o[19]} {bus_arbiter_inst/s0_addr_o[20]} {bus_arbiter_inst/s0_addr_o[21]} {bus_arbiter_inst/s0_addr_o[22]} {bus_arbiter_inst/s0_addr_o[23]} {bus_arbiter_inst/s0_addr_o[24]} {bus_arbiter_inst/s0_addr_o[25]} {bus_arbiter_inst/s0_addr_o[26]} {bus_arbiter_inst/s0_addr_o[27]} {bus_arbiter_inst/s0_addr_o[28]} {bus_arbiter_inst/s0_addr_o[29]} {bus_arbiter_inst/s0_addr_o[30]} {bus_arbiter_inst/s0_addr_o[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 2 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {u_jtag_top/u_jtag_dm/dm_mem_sel_o[0]} {u_jtag_top/u_jtag_dm/dm_mem_sel_o[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 14 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {u_jtag_top/u_jtag_dm/dm_mem_addr_o[14]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[15]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[16]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[17]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[18]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[19]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[20]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[21]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[22]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[23]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[24]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[25]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[26]} {u_jtag_top/u_jtag_dm/dm_mem_addr_o[27]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list u_jtag_top/u_jtag_dm/dm_halt_req_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list u_jtag_top/u_jtag_dm/dm_mem_we_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list u_jtag_top/u_jtag_dm/dm_reset_req_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list u_jtag_top/u_jtag_dm/req_ready_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list u_jtag_top/u_jtag_dm/req_valid_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list u_jtag_top/u_jtag_dm/rsp_ready_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list u_jtag_top/u_jtag_dm/rsp_valid_i]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list bus_arbiter_inst/s0_addr_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list bus_arbiter_inst/s0_data_ok]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list bus_arbiter_inst/s0_req_o]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list bus_arbiter_inst/s0_we_o]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
