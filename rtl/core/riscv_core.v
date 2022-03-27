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
    input [7:0]external_int_flag,
    output [`BUS_WIDTH - 1:0] rom_address,
    output rom_req,
    output jump_req,
    input rom_addr_ok,
    output rom_data_resp,
    input rom_data_ok,
    input [`DATA_WIDTH - 1: 0]rom_rdata,
    output [`BUS_WIDTH - 1:0]ram_address,
    input ram_addr_ok,
    input ram_data_ok,
    output ram_data_resp,
    output ram_req,
    output ram_re,
    output ram_we,
    output [`DATA_WIDTH - 1: 0]ram_wdata,
    input  [`DATA_WIDTH - 1: 0]ram_rdata,
    output [`RAM_MASK_WIDTH - 1: 0]ram_wmask,
    input wire [`RD_WIDTH - 1:0]  jtag_reg_addr_i,   // jtag模块读�?�写寄存器的地址
    input wire [`DATA_WIDTH - 1: 0] jtag_reg_data_i,       // jtag模块写寄存器数据
    input wire jtag_reg_we_i,                  // jtag模块写寄存器标志
    output wire [`DATA_WIDTH - 1: 0]  jtag_reg_data_o,      // jtag模块读取到的寄存器数�?
    input wire jtag_halt_flag_i               // jtag暂停标志
    );
    
    //self_arbiter
//    assign 
    
    //instruction fetch signals
    wire [`BUS_WIDTH - 1:0]pc_if;
    wire [`BUS_WIDTH - 1:0]next_pc;
//    wire [`BUS_WIDTH - 1:0]pc_if_id;
//    wire [`DATA_WIDTH - 1:0]instruction_if;
    wire [`BUS_WIDTH - 1:0]jump_addr;
    wire [`DATA_WIDTH - 1:0] instruction_if; 
    wire allow_in_if;
    wire ready_go_pre;
    wire valid_pre;
    wire allow_in_id;
    wire ready_go_if;
    wire valid_if;
    
    //instruction decode signals
//    wire cancel_pc;
    wire [`BUS_WIDTH - 1:0]pc_id;
    wire [`DATA_WIDTH - 1:0]instruction_id;
    wire [`DATA_WIDTH - 1:0]rs2_data_reg;
    wire [`DATA_WIDTH - 1:0]rs1_data_reg;
    wire branch_id;
//    wire [`ALU_CONTROL_CODE_WIDTH - 1: 0]ALU_control_id;
    wire ALU_src_id;
    wire read_mem_id;
    wire write_mem_id;
    wire mem2reg_id;
    wire write_reg_id;
    //for auipc
    wire imm_shift_id;
//	wire imm_auipc_id;
    wire imm_src_id;
    wire auipc_id;
    wire jalr_id;
    wire jal_id;
    wire lui_type_id;
    wire csr_type_id;
    wire csr_we_id;
    wire fence_type_id;
    wire [11:0]control_flow_id;
    assign control_flow_id = {lui_type_id, csr_we_id, jal_id,fence_type_id,jalr_id,auipc_id,branch_id,ALU_src_id,read_mem_id,write_mem_id,mem2reg_id,write_reg_id};
    
    wire signed_div_id;	
	wire signed_mult_num_1_id;
	wire signed_mult_num_2_id;
	wire div_res_req_id;
	wire div_rem_req_id;
	wire mull_req_id;
	wire mulh_req_id;
	wire [6:0]multdiv_control_id;
    assign multdiv_control_id = 
    {signed_div_id, 
    signed_mult_num_1_id,
    signed_mult_num_2_id,
    div_res_req_id,
    div_rem_req_id,
    mull_req_id,
    mulh_req_id};    
	
    wire [`RS2_WIDTH - 1:0] rs2_id;
    wire [`RS1_WIDTH - 1:0] rs1_id;
    wire [`DATA_WIDTH - 1:0] rs2_data_forward_id;
    wire [`DATA_WIDTH - 1:0] rs1_data_forward_id;
    wire [`RD_WIDTH - 1:0] rd_id;
    wire [`IMM_WIDTH - 1:0]  imm_short;
    wire [`DATA_WIDTH - 1:0] imm_long;
    wire [`DATA_WIDTH - 1:0] imm_extend_id;
    wire [`DATA_WIDTH - 1:0] imm_before_shift;
    wire [`DATA_WIDTH - 1:0] imm_shifted_id;
