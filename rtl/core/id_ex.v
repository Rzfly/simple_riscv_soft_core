
`include "include.v"

module id_ex(
    input clk,
    input rst_n,
    input flush,
    input hold,
	input [`DATA_WIDTH - 1:0]rs2_data_id,
    output [`DATA_WIDTH - 1:0]rs2_data_ex,
	input [`DATA_WIDTH - 1:0]rs1_data_id,
    output [`DATA_WIDTH - 1:0]rs1_data_ex,
    input [`DATA_WIDTH - 1:0] imm_id,
    output [`DATA_WIDTH - 1:0] imm_ex,
    input [`DATA_WIDTH - 1:0]instruction_id,
    output [`DATA_WIDTH - 1:0]instruction_ex,
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
    input csr_type_id,
    output csr_type_ex,
    input [`ALU_CONTROL_CODE_WIDTH + 4 :0]control_flow_id,
    output jalr_ex,
    output auipc_ex,
    output branch_ex,
    output ALU_src_ex,
    output [3:0]control_flow_o,
    //to next pipe
    input allow_in_mem,
    //processing
    output valid_ex,
    output ready_go_ex,
    //to pre pipe
    output allow_in_ex,
    //processing
    input valid_id,
    input ready_go_id
);
	
    reg [`DATA_WIDTH - 1:0]rs2_data;
    reg [`DATA_WIDTH - 1:0]rs1_data;
    reg [`DATA_WIDTH - 1:0]imm;
    reg [`DATA_WIDTH - 1:0]instruction;
    reg [`ALU_OP_WIDTH - 1:0]alu_control;
    reg csr_type;
    reg jalr;
    reg auipc;
    reg branch;
    reg ALU_src;
    reg [3:0]control_flow;
    reg [`DATA_WIDTH - 1:0]pc;
    reg [`RD_WIDTH - 1:0] rd;
    reg [`RS2_WIDTH - 1:0] rs2;
    reg [`RS1_WIDTH - 1:0] rs1;
    
    assign rs1_data_ex = rs1_data;
    assign rs2_data_ex = rs1_data;
    assign rd_ex = rd;
    assign rs2_ex = rs2;
    assign rs1_ex = rs2;
    assign imm_ex = imm;
    assign instruction_ex = instruction;
    assign pc_ex = pc;
    assign csr_type_ex = csr_type;
    assign jalr_ex = jalr & valid_ex;
    assign auipc_ex = auipc & valid_ex;
    assign branch_ex = branch & valid_ex;
    assign ALU_src_ex = ALU_src & valid_ex;
    assign alu_control_ex = alu_control & {`ALU_OP_WIDTH{valid_ex}};
    assign control_flow_o = control_flow & {4{valid_ex}};
    
    reg valid;
    wire pipe_valid;
    wire hold_pipe;
    wire ram_req;
    assign hold_pipe = ~allow_in_mem | hold;
    assign pipe_valid = valid_id & ready_go_id & (~flush);
    assign valid_ex = valid;    // decide pc pipe
//    assign ram_req = pipe_valid & allow_in_mem & (~hold) & ();
//    assign ready_go_ex = ram_req & mem_addr_ok;
    assign ready_go_ex = 1'b1;
    //if hold, 0 or 1 || 0;
    //or, store || pipe
    assign allow_in_ex = !(valid_ex) || ready_go_ex & (~hold_pipe);
     
  always@(posedge clk or negedge rst_n)
    begin
        if ( ~rst_n )
        begin;
            valid <= 1'b0;
        end
        else if( allow_in_ex )begin
            valid <= pipe_valid;
        end
    end
    
    always@(posedge clk)
    begin
        if(pipe_valid & allow_in_ex)begin
            pc <= pc_id;
            rs1 <= rs1_id;
            rs2 <= rs2_id;
            rs2_data <= rs2_data_id;
            rs1_data <= rs1_data_id;
            imm <= imm_id;
            control_flow <= control_flow_id[3:0];
            rd <= rd_id;    
            jalr <= control_flow_id[7];
            auipc <= control_flow_id[6];
            branch <= control_flow_id[5];
            ALU_src <= control_flow_id[4];
            alu_control <= alu_control_id;
            csr_type <= csr_type_id;
            pc <= pc_id;
            instruction <= instruction_id;
        end
    end
    
endmodule
