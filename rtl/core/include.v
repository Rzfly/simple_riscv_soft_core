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

//p59 I-type
`define JAL_IMM_WIDTH 20
`define IMM_WIDTH 12

//control input of alu 
`define ALU_OP_WIDTH 4
`define ALU_CONTROL_CODE 2

//type define p83
`define R_TYPE       2'b0110011
`define I_TYPE_LOAD  2'b0000011 
`define I_TYPE_ALUI  2'b0010011 
`define I_TYPE_JALR  2'b1100011

`define S_TYPE       2'b0100011
`define SB_TYPE      2'b1100111
`define U_TYPE       2'b0110111
`define UJ_TYPE      2'b1101111
`define AUIPC_TYPE   2'b0010111

//other define
`define FUNC6_WIDTH 6
