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

module if_id(
    input clk,
    input rst_n,
    input cancel,
    input hold,
    input [`BUS_WIDTH - 1:0]pc_if,
    output [`BUS_WIDTH - 1:0]pc_id,
    input [`DATA_WIDTH - 1:0]instruction_if,
    output [`DATA_WIDTH - 1:0]instruction_id,
    input [`BUS_WIDTH - 1:0]pre_taken_target_if,
    output [`BUS_WIDTH - 1:0]pre_taken_target_id,
    input bp_taken_if,
    output bp_taken_id,
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
    
    reg [`BUS_WIDTH - 1:0]pc;
    reg valid;
    reg bp_taken;
    reg [`DATA_WIDTH - 1:0]instruction;
    reg [`BUS_WIDTH - 1:0]pre_taken_target;
    wire pipe_valid;
//    wire hold_pipe;
//    assign hold_pipe = ~allow_in_ex ;
    assign pipe_valid = valid_if & ready_go_if && (!cancel);
    assign pc_id = pc;
    assign valid_id = valid;    // decide pc pipe
    assign bp_taken_id = bp_taken & valid;
    assign instruction_id = instruction;
    assign pre_taken_target_id = pre_taken_target;
    assign ready_go_id = !hold;
    //if hold, 0 or 1 || 0;
    //or, store || pipe
 
    assign allow_in_id = !(valid_id) || ready_go_id & (allow_in_ex);

    always@(posedge clk)
    begin
        if ( !rst_n )
        begin;
            valid <= 1'b0;
        end
        else if(cancel)begin
            valid <= 1'b0;
        end
        else if(allow_in_id)begin
            valid <= pipe_valid;
        end
    end
    
    always@(posedge clk)
    begin
        if ( !rst_n )
        begin;
            pc <= 0;
            instruction <= 0;
            bp_taken <= 0;
            pre_taken_target <= 0;
        end
        else if(pipe_valid && allow_in_id)begin
            pc <= pc_if;
            instruction <= instruction_if;
            bp_taken <= bp_taken_if;
            pre_taken_target <= pre_taken_target_if;
        end
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