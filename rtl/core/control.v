

`include "include.v"

module control(
	input [`DATA_WIDTH - 1:0]instruction,
	output reg write_reg,
	//reg data or imm data
	output reg  ALU_src,
	output reg [`ALU_CONTROL_CODE_WIDTH - 1: 0]ALU_control,
	output reg  mem2reg,
	output reg  read_mem,
	output reg  write_mem,
	//imm auipc or normal
	output reg  imm_shift,
	//imm long or short
	output reg  imm_src,
	output reg  branch,
	output reg  jalr,
	output reg  auipc,
	output reg  csr_type,
	output reg  fence_type,
	output [`OP_WIDTH - 1:0]ins_opcode,
	output [`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC7_WIDTH]ins_func7,
	output [`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC6_WIDTH]ins_func6,
	output [`DATA_WIDTH - `FUNC7_WIDTH - `RD_WIDTH - 1: `DATA_WIDTH - `FUNC7_WIDTH - `RD_WIDTH - `FUNC3_WIDTH]ins_func3,
	output [`RS2_WIDTH - 1: 0]rs2,
	output [`RS1_WIDTH - 1: 0]rs1,
	output [`RD_WIDTH - 1: 0]rd,
	output reg [`IMM_WIDTH - 1:0]imm_short,
	//for shift and or
	output reg [`DATA_WIDTH - 1:0]imm_long
);


    assign ins_opcode = instruction[`OP_WIDTH - 1:0];
    assign ins_func7 = instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC7_WIDTH];
    assign ins_func6 = instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC6_WIDTH];
    assign rs2 = instruction[`DATA_WIDTH - 1 - `FUNC7_WIDTH :`DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH];
    assign rs1 = instruction[`DATA_WIDTH - 1 - `FUNC7_WIDTH - `RS2_WIDTH :`DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH];
    assign ins_func3 = instruction[`DATA_WIDTH - 1 - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH : `DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH - `FUNC3_WIDTH];
    assign rd = instruction[`DATA_WIDTH - 1 - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH - `FUNC3_WIDTH: `DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH - `FUNC3_WIDTH - `RD_WIDTH];

    always@(*)begin
        case(ins_opcode)
            //add
           `R_TYPE:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b0;
                imm_shift  <= 1'b0;
                imm_src  <= 1'b0;
                branch <= 1'b0;
                auipc  <= 1'b0;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_R_TYPE;
                imm_short <= `IMM_WIDTH'd0;
                imm_long <= `DATA_WIDTH'd0;
            end
            //Lw
           `I_TYPE_LOAD:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b1;
                read_mem <= 1'b1;
                write_mem <= 1'b0;
                ALU_src  <= 1'b1;
                imm_shift  <= 1'b0;
                imm_src  <= 1'b0;
                branch <= 1'b0;
                auipc  <= 1'b0;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                //add rs as addr. no need to shift 
                ALU_control <= `ALU_CONTROL_I_TYPE_LOAD;
                imm_short <= instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
                imm_long <= `DATA_WIDTH'd0;
           end
            //addi
           `I_TYPE_ALUI:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b1;
                imm_src  <= 1'b0;
                imm_shift  <= 1'b0;
                branch <= 1'b0;
                auipc  <= 1'b0;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_I_TYPE_ALUI;
                //add rs
                imm_short <= instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
                imm_long <= `DATA_WIDTH'd0;
           end
           //jalr lowest address is set to 0
           `I_TYPE_JALR:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b1;
                imm_src  <= 1'b0;
                imm_shift  <= 1'b0;
                branch <= 1'b1;
                auipc  <= 1'b1;
                jalr  <= 1'b1;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_I_TYPE_JALR;
                // add rs no need to shift
                imm_short <= instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
                imm_long <= `DATA_WIDTH'd0;
           end
           //memory store
           `S_TYPE:begin
                write_reg <= 1'b0;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b1;
                ALU_src  <= 1'b1;
                imm_shift  <= 1'b0;
                imm_src  <= 1'b0;
                branch <= 1'b0;
                auipc  <= 1'b0;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_S_TYPE;
                //add rs2 no need to shift
                imm_short <= {instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC7_WIDTH],instruction[`OP_WIDTH + `RD_WIDTH - 1:`OP_WIDTH]};
                imm_long <= `DATA_WIDTH'd0;
           end
           //bne
           `SB_TYPE:begin
                write_reg <= 1'b0;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //����ʹ��alu����ƫ�Ƶ�ַ
                ALU_src  <= 1'b0;
                imm_src  <= 1'b0;
                imm_shift  <= 1'b1;
                branch <= 1'b1;
                auipc  <= 1'b0;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_SB_TYPE;
                imm_short <= {instruction[`DATA_WIDTH - 1],instruction[`OP_WIDTH],instruction[`DATA_WIDTH - 2:`DATA_WIDTH - 7],instruction[`OP_WIDTH + 4:`OP_WIDTH + 1]};
                //add pc. not shifted
                imm_long <= `DATA_WIDTH'd0;
           end
           //lui
           `U_TYPE:begin 
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //add imm by zero
                ALU_src  <= 1'b1;     
                //long imm
                imm_src  <= 1'b1;
                imm_shift  <= 1'b0;
                branch <= 1'b0;
                auipc  <= 1'b0;
                //for encoding
                jalr  <= 1'b1;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_U_TYPE;
                imm_short <= `IMM_WIDTH'd0;
                //lower bits neglected
                //no add. no shift
                imm_long <= {instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `JAL_IMM_WIDTH], 12'd0};
           end
           //AUIPC
           `AUIPC_TYPE:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //����ʹ��alu����ƫ�Ƶ�ַ
                ALU_src  <= 1'b1;      
                imm_src  <= 1'b1;
                imm_shift  <= 1'b0;
                branch <= 1'b0;
                auipc  <= 1'b1;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_AUIPC_TYPE;
                imm_short <= `IMM_WIDTH'd0;
                //lower bits remains to be added by pc
                //add pc no shift
                imm_long <= {instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `JAL_IMM_WIDTH], 12'd0};
           end
           //jal
          `UJ_TYPE:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //����ʹ��alu����ƫ�Ƶ�ַ
                ALU_src  <= 1'b1;     
                imm_src  <= 1'b1;
                imm_shift  <= 1'b1;
                branch <= 1'b1;
                auipc  <= 1'b1;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_UJ_TYPE;
                imm_short <= `IMM_WIDTH'd0;
                //11'd0, imm[20]. imm[19:12],imm[11],imm[10:1],0
                //12'd0, imm[20]. imm[19:12],imm[11],imm[10:1]
                //add pc.not shifted
                imm_long <= {12'd0,instruction[`DATA_WIDTH - 1],instruction[`DATA_WIDTH - `JAL_IMM_WIDTH + 7:`DATA_WIDTH - `JAL_IMM_WIDTH],instruction[`DATA_WIDTH - `JAL_IMM_WIDTH + 8],instruction[`DATA_WIDTH - 2:`DATA_WIDTH - 11]};
                //`DATA_WIDTH - 11 = `DATA_WIDTH - `JAL_IMM_WIDTH + 9 ? yes
            end
           `CSR_TYPE:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //����ʹ��alu����ƫ�Ƶ�ַ
                ALU_src  <= 1'b1;     
                imm_src  <= 1'b1;
                imm_shift  <= 1'b0;
                branch <= 1'b0;
                auipc  <= 1'b0;
                jalr  <= 1'b0;
                csr_type <= 1'b1;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_NOT_USED;
                imm_short <= instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
                imm_long <= {27'd0,instruction[`DATA_WIDTH - `IMM_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH - `RS2_WIDTH]};
           end
          `FENCE_TYPE:begin
//                write_reg <= 1'b0;
//                mem2reg <= 1'b0;
//                read_mem <= 1'b0;
//                write_mem <= 1'b0;
//                ALU_src  <=  1'b0; 
//                imm_src  <=  1'b0;
//                imm_shift  <= 1'b0;
//                branch <= 1'b0;
//                auipc  <= 1'b0;
//                jalr  <= 1'b0;
//                csr_type <= 1'b0;
//                fence_type <= 1'b1;
//                ALU_control <= `ALU_CONTROL_NOT_USED;
//                imm_short <= `IMM_WIDTH'd0;
//                imm_long <= `DATA_WIDTH'd0;
                write_reg <= 1'b0;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b0;     
                imm_src  <= 1'b0;
                imm_shift  <= 1'b0;
                branch <= 1'b0;
                auipc  <= 1'b0;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b1;
                ALU_control <= `ALU_CONTROL_NOT_USED;
                imm_short <= 12'h004;
                imm_long <= `DATA_WIDTH'd0;
           end
           default:begin
                write_reg <= 1'b0;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b0;    
                imm_shift  <= 1'b0;
                imm_src  <= 1'b0;
                auipc  <= 1'b0;
                branch <= 1'b0;
                jalr  <= 1'b0;
                csr_type <= 1'b0;
                fence_type <= 1'b0;
                ALU_control <= `ALU_CONTROL_NOT_USED;
                imm_short <= `IMM_WIDTH'd0;
                imm_long <= `DATA_WIDTH'd0;
            end
        endcase
    end
        
endmodule
