
`include "include.v"

module id_ex(
    input clk,
    input rst_n,
    input flush,
    input hold,
    input mem_addr_ok,
    output ram_req,
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
    input csr_type_id,
    output csr_type_ex,
    input [8 :0]control_flow_id,
    output jalr_ex,
    output auipc_ex,
    output branch_ex,
    output ALU_src_ex,
    input fence_type_id,
    output fence_type_ex,
    output [3:0]control_flow_ex,
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
    reg [`DATA_WIDTH - 1:0]csr_write_data;
    reg [`DATA_WIDTH - 1:0]imm;
    reg [`DATA_WIDTH - 1:0]instruction;
    reg [`ALU_OP_WIDTH - 1:0]alu_control;
    reg csr_type;
    reg jalr;
    reg auipc;
    reg branch;
    reg ALU_src;
    reg fence_type;
    reg [3:0]control_flow;
    reg [`DATA_WIDTH - 1:0]pc;
    reg [`RD_WIDTH - 1:0] rd;
    reg [`RS2_WIDTH - 1:0] rs2;
    reg [`RS1_WIDTH - 1:0] rs1;
    
    assign rs1_data_ex = rs1_data;
    assign rs2_data_ex = rs2_data;
    assign rd_ex = rd;
    assign rs2_ex = rs2;
    assign rs1_ex = rs1;
    assign imm_ex = imm;
    assign instruction_ex = instruction;
    assign pc_ex = pc;
    assign csr_type_ex = csr_type & valid_ex;
    assign jalr_ex = jalr & valid_ex;
    assign auipc_ex = auipc & valid_ex;
    assign branch_ex = branch & valid_ex;
    assign ALU_src_ex = ALU_src & valid_ex;
    assign fence_type_ex = fence_type & valid_ex;
    assign alu_control_ex = alu_control & {`ALU_OP_WIDTH{valid_ex}};
    assign control_flow_ex = control_flow & {4{valid_ex}};
    assign csr_write_data_ex = csr_write_data;
    
    reg valid;
    wire pipe_valid;
//    wire hold_pipe;
//    assign hold_pipe = ~allow_in_mem | ;
    wire ram_req_type;
    wire mem_read;
    wire mem_write;
    assign mem_read = control_flow_ex[3];
    assign mem_write = control_flow_ex[2];
    assign ram_req_type =  (mem_read | mem_write);
    
    assign pipe_valid = valid_id & ready_go_id & (~flush);
    assign valid_ex = valid;    // decide pc pipe
    assign ready_go_ex = ((ram_req & mem_addr_ok) || !ram_req_type )&& (!hold);
    assign ram_req =  allow_in_mem & (~hold) & ram_req_type & valid_ex;
    assign allow_in_ex = !(valid_ex) || ready_go_ex & allow_in_mem;
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
        else if( allow_in_ex )begin
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
            jalr <= 0;
            auipc <= 0;
            branch <= 0;
            ALU_src <= 0;
            alu_control <= 0;
            csr_type <= 0;
            pc <= 0;
            instruction <= 0;
            fence_type  <= 0;
            csr_write_data <= 0;
        end
        else if(pipe_valid & allow_in_ex)begin
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
            fence_type  <= fence_type_id;
            instruction <= instruction_id;
            csr_write_data <= csr_write_data_id;
        end
    end
    
endmodule
