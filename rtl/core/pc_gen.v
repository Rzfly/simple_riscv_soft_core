`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 21:18:15
// Design Name: 
// Module Name: pc_gen
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

//true pre_if
module pc_gen #(
    parameter PC_WIDTH = 31
)(
    input [`BUS_WIDTH - 1:0]branch_addr,
    input jump,
    input hold,
    input mem_addr_ok,
    //input mem_ok,
    output rom_req,
    input [`BUS_WIDTH - 1:0] pc_if,
    output [`BUS_WIDTH - 1:0] next_pc,
    //not used
    input allow_in_if,
    output ready_go_pre,
    output valid_pre
    );

    wire hold_pipe;
    wire [`BUS_WIDTH - 1:0] pc_add;
    assign pc_add = pc_if + {`BUS_WIDTH'd4};
    assign hold_pipe = ~allow_in_if | hold;
    assign next_pc = (hold_pipe)?pc_if:(jump)?branch_addr:pc_add;
    assign ready_go_pre = rom_req & mem_addr_ok;
    //if no ready go, next stage set this to zero
    assign valid_pre = mem_addr_ok;
    assign rom_req = allow_in_if & (~hold);
    
    
//    always@(posedge clk)
//    begin
//        if (jump | ~rst_n )
//        begin
//            rom_req <= 0;
//        end
//        else
//        begin
//            rom_req <= 1;
//        end
//    end
    
endmodule