//    wire [`DATA_WIDTH - 1:0] imm_for_pc_addition;
    wire [`DATA_WIDTH - 1:0] imm_id;
    wire r_type_ins_id;
    
    wire [`OP_WIDTH - 1:0]ins_opcode_id;
    wire [`FUNC7_WIDTH - 1 : 0]ins_func7_id;
    wire [`FUNC6_WIDTH - 1 : 0]ins_func6_id;
    wire [`FUNC3_WIDTH - 1 : 0]ins_func3_id;
    wire [`ALU_INS_TYPE_WIDTH - 1:0] alu_optype_id;
    wire [`ALU_OP_WIDTH - 1:0] alu_control_id;
    
    wire allow_in_ex;
    wire valid_id;
    wire ready_go_id;
    
    //excution signals
    wire [`BUS_WIDTH - 1:0]pc_ex;
    wire jalr_ex;
    wire auipc_ex;
    wire branch_ex;
    wire ALU_src_ex;
    wire flush_ex;
    wire fence_type_ex;
    wire [3:0]control_flow_ex;
    wire [`BUS_WIDTH - 1:0]pc_branch_addr_ex;
    wire [`DATA_WIDTH - 1:0] imm_ex;
    wire [`CsrMemAddrWIDTH - 1:0]csr_addr_ex;
    wire [`DATA_WIDTH - 1:0]csr_read_data_ex;
    wire [`DATA_WIDTH - 1:0]csr_write_data_ex;
    wire csr_we_ex;
    
    wire [`DATA_WIDTH - 1:0] rs2_data_ex;
    wire [`DATA_WIDTH - 1:0] rs1_data_ex;

    wire [`RS2_WIDTH - 1:0] rs2_ex;
    wire [`RS2_WIDTH - 1:0] rs1_ex;
    wire [`RD_WIDTH - 1:0] rd_ex;
    wire [2:0]ins_func3_ex;
    wire [`DATA_WIDTH - 1:0] alu_input_num2;
    wire [`DATA_WIDTH - 1:0] alu_input_num1;
    wire [`DATA_WIDTH - 1:0] branch_adder_in1;
    wire [`DATA_WIDTH - 1:0] branch_adder_in2;
    wire [`DATA_WIDTH - 1:0] instruction_ex;
    wire [`DATA_WIDTH - 1:0] ram_wdata_ex;
    wire [`DATA_WIDTH - 1 :0]ram_address_ex;
    
    wire signed_div_ex;
    wire req_div_valid;
    wire req_div_ready;
    wire rsp_div_valid;
    wire rsp_div_ready;
    wire [`DATA_WIDTH - 1:0]signed_div_res;
    wire [`DATA_WIDTH - 1:0]unsigned_div_res;
    wire [`DATA_WIDTH - 1:0]signed_rem_res;
    wire [`DATA_WIDTH - 1:0]unsigned_rem_res;
    
    wire signed_mult_ex;
    wire req_mult_valid;
    wire req_mult_ready;
    wire rsp_mult_valid;
    wire rsp_mult_ready;
    wire [`DATA_WIDTH - 1:0]signed_mult_resh;
    wire [`DATA_WIDTH - 1:0]unsigned_mult_resh;
    wire [`DATA_WIDTH - 1:0]signed_mult_resl;
    wire [`DATA_WIDTH - 1:0]unsigned_mult_resl;
    
    wire [`ALU_OP_WIDTH - 1: 0]alu_control_ex;
    wire [`DATA_WIDTH - 1:0] alu_output_ex;
    wire [6:0]multdiv_control_ex;
    wire alu_no_zero;
    wire stall_pipe;
    wire branch_res;
    wire jal_ex;
    wire lui_type_ex;
    wire read_mem_ex;
    wire write_mem_ex;
    wire write_reg_ex;
    assign read_mem_ex = control_flow_ex[3];
    assign write_mem_ex = control_flow_ex[2];
    assign write_reg_ex = control_flow_ex[0];
    wire valid_ex;
    wire ready_go_ex;
    assign signed_div_ex  = multdiv_control_ex[6];
    assign signed_mult_num_1_ex = multdiv_control_ex[5];
    assign signed_mult_num_2_ex = multdiv_control_ex[4];
    assign signed_mult_ex = signed_mult_num_1_ex | signed_mult_num_2_ex;
    assign req_div_valid  = multdiv_control_ex[3] | multdiv_control_ex[2];
    assign req_mult_valid = multdiv_control_ex[1] | multdiv_control_ex[0];
    
    wire [`DATA_WIDTH - 1:0] clint_csr_mtvec;   // mtvec
    wire [`DATA_WIDTH - 1:0] clint_csr_mepc;    // mepc
    wire [`DATA_WIDTH - 1:0] clint_csr_mstatus; // mstatus
    wire clint_hold_flag;
    wire clint2csr_we;
    wire [`BUS_WIDTH - 1 : 0] clint2csr_waddr;
    wire [`DATA_WIDTH - 1 : 0] clint2csr_wdata;
    wire [`BUS_WIDTH - 1:0] clint_int_pc;
    wire clint_int_assert;
    wire [`DATA_WIDTH - 1 : 0]ex2wb_wdata;
    
    //memory access signals

        
    //write back signals
    wire [`RD_WIDTH - 1:0]rd_wb;
    wire [`DATA_WIDTH - 1:0]wb_data_wb;
    wire allow_in_wb;
        
    wire write_reg_wb;
    //to next pipe
    wire allow_in_regfile;
    //processing
    wire valid_wb;
    wire ready_go_wb;
