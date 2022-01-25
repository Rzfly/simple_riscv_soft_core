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
    output [`BUS_WIDTH - 1:0] rom_address,
    input [`DATA_WIDTH - 1:0] rom_rdata,
    output [`DATA_WIDTH - 1:0]instruction_o,
    output reg [`BUS_WIDTH - 1:0]pc_id
    );
    
    always@(posedge clk)
    begin
        if ( ~rst_n )
        begin
            pc_id <= `BUS_WIDTH'd0;
        end
        else
        begin
            if(hold)begin
                pc_id <= pc_id;
            end
            else begin
                pc_id <= pc_if;
            end
        end
    end

    assign rom_address   = (hold)?pc_id:pc_if;
    assign instruction_o = (flush | (~rst_n))? `INST_NOP:rom_rdata;
//    assign instruction_o = (flush | ~rst_n )? 0 : 
//                            (hold) instruction_i;
        
endmodule
