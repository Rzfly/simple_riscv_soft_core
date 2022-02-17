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
    input flush,
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
    
    reg [`BUS_WIDTH - 1:0]pc;
    reg valid;
    reg [`DATA_WIDTH - 1:0]instruction;
    wire pipe_valid;
//    wire hold_pipe;
//    assign hold_pipe = ~allow_in_ex ;
    assign pipe_valid = valid_if & ready_go_if & (~flush);
    assign pc_id = pc;
    assign valid_id = valid;    // decide pc pipe
    assign instruction_id = instruction;
    assign ready_go_id = !hold;
    //if hold, 0 or 1 || 0;
    //or, store || pipe
 
    assign allow_in_id = !(valid_id) || ready_go_id & (allow_in_ex);


    always@(posedge clk or negedge rst_n)
    begin
        if ( ~rst_n )
        begin;
            valid <= 1'b0;
        end
        else if(allow_in_id)begin
            valid <= pipe_valid;
        end
    end
    
    always@(posedge clk)
    begin
        if ( ~rst_n )
        begin;
            pc <= 0;
            instruction <= 0;
        end
        else if(pipe_valid & allow_in_id)begin
            pc <= pc_if;
            instruction <= instruction_if;
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
