`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 21:07:26
// Design Name: 
// Module Name: instruction_fetch
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

module instruction_fetch(
    input [`MEMORY_DEPTH:0]pc,
    output [`DATA_WIDTH:0]instruction_out
    );
       
           
    rom rom_inst(
        .we(1'b1),
        .rst_n(1'b1),
        .addr(pc),
        .datai(`DATA_WIDTH'hffffffff),
        .datao(instruction_out)
    );
    
    
endmodule
