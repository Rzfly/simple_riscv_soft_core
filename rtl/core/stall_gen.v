
module stall_gen(
	input branch_id,
	output branch_stall
);

	assign branch_stall = branch_id;
endmodule	