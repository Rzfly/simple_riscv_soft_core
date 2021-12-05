

`include "include.v"

module control(
	input [`DATA_WIDTH - 1:0]instruction,
	output reg write_reg,
	output reg  ALU_src,
	output reg [`ALU_CONTROL_CODE_WIDTH - 1: 0]ALU_control,
	output reg  mem2reg,
	output reg  read_mem,
	output reg  write_mem,
	output reg  imm_src,
	output [`OP_WIDTH - 1:0]ins_opcode,
	output [`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC7_WIDTH]ins_func7,
	output [`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC6_WIDTH]ins_func6,
	output [`DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH : `DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH - `FUNC3_WIDTH]ins_func3,
	output reg [`IMM_WIDTH - 1:0]imm_short,
	//for shift and or
	output reg [`DATA_WIDTH - 1:0]imm_long
);

    assign ins_opcode = instruction[`OP_WIDTH - 1:0];
    assign ins_func7 = instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC7_WIDTH];
    assign ins_func6 = instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `FUNC6_WIDTH];
    assign ins_func3 = instruction[`DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH : `DATA_WIDTH - `FUNC7_WIDTH - `RS2_WIDTH - `RS1_WIDTH - `FUNC3_WIDTH];
    
    `define ALU_CONTROL_R_TYPE      3'b000
`define ALU_CONTROL_I_TYPE_LOAD 3'b001
`define ALU_CONTROL_I_TYPE_ALUI 3'b010
`define ALU_CONTROL_I_TYPE_JALR 3'b011
`define ALU_CONTROL_S_TYPE      3'b100
`define ALU_CONTROL_SB_TYPE     3'b101
`define ALU_CONTROL_U_TYPE      3'b110
`define ALU_CONTROL_AUIPC_TYPE  3'b111

    always@(*)begin
        case(ins_opcode)
           `R_TYPE:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b0;
                imm_src  <= 1'b0;
                ALU_control <= `ALU_CONTROL_R_TYPE;
                imm_short <= `IMM_WIDTH'd0;
                imm_long <= `DATA_WIDTH'd0;
            end
           `I_TYPE_LOAD:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b1;
                read_mem <= 1'b1;
                write_mem <= 1'b0;
                ALU_src  <= 1'b1;
                imm_src  <= 1'b0;
                //add rs as addr
                ALU_control <= `ALU_CONTROL_I_TYPE_LOAD;
                imm_short <= instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
                imm_long <= `DATA_WIDTH'd0;
           end
           `I_TYPE_ALUI:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b1;
                imm_src  <= 1'b0;
                ALU_control <= `ALU_CONTROL_I_TYPE_ALUI;
                //add rs
                imm_short <= instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
                imm_long <= `DATA_WIDTH'd0;
           end
           `I_TYPE_JALR:begin
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b1;
                imm_src  <= 1'b0;
                ALU_control <= `ALU_CONTROL_I_TYPE_JALR;
                // add rs
                imm_short <= instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `IMM_WIDTH];
                imm_long <= `DATA_WIDTH'd0;
           end
           `S_TYPE:begin//sh
                write_reg <= 1'b0;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b1;
                ALU_src  <= 1'b1;
                imm_src  <= 1'b0;
                ALU_control <= `ALU_CONTROL_S_TYPE;
                //add rs
                imm_short <= {instruction[`DATA_WIDTH - 1:`DATA_WIDTH - 7],instruction[`OP_WIDTH + 4:`OP_WIDTH]};
                imm_long <= `DATA_WIDTH'd0;
           end
           `SB_TYPE:begin
                write_reg <= 1'b0;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //����ʹ��alu����ƫ�Ƶ�ַ
                ALU_src  <= 1'b1;
                imm_src  <= 1'b0;
                imm_short <= `IMM_WIDTH'd0;
                ALU_control <= `ALU_CONTROL_SB_TYPE;
                // 20'd0 imm12 imm11 imm[10:5] imm[4:1]
                //add pc shift
                imm_long <= { 20'd0, instruction[`DATA_WIDTH - 1],instruction[`OP_WIDTH],instruction[`DATA_WIDTH - 2:`DATA_WIDTH - 7],instruction[`OP_WIDTH + 4:`OP_WIDTH + 1]};
           end
           `U_TYPE:begin //lui
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //not used or add imm by zero
                ALU_src  <= 1'b1;     
                imm_src  <= 1'b0;
                ALU_control <= `ALU_CONTROL_U_TYPE;
                imm_short <= `IMM_WIDTH'd0;
                //lower bits neglected
                //no add no shift
                imm_long <= {instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `JAL_IMM_WIDTH], 12'd0};
           end
           `AUIPC_TYPE:begin//AUIPC
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //����ʹ��alu����ƫ�Ƶ�ַ
                ALU_src  <= 1'b1;      
                imm_src  <= 1'b1;
                ALU_control <= `ALU_CONTROL_AUIPC_TYPE;
                imm_short <= `IMM_WIDTH'd0;
                //lower bits remains to be added by pc
                //add pc no shift
                imm_long <= {instruction[`DATA_WIDTH - 1:`DATA_WIDTH - `JAL_IMM_WIDTH], 12'd0};
           end
          `UJ_TYPE:begin//jal
                write_reg <= 1'b1;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                //����ʹ��alu����ƫ�Ƶ�ַ
                ALU_src  <= 1'b1;     
                imm_src  <= 1'b0;
                ALU_control <= `ALU_CONTROL_UJ_TYPE;
                imm_short <= `IMM_WIDTH'd0;
                //11'd0, imm[20]. imm[19:12],imm[11],imm[10:1],0
                //12'd0, imm[20]. imm[19:12],imm[11],imm[10:1]
                //add pc shift
                imm_long <= {12'd0,instruction[`DATA_WIDTH - 1],instruction[`DATA_WIDTH - `JAL_IMM_WIDTH + 7:`DATA_WIDTH - `JAL_IMM_WIDTH],instruction[`DATA_WIDTH - `JAL_IMM_WIDTH + 8],instruction[`DATA_WIDTH - 2:`DATA_WIDTH - 11]};
                //`DATA_WIDTH - 11 = `DATA_WIDTH - `JAL_IMM_WIDTH + 9 ? yes
            end
           default:begin
                write_reg <= 1'b0;
                mem2reg <= 1'b0;
                read_mem <= 1'b0;
                write_mem <= 1'b0;
                ALU_src  <= 1'b0;    
                imm_src  <= 1'b0;
                ALU_control <= `ALU_CONTROL_NOT_USED;
                imm_short <= `IMM_WIDTH'd0;
                imm_long <= `DATA_WIDTH'd0;
            end
        endcase
    end
        
        
endmodule

//                case(ins_func3)
//                2'b000:begin
//                      case(ins_func7)
//                      //ADD
//                        2'b0000000:begin
//                            write_reg = 1'b1;
//                        end
//                      //SUB
//                        2'b0100000:begin
//                        end
//                        endcase
//                end

//                endcase
                