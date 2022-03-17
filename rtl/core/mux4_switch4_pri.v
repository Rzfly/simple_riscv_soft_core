
`include "include.v"

module mux4_switch4_pri #(
	parameter WIDTH = `DATA_WIDTH
)(
	input [WIDTH-1:0]num0,
	input [WIDTH-1:0]num1,
	input [WIDTH-1:0]num2,
	input [WIDTH-1:0]num3,
	input [3:0]switch,
	output reg [3:0]  mux_index,
	output reg [WIDTH-1:0]  muxout
);
		
//	assign muxout = (switch == 3'b001)?num0:
//		(switch == 3'b010)?num1:
//		(switch == 3'b100)?num2:
//		0;
		
  always@(*)begin
      case(switch)
        4'b0000:begin
            muxout <= 'd0;
			mux_index <= 4'b0000;
		end
        4'b0001:begin
            muxout <= num0;
			mux_index <= 4'b0001;
        end
        4'b0010:begin
            muxout <= num1;
			mux_index <= 4'b0010;
        end
        4'b0011:begin
            muxout <= num1;
			mux_index <= 4'b0010;
        end
        4'b0100:begin
            muxout <= num2;
			mux_index <= 4'b0100;
        end
        4'b0101:begin
            muxout <= num2;
			mux_index <= 4'b0100;
        end
        4'b0110:begin
            muxout <= num2;
			mux_index <= 4'b0100;
        end
        4'b0111:begin
            muxout <= num2;
			mux_index <= 4'b0100;
        end
        4'b1xxx:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        4'b1000:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        4'b1001:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        4'b1010:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        4'b1011:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        4'b1100:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        4'b1101:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        4'b1110:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        4'b1111:begin
            muxout <= num3;
			mux_index <= 4'b1000;
        end
        default:begin
            muxout <= 'd0;
			mux_index <= 4'b0000;
        end
      endcase
  end
		
endmodule