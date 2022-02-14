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
    input rom_addr_ok,
    input rom_data_ok,
    input ram_addr_ok,
    input ram_data_ok,
    output ram_req,
    output rom_req,
    output ram_we,
    output [`BUS_WIDTH - 1:0]ram_address,
    output reg [`DATA_WIDTH - 1: 0]ram_wdata,
    output reg [`RAM_MASK_WIDTH - 1: 0]ram_wmask
    );
    
    
    //instruction fetch signals
    wire [`BUS_WIDTH - 1:0]pc_if;
    wire [`BUS_WIDTH - 1:0]next_pc;
//    wire [`BUS_WIDTH - 1:0]pc_if_id;
//    wire [`DATA_WIDTH - 1:0]instruction_if;
    wire flush_if;
    wire pc_jump;
    wire pc_hold;
    wire [`BUS_WIDTH - 1:0]jump_addr;
    wire read_rom_if;
    wire [`DATA_WIDTH - 1:0] instruction_if;
    
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
    wire [`ALU_OP_WIDTH - 1:0] alu_control_id;
    
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
    
    
    wire [`DATA_WIDTH - 1:0] csr2clint_data;   // clint?????????????
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

    
    wire hold_if;
    wire hold_id;
    //no hold signal for id
    assign hold_if = stall_pipe;
    assign hold_id = stall_pipe;
    assign pc_hold = stall_pipe;
    wire allow_in_if;
    wire ready_go_pre;
    wire valid_pre;
    // regs 
    pc_gen #(.PC_WIDTH(`MEMORY_DEPTH)) pc_gen_inst(
        .branch_addr(jump_addr),
        .jump(pc_jump),
        .hold(pc_hold),
        .mem_addr_ok(rom_addr_ok),
        .rom_req(rom_req),
        .pc_now(pc_if),
        .next_pc(next_pc),
        .allow_in_if(allow_in_if),
        .ready_go_pre(ready_go_pre),
        .valid_pre(valid_pre)
    );
    
    
    assign pc_jump = branch_res | clint_hold_flag;
    assign jump_addr = (clint_hold_flag)?32'h1C090000:pc_branch_addr_ex;

    wire allow_in_id;
    wire ready_go_if;
    wire valid_if;
    pre_if pre_if_inst(
        .clk(clk),
        .rst_n(rst_n),
        .hold(hold_if),
        .flush(flush_if),
        .mem_data_ok(rom_data_ok),
        .next_pc(next_pc),
        .pc_if(pc_if),
        .rom_rdata(rom_rdata),
        .instruction_if(instruction_if),
        .allow_in_if(allow_in_if),
        .valid_pre(valid_pre),
        .ready_go_pre(ready_go_pre),
        .allow_in_id(allow_in_id),
        .valid_if(allow_in_if),
        .ready_go_if(ready_go_if)
    );
    
    
    //turn to not valid
    assign flush_if = branch_res | clint_hold_flag;
    //turn to not valid
    assign flush_id = branch_res | clint_hold_flag;
    //turn to nop
    assign flush_ex = branch_res | clint_hold_flag | stall_pipe ;
 
    wire allow_in_ex;
    wire valid_id;
    wire ready_go_id;
    
    // regs
    if_id if_id_inst(
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_id),
        .hold(hold_id),
        .pc_if(pc_if),
        .pc_id(pc_id),
        .instruction_if(instruction_if),
        .instruction_id(instruction_id),
        .allow_in_id(allow_in_id),
        .valid_if(allow_in_if),
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

//    wire [`DATA_WIDTH - 1:0] rs2_mask;
    alucontrol alucontrol_inst(
        .ins_optype(alu_optype_id),
        .ins_fun3(ins_func3_id),
        .ins_fun7(ins_func7_id),
        .alu_operation(alu_control_id)
//        .alu_mask(rs2_mask)
    );
    
    //to next pipe
    wire allow_in_regfile;
    //processing
    wire valid_wb;
    wire ready_go_wb;
    
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
        .wa(rd_wb),
        .allow_in_regfile(allow_in_regfile),
        .valid_wb(valid_wb),
        .ready_go_wb(ready_go_wb)
    );
    
    //?§Ù?????? 12 -> 32
    sign_extend sign_extend_inst(
        .immediate_num(imm_short),
        .num(imm_extend_id)
    );
    
     //?§Ù??????????????????
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
                
    //????????????
