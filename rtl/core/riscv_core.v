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
    input mem_hold,
    input [7:0]external_int_flag,
    output [`BUS_WIDTH - 1:0] rom_address,
    output rom_req,
    input rom_addr_ok,
    input rom_data_ok,
    input [`DATA_WIDTH - 1: 0]rom_rdata,
    output [`BUS_WIDTH - 1:0]ram_address,
    input ram_addr_ok,
    input ram_data_ok,
    output ram_req,
    output ram_we,
    output reg [`DATA_WIDTH - 1: 0]ram_wdata,
    input [`DATA_WIDTH - 1: 0]ram_rdata,
    output reg [`RAM_MASK_WIDTH - 1: 0]ram_wmask
    );
    
    //self_arbiter
//    assign 
    
    //instruction fetch signals
    wire [`BUS_WIDTH - 1:0]pc_if;
    wire [`BUS_WIDTH - 1:0]next_pc;
    assign rom_address = next_pc;
//    wire [`BUS_WIDTH - 1:0]pc_if_id;
//    wire [`DATA_WIDTH - 1:0]instruction_if;
    wire flush_if;
    wire pc_jump;
    wire pc_hold;
    wire [`BUS_WIDTH - 1:0]jump_addr;
    wire [`DATA_WIDTH - 1:0] instruction_if; 
    wire allow_in_if;
    wire ready_go_pre;
    wire valid_pre;
    wire allow_in_id;
    wire ready_go_if;
    wire valid_if;
    
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
//	wire imm_auipc_id;
    wire imm_src_id;
    wire auipc_id;
    wire jalr_id;
    wire flush_id;
    wire csr_type_id;
    wire fence_type_id;
    wire [8:0]control_flow_id;
    assign control_flow_id = {fence_type_id,jalr_id,auipc_id,branch_id,ALU_src_id,read_mem_id,write_mem_id,mem2reg_id,write_reg_id};
    
    wire [`RS2_WIDTH - 1:0] rs2_id;
    wire [`RS1_WIDTH - 1:0] rs1_id;
    wire [`RD_WIDTH - 1:0] rd_id;
    wire [`IMM_WIDTH - 1:0]  imm_short;
    wire [`DATA_WIDTH - 1:0] imm_long;
    wire [`DATA_WIDTH - 1:0] imm_extend_id;
    wire [`DATA_WIDTH - 1:0] imm_before_shift;
    wire [`DATA_WIDTH - 1:0] imm_shifted_id;
