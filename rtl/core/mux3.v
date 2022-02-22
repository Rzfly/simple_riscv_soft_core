
`include "include.v"

module mux3 #(
	parameter WIDTH = `DATA_WIDTH
)(
	input [WIDTH-1:0]num0,
	input [WIDTH-1:0]num1,
	input [WIDTH-1:0]num2,
	input [2:0]switch,
	output reg [WIDTH-1:0]  muxout
);
		
//	assign muxout = (switch == 3'b001)?num0:
//		(switch == 3'b010)?num1:
//		(switch == 3'b100)?num2:
//		0;
		
  always@(*)begin
      case(switch)
        3'b001:begin
            muxout <= num0;
        end
        3'b010:begin
            muxout <= num1;
        end
        3'b100:begin
            muxout <= num2;
        end
        default:begin
            muxout <= num0;
        end
      endcase
  end
		
endmodule