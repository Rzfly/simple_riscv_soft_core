`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 19:41:07
// Design Name: 
// Module Name: riscv_core
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

`include "include.v"

module riscv_core(
    input clk,
    input rst_n
    );
    
    wire [`BUS_WIDTH:0]pc_out;
    wire [`DATA_WIDTH:0]instruction_out;
    
    // regs 
    pc_gen #(.PC_WIDTH(`MEMORY_DEPTH)) pc_gen_inst(
        .clk(clk),
        .rst_n(rst_n),
        .branch_addr(),
        .branch(),
        .hold(),
        .pc_reset_value(2'b0000000000),
        .pc_out(pc_out)
    );

    // pure logic 
    instruction_fetch if_inst(
        .pc(pc_out),
        .instruction_out(instruction_out)
    );
    
    // regs
    if_id if_id_inst(
        .clk(clk),
        .rst_n(rst_n),
    );
    
endmodule
