
strs = ['iverilog', '-o', 'out.vvp', '-I', '../rtl/core', '-D', 'OUTPUT="signature.output"', '../tb/tinyriscv_soc_tb.v', '../rtl/core/clint.v', '../rtl/core/csr_reg.v', '../rtl/core/ctrl.v', '../rtl/core/defines.v', '../rtl/core/div.v', '../rtl/core/ex.v', '../rtl/core/id.v', '../rtl/core/id_ex.v', '../rtl/core/if_id.v', '../rtl/core/pc_reg.v', '../rtl/core/regs.v', '../rtl/core/rib.v', '../rtl/core/tinyriscv.v', '../rtl/perips/ram.v', '../rtl/perips/rom.v', '../rtl/perips/timer.v', '../rtl/perips/uart.v', '../rtl/perips/gpio.v', '../rtl/perips/spi.v', '../rtl/debug/jtag_dm.v', '../rtl/debug/jtag_driver.v', '../rtl/debug/jtag_top.v', '../rtl/debug/uart_debug.v', '../rtl/soc/tinyriscv_soc_top.v', '../rtl/utils/full_handshake_rx.v', '../rtl/utils/full_handshake_tx.v', '../rtl/utils/gen_buf.v', '../rtl/utils/gen_dff.v']


L = len(strs)
strout = ''
for i in range(0,L-1):
    strout = strout + strs[i] + " "


print(strout)

python .\sim_new_nowave.py ..\tests\isa\generated\rv32ui-p-add.bin inst.data
python ../tools/BinToMem_CLI.py ..\tests\isa\generated\rv32ui-p-add.bin inst.data
python compile_rtl.py ..
iverilog -o out.vvp -I ../rtl/core -D OUTPUT="signature.output" ../tb/tinyriscv_soc_tb.v ../rtl/core/clint.v ../rtl/core/csr_reg.v ../rtl/core/ctrl.v ../rtl/core/defines.v ../rtl/core/div.v ../rtl/core/ex.v ../rtl/core/id.v ../rtl/core/id_ex.v ../rtl/core/if_id.v ../rtl/core/pc_reg.v ../rtl/core/regs.v ../rtl/core/rib.v ../rtl/core/tinyriscv.v ../rtl/perips/ram.v ../rtl/perips/rom.v ../rtl/perips/timer.v ../rtl/perips/uart.v ../rtl/perips/gpio.v ../rtl/perips/spi.v ../rtl/debug/jtag_dm.v ../rtl/debug/jtag_driver.v ../rtl/debug/jtag_top.v ../rtl/debug/uart_debug.v ../rtl/soc/tinyriscv_soc_top.v ../rtl/utils/full_handshake_rx.v ../rtl/utils/full_handshake_tx.v ../rtl/utils/gen_buf.v