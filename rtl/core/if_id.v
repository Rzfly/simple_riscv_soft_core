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
    input [`DATA_WIDTH - 1:0]instruction_i,
    output reg [`DATA_WIDTH - 1:0]instruction_o,
    input [`BUS_WIDTH - 1:0]pc_in,
    output reg [`BUS_WIDTH - 1:0]pc_out,
    input hold,
    input flush
    );
    
    always@(posedge clk)
    begin
        if (flush | ~rst_n )
        begin
            instruction_o <= `DATA_WIDTH'd0;
        end
        else
        begin
            if( hold) begin
                instruction_o <= instruction_o;
            end
            else begin
                instruction_o <= instruction_i;
            end
        end
    end
    
    always@(posedge clk)
    begin
        if ( ~rst_n )
        begin
            pc_out <= `BUS_WIDTH'd0;
        end
        else
        begin
            if( hold | flush )begin
                pc_out <= pc_out;
            end
            else begin
                pc_out <= pc_in;
            end
        end
    end

//    assign instruction_o = (flush | ~rst_n )? 0 : 
//                            (hold) instruction_i;
        
endmodule
