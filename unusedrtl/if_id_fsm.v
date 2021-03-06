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

module if_id_fsm(
    input clk,
    input rst_n,
    input cancel,
    input hold,
    input [`BUS_WIDTH - 1:0]pc_if,
    output [`BUS_WIDTH - 1:0]pc_id,
    input [`DATA_WIDTH - 1:0]instruction_if,
    output [`DATA_WIDTH - 1:0]instruction_id,
    //to next pipe
    input allow_in_ex,
    //processing
    output valid_id,
    output ready_go_id,
    //to pre pipe
    output allow_in_id,
    //processing
    input valid_if,
    input ready_go_if
    );
    
    parameter state_empty  = 3'b001;
    parameter state_pipe   = 3'b010;
    parameter state_full   = 3'b100;
    
    reg [2:0]state;
    reg [2:0]next_state;
    reg [`BUS_WIDTH - 1:0]pc;
    reg [`DATA_WIDTH - 1:0]instruction;
    wire pipe_valid;
//    wire hold_pipe;
//    assign hold_pipe = ~allow_in_ex ;
    assign pipe_valid = valid_if && ready_go_if && (!cancel);
    assign pc_id = pc;
    assign instruction_id = instruction;
    assign ready_go_id = !hold;
    //if hold, 0 or 1 || 0;
    //or, store || pipe
    wire req_ok;
    assign req_ok = allow_in_id && pipe_valid;
    wire commit_ok;
    assign commit_ok = allow_in_ex && ready_go_id;
    
    assign ready_go_id = !hold;
    assign allow_in_id =  state[0] || state[1] && allow_in_ex;
    assign valid_id = !state[0];
    
    always@(posedge clk)
    begin
        if ( !rst_n )
        begin;
            pc <= 0;
            instruction <= 0;
        end
        else if( req_ok )begin
            pc <= pc_if;
            instruction <= instruction_if;
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
            state_empty:begin
                if( req_ok && hold || req_ok && !allow_in_ex )begin
                    next_state <= state_full;
                end
                else if (req_ok) begin
                    next_state <= state_pipe;
                end
                else begin
                    next_state = state_empty;
                end
            end
            state_pipe:
                if (cancel && hold || cancel && !allow_in_ex )begin
                    next_state = state_empty;
                end
                else if( hold || !allow_in_ex )begin
                    next_state = state_full;
                end
                else begin
                    next_state = state_pipe;
            end
            state_full:begin
                if (cancel && hold || cancel && !allow_in_ex )begin
                    next_state = state_empty;
                end
                else if( hold || !allow_in_ex )begin
                    next_state = state_full;
                end
                else if(commit_ok)begin
                    next_state = state_empty ;
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
 
endmodule
