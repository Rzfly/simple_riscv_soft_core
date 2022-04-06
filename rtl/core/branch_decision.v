`include "include.v"

module branch_decision(
	input branch_req,
	input [2:0]ins_fun3,
	input [`DATA_WIDTH - 1 :0]alu_res,
	input alu_no_zero,
	output branch_res
);
	//beq
	//bne
	wire temp;
	//beq
	assign temp = branch_req && (ins_fun3 == 3'b000) &&  (!alu_no_zero)
	//bne
				|| branch_req && (ins_fun3 == 3'b001) && (alu_no_zero)
	             //blt
				|| branch_req && (ins_fun3 == 3'b100) && (alu_res[0])
	             //bge
				|| branch_req && (ins_fun3 == 3'b101) && (~alu_res[0])
	             //bltu
				|| branch_req && (ins_fun3 == 3'b110) && (alu_res[0])
	             //bgeu
				|| branch_req && (ins_fun3 == 3'b111) && (~alu_res[0]);

	assign branch_res = temp;
	
endmodule