//  wire flush_mem;
    wire flush_wb;
    wire forwording_invalid;
    
    wire fence_flush;
    wire fence_jump;
//  wire jump_fail;
    
    assign fence_jump = fence_type_ex && allow_in_wb;
    assign fence_flush = fence_type_ex && !allow_in_wb;
    wire hold_if;
    wire hold_id;
    wire hold_ex;
    wire hold_wb;
    wire cancel_if;
    wire cancel_id;
    wire cancel_ex;
    wire pc_jump;
//    wire jump_fail;
    assign jump_req = pc_jump;
    assign  pc_jump = jal_ex || jalr_ex || branch_res || clint_int_assert || fence_jump;

    assign  jump_addr = (clint_int_assert)?clint_int_pc:pc_branch_addr_ex;

    assign  cancel_if = pc_jump;
    assign  cancel_id = pc_jump;
    //next instruction  is not nop. so it needs to be flushed
    //if jump fail ,it wait in ex.
    // flush generate a nop input, but it would not be received unless the stage allow in
    assign  flush_ex = pc_jump;
    //cancel mult & div
    assign  cancel_ex = clint_hold_flag;
    assign  hold_if = jtag_halt_flag_i || clint_hold_flag || stall_pipe;
    assign  hold_id = jtag_halt_flag_i || clint_hold_flag || stall_pipe;
    assign  hold_ex = 1'b0;    
