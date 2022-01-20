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

module pc_gen #(
    parameter PC_WIDTH = 31
)(
    input clk,
    input rst_n,
    input [`BUS_WIDTH - 1:0]branch_addr,
    input jump,
    input hold,
//    input [PC_WIDTH - 1:0]pc_reset_value,
    output [`BUS_WIDTH - 1:0]pc_out
    );

    wire [`BUS_WIDTH - 1:0]pc_src;
    assign pc_src = (hold)?pc_out:(jump)?branch_addr:(pc_out + 4);
    
    dff_rst2zero #(.WIDTH(`BUS_WIDTH)) dff_rst2zero_inst(
        .clk(clk),
        .rst_n(rst_n),
        .din(pc_src),
        .qout(pc_out) 
     );

endmodule
