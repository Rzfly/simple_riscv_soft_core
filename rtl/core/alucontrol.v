
`include "include.v"

module alucontrol(
    input  [`ALU_CONTROL_CODE_WIDTH - 1 :0]ins_optype,
    input  [`FUNC3_WIDTH - 1: 0 ]ins_fun3,
    input  [`FUNC7_WIDTH - 1: 0 ]ins_fun7,
    output [`ALU_OP_WIDTH - 1 : 0]alu_operation
);

    wire alu_add_req;
    wire alu_sub_req;
    wire alu_xor_req;
    wire alu_sll_req;
    wire alu_srl_req;
    wire alu_sra_req;
    wire alu_or_req;
    wire alu_and_req;
    wire alu_slt_req;
    wire alu_sltu_req;
    
    wire alu_ldsd_add_req;
    
    
    wire ins_rtype;
    wire ins_itype;
    wire ins_stype;
    wire ins_sbtype;
    wire ins_utype;
    wire ins_ujtype;
    wire ins_auipctype;
    wire ins_ri_type;
    

    assign ins_rtype = (ins_optype == `ALU_CONTROL_R_TYPE)?1'b1:1'b0;
    assign ins_itype = (ins_optype == `ALU_CONTROL_I_TYPE_LOAD)| (ins_optype == `ALU_CONTROL_I_TYPE_ALUI)|
    (ins_optype == `ALU_CONTROL_I_TYPE_JALR);
    assign ins_stype = (ins_optype == `ALU_CONTROL_S_TYPE)?1'b1:1'b0;
    assign ins_sbtype = (ins_optype == `ALU_CONTROL_SB_TYPE)?1'b1:1'b0;
    assign ins_utype = (ins_optype == `ALU_CONTROL_U_TYPE)?1'b1:1'b0;
    assign ins_ujtype = (ins_optype == `ALU_CONTROL_UJ_TYPE)?1'b1:1'b0;
    assign ins_auipctype = (ins_optype == `ALU_CONTROL_AUIPC_TYPE)?1'b1:1'b0;
    assign ins_ri_type = ins_rtype | ins_itype;
    
    
    assign alu_operation[`OP_DECINFO_ADD] = alu_add_req;
    assign alu_operation[`OP_DECINFO_SUB] = alu_sub_req;
    assign alu_operation[`OP_DECINFO_XOR] = alu_xor_req;
    assign alu_operation[`OP_DECINFO_SLL] = alu_sll_req;
    assign alu_operation[`OP_DECINFO_SRL] = alu_srl_req;
    assign alu_operation[`OP_DECINFO_SRA] = alu_sra_req;
    assign alu_operation[`OP_DECINFO_OR] = alu_or_req;
    assign alu_operation[`OP_DECINFO_AND] = alu_and_req;
    assign alu_operation[`OP_DECINFO_SLT] = alu_slt_req;
    assign alu_operation[`OP_DECINFO_SLTU] = alu_sltu_req;
    
    
    //branch 地址已经在id阶段被计算
    assign alu_add_req = ins_ri_type & (ins_fun3 == 3'b000) & ~ins_fun7 [5];
    //data-type
    assign alu_sub_req = ins_ri_type & (ins_fun3 == 3'b000) & ins_fun7 [5];
    assign alu_xor_req = ins_ri_type & (ins_fun3 == 3'b100);
    assign alu_sll_req = ins_ri_type & (ins_fun3 == 3'b001);
    assign alu_srl_req = ins_ri_type & (ins_fun3 == 3'b101) & ~ins_fun7 [5];
    assign alu_sra_req = ins_ri_type & (ins_fun3 == 3'b101) & ins_fun7 [5];
    assign alu_or_req  = ins_ri_type & (ins_fun3 == 3'b110) ;
    assign alu_and_req = ins_ri_type & (ins_fun3 == 3'b111) ;
    assign alu_slt_req = ins_ri_type & (ins_fun3 == 3'b010) ;
    assign alu_sltu_req = ins_ri_type & (ins_fun3 == 3'b011);
    
//    assign alu_ldsd_add_req = ins_optype[`DEFINE_LOAD_OR_STORE]
    
endmodule
