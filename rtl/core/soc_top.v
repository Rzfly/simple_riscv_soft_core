`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 19:40:26
// Design Name: 
// Module Name: soc_top
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

module soc_top(
    input clk,
    input rst_n
//    remain todo
//    output reg over,      
//    output reg succ,      

//    output wire halted_ind, 

//    input wire uart_debug_pin, 

//    output wire uart_tx_pin, 
//    input wire uart_rx_pin, 
//    inout wire[1:0] gpio,   

//    input wire jtag_TCK,     
//    input wire jtag_TMS,    
//    input wire jtag_TDI,    
//    output wire jtag_TDO,

//    input wire spi_miso,    
//    output wire spi_mosi,   
//    output wire spi_ss,    
//    output wire spi_clk   
    );
    
    wire [`BUS_WIDTH - 1:0]bus_axi_addr;
    wire [`DATA_WIDTH - 1:0]bus_axi_data_out;
    wire [`DATA_WIDTH - 1:0]bus_axi_data_in;
    
    riscv_core  riscv_core_inst(
        .clk(clk),
        .rst_n(rst_n)
//        .rib_ex_addr_o(m0_addr_i),
//        .rib_ex_data_i(m0_data_o),
//        .rib_ex_data_o(m0_data_i),
//        .rib_ex_req_o(m0_req_i),
//        .rib_ex_we_o(m0_we_i),

//        .rib_pc_addr_o(m1_addr_i),
//        .rib_pc_data_i(m1_data_o),

//        .jtag_reg_addr_i(jtag_reg_addr_o),
//        .jtag_reg_data_i(jtag_reg_data_o),
//        .jtag_reg_we_i(jtag_reg_we_o),
//        .jtag_reg_data_o(jtag_reg_data_i),

//        .rib_hold_flag_i(rib_hold_flag_o),
//        .jtag_halt_flag_i(jtag_halt_req_o),
//        .jtag_reset_flag_i(jtag_reset_req_o),

//        .int_i(int_flag)
    );
    
    ram ram_inst(
        .clk(clk),
        .we(1'b1),
        .rst_n(1'b1),
        .addr(bus_axi_addr),
        .datai(bus_axi_data_in),
        .datao(bus_axi_data_out)
    );
    
endmodule
