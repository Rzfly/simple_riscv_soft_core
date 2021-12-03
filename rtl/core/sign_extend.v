	
`include "include.v"

module sign_extend(
	input [`IMM_WIDTH - 1:0]immediate_num,
	output [`DATA_WIDTH - 1:0]num
);
	assign num = {{(`DATA_WIDTH - `IMM_WIDTH){immediate_num[`IMM_WIDTH - 1]}}, immediate_num};
endmodule
	