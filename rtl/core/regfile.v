	
`include "include.v"

module regfile(
	input wire clk,
	input wire we,
	input wire[`RS2_WIDTH - 1:0] rs2,
	input wire[`RS1_WIDTH - 1:0] rs1,
	input wire[`RD_WIDTH - 1:0] wa,
	input wire[`DATA_WIDTH - 1:0] wd,
	output wire[`DATA_WIDTH - 1:0] rd1_data,rd2_data
);

	reg [`DATA_WIDTH - 1:0] rf[31:0];

	always @(negedge clk) begin
		if(we) begin
			 rf[wa] <= wd;
		end
	end

	//by default, x0 reg is set to be zero.
	assign rd1_data = (rs1 != 0) ? rf[rs1] : 0;
	assign rd2_data = (rs1 != 0) ? rf[rs2] : 0;
endmodule
	