
`include "include.v"


module csr_control(
	input csr_type_id,
	input [`FUNC3_WIDTH - 1:0]fun3,
	input [`DATA_WIDTH -1:0]wdata_imm,
	input [`DATA_WIDTH -1:0]wdata_rs,
	input [`DATA_WIDTH -1:0]rdata_i,
	input [`CsrMemAddrWIDTH - 1:0] csr_addr_id,
	output reg  csr_we,
	output reg  inst_ecall_type,
	output reg  inst_ebreak_type,
	output reg  inst_mret_type,	
	output reg  inst_wfi,	
	output reg [`DATA_WIDTH -1:0]wdata_o
);

	
	always@(*)begin
		case(fun3)
			//ecall ebreak
			3'b000:begin
				wdata_o <= 0;
				csr_we <= 0;
				begin
                    case(csr_addr_id) 
                        12'h000:begin
                            inst_ecall_type <= csr_type_id;
                            inst_ebreak_type <= 1'b0;
                            inst_mret_type <= 1'b0;
                            inst_wfi <= 1'b0;
                        end
                        12'h001:begin
                            inst_ecall_type <= 1'b0;
                            inst_ebreak_type <= csr_type_id;
                            inst_mret_type <= 1'b0;
                            inst_wfi <= 1'b0;
                        end
                        12'h002:begin
                            inst_ecall_type <= 1'b0;
                            inst_ebreak_type <= 1'b0;
                            inst_mret_type <= csr_type_id;
                            inst_wfi <= 1'b0;
                        end
                        12'h102:begin
                            inst_ecall_type <= 1'b0;
                            inst_ebreak_type <= 1'b0;
                            inst_mret_type <= csr_type_id;
                            inst_wfi <= 1'b0;
                        end
                        12'h302:begin
                            inst_ecall_type <= 1'b0;
                            inst_ebreak_type <= 1'b0;
                            inst_mret_type <= csr_type_id;
                            inst_wfi <= 1'b0;
                        end
                        12'h105:begin
                            inst_ecall_type <= 1'b0;
                            inst_ebreak_type <= 1'b0;
                            inst_mret_type <= 1'b0;
                            inst_wfi <= csr_type_id;
                        end
                        default:begin
                            inst_ecall_type <= 1'b0;
                            inst_ebreak_type <= 1'b0;
                            inst_mret_type <= 1'b0;
                            inst_wfi <= 1'b0;
                        end
                    endcase
				end
			end
			//csrrw
			3'b001:begin
				wdata_o <= wdata_rs;
				csr_we <= csr_type_id;
                inst_ecall_type <= 1'b0;
                inst_ebreak_type <= 1'b0;
                inst_mret_type <= 1'b0;
                inst_wfi <= 1'b0;
			end
			//csrrs
			//xxxxx | (11111) = 11111
			3'b010:begin
				wdata_o <= rdata_i | wdata_rs;
				csr_we <= csr_type_id;
                inst_ecall_type <= 1'b0;
                inst_ebreak_type <= 1'b0;
                inst_mret_type <= 1'b0;
                inst_wfi <= 1'b0;
			end
			//csrrc
			//xxxxx & (~11011) = 00x00
			3'b011:begin
				wdata_o <= rdata_i & (~wdata_rs);
				csr_we <= csr_type_id;
                inst_ecall_type <= 1'b0;
                inst_ebreak_type <= 1'b0;
                inst_mret_type <= 1'b0;
                inst_wfi <= 1'b0;
			end
			//csrrwi
			3'b101:begin
				wdata_o <= wdata_imm;
				csr_we <= csr_type_id;
                inst_ecall_type <= 1'b0;
                inst_ebreak_type <= 1'b0;
                inst_mret_type <= 1'b0;
                inst_wfi <= 1'b0;
			end
			//csrrsi
			//xxxxx | (11111) = 11111
			3'b110:begin
				wdata_o <= rdata_i | wdata_imm;
				csr_we <= csr_type_id;
                inst_ecall_type <= 1'b0;
                inst_ebreak_type <= 1'b0;
                inst_mret_type <= 1'b0;
                inst_wfi <= 1'b0;
			end
			//csrrci
			//xxxxx & (~11011) = 00x00
			3'b111:begin
				wdata_o <= rdata_i & (~wdata_imm);
				csr_we <= csr_type_id;
                inst_ecall_type <= 1'b0;
                inst_ebreak_type <= 1'b0;
                inst_mret_type <= 1'b0;
                inst_wfi <= 1'b0;
			end
			default:begin
				wdata_o <= rdata_i;   
				csr_we <= 0;
                inst_ecall_type <= 1'b0;
                inst_ebreak_type <= 1'b0;
                inst_mret_type <= 1'b0;
                inst_wfi <= 1'b0;
			end	
		endcase
	end
	
endmodule