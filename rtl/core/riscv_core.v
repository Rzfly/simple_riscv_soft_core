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
    input rst_n,
    input [`DATA_WIDTH - 1: 0]ram_rdata,
    output ram_we,
    output [`BUS_WIDTH - 1:0]ram_address,
    output [`DATA_WIDTH - 1: 0]ram_wdata
    );
    
    wire [`BUS_WIDTH - 1:0]pc_out;
    wire [`DATA_WIDTH - 1:0]instruction_if;
    
    wire [`BUS_WIDTH - 1:0]pc_id;
    wire [`DATA_WIDTH - 1:0]instruction_id;
    wire [`DATA_WIDTH - 1:0]id_rs2_data;
    wire [`DATA_WIDTH - 1:0]id_rs1_data;
    wire [`DATA_WIDTH - 1:0]id_rd;
    
    
    wire [`BUS_WIDTH - 1:0]pc_ex;
    
    wire [`RD_WIDTH - 1:0]wb_reg;
    wire [`RD_WIDTH - 1:0]wb_data;
    
    
    //control
    wire [`ALU_CONTROL_CODE - 1: 0]ALU_control_ex;
    wire ALU_src_ex;
    wire read_mem_ex;
    wire write_mem_ex;
    wire mem2reg_ex;
    wire write_reg_ex;
    wire [`ALU_CONTROL_CODE + 4 :0]control_flow_ex;
    assign control_flow_ex = {ALU_control_ex,ALU_src_ex,read_mem_ex,write_mem_ex,mem2reg_ex,write_reg_ex};
    //wire branch_ex;
    
    //control
    wire read_mem_mem;
    wire writre_mem_mem;
    wire mem2reg_mem;
    wire write_reg_mem;
    wire[3:0]control_flow_mem;
    assign control_flow_mem = {read_mem_mem, writre_mem_mem, mem2reg_mem, write_reg_mem};
    
    //control
    wire mem2reg_wb;
    wire write_reg_wb;
    wire [1:0]control_flow_wb;
    assign control_flow_wb = {mem2reg_wb, write_reg_wb};
    
    //control
    wire write_reg;
    wire mem2reg;
    wire read_mem;
    wire write_mem;
    wire ALU_src;
    wire [`ALU_CONTROL_CODE - 1: 0]ALU_control;
    //for auipc
    wire imm_src;
    
    wire [`OP_WIDTH - 1:0]ins_opcode;
    wire [`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC7_WIDTH]ins_func7;
    wire [`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC6_WIDTH]ins_func6;
    wire [`DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH : `DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH - `FUNC3_WIDTH]ins_func3;
    
    wire [`BUS_WIDTH - 1:0]pc_branch_addr;
    
    wire [`IMM_WIDTH - 1:0]  imm_short;
    wire [`DATA_WIDTH - 1:0] imm_long;
    wire [`DATA_WIDTH - 1:0] imm_extend;
    wire [`DATA_WIDTH - 1:0] imm_for_pc_addition;
    
    wire [`DATA_WIDTH - 1:0] imm_alu_src_i;
    wire [`DATA_WIDTH - 1:0] imm_alu_src_o;
    
    wire [`DATA_WIDTH - 1:0] rd2_data_o;
    wire [`DATA_WIDTH - 1:0] rd1_data_o;
    wire [`RS2_WIDTH - 1:0] rs2_id;
    wire [`RS1_WIDTH - 1:0] rs1_id;
    wire [`RS2_WIDTH - 1:0] rs2_ex;
    wire [`RS2_WIDTH - 1:0] rs1_ex;
    wire [`RD_WIDTH - 1:0] rd_ex;
    wire [`RD_WIDTH - 1:0] rd_id;
    
    wire [`DATA_WIDTH - 1:0] alu_input_num2;
    wire [`DATA_WIDTH - 1:0] alu_input_num1;
//    wire [`ALU_OP_WIDTH - 1:0] alu_operation_input;
    wire [`ALU_OP_WIDTH - 1:0] alu_control_i;
    wire [`ALU_OP_WIDTH - 1:0] alu_operation_input;
    wire [`ALU_INS_TYPE_WIDTH - 1:0] alu_optype_ex;
    
    wire [`DATA_WIDTH - 1:0] alu_output_ex;
    
    // regs 
    pc_gen #(.PC_WIDTH(`MEMORY_DEPTH)) pc_gen_inst(
        .clk(clk),
        .rst_n(rst_n),
        .branch_addr(pc_branch_addr),
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
        .pc_in(pc_out),
        .pc_out(pc_id),
         //not implemented yet
        .hold(1'b0),
        .flush()
    );
    
    // pure logic 
    // for id
    control control_inst(
        .instruction(instruction_id),
        .write_reg(write_reg_ex),
        .ALU_src(ALU_src_ex),
        .ALU_control(alu_optype_ex),
        .mem2reg(mem2reg_ex),
        .read_mem(read_mem_ex),
        .write_mem(write_mem_ex),
        .imm_src(imm_src),
        .ins_opcode(ins_opcode),
        .ins_func7(ins_func7),
        // ins_func6 unused, to be used in the future
        .ins_func6(ins_func6),
        .ins_func3(ins_func3),
        .imm_short(imm_short),
	    .imm_long(imm_long)
    );

    alucontrol alucontrol_inst(
        .ins_optype(alu_optype_ex),
        .ins_fun3(ins_func3),
        .ins_fun7(ins_func7),
        .alu_operation(alu_control_i)
    );
    
    //clock for WB.
    //pure logic for id
    regfile regfile_inst(
        .clk(clk),
        .we(write_reg),
        .rs2(instruction_id[24:20]),
        .rs1(instruction_id[19:15]),
        .rd2_data(id_rs2_data),
        .rd1_data(id_rs1_data),
        .wd(wb_data),
        .wa(wb_reg)
    );
       
    sign_extend sign_extend_inst(
        .immediate_num(imm_short),
        .num(imm_extend)
    );
    
         //for auipc / jal
     mux2num imm_switch_for_pc_add(
     .num0({imm_long[`DATA_WIDTH - 1:1],1'b0}),
     .num1(imm_long),
     .switch(imm_src),
     .muxout(imm_for_pc_addition)
     );

     mux2num imm_switch_for_alu_src(
     .num0(imm_extend),
     .num1(imm_for_pc_addition),
     //auipc 
     .switch(imm_src),
     .muxout(imm_alu_src_i)
     );
     
    //pure logic
    branch_addr_gen(
        .pc(pc_ex),
        .imm(imm_for_pc_addition),
        .branch_addr(pc_branch_addr)
    );
    
    
    //regs
    id_ex id_ex_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rd2_data_i(id_rs2_data),
        .rd1_data_i(id_rs1_data),
        .rd2_data_o(rd2_data_o),
        .rd1_data_o(rd1_data_o),
        .imm_alu_src_i(imm_alu_src_i),
        .imm_alu_src_o(imm_alu_src_o),
        .control_flow_i(control_flow_ex),
        .rs2_id(instruction_id[24:20]),
        .rs1_id(instruction_id[19:15]),
        .rd_id(instruction_id[11:7]),
        .alu_control_i(alu_control_i),
        .alu_control_o(alu_operation_input),
        .ALU_src_ex(ALU_src),
        .control_flow_o(control_flow_mem),
        .rs2_ex(rs2_ex),
        .rs1_ex(rs2_ex),
        .rd_ex(rd_ex)
    );
    
    
    mux2num  mux2_rd2_switch(
        .num0(rd2_data_o),
        .num1(imm_alu_src_o),
        .switch(ALU_src),
        .muxout(alu_input_num2)
     );
     
    
    alu alu_inst(
        .alu_src_1(alu_input_num1),
        .alu_src_2(alu_input_num2),
        .alu_control(alu_operation_input),
        .alu_output(alu_output)
    );

    wire [`DATA_WIDTH - 1 :0]mem_imm;

    //regs
    ex_mem ex_mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .alu_res_i(alu_output),
        .imm_i(alu_input_num2),
        .imm_o(mem_imm),
        .mem_address_o(ram_address),
        .mem_write_data_o(ram_wdata),
        .control_flow_i(control_flow_mem),
        .control_flow_o(control_flow_wb),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem)
    );
    
    
    assign ram_we = mem_write;
    
    wire [`DATA_WIDTH - 1 :0]mem_wb_ram_rdata = {`DATA_WIDTH{mem_read}} & ram_rdata; 
            
    mem_wb mem_wb_inst(
        .clk(clk),
        .rst_n(rst_n),
        .mem_read_data_i(mem_wb_ram_rdata),
        .imm_i(mem_imm),
        .wb_data(wb_data),
        .control_flow_i(control_flow_mem),
        .control_flow_o(control_flow_wb),
        .write_reg(write_reg),
        .mem2reg(mem2reg),
        .rd_mem(rd_mem),
        .rd_wb(wb_reg)
    );
    
endmodule
