

`include "include.v"

module mem_wb(
    input clk,
    input rst_n,
    input hold,
    input flush,
    input mem_data_ok,
    input [`DATA_WIDTH - 1:0]mem_read_data_i,
    input [`BUS_WIDTH - 1:0] mem_address_i,
    input [`RD_WIDTH - 1:0]  rd_mem,
    input [1:0]control_flow_i,
    output [`BUS_WIDTH - 1:0] mem_address_o,
    output [`DATA_WIDTH - 1:0]mem_read_data_o,
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

    parameter state_leap  = 4'b0001;
    parameter state_empty = 4'b0010;
    parameter state_pipe  = 4'b0100;
    parameter state_full  = 4'b1000;
    reg [`DATA_WIDTH - 1:0]mem_address;
    reg [`DATA_WIDTH - 1:0]mem_read_data;
    reg [1:0]control_flow;
    reg [`RD_WIDTH - 1:0]rd;
    reg [2:0]ins_func3;

    reg valid;
    reg ram_data_valid;
    reg [3:0] state;
    reg [3:0] next_state;
    wire pipe_valid;
    wire hold_pipe;
    wire mem_ready;
    wire ram_req_type;
    assign ram_req_type = mem2reg;
    assign mem_ready = (~ram_req_type) | (mem_data_ok & ram_req_type);
    assign hold_pipe = (~allow_in_regfile) | hold;
    assign pipe_valid = valid_mem & ready_go_mem & (~flush);
    assign valid_wb = valid;    // decide pc pipe
    assign mem_read_data_o = (ram_data_valid)?mem_read_data:mem_read_data_i;
    // note there can be one more state ,but emited
    assign ready_go_wb = (state[3]) || (mem_data_ok & ( state[2] | state[1]));
    wire data_allow_in;
    //note when state[0], allow_in_wb = 0 but data_allow_in = 1
    assign data_allow_in = (!(valid_wb | ram_data_valid)) || (ready_go_wb) & (~hold_pipe);
    assign allow_in_wb =  next_state[1] || next_state[2];
    //next_state[1] || next_state[2]
//    assign allow_in_wb = (!(valid_wb | ram_data_valid)) || (state[1]) & (~flush) || ((state[2] | state[3]) & (~hold_pipe));
//    assign allow_in_wb = (!(valid_wb | ram_data_valid)) || next_state[1] || next_state[2];
      
    assign mem_address_o = mem_address[`BUS_WIDTH - 1:0];
    assign ins_func3_o = ins_func3;
    assign mem2reg = control_flow[1] & valid_wb;
    //valid for flush£¬ not for write valid
    assign write_reg = control_flow[0] & valid_wb & mem_ready;
    assign rd_wb = rd;
    

    always@(posedge clk or negedge rst_n)begin
       if ( ~rst_n )begin
            state <= 1'b0;
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
                if( mem_data_ok & ram_req_type )begin
                    next_state = state_empty;
                end
                else begin
                    next_state = state_leap;
                end
            end
            state_empty:begin
                if( mem_ready & hold_pipe & data_allow_in)begin
                    next_state = state_full;
                end
                else if(mem_ready & data_allow_in & (~flush)) begin
                    next_state = state_pipe;
                end
                else if( ram_req_type & (~mem_data_ok) & flush)begin
                    next_state = state_leap;
                end
                else begin
                    next_state = state_empty;
                end
            end
            state_pipe:begin
                if (!mem_ready)begin
                    next_state = state_empty;
                end
                else if( mem_ready & hold_pipe & data_allow_in)begin
                    next_state = state_full;
                end
                else begin
                    next_state = state_pipe;
                end
            end
            state_full:begin
            //note: if( flush & (hold_pipe) )  then state_full
               if( !data_allow_in )begin
                    next_state = state_full;
                end
                else begin
                    next_state = state_empty;
                end
            end
       endcase
    end
        
    always@(posedge clk or negedge rst_n)
    begin
        if ( ~rst_n )
        begin;
            valid <= 1'b0;
        end
        //else if( next_state[1] || next_state[2] || next_state[3] )begin
        //if  next_state[3] and next instruction is flush? pass.
        //if  next_state[3] and next instruction is not flush? then ram type is flushed. not pass.
        //if( next_state[1] || next_state[2]  )begin
        //if  next_state[3] and next instruction is flush? flush failed not pass.
        //if  next_state[3] and next instruction is not flush? hold ram type pass..
        //if( allow_in_wb)begin
        //if  next_state[3] and next instruction is flush? reflush dose not clear valid. pass.
        //if  next_state[3] and next instruction is not flush? hold ram type pass..
        else if( allow_in_wb )begin
            valid <= pipe_valid;
        end
    end
    
    always@(posedge clk)
    begin
        if(pipe_valid && allow_in_wb)begin
            mem_address <= mem_address_i;
            control_flow <= control_flow_i;
            rd <= rd_mem;
            ins_func3 <= ins_func3_i;
        end
    end
    
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
            ram_data_valid <=  1'b0;
        end
        else if( flush )begin
            ram_data_valid <=  1'b0;
        end
        else if( next_state[3] && !(ram_data_valid))begin
            mem_read_data <= mem_read_data_i;
            ram_data_valid <= valid_wb;
        end
        else if( next_state[2] || next_state[1] ||  next_state[0])begin
            ram_data_valid <=  1'b0;
        end
        
    end
    
endmodule