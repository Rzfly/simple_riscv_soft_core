module lfsr(
	input clk,
	input rst_n,
	output pn_seq
);

	reg [3:0]pn_regs;
	wire [3:0]pn_next;
	always@(posedge clk)begin
		if(!rst_n)begin
			pn_regs <= 4'b1111;
		end
		else begin
			pn_regs <= pn_next;
		end
	end
	assign pn_next = {pn_regs[3]^pn_regs[0],pn_regs[3],pn_regs[2],pn_regs[1]};	
	assign pn_seq = pn_regs[0];
endmodule
