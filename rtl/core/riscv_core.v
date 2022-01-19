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
    input [`DATA_WIDTH - 1: 0]rom_rdata,
    output [`BUS_WIDTH - 1:0] rom_address,
    input [`DATA_WIDTH - 1: 0]ram_rdata,
    output ram_we,
    output [`BUS_WIDTH - 1:0]ram_address,
    output [`DATA_WIDTH - 1: 0]ram_wdata
    );
    
    //instruction fetch signals
    wire [`BUS_WIDTH - 1:0]pc_if;
    wire [`DATA_WIDTH - 1:0]instruction_if;
    
    //instruction decode signals
    wire [`BUS_WIDTH - 1:0]pc_id;
    wire [`DATA_WIDTH - 1:0]instruction_id;
    wire [`DATA_WIDTH - 1:0]rs2_data_id;
    wire [`DATA_WIDTH - 1:0]rs1_data_id;
    wire branch_id;
//    wire [`ALU_CONTROL_CODE_WIDTH - 1: 0]ALU_control_id;
    wire ALU_src_id;
    wire read_mem_id;
    wire write_mem_id;
    wire mem2reg_id;
    wire write_reg_id;
    //for auipc
    wire imm_shift_id;
	wire imm_auipc_id;
    wire imm_src_id;
    wire auipc_id;
    wire [`ALU_CONTROL_CODE_WIDTH + 6 :0]control_flow_id;
    assign control_flow_id = {auipc_id,branch_id,ALU_src_id,read_mem_id,write_mem_id,mem2reg_id,write_reg_id};
    
    wire [`RS2_WIDTH - 1:0] rs2_id;
    wire [`RS1_WIDTH - 1:0] rs1_id;
    wire [`RD_WIDTH - 1:0] rd_id;
    wire [`IMM_WIDTH - 1:0]  imm_short;
    wire [`DATA_WIDTH - 1:0] imm_long;
    wire [`DATA_WIDTH - 1:0] imm_extend_id;
    wire [`DATA_WIDTH - 1:0] imm_before_shift;
    wire [`DATA_WIDTH - 1:0] imm_shifted_id;
    
    wire [`DATA_WIDTH - 1:0] imm_for_pc_addition;
    wire [`DATA_WIDTH - 1:0] imm_id;
    
    wire [`OP_WIDTH - 1:0]ins_opcode_id;
    wire [`FUNC7_WIDTH - 1 : 0]ins_func7_id;
    wire [`FUNC6_WIDTH - 1 : 0]ins_func6_id;
    wire [`FUNC3_WIDTH - 1 : 0]ins_func3_id;
    wire [`ALU_INS_TYPE_WIDTH - 1:0] alu_optype_id;
    wire [`ALU_OP_WIDTH - 1:0] alu_control_i;
    
    
    //excution signals
    wire [`BUS_WIDTH - 1:0]pc_ex;
    wire auipc_ex;
    wire branch_ex;
    wire ALU_src_ex;
    wire [3:0]control_flow_ex;
    wire [`BUS_WIDTH - 1:0]pc_branch_addr_ex;
    wire [`DATA_WIDTH - 1:0] imm_ex;
    
    wire [`DATA_WIDTH - 1:0] rs2_data_ex;
    wire [`DATA_WIDTH - 1:0] rs1_data_ex;
    wire [`RS2_WIDTH - 1:0] rs2_ex;
    wire [`RS2_WIDTH - 1:0] rs1_ex;
    wire [`RD_WIDTH - 1:0] rd_ex;
    wire [2:0]ins_func3_ex;
    wire [`DATA_WIDTH - 1:0] alu_input_num2;
    wire [`DATA_WIDTH - 1:0] alu_input_num1;
    
    wire [`ALU_CONTROL_CODE_WIDTH - 1: 0]ALU_control_ex;
    wire [`ALU_OP_WIDTH - 1:0] alu_operation_input;  
    wire [`DATA_WIDTH - 1:0] alu_output_ex;
    wire alu_zero;
    wire stall_pc;
    wire branch_res;
    

    //memory access signals
    wire read_mem_mem;
    wire writre_mem_mem;
    wire [1:0]control_flow_mem;
    wire [`DATA_WIDTH - 1:0] ram_wdata_mem;
    assign ram_wdata = ram_wdata_mem;
    wire [2:0]ins_func3_mem;
    wire [`RD_WIDTH - 1:0] rd_mem;
    wire [`DATA_WIDTH - 1 :0]ram_rdata_mem;
    wire [`DATA_WIDTH - 1 :0]ram_address_mem;
    
    //write back signals
    wire [`RD_WIDTH - 1:0]wb_reg_wb;
    wire [`DATA_WIDTH - 1:0]wb_data_wb;
    wire [2:0]ins_func3_wb;
    wire [`DATA_WIDTH - 1 :0]ram_address_wb;
    reg [`DATA_WIDTH - 1 :0]ram_rdata_wb_mask;
    wire [`DATA_WIDTH - 1 :0]ram_rdata_wb; 
    wire mem2reg_wb;
    wire write_reg_wb;

    assign ram_address = ram_address_mem;
    assign ram_rdata_mem = ram_rdata;
    
    // regs 
    pc_gen #(.PC_WIDTH(`MEMORY_DEPTH)) pc_gen_inst(
        .clk(clk),
        .rst_n(rst_n),
        .branch_addr(pc_branch_addr_ex),
        .branch( branch_res),
        .hold(stall_pc),
        .pc_out(pc_if)
    );

    
    stall_gen stall_gen_inst(
        //stall one ins to avoid unnecessary ins excuted
        .branch_id(branch_id),
        .branch_stall(stall_pc)
    );

    assign rom_address = pc_if;
    assign instruction_if = rom_rdata;
    
    // regs
    if_id if_id_inst(
        .clk(clk),
        .rst_n(rst_n),
        .instruction_i(instruction_if),
        .instruction_o(instruction_id),
        .pc_in(pc_if),
        //for auipc
        .pc_out(pc_id),
         //not implemented yet
        .hold(1'b0),
        .flush(stall_pc)
    );
    // pure logic 
    // for id
    control control_inst(
        .instruction(instruction_id),
        .write_reg(write_reg_id),
        .ALU_src(ALU_src_id),
        .ALU_control(alu_optype_id),
        .mem2reg(mem2reg_id),
        .read_mem(read_mem_id),
        .write_mem(write_mem_id),
        .imm_shift(imm_shift_id),
        .imm_src(imm_src_id),
        .branch(branch_id),
        .auipc(auipc_id),
        .ins_opcode(ins_opcode_id),
        .ins_func7(ins_func7_id),
        // ins_func6 unused, to be used in the future
        .ins_func6(ins_func6_id),
        .ins_func3(ins_func3_id),
        .rs2(rs2_id),
        .rs1(rs1_id),
        .rd(rd_id),
        .imm_short(imm_short),
	    .imm_long(imm_long)
    );

    wire [`DATA_WIDTH - 1:0] rs2_mask;
    alucontrol alucontrol_inst(
        .ins_optype(alu_optype_id),
        .ins_fun3(ins_func3_id),
        .ins_fun7(ins_func7_id),
        .alu_operation(alu_control_i),
        .alu_mask(rs2_mask)
    );
    
    //clock for WB.
    //pure logic for id
    regfile regfile_inst(
        .clk(clk),
        .rst_n(rst_n),
        .we(write_reg_wb),
        .rs2(instruction_id[24:20]),
        .rs1(instruction_id[19:15]),
        .rd2_data(rs2_data_id),
        .rd1_data(rs1_data_id),
        .wd(wb_data_wb),
        .wa(wb_reg_wb)
    );
    
    //有符号扩展 12 -> 32
    sign_extend sign_extend_inst(
        .immediate_num(imm_short),
        .num(imm_extend_id)
    );
    
     //for auipc / jal  是否实现了地址的乘以2
     //bne 12位 jal 20位 jalr 12位 共同点是都经过无符号扩展到32位 
     mux2num imm_switch_for_immtype(
     .num0(imm_extend_id),
     .num1(imm_long),
     .switch(imm_src_id),
     .muxout(imm_before_shift)
     );

     mux2num imm_switch_for_pc_additon(
     .num0(imm_before_shift),
     .num1(imm_shifted_id),
     .switch(imm_shift_id),
     .muxout(imm_id)
     );
    
    // auipc 立即数扩展到32 地址不乘以2 然而，另一个加数是pc 
    assign imm_shifted_id = {imm_before_shift[`DATA_WIDTH - 2:0],1'b0};
    //auipc or lui
//    assign imm_auipc_id = ~imm_shift_id & imm_src_id & ~branch_id;
    
    //regs
    id_ex id_ex_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rd2_data_i(rs2_data_id &  rs2_mask),
        .rd1_data_i(rs1_data_id),
        .rd2_data_o(rs2_data_ex),
        .rd1_data_o(rs1_data_ex),
        .imm_i(imm_id),
        .imm_o(imm_ex),
        .control_flow_i(control_flow_id),
        .rs2_id(rs2_id),
        .rs1_id(rs1_id),
        .rd_id(rd_id),
        .alu_control_i(alu_control_i),
        .alu_control_o(alu_operation_input),
        .ALU_src_ex(ALU_src_ex),
        .branch_ex(branch_ex),
        .auipc_ex(auipc_ex),
        .control_flow_o(control_flow_ex),
        .pc_i(pc_id),
        .pc_o(pc_ex),
        .rd_ex(rd_ex),
        .ins_func3_i(ins_func3_id),
        .ins_func3_o(ins_func3_ex)
    );
    

    branch_decision branch_decision_inst(
        .branch_req(branch_ex),
        .ins_fun3(ins_func3_ex),
        .alu_res(alu_output_ex),
        .alu_zero(alu_zero),
        .branch_res(branch_res)
    );
    
    //pure logic
    //注意 auipc复用了alu而不是这个加法器
    assign pc_branch_addr_ex = imm_ex + pc_ex;
    //no fowarding unit
    assign alu_input_num1 =(auipc_ex)? pc_ex : rs1_data_ex;
    
    mux2num  mux2_rd2_switch(
        .num0(rs2_data_ex),
        .num1(imm_ex),
        .switch(ALU_src_ex),
        .muxout(alu_input_num2)
     );
     
    alu alu_inst(
        .alu_src_1(alu_input_num1),
        .alu_src_2(alu_input_num2),
        .operation(alu_operation_input),
        .alu_output(alu_output_ex),
        .alu_zero(alu_zero)
    );

    //regs
    ex_mem ex_mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .alu_res_i(alu_output_ex),
        //写存储用的是regfile的值而不是立即数
        .reg_data_i(rs2_data_ex),
        .mem_address_o(ram_address_mem),
        .mem_write_data_o(ram_wdata_mem),
        .control_flow_i(control_flow_ex),
        .control_flow_o(control_flow_mem),
        .mem_write(writre_mem_mem),
        .mem_read(read_mem_mem),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem),
        .ins_func3_i(ins_func3_mem),
        .ins_func3_o(ins_func3_wb)
    );
    
    //pure logic
    assign ram_we = writre_mem_mem;
     
    //regs       
    mem_wb mem_wb_inst(
        .clk(clk),
        .rst_n(rst_n),
        .mem_read_data_i(ram_rdata_mem),
        .mem_read_data_o(ram_rdata_wb),
        .mem_address_i(ram_address_mem),
        .mem_address_o(ram_address_wb),
        //read_data from memory
        .control_flow_i(control_flow_mem),
        .write_reg(write_reg_wb),
        .mem2reg(mem2reg_wb),
        .rd_mem(rd_mem),
        //reg destination
        .rd_wb(wb_reg_wb),
        .ins_func3_i(ins_func3_mem),
        .ins_func3_o(ins_func3_wb)
    );
    
    //pure logic
    //for load ins
    always@(*)begin
        if(read_mem_mem)begin
            case (ins_func3_wb)
                3'b000:begin
                    ram_rdata_wb_mask = {{24{ram_rdata_wb[7]}}, ram_rdata_wb[7:0]}; 
                end
                3'b001:begin
                    ram_rdata_wb_mask = {{16{ram_rdata_wb[15]}}, ram_rdata_wb[15:0]}; 
                end
                3'b010:begin
                    ram_rdata_wb_mask = ram_rdata_wb; 
                end
                3'b100:begin
                    ram_rdata_wb_mask = { 24'b0, ram_rdata_wb[7:0]}; 
                end
                3'b101:begin
                    ram_rdata_wb_mask = { 16'b0, ram_rdata_wb[7:0]};
                end
                default:begin
                    ram_rdata_wb_mask = ram_rdata_wb;
                end
            endcase
        end
    end
    
    mux2num  mux2_wb_data_switch(
        .num0(ram_address_wb),
        .num1(ram_rdata_wb_mask),
        .switch(mem2reg_wb),
        .muxout(wb_data_wb)
     );

endmodule
