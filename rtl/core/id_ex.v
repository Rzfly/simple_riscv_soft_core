
`include "include.v"

module id_ex(
    input clk,
    input rst_n,
	input [`DATA_WIDTH - 1:0]rd2_data_i,
	input [`DATA_WIDTH - 1:0]rd1_data_i,
    output reg [`DATA_WIDTH - 1:0]rd2_data_o,
    output reg [`DATA_WIDTH - 1:0]rd1_data_o,
    input [`DATA_WIDTH - 1:0] imm_i,
    output reg [`DATA_WIDTH - 1:0] imm_o,
    input [`ALU_CONTROL_CODE_WIDTH + 4 :0]control_flow_i,
    input [`RS2_WIDTH - 1:0] rs2_id,
    input [`RS1_WIDTH - 1:0] rs1_id,
    input [`RD_WIDTH - 1:0] rd_id,
    input [`ALU_OP_WIDTH - 1:0]alu_control_i,
    output reg [`ALU_OP_WIDTH - 1:0]alu_control_o,
    output reg auipc_ex,
    output reg branch_ex,
    output reg ALU_src_ex,
    output reg [3:0]control_flow_o,
    input [`DATA_WIDTH - 1:0]pc_i,
    output reg [`DATA_WIDTH - 1:0]pc_o,
    output reg [`RD_WIDTH - 1:0] rd_ex,
    input [2: 0]ins_func3_i,
    output reg [2: 0]ins_func3_o
);
	
	always@(posedge clk)
	begin
	   if(~rst_n)begin
            rd2_data_o <= 0;
            rd1_data_o <= 0;
            imm_o <= 0;
            control_flow_o <= 0;
            pc_o <= 0;
            rd_ex <= 0;    
            ALU_src_ex <= 0;
            branch_ex <= 0;
            alu_control_o <= 0;
            ins_func3_o <= 0;
	   end
	   else begin
            rd2_data_o <= rd2_data_i;
            rd1_data_o <= rd1_data_i;
            imm_o <= imm_i;
            control_flow_o <= control_flow_i[3:0];
            pc_o <= pc_i;
            rd_ex <= rd_id;    
            auipc_ex <= control_flow_i[6];
            ALU_src_ex <= control_flow_i[4];
            branch_ex <= control_flow_i[5];
            alu_control_o <= alu_control_i;
            ins_func3_o <= ins_func3_i;
	   end
	end

    
endmodule