//    wire [`DATA_WIDTH - 1:0] imm_for_pc_addition;
    wire [`DATA_WIDTH - 1:0] imm_id;
    
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
    wire csr_type_ex;
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
    wire [`DATA_WIDTH - 1:0] ram_wdata_ex;
    wire req_not_hit;
    wire [`DATA_WIDTH - 1 :0]ram_address_ex;
    wire [`DATA_WIDTH - 1 :0]mem_address_ex;
    
    wire [`ALU_OP_WIDTH - 1: 0]alu_control_ex;
//    wire [`ALU_OP_WIDTH - 1:0] alu_operation_input;  
    wire [`DATA_WIDTH - 1:0] alu_output_ex;
    wire alu_zero;
    wire stall_pipe;
    wire branch_res;
    wire jal_ex;
    wire lui_type_ex;
    wire read_mem_ex;
    wire write_mem_ex;
    assign read_mem_ex = control_flow_ex[3];
    assign write_mem_ex = control_flow_ex[2];
    assign lui_type_ex = jalr_ex & (~ branch_ex );
    
    wire allow_in_mem;
    wire valid_ex;
    wire ready_go_ex;
    
    
    wire [`DATA_WIDTH - 1:0] csr2clint_data;   // clint?????????????
    wire [`DATA_WIDTH - 1:0] clint_csr_mtvec;   // mtvec
    wire [`DATA_WIDTH - 1:0] clint_csr_mepc;    // mepc
    wire [`DATA_WIDTH - 1:0] clint_csr_mstatus; // mstatus
    wire global_int_enable;
    wire clint_hold_flag;
    wire clint2csr_we;
    wire [`BUS_WIDTH - 1 : 0] clint2csr_waddr;
    wire [`BUS_WIDTH - 1 : 0] clint2csr_raddr;
    wire [`DATA_WIDTH - 1 : 0] clint2csr_wdata;
    wire [`BUS_WIDTH - 1:0] clint_int_pc;
    wire clint_int_assert;
    
    //memory access signals
    wire read_mem_mem;
    wire write_mem_mem;
    wire [1:0]control_flow_mem;
    wire [2:0]ins_func3_mem;
    wire [`RD_WIDTH - 1:0] rd_mem;
    wire [`DATA_WIDTH - 1 :0]ram_rdata_mem;
    wire [`DATA_WIDTH - 1 :0]ram_address_mem;
    reg [`DATA_WIDTH - 1 :0]ram_rdata_mem_mask;
    wire fence_type_mem;
    wire flush_mem;

    wire allow_in_wb;
    wire valid_mem;
    wire ready_go_mem;
        
        
    //write back signals
    wire [`RD_WIDTH - 1:0]rd_wb;
    wire [`DATA_WIDTH - 1:0]wb_data_wb;
    wire [2:0]ins_func3_wb;
    wire [`DATA_WIDTH - 1 :0]ram_address_wb;
    wire [`DATA_WIDTH - 1 :0]ram_rdata_wb; 
    wire mem2reg_wb;
    wire write_reg_wb;
    //to next pipe
    wire allow_in_regfile;
    //processing
    wire valid_wb;
    wire ready_go_wb;
    wire fence_type_wb;
    
    wire fence_flush;
    assign fence_flush = fence_type_ex;
    wire hold_if;
    wire hold_id;
    wire hold_ex;
    assign pc_hold = stall_pipe | mem_hold | clint_hold_flag;
    assign hold_if = pc_hold;
    assign hold_id = stall_pipe | clint_hold_flag;
    assign hold_ex = 1'b0;
    //because pc_hold = hold_if
        
    //turn to not valid
    //branch itself equals a type of flush operation
    assign flush_if = fence_flush;
    //turn to not valid
    assign flush_id = branch_res | fence_flush;
    //turn to nop
    assign flush_ex = branch_res | stall_pipe | fence_flush ;

    // regs 
    pc_gen #(.PC_WIDTH(`MEMORY_DEPTH)) pc_gen_inst(
        .branch_addr(jump_addr),
        .jump(pc_jump),
        .hold(hold_if),
        .flush(flush_if),
        .mem_addr_ok(rom_addr_ok),
        .rom_req(rom_req),
        .pc_if(pc_if),
        .next_pc(next_pc),
        .allow_in_if(allow_in_if),
        .ready_go_pre(ready_go_pre),
        .valid_pre(valid_pre)
    );
    
    assign pc_jump = branch_res | clint_int_assert | fence_type_mem;
    assign jump_addr = (clint_int_assert)?clint_int_pc:pc_branch_addr_ex;

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
        .valid_if(valid_if),
        .ready_go_if(ready_go_if)
    );
    

    
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
        .fence_type(fence_type_id),
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
                        
    wire [`CsrMemAddrWIDTH - 1:0]csr_addr_id;
    wire [`DATA_WIDTH - 1:0]csr_read_data_id;
    wire [`DATA_WIDTH - 1:0]csr_write_data_id;
    wire csr_we_id;
    assign csr_we_id = csr_type_id;
    assign csr_addr_id = instruction_id[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
    
    csr_control csr_control_inst(
        .fun3(ins_func3_id),
        .wdata_imm(imm_id),
        .wdata_rs(rs1_data_id),
        .rdata_i(csr_read_data_id),
        .wdata_o(csr_write_data_id)
    );
    
     clint clint_inst(
        .clk(clk),
        .rst_n(rst_n),
        .int_flag_i(external_int_flag),
        .inst_i(instruction_id),        
        .inst_addr_i(pc_id),   
        
        .jump_flag_i(1'b0),
        .jump_addr_i(32'd0),
        .data_i(csr2clint_data),      
        .csr_mtvec(clint_csr_mtvec), 
        .csr_mepc(clint_csr_mepc),           
        .csr_mstatus(clint_csr_mstatus),        
        .global_int_en_i(global_int_enable),    
        
        .hold_flag_o(clint_hold_flag), 
        .we_o(clint2csr_we),        
        .waddr_o(clint2csr_waddr), 
        .raddr_o(clint2csr_raddr),
        .data_o(clint2csr_wdata), 
        .int_addr_o(clint_int_pc), 
        .int_assert_o(clint_int_assert) 
    );
   
//    assign rs1_data_id = (lui_type_id)?32'd0:rs1_data_reg;
//    assign rs1_data_id = (lui_type_id)?32'd0:rs1_data_reg;
    assign rs1_data_id = rs1_data_reg;
    assign rs2_data_id = rs2_data_reg;
    assign ram_wdata_ex = rs2_data_forward;
    //pure logic
    assign ram_we = write_mem_ex;
    
    //regs
    id_ex id_ex_inst(
        .clk(clk),
        .rst_n(rst_n),
        .hold(hold_ex),
        .flush(flush_ex),
        .mem_addr_ok(ram_addr_ok),
        .ram_req(ram_req),
        .rs2_data_id(rs2_data_id),
        .rs1_data_id(rs1_data_id),
        .rs2_data_ex(rs2_data_ex),
        .rs1_data_ex(rs1_data_ex),
        .imm_id(imm_id),
        .imm_ex(imm_ex),
        .instruction_id(instruction_id),
        .instruction_ex(instruction_ex),
        .csr_write_data_id(csr_write_data_id),
        .csr_write_data_ex(csr_write_data_ex),
        .control_flow_id(control_flow_id),
        .rs2_id(rs2_id),
        .rs1_id(rs1_id),
        .rd_id(rd_id),
        .alu_control_id(alu_control_id),
        .alu_control_ex(alu_control_ex),
//        .ram_address_ex(ram_address_ex),
//        .ram_address(ram_address),
        .ALU_src_ex(ALU_src_ex),
        .branch_ex(branch_ex),
        .auipc_ex(auipc_ex),
        .jalr_ex(jalr_ex),
        .control_flow_ex(control_flow_ex),
        .fence_type_id(fence_type_id),
        .fence_type_ex(fence_type_ex),
        .csr_type_id(csr_type_id),
        .csr_type_ex(csr_type_ex),
        .pc_id(pc_id),
        .pc_ex(pc_ex),
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
        
    assign csr_we_ex = csr_type_ex;
    assign csr_addr_ex = instruction_ex[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];

    
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
        .clint_raddr_i(clint2csr_waddr),        
        .clint_waddr_i(clint2csr_raddr),      
        .clint_data_i(clint2csr_wdata),         

        .global_int_en_o(global_int_enable),          
    
        //not used
        .clint_data_o(csr2clint_data),      
        .clint_csr_mtvec(clint_csr_mtvec),   // mtvec
        .clint_csr_mepc(clint_csr_mepc),    // mepc
        .clint_csr_mstatus(clint_csr_mstatus) // mstatus
    );
    
    
    wire [1:0]mem_raddr_index;
    wire [1:0]mem_waddr_index;
    wire [7:0] ram_wdata_byte;
    assign ram_wdata_byte = ram_wdata_ex[7:0];
    wire [15:0]ram_wdata_half_word;
    assign ram_wdata_half_word = ram_wdata_ex[15:0];
    wire [31:0]ram_wdata_word;
    assign ram_wdata_word = ram_wdata_ex[31:0];
    reg [3:0]ram_wbyte;
    reg [1:0]ram_whalfword;
    wire ram_wword;
 
    assign ram_wword = (ins_func3_ex ==  3'b010)? ram_we: 1'b0;
    assign ram_wdata_ex = rs2_data_forward;
    assign mem_waddr_index = {ram_address_ex[1],  ram_address_ex[0]};
    always@(*)begin
        if( (ins_func3_ex ==  3'b000))begin
            case(mem_waddr_index)
                2'b00:begin
                    ram_wbyte = {3'b000,ram_we};
                end
                2'b01:begin
                    ram_wbyte = {2'b00,ram_we, 1'b0};
                end
                2'b10:begin
                    ram_wbyte =  {1'b0,ram_we, 2'b00};
                end
                2'b11:begin
                    ram_wbyte = {ram_we, 3'b000};
                end
                default:begin
                    ram_wbyte = 4'b0000;
                end
            endcase
        end
        else begin
            ram_wbyte = 4'b0000;
        end
    end
    
    always@(*)begin
        if((ins_func3_ex ==  3'b001))begin
            case(mem_waddr_index)
                2'b00:begin
                    ram_whalfword =  {1'b0,ram_we};
                end
                2'b10:begin
                    ram_whalfword =  {ram_we, 1'b0};
                end
                default:begin
                    ram_whalfword = 2'b00;
                end
            endcase
        end
        else begin
            ram_whalfword = 2'b00;
        end
    end
                                
    always@(*)begin
            case(ins_func3_ex)
            //SB
             3'b000:begin
                    ram_wmask <= ram_wbyte;
                    ram_wdata[31:24] = (ram_wbyte[3])?ram_wdata_byte:8'd0;
                    ram_wdata[23:16] = (ram_wbyte[2])?ram_wdata_byte:8'd0;
                    ram_wdata[15:8] = (ram_wbyte[1])?ram_wdata_byte:8'd0;
                    ram_wdata[7:0] = (ram_wbyte[0])?ram_wdata_byte:8'd0;
             end
            //SH
             3'b001:begin
                    ram_wmask <= {{2{ram_whalfword[1]}},{2{ram_whalfword[0]}}};
                    ram_wdata[31:16] = (ram_whalfword[1])?ram_wdata_half_word:16'd0;
                    ram_wdata[15:0] = (ram_whalfword[0])?ram_wdata_half_word:16'd0;
             end
             3'b010:begin
                    ram_wmask <= {4{ram_wword}};
                    ram_wdata <= ram_wdata_word;
             end
             default:begin
                   ram_wmask <= 4'b0000;
                   ram_wdata <= 32'd0;
             end
         endcase
    end
    
    
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
        .operation(alu_control_ex),
        .alu_output(alu_output_ex),
        .alu_zero(alu_zero)
    );

    reg [`BUS_WIDTH - 1:0]ram_address_final;
    reg ram_address_valid;
    assign ram_address_ex = alu_output_ex;
    assign ram_address = (ram_address_valid)?ram_address_final:ram_address_ex;
    assign req_not_hit = ram_req  &&  !(ram_addr_ok);
    
    always@(posedge clk)
    begin
        if (!rst_n )
        begin;
            ram_address_valid <= 1'b0;
            ram_address_final <= 0;
        end
        else if( req_not_hit && !(ram_address_valid))begin
            ram_address_final <= ram_address_ex;
            ram_address_valid <= 1'b1;
        end
        else if(!req_not_hit)begin
            ram_address_valid <= 1'b0;
        end
    end
    
    wire [1:0]mem_address_mux_ex;
    assign mem_address_mux_ex={ csr_type_ex, lui_type_ex};
    mux3_switch2 #(.WIDTH(`DATA_WIDTH))
    mem_address_mux(
        .num0(alu_output_ex),
        .num1(imm_ex),
        //mem2reg
        .num2(csr_read_data_ex),
        .switch(mem_address_mux_ex),
        .muxout(mem_address_ex)
    );
    
    //when flush,next ins becomes nop
    //when cancel,this ins becomes nop 
    //regs
    ex_mem ex_mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .flush(1'b0),
        .hold(1'b0),
        .mem_data_ok(ram_data_ok),
        .mem_address_i(mem_address_ex),
        .mem_address_o(ram_address_mem),
        .mem_read_data_i(ram_rdata),
        .mem_read_data_o(ram_rdata_mem),
        .control_flow_ex(control_flow_ex),
        .control_flow_mem(control_flow_mem),
        .mem_write(write_mem_mem),
        .mem_read(read_mem_mem),
        .rd_ex(rd_ex),
        .rd_mem(rd_mem),
        .ins_func3_i(ins_func3_ex),
        .ins_func3_o(ins_func3_mem),
        .fence_type_ex(fence_type_ex),
        .fence_type_mem(fence_type_mem),
        .allow_in_mem(allow_in_mem),
        .valid_ex(valid_ex),
        .ready_go_ex(ready_go_ex),
        .allow_in_wb(allow_in_wb),
        .valid_mem(valid_mem),
        .ready_go_mem(ready_go_mem)
    );

    //pure logic
    //for load ins
    assign mem_raddr_index = ram_address_mem[1:0];
    always@(*)begin
        case (ins_func3_mem)
            //LB
            3'b000:begin
                case(mem_raddr_index)
                    2'b00: begin
                        ram_rdata_mem_mask = {{24{ram_rdata_mem[7]}}, ram_rdata_mem[7:0]};
                    end
                    2'b01: begin
                        ram_rdata_mem_mask = {{24{ram_rdata_mem[15]}}, ram_rdata_mem[15:8]};
                    end
                    2'b10: begin
                        ram_rdata_mem_mask = {{24{ram_rdata_mem[23]}}, ram_rdata_mem[23:16]};
                    end
                    default: begin
                        ram_rdata_mem_mask = {{24{ram_rdata_mem[31]}}, ram_rdata_mem[31:24]};
                    end
                endcase               
            end
            //LH
            3'b001:begin
                case(mem_raddr_index)
                    2'b00: begin
                        ram_rdata_mem_mask = {{16{ram_rdata_mem[15]}}, ram_rdata_mem[15:0]};
                    end
                    default: begin
                        ram_rdata_mem_mask = {{16{ram_rdata_mem[31]}}, ram_rdata_mem[31:16]}; 
                    end
                endcase     
            end
            //LW
            3'b010:begin
                ram_rdata_mem_mask = ram_rdata_mem; 
            end
            //LBU
            3'b100:begin
                case(mem_raddr_index)
                    2'b00: begin
                        ram_rdata_mem_mask = {24'b0, ram_rdata_mem[7:0]};
                    end
                    2'b01: begin
                        ram_rdata_mem_mask = {24'b0, ram_rdata_mem[15:8]};
                    end
                    2'b10: begin
                        ram_rdata_mem_mask = {24'b0, ram_rdata_mem[23:16]};
                    end
                    default: begin
                        ram_rdata_mem_mask = {24'b0, ram_rdata_mem[31:24]};
                    end
                endcase
            end
            //LHU
            3'b101:begin
                case(mem_raddr_index)
                    2'b00: begin
                        ram_rdata_mem_mask = {16'b0, ram_rdata_mem[15:0]};
                    end
                    default: begin
                        ram_rdata_mem_mask = {16'b0, ram_rdata_mem[31:16]}; 
                    end
                endcase    
            end
            default:begin
                ram_rdata_mem_mask = ram_rdata_mem;
            end
        endcase
    end
    
    //regs       
    mem_wb mem_wb_inst(
        .clk(clk),
        .rst_n(rst_n),
        .flush(1'b0),
        .hold(1'b0),
        .mem_address_i(ram_address_mem),
        .mem_address_o(ram_address_wb),
        .mem_read_data_i(ram_rdata_mem_mask),
        .mem_read_data_o(ram_rdata_wb),
        //read_data from memory
        .control_flow_mem(control_flow_mem),
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
    
    mux2num  mux2_wb_data_switch(
        .num0(ram_address_wb),
        .num1(ram_rdata_wb),
        .switch(mem2reg_wb),
        .muxout(wb_data_wb)
     );

endmodule
