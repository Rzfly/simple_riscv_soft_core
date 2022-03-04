

`include "include.v"

module ex_wb(
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
    output write_reg_wb,
    input [3:0]control_flow_ex,
    output mem_write,
    output mem_read,
    output mem2reg_wb,
    output wb2reg_valid,
    output forwording_invalid,
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
    
//    parameter state_leap  = 4'b0001;
//    parameter state_empty = 4'b0010;
//    parameter state_pipe  = 4'b0100;
//    parameter state_full  = 4'b1000;
//    reg [3:0] state;
//    reg [3:0] next_state;
    parameter state_leap  = 3'b001;
    parameter state_empty = 3'b010;
    parameter state_full  = 3'b100;
    reg [2:0] state;
    reg [2:0] next_state;
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
    wire pipe_valid;

    wire req_ok;
    wire commit_ok;
    assign req_ok    = pipe_valid && allow_in_wb;
    assign commit_ok = ready_go_wb && allow_in_regfile;
    assign wb2reg_valid = ready_go_wb && valid_wb;
    assign forwording_invalid = !ready_go_wb && write_reg_wb;
    
    assign data_ok_resp = 1'b1;
    assign pipe_valid = valid_ex && ready_go_ex ;
    // not related with flush
    assign ready_go_wb = ((mem_data_ok || ram_data_valid) && control_flow[1]) && (!hold) && state[2] || (!control_flow[1]) && (!hold) && state[2]; 
    assign valid_wb = state[2];
    assign allow_in_wb = ( state[1] ) || commit_ok && !cancel;
    
    assign  rd_wb  = rd;
    assign  mem2reg_wb = control_flow[1]  && valid_wb;
    assign  write_reg_wb = control_flow[0]  && valid_wb;
    assign  fence_type_wb = fence_type & valid_wb;

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
    
 
    always@(posedge clk)begin
       if ( ~rst_n )begin
            state <= state_empty;
        end
        else begin
            state <= next_state;
        end
    end
    
    
    
    always@(posedge clk)begin
       if ( !rst_n )begin
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
                if( mem_data_ok)begin
                    next_state = state_empty;
                end
                else begin
                    next_state = state_leap;
                end
            end
            state_empty:begin
                if( pipe_valid )begin
                    next_state = state_full;
                end
                else begin
                    next_state = state_empty;
                end
            end
            state_full:begin
            //note: if( flush & (hold_pipe) )  then state_full
                if( cancel && (!commit_ok) && (!ram_data_valid))begin
                    next_state = state_leap;
                end
                else if( cancel && (!commit_ok) && (ram_data_valid))begin
                    next_state = state_empty;
                end
                else if(!pipe_valid && commit_ok)begin
                    next_state = state_empty;
                end
                else begin
                    next_state = state_full;
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
            mem_address_testtest <= 0;
            control_flow <= 0;
            rd <= 0;
            ins_func3 <= 0;
            fence_type <= 0;
        end
        else if ( req_ok )begin
            mem_address_testtest <= mem_address_i;
            control_flow <= control_flow_ex;
            rd <= rd_ex;
            ins_func3 <= ins_func3_i;
            fence_type <= fence_type_ex;
        end
    end
    
    always@(posedge clk)
    begin
        if(!rst_n | cancel)begin
            ram_data_valid <=  1'b0;
        end
        else if(mem_data_ok && ( hold  || !allow_in_regfile ))begin
            mem_read_data_reg <= mem_read_data_i;
            ram_data_valid <= valid_wb;
        end
        else if( commit_ok)begin
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