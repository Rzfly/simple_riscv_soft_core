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
    parameter PC_WIDTH = `MEMORY_DEPTH
)(
    input clk,
    input rst_n,
    input [`BUS_WIDTH - 1:0]branch_addr,
    input branch,
    input hold,
    input [PC_WIDTH - 1:0]pc_reset_value,
    output [PC_WIDTH - 1:0]pc_out
    );

    wire [PC_WIDTH - 1:0]pc_src;
    assign pc_src = (rst_n)?
                (hold)?pc_out:
                (branch)?branch_addr:
                (pc_out + `MEMORY_DEPTH'd1)
                :pc_reset_value;
    
    dff_rst2zero #(.WIDTH(`MEMORY_DEPTH )) dff_rst2zero_inst(
        .clk(clk),
        .rst_n(rst_n),
        .din(pc_src),
        .qout(pc_out) 
     );

endmodule
