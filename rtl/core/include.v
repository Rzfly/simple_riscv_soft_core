`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 20:15:50
// Design Name: 
// Module Name: include
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define RstDisable 1
`define RstEnable 0
`define BUS_WIDTH  32
`define DATA_WIDTH 32
`define MEMORY_DEPTH 1024
`define MEMORY_WIDTH 10

//p58 R-type
`define FUNC7_WIDTH 7
`define RS2_WIDTH 5
`define RS1_WIDTH 5
`define FUNC3_WIDTH 3
`define RD_WIDTH 5
`define OP_WIDTH 7
//`define Reg_WIDTH `RD_WIDTH
`define MemAddrWIDTH `BUS_WIDTH
`define CsrMemAddrWIDTH 12
`define True  1'b1
`define False 1'b0

//p59 I-type
`define JAL_IMM_WIDTH 20
`define IMM_WIDTH 12

//control input of alu 
`define ALU_OP_WIDTH 10
`define ALU_CONTROL_CODE_WIDTH 4
`define DEFINE_DATA_OR_BRANCH  5
`define DEFINE_LOAD_OR_STORE  6
`define ALU_INS_TYPE_WIDTH `ALU_CONTROL_CODE_WIDTH
//type define p83
`define R_TYPE       7'b0110011
`define I_TYPE_LOAD  7'b0000011 
`define I_TYPE_ALUI  7'b0010011 
`define I_TYPE_JALR  7'b1100111

`define S_TYPE       7'b0100011
`define SB_TYPE      7'b1100011
`define U_TYPE       7'b0110111
`define UJ_TYPE      7'b1101111
`define AUIPC_TYPE   7'b0010111
`define CSR_TYPE     7'b1110011

`define ALU_CONTROL_R_TYPE      4'b0000
`define ALU_CONTROL_I_TYPE_LOAD 4'b0001
`define ALU_CONTROL_I_TYPE_ALUI 4'b0010
`define ALU_CONTROL_I_TYPE_JALR 4'b0011
`define ALU_CONTROL_S_TYPE      4'b0100
`define ALU_CONTROL_SB_TYPE     4'b0101
`define ALU_CONTROL_U_TYPE      4'b0110
`define ALU_CONTROL_AUIPC_TYPE  4'b0111
`define ALU_CONTROL_UJ_TYPE     4'b1001
`define ALU_CONTROL_NOT_USED    4'b1000
//other define
`define FUNC6_WIDTH 6

//alu define
`define ALU_ADDER_WIDTH 35
`define OP_DECINFO_ADD  0
`define OP_DECINFO_SUB  `OP_DECINFO_ADD + 1 
`define OP_DECINFO_XOR  `OP_DECINFO_SUB + 1 
`define OP_DECINFO_SLL  `OP_DECINFO_XOR + 1 
`define OP_DECINFO_SRL  `OP_DECINFO_SLL + 1 
`define OP_DECINFO_SRA  `OP_DECINFO_SRL + 1 
`define OP_DECINFO_OR   `OP_DECINFO_SRA + 1 
`define OP_DECINFO_AND  `OP_DECINFO_OR + 1 
`define OP_DECINFO_SLT  `OP_DECINFO_AND + 1 
`define OP_DECINFO_SLTU  `OP_DECINFO_SLT + 1 

// CSR reg addr
`define CSR_CYCLE   12'hc00
`define CSR_CYCLEH  12'hc80
`define CSR_MTVEC   12'h305
`define CSR_MCAUSE  12'h342
`define CSR_MEPC    12'h341
`define CSR_MIE     12'h304
`define CSR_MSTATUS 12'h300
`define CSR_MSCRATCH 12'h340

`define INT_BUS 7:0
`define InstBus 31:0
`define InstAddrBus 31:0
`define Hold_Flag_Bus 2:0

`define INST_NOP    32'h00000013
`define INST_MRET   32'h30200073
`define INST_RET    32'h00008067

`define INST_ECALL  32'h73
`define INST_EBREAK 32'h00100073
`define INT_NONE    8'h0
