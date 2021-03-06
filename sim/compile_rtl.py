import sys
import filecmp
import subprocess
import sys
import os

def listdir(path, list_name):  #传入存储的list
    for file in os.listdir(path):  
        file_path = os.path.join(path, file)  
        if os.path.isdir(file_path):  
            listdir(file_path, list_name)  
        else:  
            list_name.append(file_path)
    return list_name

def addrtl(cmd, rtl_path):  #传入存储的list
    #print(rtl_path)
    rtl_list = [];
    rtl_list = listdir(rtl_path,rtl_list)
    #print(len(rtl_list))
    for inst in rtl_list:
        if(inst[-1] == 'v'):
            print(inst)
            cmd.append(inst)
    return cmd

# 主函数
def main():
    rtl_dir = sys.argv[1]

    tb_file = sys.argv[2]

#    print('rtl_dir')
 #   print(rtl_dir + r'/rtl')
  #  test = input("now input!")
    # iverilog程序
    iverilog_cmd = ['iverilog']
    # 顶层模块
    #iverilog_cmd = ['-s', r'axi_riscv_core_sim.v']
    # 编译生成文件
    iverilog_cmd += ['-o', r'out.vvp']
    # 头文件(defines.v)路径
    iverilog_cmd += ['-I', rtl_dir + r'/rtl/core']
    # 宏定义，仿真输出文件
    iverilog_cmd += ['-D', r'OUTPUT="signature.output"']
    # testbench文件
    # ../rtl/core
    iverilog_cmd = addrtl(iverilog_cmd,rtl_dir + r'/rtl/')
    #iverilog_cmd+= ['-y', rtl_dir + r'/rtl/']
    iverilog_cmd.append(rtl_dir + tb_file)
    
    #print(iverilog_cmd)
    
    # 编译
    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=5)

if __name__ == '__main__':
    sys.exit(main())


# -*- coding: utf-8 -*-  

      
