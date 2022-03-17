`include "include.v"
module multdiv_control(
	input r_type,
	input [6:0]func7,
	input [2:0]func3,
	output reg signed_div,	
	output reg signed_mult_num_1,
	output reg signed_mult_num_2,
	output reg div_res_req,
	output reg div_rem_req,
	output reg mull_req,
	output reg mulh_req
);
	wire valid;
	assign valid = func7[0] & r_type;
	
	always@(*)begin
		case(func3)
		      //mul
			3'b000:begin
			signed_div <= 'd0;	
			signed_mult_num_1 <= 'd0;	
			signed_mult_num_2 <= 'd0;	
			div_res_req<= 'd0;
			div_rem_req<= 'd0;
			mull_req <= valid;
			mulh_req <= 'd0;			
			end
			//mulh
			3'b001:begin
			signed_div <= 'd0;	
			signed_mult_num_1 <= valid;	
			signed_mult_num_2 <= valid;	
			div_res_req<= 'd0;
			div_rem_req<= 'd0;
			mull_req <= 'd0;
			mulh_req <= valid;
			end
			//mulhsu
			3'b010:begin
			signed_div <= 'd0;	
			signed_mult_num_1 <= valid;	
			signed_mult_num_2 <= 'd0;	
			div_res_req<= 'd0;
			div_rem_req<= 'd0;
			mull_req <= 'd0;
			mulh_req <= valid;
			end
			//mulhu
			3'b011:begin
			signed_div <= 'd0;	
			signed_mult_num_1 <= 'd0;	
			signed_mult_num_2 <= 'd0;	
			div_res_req<= 'd0;
			div_rem_req<= 'd0;
			mull_req <= 'd0;
			mulh_req <= valid;
			end
			3'b100:begin
			signed_div <= valid;	
			signed_mult_num_1 <= 'd0;	
			signed_mult_num_2 <= 'd0;	
			div_res_req<= valid;
			div_rem_req<= 'd0;
			mull_req <= 'd0;
			mulh_req <= 'd0;
			end
			3'b101:begin
			signed_div <= 'd0;	
			signed_mult_num_1 <= 'd0;	
			signed_mult_num_2 <= 'd0;	
			div_res_req<= valid;
			div_rem_req<= 'd0;
			mull_req <= 'd0;
			mulh_req <= 'd0;
			end
			3'b110:begin
			signed_div <= valid;	
			signed_mult_num_1 <= 'd0;	
			signed_mult_num_2 <= 'd0;	
			div_res_req<= 'd0;
			div_rem_req<= valid;
			mull_req <= 'd0;
			mulh_req <= 'd0;
			end
			3'b111:begin
			signed_div <= 'd0;	
			signed_mult_num_1 <= 'd0;	
			signed_mult_num_2 <= 'd0;	
			div_res_req<= 'd0;
			div_rem_req<= valid;
			mull_req <= 'd0;
			mulh_req <= 'd0;
			end
			default:begin
			signed_div <= 'd0;	
			signed_mult_num_1 <= 'd0;	
			signed_mult_num_2 <= 'd0;	
			div_res_req<= 'd0;
			div_rem_req<= 'd0;
			mull_req <= 'd0;
			mulh_req <= 'd0;
			end
		endcase
	end 

endmodule
