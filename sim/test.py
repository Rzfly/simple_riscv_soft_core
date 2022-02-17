import os

def listdir(path, list_name):  #传入存储的list
    for file in os.listdir(path):  
        file_path = os.path.join(path, file)  
        if os.path.isdir(file_path):  
            listdir(file_path, list_name)  
        else:  
            list_name.append(file_path)
    return list_name
    
strs = ['iverilog', '-o', 'out.vvp', '-I', '../rtl/core', '-D', 'OUTPUT="signature.output"', '../tb/tinyriscv_soc_tb.v', '../rtl/core/clint.v', '../rtl/core/csr_reg.v', '../rtl/core/ctrl.v', '../rtl/core/defines.v', '../rtl/core/div.v', '../rtl/core/ex.v', '../rtl/core/id.v', '../rtl/core/id_ex.v', '../rtl/core/if_id.v', '../rtl/core/pc_reg.v', '../rtl/core/regs.v', '../rtl/core/rib.v', '../rtl/core/tinyriscv.v', '../rtl/perips/ram.v', '../rtl/perips/rom.v', '../rtl/perips/timer.v', '../rtl/perips/uart.v', '../rtl/perips/gpio.v', '../rtl/perips/spi.v', '../rtl/debug/jtag_dm.v', '../rtl/debug/jtag_driver.v', '../rtl/debug/jtag_top.v', '../rtl/debug/uart_debug.v', '../rtl/soc/tinyriscv_soc_top.v', '../rtl/utils/full_handshake_rx.v', '../rtl/utils/full_handshake_tx.v', '../rtl/utils/gen_buf.v', '../rtl/utils/gen_dff.v']

root_path = 'C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core'
rtl_path = root_path + '\\rtl'
tb_path = root_path + '\\tb'


rtl_list = [];
tb_list = [];


L = len(strs)
strout = ''
for i in range(0,L-1):
    strout = strout + strs[i] + " "

print(strout)

rtl_list = listdir(rtl_path, rtl_list);

print(rtl_list)
#python .\sim_new_nowave.py ..\tests\isa\generated\rv32ui-p-add.bin inst.data
#python ../tools/BinToMem_CLI.py ..\tests\isa\generated\rv32ui-p-add.bin inst.data
#python compile_rtl.py ..
#iverilog -o out.vvp -I ../rtl/core -D OUTPUT="signature.output" ../tb/tinyriscv_soc_tb.v ../rtl/core/clint.v ../rtl/core/csr_reg.v ../rtl/core/ctrl.v ../rtl/core/defines.v ../rtl/core/div.v ../rtl/core/ex.v ../rtl/core/id.v ../rtl/core/id_ex.v ../rtl/core/if_id.v ../rtl/core/pc_reg.v ../rtl/core/regs.v ../rtl/core/rib.v ../rtl/core/tinyriscv.v ../rtl/perips/ram.v ../rtl/perips/rom.v ../rtl/perips/timer.v ../rtl/perips/uart.v ../rtl/perips/gpio.v ../rtl/perips/spi.v ../rtl/debug/jtag_dm.v ../rtl/debug/jtag_driver.v ../rtl/debug/jtag_top.v ../rtl/debug/uart_debug.v ../rtl/soc/tinyriscv_soc_top.v ../rtl/utils/full_handshake_rx.v ../rtl/utils/full_handshake_tx.v ../rtl/utils/gen_buf.v

iverilog -o out.vvp -I C:/Users/newrz/Desktop/riscv/simple_riscv_soft_core/rtl/core -D OUTPUT="signature.output" -y C:/Users/newrz/Desktop/riscv/simple_riscv_soft_core/rtl/ C:/Users/newrz/Desktop/riscv/simple_riscv_soft_core/tb/riscv_core_sim.v

['iverilog', '-o', 'out.vvp', '-I', '../rtl/core', '-D', 'OUTPUT="signature.output"', '-y', '../rtl/', '../tb/riscv_core_sim.v']