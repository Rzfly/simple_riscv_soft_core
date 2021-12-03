
`include "include.v"

module id_ex(
    input clk,
    input rst_n,
	input [`DATA_WIDTH - 1:0]rd2_data_i,
	input [`DATA_WIDTH - 1:0]rd1_data_i,
    output reg [`DATA_WIDTH - 1:0]rd2_data_o,
    output reg [`DATA_WIDTH - 1:0]rd1_data_o,
    input [`DATA_WIDTH - 1:0] imm_alu_src_i,
    output reg [`DATA_WIDTH - 1:0] imm_alu_src_o,
    input [`ALU_CONTROL_CODE + 4 :0]control_flow_i,
    input [`RS2_WIDTH - 1:0] rs2_id,
    input [`RS1_WIDTH - 1:0] rs1_id,
    input [`RD_WIDTH - 1:0] rd_id,
    output reg [`ALU_CONTROL_CODE - 1: 0]ALU_control,
    output reg ALU_src_ex,
    output reg [3:0]control_flow_o,
    output reg [`RS2_WIDTH - 1:0] rs2_ex,
    output reg [`RS1_WIDTH - 1:0] rs1_ex,
    output reg [`RD_WIDTH - 1:0] rd_ex    
);
	
	always@(posedge clk)
	begin
        rd2_data_o <= rd2_data_i;
        rd1_data_o <= rd1_data_i;
        imm_alu_src_o <= imm_alu_src_i;
        control_flow_o <= control_flow_i[3:0];
        rs2_ex <= rs2_id;
        rs1_ex <= rs1_id;
        rd_ex <= rd_id;    
        ALU_src_ex <= control_flow_i[4];
        ALU_control<= control_flow_i[`ALU_CONTROL_CODE + 4: 5];
	end

endmodule