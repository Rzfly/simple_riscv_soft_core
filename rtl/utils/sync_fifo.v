
//for pipe requiring

module syc_fifo#(
	parameter DATA_WIDTH = 32,
	parameter DEPTH      = 2,
	parameter PTR_LENGTH = 2
)
(
	input clk,
	input rst_n,
	//master
	input [DATA_WIDTH - 1:0]wdata,
	input w_req,
	output write_enable,
	output full,
	//slave
	output [DATA_WIDTH - 1:0]rdata,
	input  r_req,
	output read_enable,
	output empty
);


	reg [DATA_WIDTH - 1:0]saving_regs[DEPTH - 1 :0];
	reg [PTR_LENGTH - 1:0]wptr;
	reg [PTR_LENGTH - 1:0]rptr;
	wire [PTR_LENGTH - 2:0]w_address;
	wire [PTR_LENGTH - 2:0]r_address;
	assign w_address = wptr[PTR_LENGTH - 2:0];
	assign r_address = rptr[PTR_LENGTH - 2:0];
	
	
	assign write_enable = (!full) && rst_n;
	assign read_enable  = (!empty) && rst_n;
	assign rdata = saving_regs[r_address];
	
	integer i;
	always@(posedge clk)begin
		if(!rst_n)begin
			for(i = 0; i < DEPTH;i = i + 1)begin
				saving_regs[i] <= 0;
			end
		end
		else if(w_req && (!full)) begin
			saving_regs[w_address] <= wdata;
		end
	end
	
	always@(posedge clk)begin
		if(!rst_n)begin
			wptr <= 0;
		end
		//increass after write
		else if(w_req && (!full)) begin
			wptr = wptr + 1;
		end
	end
	
	
	always@(posedge clk)begin
		if(!rst_n)begin
			rptr <= 0;
		end
		else if(r_req && (!empty)) begin
			rptr = rptr + 1;
		end
	end
	
	wire [PTR_LENGTH-2:0]sub_temp;
	assign sub_temp =  w_address ^ r_address;
	assign full = (!(|sub_temp)) && (wptr[PTR_LENGTH - 1] ^ rptr[PTR_LENGTH - 1] );
	assign empty = (!(|sub_temp)) && (!(wptr[PTR_LENGTH - 1] ^ rptr[PTR_LENGTH - 1]));
	
	
endmodule