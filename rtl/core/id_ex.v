
`include "include.v"

module id_ex(
    input clk,
    input rst_n,
    input flush,
    input hold,
    input mem_addr_ok,
    output ram_req,
    input [`DATA_WIDTH - 1:0]csr_read_data_id,
    output [`DATA_WIDTH - 1:0]csr_read_data_ex,
	input [`DATA_WIDTH - 1:0]rs2_data_id,
    output [`DATA_WIDTH - 1:0]rs2_data_ex,
	input [`DATA_WIDTH - 1:0]rs1_data_id,
    output [`DATA_WIDTH - 1:0]rs1_data_ex,
    input [`DATA_WIDTH - 1:0] imm_id,
    output [`DATA_WIDTH - 1:0] imm_ex,
    input [`DATA_WIDTH - 1:0]instruction_id,
    output [`DATA_WIDTH - 1:0]instruction_ex,
    input [`DATA_WIDTH - 1:0]csr_write_data_id,
    output [`DATA_WIDTH - 1:0]csr_write_data_ex,
    input [`RS2_WIDTH - 1:0] rs2_id,
    output [`RS2_WIDTH - 1:0] rs2_ex,
    input [`RS1_WIDTH - 1:0] rs1_id,
    output [`RS1_WIDTH - 1:0] rs1_ex,
    input [`RD_WIDTH - 1:0] rd_id,
    output [`RD_WIDTH - 1:0] rd_ex,
    input [`ALU_OP_WIDTH - 1:0]alu_control_id,
    output [`ALU_OP_WIDTH - 1:0]alu_control_ex,
    input [`DATA_WIDTH - 1:0]pc_id,
    output [`DATA_WIDTH - 1:0]pc_ex,
//    input [`BUS_WIDTH - 1:0] ram_address_ex,
//    output [`BUS_WIDTH - 1:0] ram_address,
    input [11:0]control_flow_id,
    input [3:0]int_ins_type_id,
    input [6:0]multdiv_control_id,
    output [6:0]multdiv_control_ex,
    output jal_ex,
    output jalr_ex,
    output auipc_ex,
    output branch_ex,
    output ALU_src_ex,
    output fence_type_ex,
    output csr_we_ex,
    output inst_ecall_type_ex,
	output inst_ebreak_type_ex,
	output inst_mret_type_ex,	
    output lui_type_ex,
    output [3:0]control_flow_ex,
    input allow_in_ex_commit,
    //to next pipe
    input allow_in_wb,
    //processing
    output valid_ex,
//    output ready_go_ex,
    //to pre pipe
//    output allow_in_ex,
    //processing
    input valid_id,
    input ready_go_id
);
	
    reg [`DATA_WIDTH - 1:0]rs2_data;
    reg [`DATA_WIDTH - 1:0]rs1_data;
    reg [`DATA_WIDTH - 1:0]csr_write_data;
    reg [`DATA_WIDTH - 1:0]csr_read_data;
    reg [`DATA_WIDTH - 1:0]imm;
    reg [`DATA_WIDTH - 1:0]instruction;
    reg [`ALU_OP_WIDTH - 1:0]alu_control;
    reg [6:0]multdiv_control;
    reg jalr;
    reg jal;
    reg auipc;
    reg branch;
    reg ALU_src;
    reg fence_type;
    reg csr_we;
    reg inst_ecall_type;
	reg inst_ebreak_type;
	reg inst_mret_type;
	
    reg lui_type;
    reg [3:0]control_flow;
    reg [`DATA_WIDTH - 1:0]pc;
    reg [`RD_WIDTH - 1:0] rd;
    reg [`RS2_WIDTH - 1:0] rs2;
    reg [`RS1_WIDTH - 1:0] rs1;

    reg valid;  
    assign rs1_data_ex = rs1_data;
    assign rs2_data_ex = rs2_data;
    assign rd_ex = rd;
    assign rs2_ex = rs2;
    assign rs1_ex = rs1;
    assign imm_ex = imm;
    assign instruction_ex = instruction;
    assign pc_ex = pc;
    assign lui_type_ex = lui_type & valid_ex;
    assign csr_we_ex = csr_we & valid_ex;
    assign jalr_ex = jalr & valid_ex;
    assign jal_ex = jal & valid_ex;
    assign auipc_ex = auipc & valid_ex;
    assign branch_ex = branch & valid_ex;
    assign ALU_src_ex = ALU_src & valid_ex;
    assign fence_type_ex = fence_type & valid_ex;
    assign inst_ecall_type_ex = inst_ecall_type  & valid_ex;
	assign inst_ebreak_type_ex = inst_ebreak_type  & valid_ex;
	assign inst_mret_type_ex = inst_mret_type  & valid_ex;
    assign alu_control_ex = alu_control & {`ALU_OP_WIDTH{valid_ex}};
    assign control_flow_ex = control_flow & {4{valid_ex}};
    assign csr_write_data_ex = csr_write_data;
    assign csr_read_data_ex = csr_read_data;
    assign multdiv_control_ex = multdiv_control & {7{valid_ex}};
    
    wire pipe_valid;
