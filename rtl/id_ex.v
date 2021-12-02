
`include "include.v"

module id_ex(
    input clk,
    input rst_n,
	input [`DATA_WIDTH - 1:0]rd2_data,
	input [`DATA_WIDTH - 1:0]rd1_data,
    input [`IMM_WIDTH - 1:0]imm_short_in,
    input [`ALU_CONTROL_CODE + 4 :0]control_flow_i,
    output [`DATA_WIDTH - 1:0]rd2_data_o,
    output [`DATA_WIDTH - 1:0]rd1_data_o,
    output [`DATA_WIDTH - 1:0]imm_extend,
    output [`ALU_CONTROL_CODE - 1: 0]ALU_control,
    output ALU_src_ex,
    output imm_src_ex,
    output [3 :0]control_flow_o
//    output    .instruction(instruction_id)
        
);
	
	
	
//	mux2 alu_src_mux(
//	   .num0,
//	   .num1()
//	   .switch(ALU_src)
//	);
endmodule