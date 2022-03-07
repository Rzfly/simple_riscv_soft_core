

`include "include.v"

module mem_wb(
    input clk,
    input rst_n,
    input hold,
    input flush,
    input [`DATA_WIDTH - 1:0]mem_read_data_i,
    output [`DATA_WIDTH - 1:0]mem_read_data_o,
    input [`BUS_WIDTH - 1:0] mem_address_i,
    output [`BUS_WIDTH - 1:0] mem_address_o,
    input [`RD_WIDTH - 1:0]  rd_mem,
    input [1:0]control_flow_mem,
    output write_reg,
    output mem2reg,
    output [`RD_WIDTH - 1:0]rd_wb,
    input [2:0]ins_func3_i,
    output [2:0]ins_func3_o,
    //to pre pipe
    output allow_in_wb,
    //processing
    input valid_mem,
    input ready_go_mem,
    //to next pipe
    input allow_in_regfile,
    //processing
    output valid_wb,
    output ready_go_wb
);

    reg valid;
    wire pipe_valid;
    assign pipe_valid = valid_mem & ready_go_mem & (~flush);
    assign valid_wb = valid;   
    assign ready_go_wb = !hold;  
    assign allow_in_wb =  !(valid_wb) || ready_go_wb & (allow_in_regfile);
    
    reg [`DATA_WIDTH - 1:0]mem_address;
    reg [`DATA_WIDTH - 1:0]mem_read_data;
    reg [1:0]control_flow;
    reg [`RD_WIDTH - 1:0]rd;
    reg [2:0]ins_func3;
    reg fence_type;
    assign mem_address_o = mem_address[`BUS_WIDTH - 1:0];
    assign mem_read_data_o = mem_read_data;
    assign ins_func3_o = ins_func3;
    assign mem2reg = control_flow[1] & valid_wb;
    //valid for flush£¬ not for write valid
    assign write_reg = control_flow[0] & valid_wb;
    assign rd_wb = rd;
    
    always@(posedge clk)
    begin
        if ( ~rst_n )
        begin;
            valid <= 1'b0;
        end
        else if( allow_in_wb )begin
            valid <= pipe_valid;
        end
    end
    
    always@(posedge clk)
    begin
        if( ~rst_n )begin
            mem_address <= 0;
            control_flow <=  0;
            rd <=  0;
            ins_func3 <=  0;
            mem_read_data <= 0;
        end
        else if(pipe_valid && allow_in_wb)begin
            mem_address <= mem_address_i;
            control_flow <= control_flow_mem;
            rd <= rd_mem;
            ins_func3 <= ins_func3_i;
            mem_read_data <= mem_read_data_i; 
        end
    end
    
endmodule