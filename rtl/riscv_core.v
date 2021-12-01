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
    
    wire [`BUS_WIDTH - 1:0]pc_out;
    wire [`DATA_WIDTH - 1:0]instruction_if;
    
    wire [`DATA_WIDTH - 1:0]instruction_id;
    wire [`DATA_WIDTH - 1:0]id_rs2_data;
    wire [`DATA_WIDTH - 1:0]id_rs1_data;
    wire [`DATA_WIDTH - 1:0]id_rd;
    
    wire [`RD_WIDTH - 1:0]wb_reg;
    wire [`RD_WIDTH - 1:0]wb_data;
    
    
    //control
    wire write_reg;
    wire mem2reg;
    wire read_mem;
    wire writre_mem;
    wire ALU_src;
    wire branch;
    
    
    
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
        .instruction_out(instruction_if)
    );
    
    // regs
    if_id if_id_inst(
        .clk(clk),
        .rst_n(rst_n),
        .instruction_i(instruction_if),
        .instruction_o(instruction_id),
        //not implemented yet
        .hold(1'b0),
        .flush()
    );
    
    
    // pure logic 
    // for id
    regfile regfile_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rs2(instruction_id[24:20]),
        .rs1(instruction_id[19:15]),
        .rs2_data(id_rs2_data),
        .rs1_data(id_rs1_data),
        .wb_data(wb_data),
        .wb_reg(wb_reg),
        .write_reg(write_reg)
    )
    
    
    
    //pure logic
    id_ex id_ex_inst(
        .rs2_data(id_rs2_data),
        .rs1_data(id_rs1_data),
        .rs1(instruction_id[24:20]),
        .rs2(instruction_id[19:15]),
        .ex_control(ALU_src),
        .mem_control({}),
        .wb_control({}),
        
        .ALU_src(ALU_src)
    )
    
    
        
    
    
endmodule
