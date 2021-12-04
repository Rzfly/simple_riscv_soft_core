
`include "include.v"

module alu(
    input [`DATA_WIDTH - 1:0]alu_src_1,
    input [`DATA_WIDTH - 1:0]alu_src_2,
    input [`ALU_OP_WIDTH - 1:0]operation,
    output reg [`DATA_WIDTH - 1:0]alu_output
);


    wire op_add = operation[`OP_DECINFO_ADD]; 
    wire op_sub = operation[`OP_DECINFO_SUB]; 
    wire op_addsub = op_add | op_sub;
    wire op_xor = operation[`OP_DECINFO_XOR];
    wire op_sll = operation[`OP_DECINFO_SLL];
    wire op_srl = operation[`OP_DECINFO_SRL];
    wire op_sra = operation[`OP_DECINFO_SRA];
    wire op_or  = operation[`OP_DECINFO_OR];
    wire op_and = operation[`OP_DECINFO_AND];
    wire op_slt = operation[`OP_DECINFO_SLT];
    wire op_sltu = operation[`OP_DECINFO_SLTU];
    wire adder_sub =                    (
                   // The original sub instruction
               (op_sub) 
                   // The compare lt or gt instruction
             | (
                op_slt | op_sltu 
               ))
    wire op_shift = op_sra | op_sll | op_srl;   
          
    wire [`DATA_WIDTH - 1:0]adder_in1;
    wire [`DATA_WIDTH - 1:0]adder_in2;


    wire [`DATA_WIDTH - 1:0]alu_addsub_res = adder_in1 + adder_in2;
    wire [`DATA_WIDTH - 1:0]alu_xor_res = alu_src_1 ^ alu_src_2;
    wire [`DATA_WIDTH - 1:0]shifter_res;
    wire [`DATA_WIDTH - 1:0]alu_sll_res = shifter_res;
    wire [`DATA_WIDTH - 1:0]alu_srl_res = shifter_res;
    wire [`DATA_WIDTH - 1:0]alu_sra_res = shifter_res;
    wire [`DATA_WIDTH - 1:0]alu_or_res = alu_src_1 |alu_src_2;
    wire [`DATA_WIDTH - 1:0]alu_and_res = alu_src_1 & alu_src_2;
    wire [`DATA_WIDTH - 1:0]alu_slt_res = alu_src_1 ^ alu_src_2;
    wire [`DATA_WIDTH - 1:0]alu_sltu_res = alu_src_1
    
    wire [`DATA_WIDTH - 1:0]shifter_res;
    wire [`DATA_WIDTH - 1:0]shifter_in1;
    wire [`DATA_WIDTH - 1:0]shifter_op1 = alu_src_1;
    wire [5 - 1:0]shifter_in2;
         
    assign shifter_in1 = {`DATA_WIDTH{op_shift}} & (
        (op_sra | op_srl)?
            {
            shifter_op1[00],shifter_op1[01],shifter_op1[02],shifter_op1[03],
            shifter_op1[04],shifter_op1[05],shifter_op1[06],shifter_op1[07],
            shifter_op1[08],shifter_op1[09],shifter_op1[10],shifter_op1[11],
            shifter_op1[12],shifter_op1[13],shifter_op1[14],shifter_op1[15],
            shifter_op1[16],shifter_op1[17],shifter_op1[18],shifter_op1[19],
            shifter_op1[20],shifter_op1[21],shifter_op1[22],shifter_op1[23],
            shifter_op1[24],shifter_op1[25],shifter_op1[26],shifter_op1[27],
            shifter_op1[28],shifter_op1[29],shifter_op1[30],shifter_op1[31]
                 } : (shifter_op1) );    
                 
    assign shifter_in2 = 
    assign alu_output = 
    ( {`DATA_WIDTH{op_addsub}} & alu_addsub_res )| 
    ( {`DATA_WIDTH{op_xor}} & alu_xor_res )| 
    ( {`DATA_WIDTH{op_sll}} & alu_sll_res )| 
    ( {`DATA_WIDTH{op_srl}} & alu_srl_res )| 
    ( {`DATA_WIDTH{op_sra}} & alu_sra_res )| 
    ( {`DATA_WIDTH{op_or}} & alu_or_res )| 
    ( {`DATA_WIDTH{op_and}} & alu_and_res )|
    ( {`DATA_WIDTH{op_slt}} & alu_slt_res )| 
    ( {`DATA_WIDTH{op_sltu}} & alu_sltu_res );
    
    assign adder_in1 = {`DATA_WIDTH{op_addsub}} & (alu_src_1);
    assign adder_in2 = {`DATA_WIDTH{op_addsub}} & (adder_sub ? (~alu_src_2) : alu_src_2);
    
               
  input  alu_req_alu_sub ,
  input  alu_req_alu_xor ,
  input  alu_req_alu_sll ,
  input  alu_req_alu_srl ,
  input  alu_req_alu_sra ,
  input  alu_req_alu_or  ,
  input  alu_req_alu_and ,
  input  alu_req_alu_slt ,
  input  alu_req_alu_sltu,
  input  alu_req_alu_lui ,


endmodule
