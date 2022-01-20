
`include "include.v"

module forwarding(
	input [`RS1_WIDTH -1:0]rs1_ex,
	input [`RS2_WIDTH -1:0]rs2_ex,
	input  rd_wb,
	input  write_reg_wb,
	input  rd_mem,
	input  write_reg_mem,
	output [2:0]rs1_forward,
//	output [`RS1_WIDTH -1:0]rs1_forward_data
	output [2:0]rs2_forward
//	output [`RS1_WIDTH -1:0]rs2_forward_data
);

//�?: regfile 内部已经处理了读写冲突，�?律先写后读，因此读取regfile	不需要前递wb阶段的数�?
//但是id阶段读取regfile 仍然�?要前递ex和mem阶段的指令执行结�?
//为了�?化操作，id的前递被转移到ex阶段执行，相应地，前递ex和mem阶段的指令结果转化为前�?�mem和wb阶段的指令结�?
//值得注意的是，如果同时需要前递前两个阶段的指令结果，要如何处理？
//应当注意到，mem阶段的指令结果是�?新的，�?�且也经过了前�?�处理，�?以，此时应当取mem阶段的指令结�?
//以上，开始编程！

	//前�?�wb阶段的数�?  但是mem阶段优先
	assign rs1_forward[2] = (rd_wb == rs1_ex)? (~rs1_forward[1] & write_reg_wb):1'b0;
	//前�?�mem阶段的数�? 
	assign rs1_forward[1] = (rd_mem == rs1_ex)? (write_reg_mem):1'b0;
	//不前�?
	assign rs1_forward[0] = ~rs1_forward[2] & ~rs1_forward[1];
	
	//前�?�wb阶段的数�?  但是mem阶段优先
	assign rs2_forward[2] = (rd_wb == rs2_ex)? (~rs2_forward[1] & write_reg_wb):1'b0;
	//前�?�mem阶段的数�? 
	assign rs2_forward[1] = (rd_mem == rs2_ex)? (write_reg_mem):1'b0;
	//不前�?
	assign rs2_forward[0] = ~rs2_forward[2] & ~rs2_forward[1];
	
	
endmodule