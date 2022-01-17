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

//p58 R-type
`define FUNC7_WIDTH 7
`define RS2_WIDTH 5
`define RS1_WIDTH 5
`define FUNC3_WIDTH 3
`define RD_WIDTH 5
`define OP_WIDTH 7
`define RegBus `DATA_WIDTH

//p59 I-type
`define JAL_IMM_WIDTH 20
`define IMM_WIDTH 12

//control input of alu 
`define ALU_OP_WIDTH 10
`define ALU_CONTROL_CODE_WIDTH 3
`define DEFINE_DATA_OR_BRANCH  5
`define DEFINE_LOAD_OR_STORE  6
`define ALU_INS_TYPE_WIDTH `ALU_CONTROL_CODE_WIDTH
//type define p83
`define R_TYPE       7'b0110011
`define I_TYPE_LOAD  7'b0000011 
`define I_TYPE_ALUI  7'b0010011 
`define I_TYPE_JALR  7'b1100011

`define S_TYPE       7'b0100011
`define SB_TYPE      7'b1100111
`define U_TYPE       7'b0110111
`define UJ_TYPE      7'b1101111
`define AUIPC_TYPE   7'b0010111

`define ALU_CONTROL_R_TYPE      3'b000
`define ALU_CONTROL_I_TYPE_LOAD 3'b001
`define ALU_CONTROL_I_TYPE_ALUI 3'b010
`define ALU_CONTROL_I_TYPE_JALR 3'b011
`define ALU_CONTROL_S_TYPE      3'b100
`define ALU_CONTROL_SB_TYPE     3'b101
`define ALU_CONTROL_U_TYPE      3'b110
`define ALU_CONTROL_NOT_USED    `ALU_CONTROL_U_TYPE
`define ALU_CONTROL_UJ_TYPE     `ALU_CONTROL_NOT_USED
`define ALU_CONTROL_AUIPC_TYPE  3'b111
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