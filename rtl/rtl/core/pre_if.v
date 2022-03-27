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
    input cancel,//valid or not
    input mem_data_ok,
    output data_ok_resp,
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
    
    parameter state_leap  = 3'b001;
    parameter state_empty = 3'b010;
    parameter state_full  = 3'b100;
    reg [`BUS_WIDTH - 1:0]pc;
    reg instruction_valid;
    reg [`DATA_WIDTH - 1:0]instruction;
    reg [2:0] state;
    reg [2:0] next_state;
    wire pipe_valid;
    wire req_ok;
    wire commit_ok;
    assign req_ok    = pipe_valid && allow_in_if;
    assign commit_ok = ready_go_if && allow_in_id;
    
    assign data_ok_resp = 1'b1;
//    wire hold_pipe;
//    assign hold_pipe = !allow_in_id | hold;
    assign pipe_valid = valid_pre && ready_go_pre;
    assign pc_if = pc;
    assign instruction_if = (instruction_valid)?instruction:rom_rdata;
    // not related with flush
    assign ready_go_if = (mem_data_ok || instruction_valid) && (!hold) && state[2];
    assign valid_if = state[2];
    assign allow_in_if = ( state[1] ) || commit_ok;

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
                if( cancel && (!commit_ok) && (!instruction_valid))begin
                    next_state = state_leap;
                end
                else if( cancel && (!commit_ok) && (instruction_valid))begin
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
    
    always@(posedge clk )
    begin
        if ( !rst_n )
        begin;
            pc <= 32'hfffffffc;
        end
        else if( req_ok )begin
            pc <= next_pc;
        end
    end
 
    always@(posedge clk )
    begin
        if ( !rst_n || cancel )begin
            instruction_valid <=  1'b0;
        end
        //never occur
        //寄存一次 省略了一个状态         
        else if( mem_data_ok && ( hold  || !allow_in_id ) )begin
            instruction <= rom_rdata;
            instruction_valid <= valid_if;
        end
        else if( commit_ok )begin
            instruction_valid <=  1'b0;
        end
    end
    
endmodule

