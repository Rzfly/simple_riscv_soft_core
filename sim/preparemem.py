import sys
import filecmp
import subprocess
import sys
import os

R_TYPE       = '0110011'
I_TYPE_LOAD  = '0000011' 
I_TYPE_ALUI  = '0010011' 
I_TYPE_JALR  = '1100011'
S_TYPE       = '0100011'
SB_TYPE      = '1100111'
U_TYPE       = '0110111'
UJ_TYPE      = '1101111'
AUIPC_TYPE   = '0010111'

def decode(hexin):

    #print(len(hexin))
    if(len(hexin) < 8):
        code = "UNDEFINED\n"
        return code
    #print(hexin)
    #print(len(hexin))
    bits = ""
    for i in range (8):
        bits = bits + hex2bin(hexin[i])
    print(bits)
    print(len(bits))

    code = decode_type(bits)
    
    return code


def decode_type(bits):

    code = "";
    ins = "";
    # 7 5 5 3 5 7
    opcode = bits[25:32];
    rd  = bits[20:25];
    func3 = bits[17:20];
    rs1 = bits[12:17];
    rs2 = bits[7:12];
    func7 = bits[0:7];
    
    if(opcode == R_TYPE):
        code = "R_TYPE"
        if(func3 == '000'):
            print("R_TYPE")
            print(func7)
            if(func7 == '0000000'):
                ins = "ADD"
            elif(func7 == '0100000'):
                ins = "SUB"
        elif(func3 == '010'):
            ins = "SLT"
        elif(func3 == '011'):
            ins = "SLTU"
        elif(func3 == '100'):
            ins = "XOR"
        elif(func3 == '110'):
            ins = "OR"
        elif(func3 == '111'):
            ins = "AND"
        elif(func3 == '001'):
            ins = "SLL"
        elif(func3 == '111'):
            if(func7 == '0000000'):
                ins = "SRL"
            elif(func7 == '0100000'):
                ins = "SRA"
        else:
            ins = "unknown rtype"  
    elif(opcode == I_TYPE_LOAD):
        code = "I_TYPE_LOAD" 
        if(func3 == '000'):
            ins = "LB"
        elif(func3 == '001'):
            ins = "LH"
        elif(func3 == '010'):
            ins = "LW"
        elif(func3 == '100'):
            ins = "LBU"
        elif(func3 == '101'):
            ins = "LHU"
        else:
            ins = "unknown rtype"  
    elif(opcode == I_TYPE_ALUI):
        code = "I_TYPE_ALUI"
        if(func3 == '000'):
            ins = "ADDI"
        elif(func3 == '010'):
            ins = "SLTI"
        elif(func3 == '011'):
            ins = "SLTIU"
        elif(func3 == '100'):
            ins = "XORI"
        elif(func3 == '110'):
            ins = "ORI"
        elif(func3 == '111'):
            ins = "ANDI"
        elif(func3 == '001'):
            ins = "SLLI"
        elif(func3 == '111'):
            if(func7 == '0000000'):
                ins = "SRLI"
            elif(func7 == '0100000'):
                ins = "SRAI"
        else:
            ins = "unknown itype"          
    elif(opcode == I_TYPE_JALR):
        code = "I_TYPE_JALR"
        if(func3 == '000'):
            ins = "BEQ"
        elif(func3 == '001'):
            ins = "BNE"
        elif(func3 == '100'):
            ins = "BLT"
        elif(func3 == '101'):
            ins = "BGE"
        elif(func3 == '110'):
            ins = "BLTU"
        elif(func3 == '111'):
            ins = "BGEU"
        else:
            ins = "unknown itype"  
    elif(opcode == S_TYPE):
        code = "S_TYPE"
        if(func3 == '000'):
            ins = "SB"
        elif(func3 == '001'):
            ins = "SH"
        elif(func3 == '010'):
            ins = "SW"
        else:
            ins = "unknown stype"  
    elif(opcode == SB_TYPE):
        code = "SB_TYPE"
        ins = "JALR"
    elif(opcode == U_TYPE):
        code = "U_TYPE"
        ins = "LUI"
    elif(opcode == UJ_TYPE):
        code = "UJ_TYPE"
        ins = "JAL"
    elif(opcode == AUIPC_TYPE):
        code = "AUIPC_TYPE"
        ins = "AUIPC"
    else:
        code = "UNDEFINED"
        
    code = code + "  " + bits + "  " + ins + "  rs2: " + rs2 + "  rs1: " + rs1 + "  rd: " + rd + "  func3: " + func3 + "\n"
    
    return code

def hex2bin(hexin):
  
    hexdict = {
    #  b'0': '0000',
    #  b'1': '0001',
    #  b'2': '0010',
    #  b'3': '0011',
    #  b'4': '0100',
    #  b'5': '0101',
    #  b'6': '0110',
    #  b'7': '0111',
    #  b'8': '1000',
    #  b'9': '1001',
    #  b'a': '1010',
    #  b'b': '1011',
    #  b'c': '1100',
    #  b'd': '1101',
    #  b'e': '1110',
    #  b'f': '1111',
      '0': '0000',
      '1': '0001',
      '2': '0010',
      '3': '0011',
      '4': '0100',
      '5': '0101',
      '6': '0110',
      '7': '0111',
      '8': '1000',
      '9': '1001',
      'a': '1010',
      'b': '1011',
      'c': '1100',
      'd': '1101',
      'e': '1110',
      'f': '1111',
    }
    return hexdict[hexin];

# 主函数
def main():
    #print(sys.argv[0] + ' ' + sys.argv[1] + ' ' + sys.argv[2])

    # 1.将bin文件转成mem文件
    cmd = r'python ../tools/BinToMem_CLI.py' + ' ' + sys.argv[1] + ' ' + sys.argv[2]
    print(cmd)
    f = os.popen(cmd)
    f.close()

    f1 = open("./inst.data", 'r');
    f2 = open("./instasm.txt", 'w+');
    
    count = 0;
    while 1:
        line = f1.readline();
        #print(len(line))
        #print(line)
        asm = decode(line);
        f2.write(asm);
        if(len(line) == 0):
            f1.close()
            break
        count = count + 1 
    
   # print("lines:" + str(count));
    f1.close()
    f2.close()

if __name__ == '__main__':
    sys.exit(main())
