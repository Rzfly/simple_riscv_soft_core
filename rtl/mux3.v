
`include "include.v"

module mux3 #(
	parameter WIDTH = `DATA_WIDTH
)(
	input [WIDTH-1:0]num0,
	input [WIDTH-1:0]num1,
	input [WIDTH-1:0]num2,
	input [1:0]switch,
	output [WIDTH-1:0]muxout
);


	assign muxout = (switch == 2'b00)?num0:
		(switch == 2'b01)?num1:
		(switch == 2'b10)?num2:
		0;

endmodule