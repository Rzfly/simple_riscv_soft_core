
`include "include.v"

module mux3_switch3_pri#(
	parameter WIDTH = `DATA_WIDTH
)(
	input [WIDTH-1:0]num0,
	input [WIDTH-1:0]num1,
	input [WIDTH-1:0]num2,
	input [2:0]switch,
	output reg [2:0]  mux_index,
	output reg [WIDTH-1:0]  muxout
);
		
  always@(*)begin
      case(switch)
        3'b000:begin
            muxout <= 'd0;
			mux_index <= 3'b000;
        end
        3'b001:begin
            muxout <= num0;
			mux_index <= 3'b001;
        end
        3'b010:begin
            muxout <= num1;
			mux_index <= 3'b010;
        end
        3'b011:begin
            muxout <= num1;
			mux_index <= 3'b010;
        end
        3'b100:begin
            muxout <= num2;
			mux_index <= 3'b100;
        end
        3'b101:begin
            muxout <= num2;
			mux_index <= 3'b100;
        end
        3'b110:begin
            muxout <= num2;
			mux_index <= 3'b100;
        end
        3'b111:begin
            muxout <= num2;
			mux_index <= 3'b100;
        end
        default:begin
            muxout <= 'd0;
			mux_index <= 3'b000;
        end
      endcase
  end
		
endmodule