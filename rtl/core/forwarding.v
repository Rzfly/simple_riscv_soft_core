
`include "include.v"

module forwarding_ex(
    input [`DATA_WIDTH - 1:0]rs1_data_ex,
    input [`DATA_WIDTH - 1:0]rs2_data_ex,
    input [`DATA_WIDTH - 1:0]wb_data_wb,
	input [`RS1_WIDTH -1:0]rs1_ex,
	input [`RS2_WIDTH -1:0]rs2_ex,
	input [`RD_WIDTH -1:0]rd_wb,
	input  write_reg_wb,
//	input  mem2reg_wb,
	output [`DATA_WIDTH - 1:0]rs1_data_forward,
	output [`DATA_WIDTH - 1:0]rs2_data_forward
);

	wire rs1_forward = (rd_wb == rs1_ex)? ( write_reg_wb & (|rd_wb) ):1'b0;
	wire rs2_forward = (rd_wb == rs2_ex)? ( write_reg_wb & (|rd_wb) ):1'b0;
	
//	wire [1:0]wb_source;
	assign rs1_data_forward = (rs1_forward)?wb_data_wb:rs1_data_ex;
	assign rs2_data_forward = (rs2_forward)?wb_data_wb:rs2_data_ex; 

endmodule

module forwarding_id(
    input [`DATA_WIDTH - 1:0]rs1_data_id,
    input [`DATA_WIDTH - 1:0]rs2_data_id,
    input [`DATA_WIDTH - 1:0]alu_output_ex,
    input [`DATA_WIDTH - 1:0]csr_read_data_ex,
    input [`DATA_WIDTH - 1:0]imm_ex,
    input csr_we_ex,
    input lui_type_ex,
	input [`RS1_WIDTH -1:0]rs1_id,
	input [`RS2_WIDTH -1:0]rs2_id,
	input [`RD_WIDTH -1:0]rd_ex,
	input  write_reg_ex,
//	input  mem2reg_wb,
	output reg [`DATA_WIDTH - 1:0]rs1_data_forward_id,
	output reg [`DATA_WIDTH - 1:0]rs2_data_forward_id
);

	wire rs1_forward = (rd_ex == rs1_id)? ( write_reg_ex & (|rd_ex) ):1'b0;
	wire rs2_forward = (rd_ex == rs2_id)? ( write_reg_ex & (|rd_ex) ):1'b0;
	wire [2:0]rs1_forward_mux_ex;
	wire [2:0]rs2_forward_mux_ex;
	assign rs1_forward_mux_ex = {rs1_forward, csr_we_ex, lui_type_ex};
	assign rs2_forward_mux_ex = {rs2_forward, csr_we_ex, lui_type_ex};
	
	always@(*)begin
	   case(rs1_forward_mux_ex)
	       3'b000:begin
	           rs1_data_forward_id = rs1_data_id;
	       end
	       3'b001:begin
	           rs1_data_forward_id = rs1_data_id;
	       end
	       3'b010:begin
	           rs1_data_forward_id = rs1_data_id;
	       end
	       3'b011:begin
	           rs1_data_forward_id = rs1_data_id;
	       end
	       //alu write
	       3'b100:begin
	           rs1_data_forward_id = alu_output_ex;
	       end
	       //lui
	       3'b101:begin
	           rs1_data_forward_id = imm_ex;
	       end
	       //
	       3'b110:begin
	           rs1_data_forward_id = csr_read_data_ex;
	       end
	       default:begin
	           rs1_data_forward_id = rs1_data_id;
	       end
	   endcase
	end
	
	always@(*)begin
	   case(rs2_forward_mux_ex)
	       3'b000:begin
	           rs2_data_forward_id = rs2_data_id;
	       end
	       3'b001:begin
	           rs2_data_forward_id = rs2_data_id;
	       end
	       3'b011:begin
	           rs2_data_forward_id = rs2_data_id;
	       end
	       3'b010:begin
	           rs2_data_forward_id = rs2_data_id;
	       end
	       //alu write
	       3'b100:begin
	           rs2_data_forward_id = alu_output_ex;
	       end
	       //lui
	       3'b101:begin
	           rs2_data_forward_id = imm_ex;
	       end
	       //
	       3'b110:begin
	           rs2_data_forward_id = csr_read_data_ex;
	       end
	       default:begin
	           rs2_data_forward_id = rs2_data_id;
	       end
	   endcase
	end
endmodule



module forwarding_id_simple(
    input [`DATA_WIDTH - 1:0]rs1_data_id,
    input [`DATA_WIDTH - 1:0]rs2_data_id,
    input [`DATA_WIDTH - 1:0]ex2wb_wdata,
    input to_wb_valid,
	input [`RS1_WIDTH -1:0]rs1_id,
	input [`RS2_WIDTH -1:0]rs2_id,
	input [`RD_WIDTH -1:0]rd_ex,
	input  write_reg_ex,
	output  [`DATA_WIDTH - 1:0]rs1_data_forward_id,
	output  [`DATA_WIDTH - 1:0]rs2_data_forward_id
);

	wire rs1_forward = (rd_ex == rs1_id)? ( write_reg_ex & to_wb_valid & (|rd_ex) ):1'b0;
	wire rs2_forward = (rd_ex == rs2_id)? ( write_reg_ex & to_wb_valid & (|rd_ex) ):1'b0;
	
	assign rs1_data_forward_id = (rs1_forward)?ex2wb_wdata:rs1_data_id;
	assign rs2_data_forward_id = (rs2_forward)?ex2wb_wdata:rs2_data_id;
	
endmodule
