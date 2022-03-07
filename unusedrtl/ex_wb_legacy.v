

`include "include.v"

module ex_wb_legacy(
    input clk,
    input rst_n,
    input cancel,
    input hold,
//    input fence_type_ex,
    input mem_data_ok,
    input mem_addr_ok,
    output data_ok_resp,
    //as address
    input [`DATA_WIDTH - 1:0]mem_address_i,
    //note that width of instuction and data is not sure to be the same
    input [`DATA_WIDTH - 1:0]mem_read_data_i,
    output reg [`DATA_WIDTH - 1:0]  wb_data_wb,
    input [3:0]control_flow_ex,
    output mem_write,
    output mem_read,
    output mem2reg_wb,
    output write_reg_wb,
    input [`RD_WIDTH - 1:0]rd_ex,
    output [`RD_WIDTH - 1:0]rd_wb,
    input fence_type_ex,
    output  fence_type_wb,
    input [2: 0]ins_func3_i,
    //to next pipe
    input allow_in_regfile,
    //processing
    output valid_wb,
    output ready_go_wb,
    //to pre pipe
    output allow_in_wb,
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
    reg [`DATA_WIDTH - 1:0]mem_read_data_reg;
    wire [`DATA_WIDTH - 1:0]mem_read_data_o;
    reg [`DATA_WIDTH - 1:0]mem_address_testtest;
    wire [`DATA_WIDTH - 1 :0]ram_rdata_mem_mask;
    wire [`DATA_WIDTH - 1 :0]ram_rdata_reg_mask;
    wire [1:0]mem_raddr_index;
    wire [1:0]wb_source;
    reg [3:0]control_flow;
    reg [`RD_WIDTH - 1:0]rd;
    reg fence_type;
    reg valid;
    wire pipe_valid;
    wire ram_req_type;
    wire hold_pipe;


    assign data_ok_resp = 1'b1;
    //mem2reg
    assign wb_source = {control_flow[1],ram_data_valid};
    assign mem_raddr_index = mem_address_testtest[1:0];
    always@(*)begin
        case(wb_source)
            2'b00:begin
                wb_data_wb <= mem_address_testtest;
            end
            2'b01:begin
                wb_data_wb <= mem_address_testtest;
            end
            2'b10:begin
                wb_data_wb <= ram_rdata_mem_mask;
            end
            2'b11:begin
                wb_data_wb <= ram_rdata_reg_mask;
            end
            default:begin
                wb_data_wb <= mem_address_testtest;
            end
        endcase
    end
    
    
    assign  rd_wb  = rd;
//    assign  mem_address_o = mem_address_testtest[`BUS_WIDTH - 1:0];;
    assign  mem2reg_wb = control_flow[1]  && valid_wb;
    assign  write_reg_wb = control_flow[0]  && valid_wb;
    assign  fence_type_wb = fence_type & valid_wb;
    
    assign ram_req_type =  ( control_flow[3] |  control_flow[2]);
    assign pipe_ready = ((!ram_req_type) || (mem_data_ok && ram_req_type)) && (!cancel);
    assign hold_pipe = (!allow_in_regfile) || hold;
    assign pipe_valid = valid_ex && ready_go_ex;
    assign valid_wb = valid ;    // decide pc pipe
    assign mem_read_data_o = (ram_data_valid)?mem_read_data_reg:mem_read_data_i;
    // note there can be one more state ,but emited
    // write mem instruction becomes a bubble here
    assign ready_go_wb = (state[3]) || (pipe_ready & ( state[2] | state[1]));
    wire data_allow_in;
    //note when state[0], allow_in_wb = 0 but data_allow_in = 1
    assign data_allow_in = (!(valid_wb || ram_data_valid)) || ((ready_go_wb) && (!hold_pipe));
    assign allow_in_wb =  next_state[1] || next_state[2];
    
    
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
                if( pipe_ready && hold_pipe  && valid_wb && !(ram_data_valid))begin
                    next_state = state_full;
                end
                else if(pipe_ready && data_allow_in  && valid_wb) begin
                    next_state = state_pipe;
                end
                else if( ram_req_type && !(mem_data_ok)  && valid  &&  cancel )begin
                    next_state = state_leap;
                end
                else begin
                    next_state = state_empty;
                end
            end
            state_pipe:begin
                if( ram_req_type && !(mem_data_ok)  && valid  &&  cancel )begin
                    next_state = state_leap;
                end
                else if (!pipe_ready)begin
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
               if( !data_allow_in && !cancel)begin
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
        else if( allow_in_wb )begin
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
        else if (pipe_valid & allow_in_wb)begin
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
            mem_read_data_reg <= 0;
        end
        else if( next_state[3] && !(ram_data_valid))begin
            mem_read_data_reg <= mem_read_data_i;
            ram_data_valid <= valid_wb;
        end
        else if( next_state[2] || next_state[1] ||  next_state[0])begin
            ram_data_valid <=  1'b0;
        end
        
    end
    
    ram_rdata_mask ram_rdata_mask_inst1(
        .mem_raddr_index(mem_raddr_index),
        .mem_read_data(mem_read_data_i),
        .mask_type(ins_func3),
        .mem_read_data_mask(ram_rdata_mem_mask)
    );
    ram_rdata_mask ram_rdata_mask_inst2(
        .mem_raddr_index(mem_raddr_index),
        .mem_read_data(mem_read_data_reg),
        .mask_type(ins_func3),
        .mem_read_data_mask(ram_rdata_reg_mask)
    );
    
endmodule