//    wire hold_pipe;
    wire ram_req_type;
    wire mem_read;
    wire mem_write;
    assign mem_read = control_flow_ex[3];
    assign mem_write = control_flow_ex[2];
    assign ram_req_type =  control_flow_ex[3] | control_flow_ex [2];
    
//    assign hold_pipe = !allow_in_wb || hold;
    assign pipe_valid = valid_id && ready_go_id && (!flush);
    assign valid_ex = valid;    // decide pc pipe
    assign ram_req =  allow_in_wb && (!hold) && ram_req_type && valid_ex;
//    assign ready_go_ex = (ram_req & mem_addr_ok) || (!ram_req_type && (!hold));
//    assign allow_in_ex = !(valid_ex) || (ready_go_ex && !hold_pipe);
//    assign ram_req = pipe_valid & allow_in_mem & (~hold) & ();
//    assign ready_go_ex = ram_req & mem_addr_ok;
//    assign ready_go_ex = ram_req & mem_addr_ok;
    //related with valid
    
    //generate nop
    //if hold, 0 or 1 || 0;
    //or, store || pipe
  always@(posedge clk)
    begin
        if ( ~rst_n )
        begin;
            valid <= 1'b0;
        end
        else if( allow_in_ex_commit )begin
            valid <= pipe_valid;
        end
    end
    
    always@(posedge clk)
    begin
        if ( ~rst_n )
        begin;
            pc <= 0;
            rs1 <= 0;
            rs2 <= 0;
            rs2_data <= 0;
            rs1_data <= 0;
            imm <= 0;
            control_flow <= 0;
            rd <= 0; 
            jal <= 0; 
            lui_type <= 0; 
            jalr <= 0;
            auipc <= 0;
            branch <= 0;
            ALU_src <= 0;
            alu_control <= 0;
            csr_we <= 0;
            inst_ecall_type <= 0;
            inst_ebreak_type <= 0;
            inst_mret_type <= 0;
            pc <= 0;
            instruction <= 0;
            fence_type  <= 0;
            csr_write_data <= 0;
            csr_read_data <= 0;
            multdiv_control <= 0;
        end
        else if(pipe_valid & allow_in_ex_commit)begin
            pc <= pc_id;
            rs1 <= rs1_id;
            rs2 <= rs2_id;
            rs2_data <= rs2_data_id;
            rs1_data <= rs1_data_id;
            imm <= imm_id;
            rd <= rd_id;    
            inst_ecall_type <= int_ins_type_id[3];
            inst_ebreak_type <= int_ins_type_id[2];
            inst_mret_type <= int_ins_type_id[1];
            lui_type <= control_flow_id[11];
            csr_we <= control_flow_id[10];
            jal <= control_flow_id[9];
            fence_type  <= control_flow_id[8];
            jalr <= control_flow_id[7];
            auipc <= control_flow_id[6];
            branch <= control_flow_id[5];
            ALU_src <= control_flow_id[4];
            control_flow <= control_flow_id[3:0];
            alu_control <= alu_control_id;
            multdiv_control <= multdiv_control_id;
            instruction <= instruction_id;
            csr_write_data <= csr_write_data_id;
            csr_read_data <= csr_read_data_id;
        end
    end
    
    
//        wire [11:0]control_flow_id;
//    assign control_flow_id = {lui_type_id, csr_type_id, jal_id,fence_type_id,jalr_id,auipc_id,branch_id,ALU_src_id,read_mem_id,write_mem_id,mem2reg_id,write_reg_id};
    
    
    
endmodule
