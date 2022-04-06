	
`define READ_DELAY	
	
module cache_tagv_32_24bit_dram(
	input [4:0]a,
	input [4:0]a_2,
	input [23:0]d,
	input clk,
	input we,
	input rst_n,
	output [23:0]spo,
	output [23:0]spo_2
);
	reg [23:0]dram_reg[31:0];
`ifdef READ_DELAY
	integer i;
	reg [4:0]a_2_d;
	reg [4:0]a_d;
	always@(posedge clk)begin
		if(!rst_n)begin
            a_2_d <= 'd0;
            a_d <= 'd0;
		end
		else begin
            a_d <= a;
            a_2_d <= a_2;
		end
	end
	always@(posedge clk)begin
		if(!rst_n)begin
		  for(i = 0; i < 32; i = i + 1)begin
			dram_reg[i] <= 'd0;
		  end
		end
		else if(we)begin
			dram_reg[a] <= d;
		end
	end
	assign spo = dram_reg[a_d];
	assign spo_2 = dram_reg[a_2_d];

`else
	integer i;
	always@(posedge clk)begin
		if(!rst_n)begin
		  for(i = 0; i < 32; i = i + 1)begin
			dram_reg[i] <= 'd0;
		  end
		end
		else if(we)begin
			dram_reg[a] <= d;
		end
	end
	
	assign spo = dram_reg[a];
	assign spo_2 = dram_reg[a_2];

`endif
endmodule
