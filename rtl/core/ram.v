`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 20:29:20
// Design Name: 
// Module Name: ram
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

module ram #(
    parameter DEPTH = 1024
)(
    input clk,
    input rst_n,
    input mem_req,
    input we,
    input [`BUS_WIDTH - 1:0]addr,
    input size,
    input [`DATA_WIDTH - 1:0]datai,
    output [`DATA_WIDTH - 1:0]datao,
    input [`RAM_MASK_WIDTH - 1:0]wem,
    output mem_addr_ok,
    output mem_data_ok
);

 sirv_sim_ram #(
  .DP(512),
  .FORCE_X2ZER(0),
  .DW(32),
  .MW(4),
  .AW(32) 
  )sirv_sim_ram_inst(
    .clk (clk ),
    .rst_n (rst_n ),
    .cs  (mem_req),
    .we  (we  ),
    .addr(addr),
    .din (datai ),
    .wem (wem),
    .dout(datao),
    .mem_addr_ok(mem_addr_ok),
    .mem_data_ok(mem_data_ok)
);

endmodule
