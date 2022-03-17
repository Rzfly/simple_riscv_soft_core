

`include "include.v"

module ex_mem(
    input clk,
    input rst_n,
    input flush,
    input hold,
//    input fence_type_ex,
    input mem_data_ok,
    //as address
    input [`DATA_WIDTH - 1:0]mem_address_i,
    //note that width of instuction and data is not sure to be the same
    output [`BUS_WIDTH - 1:0]mem_address_o,
    input [`DATA_WIDTH - 1:0]mem_read_data_i,
    output [`DATA_WIDTH - 1:0]mem_read_data_o,
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
    
    parameter state_leap  = 4'b0001;
    parameter state_empty = 4'b0010;
    parameter state_pipe  = 4'b0100;
    parameter state_full  = 4'b1000;
    reg [3:0] state;
    reg [3:0] next_state;
    wire pipe_ready;
    reg ram_data_valid;

    reg [2: 0]ins_func3;
    reg [`DATA_WIDTH - 1:0]mem_read_data;
    reg [`DATA_WIDTH - 1:0]mem_address_testtest;
    reg [3:0]control_flow;
    reg [`RD_WIDTH - 1:0]rd;
    reg fence_type;
    reg valid;
    wire pipe_valid;
    wire ram_req_type;
    wire hold_pipe;
     
    assign ram_req_type =  (mem_read | mem_write);
    assign pipe_ready = ((~ram_req_type) | (mem_data_ok & ram_req_type));
    assign hold_pipe = (~allow_in_wb) | hold;
    assign pipe_valid = valid_ex & ready_go_ex & (~flush);
    assign valid_mem = valid;    // decide pc pipe
    assign mem_read_data_o = (ram_data_valid)?mem_read_data:mem_read_data_i;
    // note there can be one more state ,but emited
    // write mem instruction becomes a bubble here
    assign ready_go_mem = (state[3]) || (pipe_ready & ( state[2] | state[1]));
    wire data_allow_in;
    //note when state[0], allow_in_wb = 0 but data_allow_in = 1
    assign data_allow_in = (!(valid_mem | ram_data_valid)) || (ready_go_mem) & (~hold_pipe);
    assign allow_in_mem =  next_state[1] || next_state[2];
    
    
    always@(posedge clk)begin
       if ( ~rst_n )begin
            state <= state_empty;
        end
        else begin
            state <= next_state;
        end
    end
    
    always @(*)begin
       case(state)
            // next stage hold or flush?
            // hold!because readygo = 0
            // next stage get valid = 0 because readygo = 0
            state_leap:begin
                if( mem_data_ok && ram_req_type )begin
                    next_state = state_empty;
                end
                else begin
                    next_state = state_leap;
                end
            end
            state_empty:begin
                if( pipe_ready && hold_pipe  && valid_mem && !(ram_data_valid))begin
                    next_state = state_full;
                end
                else if(pipe_ready && data_allow_in  && valid_mem && !(flush)) begin
                    next_state = state_pipe;
                end
                else if( ram_req_type && !(mem_data_ok) && flush  && valid_mem)begin
                    next_state = state_leap;
                end
                else begin
                    next_state = state_empty;
                end
            end
            state_pipe:begin
                if (!pipe_ready)begin
                    next_state = state_empty;
                end
//                else if( pipe_ready & hold_pipe & data_allow_in)begin
                else if( pipe_ready && hold_pipe && !(ram_data_valid))begin
                     next_state = state_full;
                end
                else begin
                    next_state = state_pipe;
                end
            end
            state_full:begin
            //note: if( flush & (hold_pipe) )  then state_full
            //flush becomes nop 
               if( !data_allow_in )begin
                    next_state = state_full;
                end
                else begin
                    next_state = state_empty;
                end
            end
            default:begin
                next_state = state_empty;
            end
       endcase
    end
    
    always@(posedge clk)
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
            mem_address_testtest <= 0;
            control_flow <= 0;
            rd <= 0;
            ins_func3 <= 0;
            fence_type <= 0;
        end
        else if (pipe_valid & allow_in_mem)begin
            mem_address_testtest <= mem_address_i;
            control_flow <= control_flow_ex;
            rd <= rd_ex;
            ins_func3 <= ins_func3_i;
            fence_type <= fence_type_ex;
        end
    end
    
    always@(posedge clk)
    begin
        if(~rst_n)begin
            ram_data_valid <=  1'b0;
            mem_read_data <= 0;
        end
        else if( flush )begin
            ram_data_valid <=  1'b0;
        end
        else if( next_state[3] && !(ram_data_valid))begin
            mem_read_data <= mem_read_data_i;
            ram_data_valid <= valid_mem;
        end
        else if( next_state[2] || next_state[1] ||  next_state[0])begin
            ram_data_valid <=  1'b0;
        end
        
    end
    assign  ins_func3_o  = ins_func3;
    assign  mem_address_o = mem_address_testtest[`BUS_WIDTH - 1:0];
    assign  control_flow_mem = control_flow[1:0] & {2{valid_mem}};
    assign  rd_mem = rd;
    assign  mem_read = control_flow[3] & valid_mem;
    assign  mem_write = control_flow[2] & valid_mem;
    assign  fence_type_mem = fence_type & valid_mem;
    
endmodule