//    assign rs1_data_id = (lui_type_id)?32'd0:rs1_data_reg;
//    assign rs1_data_id = (lui_type_id)?32'd0:rs1_data_reg;
    assign rs1_data_id = rs1_data_reg;
    assign rs2_data_id = rs2_data_reg;
    
    wire allow_in_mem;
    wire valid_ex;
    wire ready_go_ex;
        
    //regs
    id_ex id_ex_inst(
        .clk(clk),
        .rst_n(rst_n),
        .hold(hold_id),
        .flush(flush_id),
        .rs2_data_id(rs2_data_id),
        .rs1_data_id(rs1_data_id),
        .rs2_data_ex(rs2_data_ex),
        .rs1_data_ex(rs1_data_ex),
        .imm_id(imm_id),
        .imm_ex(imm_ex),
        .instruction_id(instruction_id),
        .instruction_ex(instruction_ex),
        .control_flow_i(control_flow_id),
        .rs2_id(rs2_id),
        .rs1_id(rs1_id),
        .rd_id(rd_id),
        .alu_control_id(alu_control_id),
        .alu_control_ex(alu_operation_input),
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
        .allow_in_ex(allow_in_ex),
        .valid_id(valid_id),
        .ready_go_id(ready_go_id),
        .allow_in_mem(allow_in_mem),
        .valid_ex(valid_ex),
        .ready_go_ex(ready_go_ex)
    );
    
    assign ins_func3_ex = instruction_ex[`DATA_WIDTH - 1 - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH : `DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH - `FUNC3_WIDTH];
    
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
        .rd_mem(rd_mem),
        .write_reg_mem(control_flow_mem[0]),
        .rd_wb(rd_wb),
        .write_reg_wb(write_reg_wb),
        .rs1_forward(rs1_forward_mux),
        .rs2_forward(rs2_forward_mux)
    );
    
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
    //??? auipc??????alu??????????????
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
        //???§Ø????? ????core
        .int_flag_i(external_int_flag),
        .inst_i(instruction_ex),          // ???????
        .inst_addr_i(pc_ex),    // ?????
        //?????jal???
        .jump_flag_i(1'b0),
        .jump_addr_i(32'd0),
        .data_i(csr2clint_data),      
        .csr_mtvec(clint_csr_mtvec), 
        .csr_mepc(clint_csr_mepc),           
        .csr_mstatus(clint_csr_mstatus),         // mstatus?????
        .global_int_en_i(global_int_enable),              // ????§Ø??????
        
        //????????§Õcsr???????hold????
        .hold_flag_o(clint_hold_flag),                 // ???????????
        .we_o(clint2csr_we),        
        .waddr_o(clint2csr_waddr),         // §ÕCSR????????
        .raddr_o(clint2csr_raddr),         // ??CSR????????
        .data_o(clint2csr_wdata),         // §ÕCSR?????????
        .int_addr_o(clint_int_pc),     // ?§Ø??????
        .int_assert_o(clint_int_assert)                     // ?§Ø???
    );
    
    csr_reg csr_reg_inst(
        .clk(clk),
        .rst_n(rst_n),
         // to ex
        .we_i(csr_we_ex),                      // ex???§Õ????????
        .raddr_i(csr_addr_ex),        // ex????????????
        .waddr_i(csr_addr_ex),                   // ex???§Õ????????
        .data_i(csr_write_data_ex),                    // ex???§Õ?????????
        .data_o(csr_read_data_ex),                     // ex?????????????

        // from clint
        .clint_we_i(clint2csr_we),                  // clint???§Õ????????
        .clint_raddr_i(clint2csr_waddr),         // clint????????????
        .clint_waddr_i(clint2csr_raddr),         // clint???§Õ????????
        .clint_data_i(clint_int_pc),          // clint???§Õ?????????

        .global_int_en_o(global_int_enable),            // ????§Ø??????
    
        .clint_data_o(csr2clint_data),       // clint?????????????
        .clint_csr_mtvec(clint_csr_mtvec),   // mtvec
        .clint_csr_mepc(clint_csr_mepc),    // mepc
        .clint_csr_mstatus(clint_csr_mstatus) // mstatus
    );
    
    wire [`BUS_WIDTH - 1 :0]mem_address_ex;
    wire [2:0]mem_address_mux_ex;
    assign mem_address_mux_ex={ csr_type_ex,lui_type_ex,~(lui_type_ex | csr_type_ex)};
//    assign mem_address_ex = (lui_type_ex)?imm_ex:alu_output_ex;
//    // num1  num2 ????§¹??????? num1
    mux3 #(.WIDTH(`DATA_WIDTH))
    mem_address_mux(
        .num0(alu_output_ex),
        .num1(imm_ex),
        //mem2reg
        .num2(csr_read_data_ex),
        .switch(mem_address_mux_ex),
        .muxout(mem_address_ex)
    );
    
    wire allow_in_wb;
    wire valid_mem;
    wire ready_go_mem;
        
    //regs
    ex_mem ex_mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .mem_address_i(mem_address_ex),
        //§Õ?›¥?????regfile???????????????
        .mem_write_data_i(rs2_data_forward),
        .mem_address_o(ram_address_mem),
        .mem_write_data_o(ram_wdata_mem),
        .control_flow_i(control_flow_ex),
        .control_flow_o(control_flow_mem),
        .mem_write(write_mem_mem),
        .mem_read(read_mem_mem),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem),
        .ins_func3_i(ins_func3_ex),
        .ins_func3_o(ins_func3_mem),
        .allow_in_mem(allow_in_mem),
        .valid_ex(valid_ex),
        .ready_go_ex(ready_go_ex),
        .allow_in_wb(allow_in_wb),
        .valid_mem(valid_mem),
        .ready_go_mem(ready_go_mem)
    );
    wire [1:0]mem_raddr_index;
    wire [1:0]mem_waddr_index;
    assign mem_waddr_index = ram_address_mem[1:0];
                                
    always@(*)begin
        if(ram_we)begin
            case(ins_func3_mem)
            //SB
             3'b000:begin
                case(mem_waddr_index)
                2'b00:begin
                    ram_wmask <= 4'b0001;