//    assign  hold_ex = jtag_halt_flag_i || jump_fail;    
     assign hold_wb = 1'b0;
    
     assign flush_wb = 1'b0;
    
    pc_gen pc_gen_inst(
        .clk(clk),
        .rst_n(rst_n),
        .jump_addr(jump_addr),
        .jump(pc_jump),
        .fence_flush(fence_flush),
        .jtag_halt_flag_i(jtag_halt_flag_i),
        .clint_hold_flag(clint_hold_flag),
        .mem_addr_ok(rom_addr_ok),
        .rom_req(rom_req),
        .pc_if(pc_if),
        .next_pc(next_pc),
        .allow_in_if(allow_in_if),
        .ready_go_pre(ready_go_pre),
        .valid_pre(valid_pre)
    );

    assign rom_address = next_pc;
    
    pre_if pre_if_inst(
        .clk(clk),
        .rst_n(rst_n),
        .hold(hold_if),
        .cancel(cancel_if),
        .mem_data_ok(rom_data_ok),
        .data_ok_resp(rom_data_resp),
        .next_pc(next_pc),
        .pc_if(pc_if),
        .rom_rdata(rom_rdata),
        .instruction_if(instruction_if),
        .allow_in_if(allow_in_if),
        .valid_pre(valid_pre),
        .ready_go_pre(ready_go_pre),
        .allow_in_id(allow_in_id),
        .valid_if(valid_if),
        .ready_go_if(ready_go_if)
    );

    // regs
    if_id if_id_inst(
        .clk(clk),
        .rst_n(rst_n),
        .cancel(cancel_id),
        .hold(hold_id),
        .pc_if(pc_if),
        .pc_id(pc_id),
        .instruction_if(instruction_if),
        .instruction_id(instruction_id),
        .allow_in_id(allow_in_id),
        .valid_if(valid_if),
        .ready_go_if(ready_go_if),
        .allow_in_ex(allow_in_ex),
        .valid_id(valid_id),
        .ready_go_id(ready_go_id)
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
        .jal(jal_id),
        .csr_type(csr_type_id),
        .lui_type(lui_type_id),
        .fence_type(fence_type_id),
        .r_type_ins(r_type_ins_id),
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

    multdiv_control multdiv_control_inst(
        .r_type(r_type_ins_id),
        .func7(ins_func7_id),
        .func3(ins_func3_id),
        .signed_div(signed_div_id),
        .signed_mult_num_1(signed_mult_num_1_id),
        .signed_mult_num_2(signed_mult_num_2_id),
        .div_res_req(div_res_req_id),
        .div_rem_req(div_rem_req_id),
        .mull_req(mull_req_id),
        .mulh_req(mulh_req_id)
    );

//    wire [`DATA_WIDTH - 1:0] rs2_mask;
    alucontrol alucontrol_inst(
        .ins_optype(alu_optype_id),
        .ins_fun3(ins_func3_id),
        .ins_fun7(ins_func7_id),
        .alu_operation(alu_control_id)
//        .alu_mask(rs2_mask)
    );
    
    //clock for WB.
    //pure logic for id
    regfile regfile_inst(
        .clk(clk),
        .rst_n(rst_n),
        .jtag_we_i(jtag_reg_we_i),
        .jtag_addr_i(jtag_reg_addr_i),
        .jtag_data_i(jtag_reg_data_i),
        .jtag_data_o(jtag_reg_data_o),
        .we(write_reg_wb),
        .rs2(rs2_id),
        .rs1(rs1_id),
        .rd2_data(rs2_data_reg),
        .rd1_data(rs1_data_reg),
        .wd(wb_data_wb),
        .wa(rd_wb),
        .allow_in_regfile(allow_in_regfile),
        .valid_wb(valid_wb),
        .ready_go_wb(ready_go_wb)
    );
    
    //?��?????? 12 -> 32
    sign_extend sign_extend_inst(
        .immediate_num(imm_short),
        .num(imm_extend_id)
    );
    
     //?��??????????????????
    mux2num imm_switch_for_immtype(
     .num0(imm_extend_id),
     .num1(imm_long),
     .switch(imm_src_id),
     .muxout(imm_before_shift)
     );

    // auipc ???????????32 ?????????2 ????????????????pc 
    assign imm_shifted_id = {imm_before_shift[`DATA_WIDTH - 2:0],1'b0};
    
    mux2num imm_switch_for_pc_additon(
     .num0(imm_before_shift),
     .num1(imm_shifted_id),
     .switch(imm_shift_id),
     .muxout(imm_id)
     );
                        
    wire [`CsrMemAddrWIDTH - 1:0]csr_addr_id;
    wire [`DATA_WIDTH - 1:0]csr_read_data_id;
    wire [`DATA_WIDTH - 1:0]csr_read_data_id_forward;
    wire [`DATA_WIDTH - 1:0]csr_write_data_id;
    wire inst_ecall_type_id;
    wire inst_ebreak_type_id;
    wire inst_mret_type_id;
    wire inst_ecall_type_ex;
    wire inst_ebreak_type_ex;
    wire inst_mret_type_ex;
    wire memory_access_missalign;
    wire inst_wfi_id;
    assign csr_addr_id = instruction_id[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
    wire [3:0] int_ins_type_id;
    assign  int_ins_type_id = {inst_ecall_type_id, inst_ebreak_type_id, inst_mret_type_id, inst_wfi_id};
    
    csr_control csr_control_inst(
        .csr_type_id(csr_type_id),
        .fun3(ins_func3_id),
        .wdata_imm(imm_id),
        .wdata_rs(rs1_data_forward_id),
        .rdata_i(csr_read_data_id_forward),
        .csr_addr_id(csr_addr_id),
        .inst_ecall_type(inst_ecall_type_id),
        .inst_ebreak_type(inst_ebreak_type_id),
        .inst_mret_type(inst_mret_type_id),
        .inst_wfi(inst_wfi_id),
        .csr_we(csr_we_id),
        .wdata_o(csr_write_data_id)
    );

    clint clint_inst(
        .clk(clk),
        .rst_n(rst_n),
        .int_flag_i(external_int_flag),
        
        .inst_ecall_i(inst_ecall_type_ex),
        .inst_ebreak_i(inst_ebreak_type_ex),
        .inst_mret_i(inst_mret_type_ex),
        .memory_access_missalign(1'b0),
        .inst_addr_i(pc_ex),   
          
        .csr_mtvec(clint_csr_mtvec), 
        .csr_mepc(clint_csr_mepc),           
        .csr_mstatus(clint_csr_mstatus),        
        
        .we_o(clint2csr_we),        
        .waddr_o(clint2csr_waddr), 
        .data_o(clint2csr_wdata), 
        
        .stall_flag_o(clint_hold_flag), 
        .int_addr_o(clint_int_pc), 
        .int_assert_o(clint_int_assert) 
    );
   
    forwarding_id_simple forwarding_id_simple_unit(
        .rs1_data_id(rs1_data_reg),
        .rs2_data_id(rs2_data_reg),
        .ex2wb_wdata(ex2wb_wdata),
        .to_wb_valid(to_wb_valid),
	    .write_reg_ex(write_reg_ex),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_ex(rd_ex),
        .rs1_data_forward_id(rs1_data_forward_id),
        .rs2_data_forward_id(rs2_data_forward_id)
    );
    
    //regs
    id_ex id_ex_inst(
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_ex),
        .hold(hold_ex),
        .mem_addr_ok(ram_addr_ok),
        .ram_req(ram_req),
        .rs2_data_id(rs2_data_forward_id),
        .rs1_data_id(rs1_data_forward_id),
        .rs2_data_ex(rs2_data_ex),
        .rs1_data_ex(rs1_data_ex),
        .imm_id(imm_id),
        .imm_ex(imm_ex),
        .instruction_id(instruction_id),
        .instruction_ex(instruction_ex),
        .csr_write_data_id(csr_write_data_id),
        .csr_write_data_ex(csr_write_data_ex),
        .csr_read_data_id(csr_read_data_id_forward),
        .csr_read_data_ex(csr_read_data_ex),
        .control_flow_id(control_flow_id),
        .rs2_id(rs2_id),
        .rs1_id(rs1_id),
        .rd_id(rd_id),
        .alu_control_id(alu_control_id),
        .alu_control_ex(alu_control_ex),
        .multdiv_control_id(multdiv_control_id),
        .multdiv_control_ex(multdiv_control_ex),
        .ALU_src_ex(ALU_src_ex),
        .branch_ex(branch_ex),
        .auipc_ex(auipc_ex),
        .jalr_ex(jalr_ex),
        .jal_ex(jal_ex),
        .control_flow_ex(control_flow_ex),
        .lui_type_ex(lui_type_ex),
        .fence_type_ex(fence_type_ex),
        .int_ins_type_id(int_ins_type_id),
        .csr_we_ex(csr_we_ex),
        .inst_ecall_type_ex(inst_ecall_type_ex),
        .inst_ebreak_type_ex(inst_ebreak_type_ex),
        .inst_mret_type_ex(inst_mret_type_ex),
        .pc_id(pc_id),
        .pc_ex(pc_ex),
        .rd_ex(rd_ex),
        .rs2_ex(rs2_ex),
        .rs1_ex(rs1_ex),
        .allow_in_ex_commit(allow_in_ex),
//        .allow_in_ex(allow_in_ex),
        .valid_id(valid_id),
        .ready_go_id(ready_go_id),
        .allow_in_wb(allow_in_wb),
        .valid_ex(valid_ex)
//        .ready_go_ex(ready_go_ex)
    );
        
    assign csr_addr_ex = instruction_ex[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
    
    wire csr_forward;
    assign csr_forward = (csr_addr_id == csr_addr_ex)?csr_we_ex:1'b0;
    
    assign csr_read_data_id_forward = (csr_forward)?csr_write_data_ex:csr_read_data_id;
    
    csr_reg csr_reg_inst(
        .clk(clk),
        .rst_n(rst_n),
         // to ex
        .we_i(csr_we_ex),
        .raddr_i(csr_addr_id), 
        .waddr_i(csr_addr_ex), 
        .data_i(csr_write_data_ex), 
        .data_o(csr_read_data_id), 
        
        // from clint
        .clint_we_i(clint2csr_we),              
        .clint_waddr_i(clint2csr_waddr),      
        .clint_data_i(clint2csr_wdata),         
            
        .clint_csr_mtvec(clint_csr_mtvec),   // mtvec
        .clint_csr_mepc(clint_csr_mepc),    // mepc
        .clint_csr_mstatus(clint_csr_mstatus) // mstatus
    );
    
     wire [1:0]mem_waddr_index;
    assign mem_waddr_index = {ram_address_ex[1],  ram_address_ex[0]};
    assign ram_wdata_ex = rs2_data_ex;
    assign ram_we = write_mem_ex;
    assign ram_re = read_mem_ex;
    assign ins_func3_ex = instruction_ex[`DATA_WIDTH - 1 - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH : `DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH - `FUNC3_WIDTH];
    
    ram_wdata_mask ram_wdata_mask_inst(
        .mem_waddr_index(mem_waddr_index),
        .mem_write_data(rs2_data_ex),
        .mask_type(ins_func3_ex),
        .ram_we(ram_we),
        .memory_access_missalign(memory_access_missalign),
        .mem_write_data_mask(ram_wdata),
        .mem_wmask(ram_wmask)
    );

    branch_decision branch_decision_inst(
        .branch_req(branch_ex),
        .ins_fun3(ins_func3_ex),
        .alu_res(alu_output_ex),
        .alu_no_zero(alu_no_zero),
        .branch_res(branch_res)
    );
    
//    forwarding forwarding_unit(
//        .rs1_ex(rs1_ex),
//        .rs2_ex(rs2_ex),
//        .rs1_data_ex(rs1_data_ex),
//        .rs2_data_ex(rs2_data_ex),
//        .rd_wb(rd_wb),
//        .wb_data_wb(wb_data_wb),
//        .write_reg_wb(write_reg_wb),
//        .rs1_data_forward(rs1_data_forward),
//        .rs2_data_forward(rs2_data_forward)
//    );
    
    //when hazard, stall. stall = flush & refetch(hold)
    //pc hold,id hold,ex becomes nop intead of other instuctions
    //when waiting mem, flush.flush = flush & refetch(hold)
    //ex becomes nop 
    //id hold
    //if hold
    //when branch jump wrong, flush.flush = flush & refetch
    //ex becomes nop 
    //id waitting
    //if refetch
    hazard_detection hazard_detection_unit(
        .read_mem_ex(control_flow_ex[3]),
        .forwording_invalid(forwording_invalid),
        .rd_ex(rd_ex),
        .rd_wb(rd_wb),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .stall(stall_pipe)
    );
    
    //pure logic
    //??? auipc??????alu??????????????
    assign branch_adder_in1 = (jalr_ex)? rs1_data_ex : pc_ex;
    assign branch_adder_in2 = imm_ex;
    
    assign pc_branch_addr_ex = branch_adder_in1 +  branch_adder_in2;
    //no fowarding unit
    
    assign alu_input_num1 =(auipc_ex)? pc_ex : rs1_data_ex;
     
     
    mux4_switch2 mux4_rs2_switch(
        .num0(rs2_data_ex),
        .num1(rs2_data_ex),
        .num2(imm_ex),
        .num3(32'd4),
        .switch({ALU_src_ex,branch_ex}),
        .muxout(alu_input_num2)
    );
     
    alu alu_inst(
        .alu_src_1(alu_input_num1),
        .alu_src_2(alu_input_num2),
        .operation(alu_control_ex),
        .alu_output(alu_output_ex),
        .alu_no_zero(alu_no_zero)
    );
    
    diver diver_inst(
        .clk(clk),
        .rst_n(rst_n),
        .cancel(cancel_ex),
        .req_valid(req_div_valid),
        .req_ready(req_div_ready),
        .rsp_valid(rsp_div_valid),
        .rsp_ready(rsp_div_ready),
        .signed_div(signed_div_ex),
        .num_1(alu_input_num1),
        .num_2(alu_input_num2),
        .signed_div_res(signed_div_res),
        .unsigned_div_res(unsigned_div_res),
        .signed_rem_res(signed_rem_res),
        .unsigned_rem_res(unsigned_rem_res)
    );
        
 
    multer_top multer_top_inst(
        .clk(clk),
        .rst_n(rst_n),
        .cancel(cancel_ex),
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_ex(rd_ex),
        .req_valid(req_mult_valid),
        .req_ready(req_mult_ready),
        .rsp_valid(rsp_mult_valid),
        .rsp_ready(rsp_mult_ready),
        .signed_mult_num_1(signed_mult_num_1_ex),
        .signed_mult_num_2(signed_mult_num_2_ex),
        .num_1(alu_input_num1),
        .num_2(alu_input_num2),
        .signed_mult_resh_d(signed_mult_resh),
        .unsigned_mult_resh_d(unsigned_mult_resh),
        .signed_mult_resl_d(signed_mult_resl),
        .unsigned_mult_resl_d(unsigned_mult_resl)
    );
    
    ex_commit ex_commit_inst(
    .clk(clk),
    .rst_n(rst_n),
    //NORMAL
    .csr_we_ex(csr_we_ex),
    .lui_type_ex(lui_type_ex),
    .alu_res(alu_output_ex),
    .imm_res(imm_ex),
    .csr_res(csr_read_data_ex),
    //MUL
    .mult_type_ok(rsp_mult_valid),
//    .func3(ins_func3_ex),
    .mult_control({signed_mult_ex,multdiv_control_ex[1:0]}),
    .signed_mult_resh(signed_mult_resh),
    .signed_mult_resl(signed_mult_resl),
    .unsigned_mult_resh(unsigned_mult_resh),
    .unsigned_mult_resl(unsigned_mult_resl),
    .mult_rsp_ready(rsp_mult_ready),
    //MEM    
    .mem_addr_ok(ram_addr_ok),
    .ram_req(ram_req),
    //DIV
    .div_type_ok(rsp_div_valid),
    .div_control({signed_div_ex,multdiv_control_ex[3:2]}),
    .signed_div_res(signed_div_res),
    .unsigned_div_res(unsigned_div_res),
    .signed_rem_res(signed_rem_res),
    .unsigned_rem_res(unsigned_rem_res),
    .div_rsp_ready(rsp_div_ready),
    //
    .ex2wb_wdata(ex2wb_wdata),
    .valid_ex(valid_ex),
    .allow_in_wb(allow_in_wb),
    .to_wb_valid(to_wb_valid),
    .ready_go_ex(ready_go_ex),
    .allow_in_ex(allow_in_ex)
 );
    assign ram_address_ex = alu_output_ex;
    assign ram_address    = ram_address_ex;

//    wire [1:0]mem_address_mux_ex;
//    assign mem_address_mux_ex={ csr_we_ex, lui_type_ex};
//    mux3_switch2 #(.WIDTH(`DATA_WIDTH))
//    mem_address_mux(
//        .num0(alu_output_ex),
//        .num1(imm_ex),
//        //mem2reg
//        .num2(csr_read_data_ex),
//        .switch(mem_address_mux_ex),
//        .muxout(mem_address_ex)
//    );
    
    ex_wb ex_wb_inst(
        .clk(clk),
        .rst_n(rst_n),
        .cancel(flush_wb),
        .hold(hold_wb),
        .mem_data_ok(ram_data_ok),
        .data_ok_resp(ram_data_resp),
        .mem_address_i(ex2wb_wdata),
        .mem_read_data_i(ram_rdata),
        .mem_type_ex(ram_req),
        .control_flow_ex(control_flow_ex),
        .wb_data_wb(wb_data_wb),    
        .rd_ex(rd_ex),
        .rd_wb(rd_wb),
        .ins_func3_i(ins_func3_ex),
        .write_reg_wb(write_reg_wb),
        .forwording_invalid(forwording_invalid),
        .allow_in_wb(allow_in_wb),
        .valid_ex(valid_ex),
        .ready_go_ex(ready_go_ex),
        .allow_in_regfile(allow_in_regfile),
        .valid_wb(valid_wb),
        .ready_go_wb(ready_go_wb)
    );
    
endmodule
