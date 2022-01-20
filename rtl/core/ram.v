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
    input we,
    input rst_n,
    input [`BUS_WIDTH - 1:0]addr,
    input [`DATA_WIDTH - 1:0]datai,
    output [`DATA_WIDTH - 1:0]datao
);

//    memory_ram memory_ram_inst(
//        .clka(clk),
//        .wea(we),
//        //多用了一个非门
//        .rsta(~rst_n),
//        .addra(addr),
//        .dina(datai),
//        .douta(datao)
//    );
 sirv_gnrl_ram #(
    .FORCE_X2ZERO(0),
    .DP(`MEMORY_DEPTH),
    .DW(`DATA_WIDTH),
    .MW(4),
    .AW(`DATA_WIDTH) 
  ) u_e203_itcm_gnrl_ram(
  .sd  (1'b1 ),
  .ds  (1'b1  ),
  .ls  (1'b1),

  .rst_n (rst_n ),
  .clk (clk ),
  .cs  (1'b1  ),
  .we  (we  ),
  .addr(addr),
  .din (datai ),
  .wem ({4{we}} ),
  .dout(datao)
  );
endmodule
