

`include "include.v"
module cache(
	input clk
	input rst_n,
	//from core srambus
	input mem_req,
	input w_req,
	input [`BUS_WIDTH - 1 : 0]mem_address,
	output cache_req_hit,
	output cache_data_ok,
	output [`DATA_WIDTH - 1 : 0] ret_data,
	//to mem,axi_bus,single channel used


);

	reg [4:0]state:
	reg []

endmodule