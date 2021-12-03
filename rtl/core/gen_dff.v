`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 21:28:26
// Design Name: 
// Module Name: gen_dff
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

module dff_rst2zero#(
    parameter WIDTH = 32)(
 
    input clk,
    input rst_n,
    input [WIDTH - 1:0] din,
    output [WIDTH - 1:0] qout
);

    reg[WIDTH - 1:0] qout_reg;

    always @ (posedge clk) begin
        if (~rst_n) begin
            qout_reg <= {WIDTH{1'b0}};
        end else begin                  
            qout_reg <= din;
        end
    end

    assign qout = qout_reg;
    
endmodule
