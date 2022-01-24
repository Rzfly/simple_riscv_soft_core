
`include "include.v"

module alu(
    input [`DATA_WIDTH - 1:0]alu_src_1,
    input [`DATA_WIDTH - 1:0]alu_src_2,
    input [`ALU_OP_WIDTH - 1:0]operation,
    output alu_zero,
    output [`DATA_WIDTH - 1:0]alu_output
);

    wire op_add = operation[`OP_DECINFO_ADD]; 
    wire op_sub = operation[`OP_DECINFO_SUB]; 
    wire op_xor = operation[`OP_DECINFO_XOR];
    wire op_sll = operation[`OP_DECINFO_SLL];
    wire op_srl = operation[`OP_DECINFO_SRL];
    wire op_sra = operation[`OP_DECINFO_SRA];
    wire op_or  = operation[`OP_DECINFO_OR];
    wire op_and = operation[`OP_DECINFO_AND];
    wire op_slt = operation[`OP_DECINFO_SLT];
    wire op_sltu = operation[`OP_DECINFO_SLTU];
    wire adder_add; 
    wire adder_addsub;
    assign adder_add = op_add;
    wire adder_sub =                    (
                   // The original sub instruction
               (op_sub) 
                   // The compare lt or gt instruction
             | (
                op_slt | op_sltu 
               ));
    wire op_shift;
    wire op_addsub;
    assign op_shift = op_sra | op_sll | op_srl;   
    assign op_addsub = op_add | op_sub;
          
    wire [`ALU_ADDER_WIDTH - 1:0]adder_in1;
    wire [`ALU_ADDER_WIDTH - 1:0]adder_in2;
    wire [`ALU_ADDER_WIDTH - 1:0] adder_res;
    wire [`DATA_WIDTH - 1:0] alu_addsub_res;


    wire [`DATA_WIDTH - 1:0]alu_xor_res = alu_src_1 ^ alu_src_2;
    wire [`DATA_WIDTH - 1:0]shifter_res;
    wire [`DATA_WIDTH - 1:0]alu_sll_res;
    wire [`DATA_WIDTH - 1:0]alu_srl_res;
    wire [`DATA_WIDTH - 1:0]alu_sra_res;
    wire [`DATA_WIDTH - 1:0]alu_or_res = alu_src_1 |alu_src_2;
    wire [`DATA_WIDTH - 1:0]alu_and_res = alu_src_1 & alu_src_2;
    wire [`DATA_WIDTH - 1:0]alu_slt_res;
    wire [`DATA_WIDTH - 1:0]alu_sltu_res;
    
    wire  [`DATA_WIDTH-1:0] sra_res;
    wire  [`DATA_WIDTH-1:0] srl_res;
    wire  [`DATA_WIDTH-1:0] sll_res;
    
//    wire [`DATA_WIDTH - 1:0]shifter_res;
    wire [`DATA_WIDTH - 1:0]shifter_in1;
    wire [`DATA_WIDTH - 1:0]shifter_op1 = alu_src_1;
    wire [`DATA_WIDTH - 1:0]shifter_op2 = alu_src_2;
    
    wire [`ALU_ADDER_WIDTH-1:0] misc_adder_op1;
    wire [`ALU_ADDER_WIDTH-1:0] misc_adder_op2;
    wire [`DATA_WIDTH - 1:0]misc_op1;
    wire [`DATA_WIDTH - 1:0]misc_op2;
   
   
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
                 
    assign shifter_in2 = {5{op_shift}} & shifter_op2[4:0];
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
    
    assign adder_addsub = adder_add | adder_sub; 
    assign adder_in1 = {`ALU_ADDER_WIDTH{adder_addsub}} & (misc_adder_op1);
    assign adder_in2 = {`ALU_ADDER_WIDTH{adder_addsub}} & (adder_sub ? (~misc_adder_op2) : misc_adder_op2);
    wire adder_cin;
    assign adder_cin = adder_addsub & adder_sub;
    assign adder_res = adder_in1 + adder_in2 + adder_cin;
    assign alu_addsub_res = adder_res[`DATA_WIDTH - 1 : 0];
  
    assign shifter_res = (shifter_in1 << shifter_in2);

    assign sll_res = shifter_res;
    assign srl_res =  
                 {
    shifter_res[00],shifter_res[01],shifter_res[02],shifter_res[03],
    shifter_res[04],shifter_res[05],shifter_res[06],shifter_res[07],
    shifter_res[08],shifter_res[09],shifter_res[10],shifter_res[11],
    shifter_res[12],shifter_res[13],shifter_res[14],shifter_res[15],
    shifter_res[16],shifter_res[17],shifter_res[18],shifter_res[19],
    shifter_res[20],shifter_res[21],shifter_res[22],shifter_res[23],
    shifter_res[24],shifter_res[25],shifter_res[26],shifter_res[27],
    shifter_res[28],shifter_res[29],shifter_res[30],shifter_res[31]
                 };

   //算术掩膜
    wire [`DATA_WIDTH-1:0] eff_mask = (~(`DATA_WIDTH'b0)) >> shifter_in2;
    assign sra_res = (srl_res & eff_mask) | ({32{shifter_op1[`DATA_WIDTH - 1]}} & (~eff_mask));

    assign alu_sll_res = sll_res;
    assign alu_srl_res = srl_res;
    assign alu_sra_res = sra_res;
    
    
   wire op_slttu = (op_slt | op_sltu);
  //   The SLT and SLTU is reusing the adder to do the comparasion
       // It is Less-Than if the adder result is negative
   wire slttu_cmp_lt = op_slttu & adder_res[`DATA_WIDTH];
   wire [`DATA_WIDTH-1:0] slttu_res = 
               slttu_cmp_lt ?
               `DATA_WIDTH'b1 : `DATA_WIDTH'b0;
               
   wire op_unsigned = op_sltu;
   assign misc_op1 = alu_src_1;
   assign misc_op2 = alu_src_2;
   //若有符号 则扩展操作数的符号位 至加法器宽度 否则扩展0�?
   assign misc_adder_op1 = {{`ALU_ADDER_WIDTH-`DATA_WIDTH{(~op_unsigned) & misc_op1[`DATA_WIDTH-1]}},misc_op1};
   assign misc_adder_op2 = {{`ALU_ADDER_WIDTH-`DATA_WIDTH{(~op_unsigned) & misc_op2[`DATA_WIDTH-1]}},misc_op2};

   assign alu_slt_res = slttu_res;
   assign alu_sltu_res = slttu_res;
   assign alu_zero = ( ~( | alu_addsub_res )) & ( op_sub );

endmodule
