`include "include.v"

module branch_decision(
	input branch_req,
    input jal_ex,
    input jalr_ex,
    input clint_int_assert,
    input fence_jump,
	input bp_taken,
	input [`BUS_WIDTH - 1:0]pre_taken_target_ex,
    input [`BUS_WIDTH - 1:0]pc_branch_addr_ex,       
	input [2:0]ins_fun3,
	input [`DATA_WIDTH - 1 :0]alu_res,
	input alu_no_zero,
	output update_btb,
	output branch_cal,
	output branch_res,
	output branch_seq
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
	wire br_bp_taken = branch_req & bp_taken;
    wire bp_addr_diff = (pre_taken_target_ex != pc_branch_addr_ex)?1'b1:1'b0;
    wire bp_addr_wrong = (temp & br_bp_taken & bp_addr_diff);
    wire branch_wrong = (temp ^ br_bp_taken);
    wire type_err = bp_taken & ~branch_req;
    assign update_btb   = branch_wrong | bp_addr_wrong | type_err;
    assign branch_cal = temp;
    assign branch_seq = ~temp & br_bp_taken;
    
	assign branch_res = branch_wrong | bp_addr_wrong;
	
endmodule