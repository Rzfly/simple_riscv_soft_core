

`include "include.v"

module ex_mem(
    input clk,
    input rst_n,
    input flush,
    input hold,
//    input fence_type_ex,
    input mem_addr_ok,
    output ram_req,
    //as address
    input [`DATA_WIDTH - 1:0]mem_address_i,
    //as wdata
    input [`DATA_WIDTH - 1:0]mem_write_data_i,
    //note that width of instuction and data is not sure to be the same
    output [`BUS_WIDTH - 1:0]mem_address_o,
    output [`DATA_WIDTH - 1:0]mem_write_data_o,
    input [3:0]control_flow_ex,
    output [1:0]control_flow_mem,
    output mem_write,
    output mem_read,
    input [`RD_WIDTH - 1:0]rd_ex,
    output [`RD_WIDTH - 1:0]rd_mem,
    input fence_type_ex,
    output  fence_type_mem,
    input [2: 0]ins_func3_i,
    output [2: 0]ins_func3_o,
    //to next pipe
    input allow_in_wb,
    //processing
    output valid_mem,
    output ready_go_mem,
    //to pre pipe
    output allow_in_mem,
    //processing
    input valid_ex,
    input ready_go_ex
    );

    reg [2: 0]ins_func3;
    reg [`DATA_WIDTH - 1:0]reg_data;
    reg [`DATA_WIDTH - 1:0]mem_address;
    reg [3:0]control_flow;
    reg [`RD_WIDTH - 1:0]rd;
    reg fence_type;
    reg valid;
    wire pipe_valid;
//    wire hold_pipe;
//    assign hold_pipe = ~allow_in_wb | hold;
    wire ram_req_type;
    assign pipe_valid = valid_ex & ready_go_ex & (~flush);
    assign valid_mem = valid;    // decide pc pipe
//    assign ready_go_ex = ram_req & mem_addr_ok;
    assign ready_go_mem = ((ram_req & mem_addr_ok) || !ram_req_type )&& (!hold);
    assign ram_req =  allow_in_wb & (~hold) & ram_req_type & valid_mem;
    //related with valid
    assign ram_req_type =  (mem_read | mem_write);
    //if hold, 0 or 1 || 0;
    //or, store || pipe
    assign allow_in_mem = !(valid_mem) || ready_go_mem & allow_in_wb;
     
    always@(posedge clk or negedge rst_n)
    begin
        if ( ~rst_n )
        begin;
            valid <= 1'b0;
        end
        else if( allow_in_mem )begin
            valid <= pipe_valid;
        end
    end
    
    always@(posedge clk)
    begin
        if ( ~rst_n )
        begin;
            reg_data <= 0;
            mem_address <= 0;
            control_flow <= 0;
            rd <= 0;
            ins_func3 <= 0;
            fence_type <= 0;
        end
        else if (pipe_valid & allow_in_mem)begin
            reg_data <= mem_write_data_i;
            mem_address <= mem_address_i;
            control_flow <= control_flow_ex;
            rd <= rd_ex;
            ins_func3 <= ins_func3_i;
            fence_type <= fence_type_ex;
        end
    end
    
    assign  ins_func3_o  = ins_func3;
    assign  mem_write_data_o = reg_data;
    assign  mem_address_o = mem_address[`BUS_WIDTH - 1:0];
    assign  control_flow_mem = control_flow[1:0] & {2{valid_mem}};
    assign  rd_mem = rd;
    assign  mem_read = control_flow[3] & valid_mem;
    assign  mem_write = control_flow[2] & valid_mem;
    assign  fence_type_mem = fence_type & valid_mem;
    
endmodule