
`include "include.v"

module mux2num #(
	parameter WIDTH = `DATA_WIDTH
)(
	input [WIDTH - 1:0]num0,
	input [WIDTH - 1:0]num1,
	input switch,
	output [WIDTH - 1:0]muxout
);

    assign muxout = (switch)? num1 : num0;

endmodule