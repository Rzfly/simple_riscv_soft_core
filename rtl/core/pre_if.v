`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/01 19:19:37
// Design Name: 
// Module Name: if_id
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "include.v"

module pre_if(
    input clk,
    input rst_n,
    input hold,//ready or not
    //if flush,not valid
    input flush,//valid or not
    input mem_data_ok,
    input [`BUS_WIDTH - 1:0]next_pc,
    output [`BUS_WIDTH - 1:0]pc_if,
    input [`DATA_WIDTH - 1:0]rom_rdata,
    output [`DATA_WIDTH - 1:0]instruction_if,
    //mem_ok is resolved in next stage
    //to pre pipe
    output allow_in_if,
    input valid_pre,
    input ready_go_pre,
    //to next pipe
    input allow_in_id,
    //processing
    output valid_if,
    output ready_go_if
    );
    
    parameter state_leap  = 4'b0001;
    parameter state_empty = 4'b0010;
    parameter state_pipe  = 4'b0100;
    parameter state_full  = 4'b1000;
    reg [`BUS_WIDTH - 1:0]pc;
    reg valid;
    reg instruction_valid;
    reg [`DATA_WIDTH - 1:0]instruction;
    reg [3:0] state;
    reg [3:0] next_state;
    wire pipe_valid;
    wire hold_pipe;
    wire mem_ready;
    assign mem_ready = mem_data_ok;
    assign hold_pipe = ~allow_in_id | hold;
    assign pipe_valid = valid_pre & ready_go_pre & (~flush);
    assign pc_if = pc;
    assign instruction_if = (instruction_valid)?instruction:rom_rdata;
    // not related with flush
    assign ready_go_if = (state[3]) || (mem_ready & ( state[2] | state[1]));
    wire data_allow_in;
    //note when state[0], allow_in_wb = 0 but data_allow_in = 1
    assign data_allow_in = (!(valid | instruction_valid)) || (ready_go_if) & (~hold_pipe);
    assign allow_in_if = next_state[1] || next_state[2];
    assign valid_if = valid;    // decide pc pipe

//    flush  allow hold hold pipe
//      1      0    0       1
//      1      0    1       x
//      1      1    0       0
//      1      1    1       x
    
    //if hold, 0 || 0;
    //or, store || pipe
 
    //output output     output
    //valid ready_go allow_in_if behavour
    // 0       1          1         flush
    // 1       1          1         next_pipe
    // 0       0          1         next_hold & flush (not used)
    // 1       0          1         next_hold & flush (not used)
    // 0       1          0         nothing
    // 1       1          0         hold & ready to pipe
    // 0       0          0         nothing
    // 1       0          0         hold & next_hold
        

    always@(posedge clk or negedge rst_n)begin
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
                if( mem_data_ok)begin
                    next_state = state_empty;
                end
                else begin
                    next_state = state_leap;
                end
            end
            state_empty:begin
                if( mem_ready && valid_if && hold_pipe && !(instruction_valid))begin
                    next_state = state_full;
                end
                else if(mem_ready && valid_if && data_allow_in && !(flush)) begin
                    next_state = state_pipe;
                end
                else if( !(mem_ready) && valid_if && flush )begin
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
//                else if( mem_ready & hold_pipe & data_allow_in)begin
                //note : nop also can bu hold
                else if( mem_ready && hold_pipe && !(instruction_valid))begin
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
            default:begin
                next_state = state_empty;
            end
       endcase
    end
        
    always@(posedge clk or negedge rst_n)
    begin
        if ( ~rst_n )
        begin;
            valid <= 1'b0;
        end
        else if( allow_in_if )begin
            valid <= pipe_valid;
        end
    end
    
    always@(posedge clk)
    begin
        if ( ~rst_n )
        begin;
            pc <= 32'hfffffffc;
        end
        else if(pipe_valid && allow_in_if)begin
            pc <= next_pc;
        end
    end
    
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)begin
            instruction_valid <=  1'b0;
            instruction <= 0;
        end
        //never occur
        else if( flush )begin
            instruction_valid <=  1'b0;
            instruction <= `INST_NOP;
        end
        //寄存一次 省略了一个状态
        else if( next_state[3] && !(instruction_valid))begin
            instruction <= rom_rdata;
            instruction_valid <= valid;
        end
        else if( next_state[2] || next_state[1] ||  next_state[0])begin
            instruction_valid <=  1'b0;
        end
    end
    
endmodule

