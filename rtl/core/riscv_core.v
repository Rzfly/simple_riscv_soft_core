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
    input external_int_flag,
    input [`DATA_WIDTH - 1: 0]rom_rdata,
    output [`BUS_WIDTH - 1:0] rom_address,
    input [`DATA_WIDTH - 1: 0]ram_rdata,
    output ram_we,
    output [`BUS_WIDTH - 1:0]ram_address,
    output [`DATA_WIDTH - 1: 0]ram_wdata,
    output reg [`RAM_MASK_WIDTH - 1: 0]ram_wmask
    );
    
    //instruction fetch signals
    wire [`BUS_WIDTH - 1:0]pc_if;
    wire [`DATA_WIDTH - 1:0]instruction_if;
    wire flush_if;
    wire pc_jump;
    wire pc_hold;
    wire [`BUS_WIDTH - 1:0]jump_addr;
    
    //instruction decode signals
    wire [`BUS_WIDTH - 1:0]pc_id;
    wire [`DATA_WIDTH - 1:0]instruction_id;
    wire [`DATA_WIDTH - 1:0]rs2_data_reg;
    wire [`DATA_WIDTH - 1:0]rs1_data_reg;
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
    wire jalr_id;
    wire flush_id;
    wire csr_type_id;
    wire [7 :0]control_flow_id;
    assign control_flow_id = {jalr_id,auipc_id,branch_id,ALU_src_id,read_mem_id,write_mem_id,mem2reg_id,write_reg_id};
    
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
    wire jalr_ex;
    wire auipc_ex;
    wire branch_ex;
    wire ALU_src_ex;
    wire flush_ex;
    wire csr_type_ex;
    wire [3:0]control_flow_ex;
    wire [`BUS_WIDTH - 1:0]pc_branch_addr_ex;
    wire [`DATA_WIDTH - 1:0] imm_ex;
    
    wire [`DATA_WIDTH - 1:0] rs2_data_ex;
    wire [`DATA_WIDTH - 1:0] rs1_data_ex;
    wire [`DATA_WIDTH - 1:0] rs2_data_forward;
    wire [`DATA_WIDTH - 1:0] rs1_data_forward;
    wire [`RS2_WIDTH - 1:0] rs2_ex;
    wire [`RS2_WIDTH - 1:0] rs1_ex;
    wire [`RD_WIDTH - 1:0] rd_ex;
    wire [2:0]ins_func3_ex;
    wire [`DATA_WIDTH - 1:0] alu_input_num2;
    wire [`DATA_WIDTH - 1:0] alu_input_num1;
    wire [`DATA_WIDTH - 1:0] alu_input_imm_switch;
    wire [`DATA_WIDTH - 1:0] branch_adder_in1;
    wire [`DATA_WIDTH - 1:0] branch_adder_in2;
    wire [`DATA_WIDTH - 1:0] instruction_ex;

//    wire [`DATA_WIDTH - 1:0] alu_input_num1_branch;
    
    wire [`ALU_CONTROL_CODE_WIDTH - 1: 0]ALU_control_ex;
    wire [`ALU_OP_WIDTH - 1:0] alu_operation_input;  
    wire [`DATA_WIDTH - 1:0] alu_output_ex;
    wire alu_zero;
    wire stall_pipe;
    wire branch_res;
    wire jal_ex;
    wire lui_type_ex;
    assign lui_type_ex = jalr_ex & (~ branch_ex );
    
    
    wire [`DATA_WIDTH - 1:0] csr2clint_data;   // clint模块读寄存器数据
    wire [`DATA_WIDTH - 1:0] clint_csr_mtvec;   // mtvec
    wire [`DATA_WIDTH - 1:0] clint_csr_mepc;    // mepc
    wire [`DATA_WIDTH - 1:0] clint_csr_mstatus; // mstatus
    wire global_int_enable;
    wire clint_hold_flag;
    wire clint2csr_we;
    wire clint2csr_waddr;
    wire clint2csr_raddr;
    wire clint2csr_wdata;
    wire [`BUS_WIDTH - 1:0] clint_int_pc;
    wire clint_int_assert;
    
    //memory access signals
    wire read_mem_mem;
    wire write_mem_mem;
    wire [1:0]control_flow_mem;
    wire [`DATA_WIDTH - 1:0] ram_wdata_mem;
    wire [2:0]ins_func3_mem;
    wire [`RD_WIDTH - 1:0] rd_mem;
    wire [`DATA_WIDTH - 1 :0]ram_rdata_mem;
    wire [`DATA_WIDTH - 1 :0]ram_address_mem;

    //write back signals
    wire [`RD_WIDTH - 1:0]rd_wb;
    wire [`DATA_WIDTH - 1:0]wb_data_wb;
    wire [2:0]ins_func3_wb;
    wire [`DATA_WIDTH - 1 :0]ram_address_wb;
    reg [`DATA_WIDTH - 1 :0]ram_rdata_wb_mask;
    wire [`DATA_WIDTH - 1 :0]ram_rdata_wb; 
    wire mem2reg_wb;
    wire write_reg_wb;

    
    // regs 
    pc_gen #(.PC_WIDTH(`MEMORY_DEPTH)) pc_gen_inst(
        .clk(clk),
        .rst_n(rst_n),
        .branch_addr(jump_addr),
        .jump(pc_jump),
        .hold(pc_hold),
        .pc_out(pc_if)
    );
    assign pc_hold = stall_pipe;
    assign pc_jump = branch_res | clint_hold_flag;
    assign jump_addr = (clint_hold_flag)?32'h1C090000:pc_branch_addr_ex;

