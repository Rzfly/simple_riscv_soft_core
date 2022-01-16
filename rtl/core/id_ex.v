
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
    input [`ALU_CONTROL_CODE_WIDTH + 4 :0]control_flow_i,
    input [`RS2_WIDTH - 1:0] rs2_id,
    input [`RS1_WIDTH - 1:0] rs1_id,
    input [`RD_WIDTH - 1:0] rd_id,
    input [`ALU_OP_WIDTH - 1:0]alu_control_i,
    output reg [`ALU_OP_WIDTH - 1:0]alu_control_o,
    output reg branch_ex,
    output reg ALU_src_ex,
    output reg [3:0]control_flow_o,
    output reg [`RS2_WIDTH - 1:0] rs2_ex,
    output reg [`RS1_WIDTH - 1:0] rs1_ex,
    output reg [`RD_WIDTH - 1:0] rd_ex    
);
	
	always@(posedge clk)
	begin
	   if(~rst_n)begin
            rd2_data_o <= 0;
            rd1_data_o <= 0;
            imm_alu_src_o <= 0;
            control_flow_o <= 0;
            rs2_ex <= 0;
            rs1_ex <= 0;
            rd_ex <= 0;    
            ALU_src_ex <= 0;
            branch_ex <= 0;
            alu_control_o <= 0;
	   end
	   else begin
            rd2_data_o <= rd2_data_i;
            rd1_data_o <= rd1_data_i;
            imm_alu_src_o <= imm_alu_src_i;
            control_flow_o <= control_flow_i[3:0];
            rs2_ex <= rs2_id;
            rs1_ex <= rs1_id;
            rd_ex <= rd_id;    
            ALU_src_ex <= control_flow_i[4];
            branch_ex <= control_flow_i[5];
            alu_control_o <= alu_control_i;
	   end
	end

//    wire [`ALU_CONTROL_CODE_WIDTH + 5 :0]control_flow_id;
//    assign control_flow_id = {ALU_control_id,branch_id,ALU_src_id,read_mem_id,write_mem_id,mem2reg_id,write_reg_id};
    
endmodule