//                    ram_wdata = {{24{ram_wdata_mem[7]}},ram_wdata_mem[7:0]};
                    ram_wdata = {24'b0 ,ram_wdata_mem[7:0]};
                end
                2'b01:begin
                    ram_wmask <= 4'b0010;
                    ram_wdata = {16'b0,ram_wdata_mem[7:0],8'b0};
                end
                2'b10:begin
                    ram_wmask <= 4'b0100;
                    ram_wdata = {8'b0,ram_wdata_mem[7:0],16'b0};
                end
                2'b11:begin
                    ram_wmask <= 4'b1000;
                    ram_wdata = {ram_wdata_mem[7:0],24'b0};
                end
                default:begin
                    ram_wmask <= 4'b0000;
                    ram_wdata <= 32'd0;
                end
               endcase
             end
            //SH
             3'b001:begin
                 case(mem_waddr_index)
                    2'b00:begin
                        ram_wmask <= 4'b0011;
                        ram_wdata = {16'b0 ,ram_wdata_mem[15:0]};
                    end
                    default:begin
                        ram_wmask <= 4'b1100;
                        ram_wdata <= {ram_wdata_mem[15:0],16'b0};
                    end
                 endcase   
             end
             3'b010:begin
                ram_wmask <= 4'b1111;
                ram_wdata <= ram_wdata_mem;
             end
             default:begin
                ram_wmask <= 4'b1111;
                ram_wdata <= ram_wdata_mem;
             end
             endcase
         end
        else begin
               ram_wmask <= 4'b0000;
               ram_wdata <= 32'd0;
        end
    end
    
    //pure logic
    assign ram_we = write_mem_mem;
    assign ram_address =  {`BUS_WIDTH{read_mem_mem | write_mem_mem}} & ram_address_mem;
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
        .ins_func3_o(ins_func3_wb),
        .allow_in_wb(allow_in_wb),
        .valid_mem(valid_mem),
        .ready_go_mem(ready_go_mem),
        .allow_in_regfile(allow_in_regfile),
        .valid_wb(valid_wb),
        .ready_go_wb(ready_go_wb)
    );
    
    //pure logic
    //for load ins
    assign mem_raddr_index = ram_address_wb[1:0];
    always@(*)begin
        case (ins_func3_wb)
            //LB
            3'b000:begin
                case(mem_raddr_index)
                    2'b00: begin
                        ram_rdata_wb_mask = {{24{ram_rdata_wb[7]}}, ram_rdata_wb[7:0]};
                    end
                    2'b01: begin
                        ram_rdata_wb_mask = {{24{ram_rdata_wb[15]}}, ram_rdata_wb[15:8]};
                    end
                    2'b10: begin
                        ram_rdata_wb_mask = {{24{ram_rdata_wb[23]}}, ram_rdata_wb[23:16]};
                    end
                    default: begin
                        ram_rdata_wb_mask = {{24{ram_rdata_wb[31]}}, ram_rdata_wb[31:24]};
                    end
                endcase               
            end
            //LH
            3'b001:begin
                case(mem_raddr_index)
                    2'b00: begin
                        ram_rdata_wb_mask = {{16{ram_rdata_wb[15]}}, ram_rdata_wb[15:0]};
                    end
                    default: begin
                        ram_rdata_wb_mask = {{16{ram_rdata_wb[31]}}, ram_rdata_wb[31:16]}; 
                    end
                endcase     
            end
            //LW
            3'b010:begin
                ram_rdata_wb_mask = ram_rdata_wb; 
            end
            //LBU
            3'b100:begin
                case(mem_raddr_index)
                    2'b00: begin
                        ram_rdata_wb_mask = {24'b0, ram_rdata_wb[7:0]};
                    end
                    2'b01: begin
                        ram_rdata_wb_mask = {24'b0, ram_rdata_wb[15:8]};
                    end
                    2'b10: begin
                        ram_rdata_wb_mask = {24'b0, ram_rdata_wb[23:16]};
                    end
                    default: begin
                        ram_rdata_wb_mask = {24'b0, ram_rdata_wb[31:24]};
                    end
                endcase
            end
            //LHU
            3'b101:begin
                case(mem_raddr_index)
                    2'b00: begin
                        ram_rdata_wb_mask = {16'b0, ram_rdata_wb[15:0]};
                    end
                    default: begin
                        ram_rdata_wb_mask = {16'b0, ram_rdata_wb[31:16]}; 
                    end
                endcase    
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
