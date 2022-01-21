
`include "include.v"


module csr_control(
	input csr_type,
	input [`FUNC3_WIDTH - 1:0]fun3,
	input [`CsrMemAddrWIDTH  -1:0]csr_addr_i,
	input [`DATA_WIDTH -1:0]wdata_imm,
	input [`DATA_WIDTH -1:0]wdata_rs,
	input [`DATA_WIDTH -1:0]rdata_i,
	output we,
	output [`CsrMemAddrWIDTH  -1:0]csr_addr_o,
	output reg [`DATA_WIDTH -1:0]wdata_o
);

	
	always@(*)begin
		case(fun3)
			//ecall ebreak
			3'b000:begin
				wdata_o <= 0;
			end
			//csrrw
			3'b001:begin
				wdata_o <= wdata_rs;
			end
			//csrrs
			//xxxxx | (11111) = 11111
			3'b010:begin
				wdata_o <= rdata_i | wdata_rs;
			end
			//csrrc
			//xxxxx & (~11011) = 00x00
			3'b011:begin
				wdata_o <= rdata_i & (~wdata_rs);
			end
			//csrrwi
			3'b101:begin
				wdata_o <= wdata_imm;
			end
			//csrrsi
			//xxxxx | (11111) = 11111
			3'b110:begin
				wdata_o <= rdata_i | wdata_imm;
			end
			//csrrci
			//xxxxx & (~11011) = 00x00
			3'b111:begin
				wdata_o <= rdata_i & (~wdata_imm);
			end
			default:begin
				wdata_o <= rdata_i;
			end	
		endcase
	end
	
	assign csr_addr_o = csr_addr_i;
	assign we = csr_type;
endmodule