//    not used
//    stall_gen stall_gen_inst(
//        //stall one ins to avoid unnecessary ins excuted
//        .branch_id(branch_id),
//        .branch_stall(stall_pc)
//    );

    assign rom_address = pc_if;
    assign instruction_if = rom_rdata;
    assign flush_if = branch_res | clint_hold_flag ;
    assign flush_id = branch_res | clint_hold_flag | stall_pipe;
    //例外尚未实现s
    assign flush_ex = 1'b0;
    // regs
    if_id if_id_inst(
        .clk(clk),
        .rst_n(rst_n),
        .instruction_i(instruction_if),
        .instruction_o(instruction_id),
        .pc_in(pc_if),
        //for auipc
        .pc_out(pc_id),
        .hold(stall_pipe),
        .flush(flush_if)
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
        .jalr(jalr_id),
        .csr_type(csr_type_id),
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
        .alu_operation(alu_control_i)
//        .alu_mask(rs2_mask)
    );
    
    //clock for WB.
    //pure logic for id
    regfile regfile_inst(
        .clk(clk),
        .rst_n(rst_n),
        .we(write_reg_wb),
        .rs2(rs2_id),
        .rs1(rs1_id),
        .rd2_data(rs2_data_reg),
        .rd1_data(rs1_data_reg),
        .wd(wb_data_wb),
        .wa(rd_wb)
    );
    
    //有符号扩展 12 -> 32
    sign_extend sign_extend_inst(
        .immediate_num(imm_short),
        .num(imm_extend_id)
    );
    
     //有符号扩展或者无符号扩展
     mux2num imm_switch_for_immtype(
     .num0(imm_extend_id),
     .num1(imm_long),
     .switch(imm_src_id),
     .muxout(imm_before_shift)
     );

    // auipc 立即数扩展到32 地址不乘以2 然而，另一个加数是pc 
    assign imm_shifted_id = {imm_before_shift[`DATA_WIDTH - 2:0],1'b0};
    
     mux2num imm_switch_for_pc_additon(
     .num0(imm_before_shift),
     .num1(imm_shifted_id),
     .switch(imm_shift_id),
     .muxout(imm_id)
     );
                
    //正好都有延迟了
//    assign rs1_data_id = (lui_type_id)?32'd0:rs1_data_reg;
//    assign rs1_data_id = (lui_type_id)?32'd0:rs1_data_reg;
    assign rs1_data_id = rs1_data_reg;
    assign rs2_data_id = rs2_data_reg &  rs2_mask;
    
    //regs
    id_ex id_ex_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rd2_data_i(rs2_data_id),
        .rd1_data_i(rs1_data_id),
        .rd2_data_o(rs2_data_ex),
        .rd1_data_o(rs1_data_ex),
        .imm_i(imm_id),
        .imm_o(imm_ex),
        .instruction_i(instruction_id),
        .instruction_o(instruction_ex),
        .control_flow_i(control_flow_id),
        .rs2_id(rs2_id),
        .rs1_id(rs1_id),
        .rd_id(rd_id),
        .alu_control_i(alu_control_i),
        .alu_control_o(alu_operation_input),
        .ALU_src_ex(ALU_src_ex),
        .branch_ex(branch_ex),
        .auipc_ex(auipc_ex),
        .jalr_ex(jalr_ex),
        .control_flow_o(control_flow_ex),
        .csr_type_id(csr_type_id),
        .csr_type_ex(csr_type_ex),
        .pc_i(pc_id),
        .pc_o(pc_ex),
        .rd_ex(rd_ex),
        .rs2_ex(rs2_ex),
        .rs1_ex(rs1_ex),
        .ins_func3_i(ins_func3_id),
        .ins_func3_o(ins_func3_ex),
        .flush(flush_id)
    );
    
    branch_decision branch_decision_inst(
        .branch_req(branch_ex),
        .ins_fun3(ins_func3_ex),
        .alu_res(alu_output_ex),
        .alu_zero(alu_zero),
        .jal_req(jal_ex),
        .branch_res(branch_res)
    );
    
    wire [2:0]rs1_forward_mux;
    wire [2:0]rs2_forward_mux;
    forwarding forwarding_unit(
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_wb(rd_wb),
        .write_reg_wb(write_reg_wb),
        .rd_mem(rd_mem),
        .write_reg_mem(control_flow_mem[0]),
        .rs1_forward(rs1_forward_mux),
        .rs2_forward(rs2_forward_mux)
    );
    
    //when stall
    //pc hold,id hold,ex becomes nop intead of other instuctions
    hazard_detection hazard_detection_unit(
        .read_mem_ex(control_flow_ex[3]),
        .rd_ex(rd_ex),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .stall(stall_pipe)
    );
    
    mux3 rs1_forward_mux3_inst(
        .num0(rs1_data_ex),
        .num1(ram_address_mem),
        //mem2reg
        .num2(wb_data_wb),
        .switch(rs1_forward_mux),
        .muxout(rs1_data_forward)
    );
    mux3 rs2_forward_mux3_inst(
        .num0(rs2_data_ex),
        .num1(ram_address_mem),
        //mem2reg
        .num2(wb_data_wb),
        .switch(rs2_forward_mux),
        .muxout(rs2_data_forward)
    );
    
    //pure logic
    //注意 auipc复用了alu而不是这个加法器
    assign branch_adder_in1 = (jalr_ex)? rs1_data_forward : pc_ex;
    assign branch_adder_in2 = imm_ex;
    
    assign pc_branch_addr_ex = branch_adder_in1 +  branch_adder_in2;
    //no fowarding unit
    
    assign alu_input_num1 =(auipc_ex)? pc_ex : rs1_data_forward;
    assign jal_ex = branch_ex & auipc_ex;
    
    mux2num  mux2_alu_imm_switch(
        .num0(imm_ex),
        .num1(32'd4),
        .switch(jal_ex),
        .muxout(alu_input_imm_switch)
     );
    
    mux2num  mux2_rs2_switch(
        .num0(rs2_data_forward),
        .num1(alu_input_imm_switch),
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

    wire [`CsrMemAddrWIDTH - 1:0]csr_addr_ex;
//    wire [`DATA_WIDTH - 1:0]csr_read_data;
    wire [`DATA_WIDTH - 1:0]csr_read_data_ex;
    wire [`DATA_WIDTH - 1:0]csr_write_data_ex;
    wire [`DATA_WIDTH - 1:0]csr_we_ex;
//    wire [`DATA_WIDTH - 1:0]csr_read_data;
    
    csr_control csr_control_inst(
        .csr_type(csr_type_ex),
        .fun3(ins_func3_ex),
        .csr_addr_i(pc_ex[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH]),
        .wdata_imm(imm_ex),
        .wdata_rs(rs1_data_forward),
        .rdata_i(csr_read_data_ex),
        .we(csr_we_ex),
        .csr_addr_o(csr_addr_ex),
        .wdata_o(csr_write_data_ex)
    );
    
     clint clint_inst(
        .clk(clk),
        .rst_n(rst_n),
        //外部中断输入 来自core
        .int_flag_i(external_int_flag),
        .inst_i(instruction_ex),          // 指令内容
        .inst_addr_i(pc_ex),    // 指令地址
        //兼顾了jal指令
        .jump_flag_i(1'b0),
        .jump_addr_i(32'd0),
        .data_i(csr2clint_data),      
        .csr_mtvec(clint_csr_mtvec), 
        .csr_mepc(clint_csr_mepc),           
        .csr_mstatus(clint_csr_mstatus),         // mstatus寄存器
        .global_int_en_i(global_int_enable),              // 全局中断使能标志
        
        //也就是说，写csr结束以后，hold拉高
        .hold_flag_o(clint_hold_flag),                 // 流水线暂停标志
        .we_o(clint2csr_we),        
        .waddr_o(clint2csr_waddr),         // 写CSR寄存器地址
        .raddr_o(clint2csr_raddr),         // 读CSR寄存器地址
        .data_o(clint2csr_wdata),         // 写CSR寄存器数据
        .int_addr_o(clint_int_pc),     // 中断入口地址
        .int_assert_o(clint_int_assert)                     // 中断标志
    );
    
    csr_reg csr_reg_inst(
        .clk(clk),
        .rst_n(rst_n),
         // to ex
        .we_i(csr_we_ex),                      // ex模块写寄存器标志
        .raddr_i(csr_addr_ex),        // ex模块读寄存器地址
        .waddr_i(csr_addr_ex),                   // ex模块写寄存器地址
        .data_i(csr_write_data_ex),                    // ex模块写寄存器数据
        .data_o(csr_read_data_ex),                     // ex模块读寄存器数据

        // from clint
        .clint_we_i(clint2csr_we),                  // clint模块写寄存器标志
        .clint_raddr_i(clint2csr_waddr),         // clint模块读寄存器地址
        .clint_waddr_i(clint2csr_raddr),         // clint模块写寄存器地址
        .clint_data_i(clint_int_pc),          // clint模块写寄存器数据

        .global_int_en_o(global_int_enable),            // 全局中断使能标志
    
        .clint_data_o(csr2clint_data),       // clint模块读寄存器数据
        .clint_csr_mtvec(clint_csr_mtvec),   // mtvec
        .clint_csr_mepc(clint_csr_mepc),    // mepc
        .clint_csr_mstatus(clint_csr_mstatus) // mstatus
    );
    
    wire [`BUS_WIDTH - 1 :0]mem_address_ex;
    wire [2:0]mem_address_mux_ex;
    assign mem_address_mux_ex={ csr_type_ex,lui_type_ex,~(lui_type_ex | csr_type_ex)};
//    assign mem_address_ex = (lui_type_ex)?imm_ex:alu_output_ex;
//    // num1  num2 同时有效时，优先 num1
    mux3 #(.WIDTH(`DATA_WIDTH))
    mem_address_mux(
        .num0(alu_output_ex),
        .num1(imm_ex),
        //mem2reg
        .num2(csr_read_data_ex),
        .switch(mem_address_mux_ex),
        .muxout(mem_address_ex)
    );
    
    //regs
    ex_mem ex_mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .mem_address_i(mem_address_ex),
        //写存储用的是regfile的值而不是立即数
        .mem_write_data_1(rs2_data_forward),
        .mem_address_o(ram_address_mem),
        .mem_write_data_o(ram_wdata_mem),
        .control_flow_i(control_flow_ex),
        .control_flow_o(control_flow_mem),
        .mem_write(write_mem_mem),
        .mem_read(read_mem_mem),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem),
        .ins_func3_i(ins_func3_ex),
        .ins_func3_o(ins_func3_mem)
    );
    
    always@(*)begin
        if(ram_we)begin
            case(ins_func3_mem)
            //SB
             3'b000:begin
               ram_wmask <= 4'b0001;
             end
            //SH
             3'b001:begin
               ram_wmask <= 4'b0011;         
             end
             3'b010:begin
               ram_wmask <= 4'b1111;
             end
             default:begin
               ram_wmask <= 4'b1111;
             end
             endcase
         end
        else begin
               ram_wmask <= 4'b1111;
        end
    end
    
    //pure logic
    assign ram_we = write_mem_mem;
    assign ram_address =  {`BUS_WIDTH{read_mem_mem | write_mem_mem}} & ram_address_mem;
    assign ram_wdata = {`DATA_WIDTH{write_mem_mem}}& ram_wdata_mem;
    assign ram_rdata_mem = ram_rdata;
   
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
        .rd_wb(rd_wb),
        .ins_func3_i(ins_func3_mem),
        .ins_func3_o(ins_func3_wb)
    );
    
    //pure logic
    //for load ins
    always@(*)begin
        case (ins_func3_wb)
            //LB
            3'b000:begin
                ram_rdata_wb_mask = {{24{ram_rdata_wb[7]}}, ram_rdata_wb[7:0]}; 
            end
            //LH
            3'b001:begin
                ram_rdata_wb_mask = {{16{ram_rdata_wb[15]}}, ram_rdata_wb[15:0]}; 
            end
            //LW
            3'b010:begin
                ram_rdata_wb_mask = ram_rdata_wb; 
            end
            //LBU
            3'b100:begin
                ram_rdata_wb_mask = { 24'b0, ram_rdata_wb[7:0]}; 
            end
            //LHU
            3'b101:begin
                ram_rdata_wb_mask = { 16'b0, ram_rdata_wb[7:0]};
            end
            default:begin
                ram_rdata_wb_mask = ram_rdata_wb;
            end
        endcase
    end
    
    mux2num  mux2_wb_data_switch(
        .num0(ram_address_wb),
        .num1(ram_rdata_wb_mask),
        .switch(mem2reg_wb),
        .muxout(wb_data_wb)
     );


   
endmodule
