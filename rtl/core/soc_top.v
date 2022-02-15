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
    
    wire [`BUS_WIDTH - 1:0]rom_address;
    wire [`DATA_WIDTH - 1:0]rom_rdata;
//    wire [`DATA_WIDTH - 1:0]rom_wdata;
    wire [`BUS_WIDTH - 1:0]ram_address;
    wire [`DATA_WIDTH - 1:0]ram_rdata;
    wire [`DATA_WIDTH - 1:0]ram_wdata;
    wire [`RAM_MASK_WIDTH - 1:0]ram_wmask;
    wire ram_we;
    wire [`DATA_WIDTH - 1  :0]ram_din_a;
    wire [`DATA_WIDTH - 1  :0]ram_din_b;
    wire [`BUS_WIDTH - 1  :0]ram_addr_a;
    wire [`BUS_WIDTH - 1  :0]ram_addr_b;
    wire [`RAM_MASK_WIDTH - 1:0]ram_wem_a;
    wire [`RAM_MASK_WIDTH - 1:0]ram_wem_b;
    wire [`DATA_WIDTH-1:0]ram_dout_a;
    wire [`DATA_WIDTH-1:0]ram_dout_b;
    wire    ram_we_a;
    wire    ram_we_b;
    wire    rom_req;
    wire    ram_req;
    wire    mem_req;
    assign ram_we_a = 1'b0;
    assign ram_we_b = ram_we;
    assign ram_din_a = 32'd0;
    assign ram_din_b = ram_wdata;
    assign ram_addr_a = {2'b00,rom_address[`BUS_WIDTH - 1:2]};
    assign ram_addr_b = {2'b00,ram_address[`BUS_WIDTH - 1:2]};
    assign ram_we_a = 1'b0;
    assign ram_we_b = ram_we;
    assign ram_wem_a = 4'b0000;
    assign ram_wem_b = ram_wmask;
    assign rom_rdata = (rom_req)?ram_dout_a:`INST_NOP;
    //Ҫ���ͷ�һ��cycle
    //assign ram_rdata = (ram_req)?ram_dout_b:32'd0;
    assign ram_rdata = ram_dout_b;  
    wire rom_addr_ok;
    wire rom_data_ok;
    wire ram_addr_ok;
    wire ram_data_ok;
    wire mem_addr_ok;
    wire mem_data_ok;
    wire mem_we;
    wire [`RAM_MASK_WIDTH - 1: 0]mem_wmask;
    wire [`BUS_WIDTH - 1:0]  mem_address;
    wire [`DATA_WIDTH - 1: 0] mem_wdata;
    wire [`DATA_WIDTH - 1: 0] mem_rdata;

    riscv_core  riscv_core_inst(
        .clk(clk),
        .rst_n(rst_n),
        .external_int_flag(8'h00),
        .rom_address(rom_address),
        .rom_rdata(rom_rdata),
        .ram_address(ram_address),
        .ram_rdata(ram_rdata),
        .ram_wdata(ram_wdata),
        .ram_wmask(ram_wmask),
        .ram_req(ram_req),
        .rom_req(rom_req),
        .ram_we(ram_we),
        .rom_addr_ok(rom_addr_ok),
        .rom_data_ok(rom_data_ok),
        .ram_addr_ok(ram_addr_ok),
        .ram_data_ok(ram_data_ok)
    );
    
    mem_arbiter mem_arbiter_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rom_address({2'b00,rom_address[`BUS_WIDTH - 1:2]}),
        .rom_rdata(rom_rdata),
        .rom_addr_ok(rom_addr_ok),
        .rom_data_ok(rom_data_ok),
        .rom_req(rom_req),
    
        .ram_address({2'b00,ram_address[`BUS_WIDTH - 1:2]}),
        .ram_wdata(ram_wdata),
        .ram_wmask(ram_wmask),
        .ram_rdata(ram_rdata),
        .ram_addr_ok(ram_addr_ok),
        .ram_data_ok(ram_data_ok),
        .ram_req(ram_req),
        .ram_we(ram_we),
    
        .mem_address(mem_address),
        .mem_rdata(mem_rdata),
        .mem_wdata(mem_wdata),
        .mem_wmask(mem_wmask),
        .mem_req(mem_req),
        .mem_we(mem_we),
        .mem_addr_ok(mem_addr_ok),
        .mem_data_ok(mem_data_ok)
    );
//    sirv_duelport_ram #(
//        .FORCE_X2ZERO(0),
//        .DP(`MEMORY_DEPTH),
//        .DW(`DATA_WIDTH),
//        .MW(`RAM_MASK_WIDTH),
//        .AW(`DATA_WIDTH) 
//    ) sirv_duelport_ram_inst(
//          .rst_n (rst_n ),
//          .clk (clk ),
//          .cs  (1'b1  ),
//          .we_a  (ram_we_a  ),
//          .we_b  (ram_we_b  ),
//          .addr_a(ram_addr_a),
//          .addr_b(ram_addr_b),
//          .din_a (ram_din_a ),
//          .din_b (ram_din_b ),
//          .wem_a (ram_wem_a),
//          .wem_b (ram_wem_b),
//          .dout_a(ram_dout_a),
//          .dout_b(ram_dout_b)
//    );

      srambus srambus_inst(
        .clk(clk),
        .rst_n(rst_n),
        .we(mem_we),
        .wem(mem_wmask),
        .size(2'b11),
        .addr(mem_address),
        .datai(mem_wdata),
        .datao(mem_rdata),
        .mem_req(mem_req),
        .mem_addr_ok(mem_addr_ok),
        .mem_data_ok(mem_data_ok)
    );
    
endmodule
