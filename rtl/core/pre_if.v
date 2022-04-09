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
    input cancel,//valid or not
    input mem_data_ok,
    output data_ok_resp,
    input [`BUS_WIDTH - 1:0]pc_pre,
    output [`BUS_WIDTH - 1:0]pc_if,
    input [`DATA_WIDTH - 1:0]rom_rdata,
    input rdata_brtype,
    output [`DATA_WIDTH - 1:0]instruction_if,
    input [`BUS_WIDTH - 1:0]pre_taken_target_pre,
    output [`BUS_WIDTH - 1:0]pre_taken_target_if,
    input  bp_taken_pre,
    output bp_taken_if,
    output early_bp_wrong_if,
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
    
    parameter req_leap  = 3'b001;
    parameter req_empty = 3'b010;
    parameter req_full  = 3'b100;
    parameter data_empty = 2'b01;
    parameter data_full  = 2'b10;
    
    reg [`BUS_WIDTH - 1:0]pc;
    reg bp_taken;
    reg [`DATA_WIDTH - 1:0]instruction;
    reg [`BUS_WIDTH - 1:0]pre_taken_target;
    
    reg [2:0] req_state;
    reg [2:0] next_req_state;
    reg [1:0] data_state;
    reg [1:0] next_data_state;
    
    wire unbranch_type;
    wire pipe_valid;
    wire req_ok;
    wire commit_ok;
    wire mem_ack_ok;
    wire ins_ok;
//    assign branch_type = rdata_brtype;
    assign unbranch_type = (rom_rdata[`OP_WIDTH-1:0] != `SB_TYPE)?1'b1:1'b0;
    assign early_bp_wrong_if = unbranch_type & bp_taken_if & (mem_data_ok);
    assign req_ok    = pipe_valid && allow_in_if;
    assign commit_ok = ready_go_if && allow_in_id;
    assign mem_ack_ok = mem_data_ok && (!hold) && req_state[2];
    assign ins_ok     = data_state[1] && (!hold);
    
    assign data_ok_resp = 1'b1;
//    wire hold_pipe;
//    assign hold_pipe = !allow_in_id | hold;
    assign pipe_valid = valid_pre && ready_go_pre && !flush;
    assign pc_if = pc;
    assign bp_taken_if = bp_taken & valid_if;
    assign instruction_if = (data_state[1])?instruction:rom_rdata;
    assign pre_taken_target_if = pre_taken_target;
    assign ready_go_if = mem_ack_ok || ins_ok;
        
    assign valid_if = req_state[2] || data_state[1];
    assign allow_in_if = ( req_state[1] && data_state[0]) || commit_ok;
    
    
//    wire [4:0]full_control;
//    assign full_control = {pipe_valid, cancel, pipe_valid, };
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
            req_state  <= req_empty;
            data_state <= data_empty;
        end
        else begin
            req_state <= next_req_state;
            data_state <= next_data_state;
        end
    end
    
    always @(*)begin
       case(req_state)
            // next stage hold or flush?
            // hold!because readygo = 0
            // next stage get valid = 0 because readygo = 0
            req_leap:begin
                if( mem_data_ok)begin
                    next_req_state <= req_empty;
                end
                else begin
                    next_req_state <= req_leap;
                end
            end
            req_empty:begin
                if( pipe_valid && ( data_state[0] || commit_ok || cancel))begin
                    next_req_state <= req_full;
                end
                else begin
                    next_req_state <= req_empty;
                end
            end
            req_full:begin
            //note: if( flush & (hold_pipe) )  then state_full          
                if( cancel && (!mem_data_ok) && (data_state[0]))begin
                    next_req_state <= req_leap;
                end
                else if( (!pipe_valid) && cancel && (!mem_data_ok) && (data_state[1]))begin
                    next_req_state <= req_empty;
                end
                else if( (!pipe_valid) && cancel && (mem_data_ok))begin
                    next_req_state <= req_empty;
                end
                else if( (!pipe_valid) && mem_data_ok)begin
                    next_req_state <= req_empty;
                end
                else begin
                    next_req_state <= req_full;
                end
//                if( cancel && (!commit_ok) && (!instruction_valid))begin
//                    next_state = state_leap;
//                end
//                else if( cancel && (!commit_ok) && (instruction_valid))begin
//                    next_state = state_empty;
//                end
//                else if(!pipe_valid && commit_ok)begin
//                    next_state = state_empty;
//                end
//                else begin
//                    next_state = state_full;
//                end
            end
            default:begin
                next_req_state = req_empty;
            end
       endcase
    end
    
    always @(*)begin
       case(data_state)
            data_empty:begin
                if( mem_data_ok && req_state[2] && !commit_ok && !cancel)begin
                    next_data_state <= data_full;
                end
                else begin
                    next_data_state <= data_empty;
                end
            end
            data_full:begin
                if( commit_ok || cancel)begin
                    next_data_state <= data_empty;
                end
                else begin
                    next_data_state <= data_full;
                end
            end
            default:begin
                next_data_state = data_empty;
            end
       endcase
    end
    
    always@(posedge clk )
    begin
        if ( !rst_n )
        begin
            pc <= 32'hfffffffc;
            bp_taken <= 1'b0;
            pre_taken_target <= 32'd0;
        end
        else if( req_ok )begin
            pc <= pc_pre;
            bp_taken <= bp_taken_pre;
            pre_taken_target <= pre_taken_target_pre;
        end
    end
 
    always@(posedge clk )
    begin
        if( mem_data_ok && !commit_ok)begin
            instruction <= rom_rdata;
        end
    end
    
endmodule

