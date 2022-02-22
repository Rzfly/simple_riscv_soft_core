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
    input wire sys_clk,
    input wire rst,

    output reg over,         // 测试是否完成信号
    output reg succ,         // 测试是否成功信号

    output wire halted_ind,  // jtag是否已经halt住CPU信号

    input wire uart_debug_pin, // 串口下载使能引脚

    output wire uart_tx_pin, // UART发�?�引�?
    input wire uart_rx_pin,  // UART接收引脚
    inout wire[1:0] gpio,    // GPIO引脚

//    input wire jtag_TCK,     // JTAG TCK引脚
//    input wire jtag_TMS,     // JTAG TMS引脚
//    input wire jtag_TDI,     // JTAG TDI引脚
//    output wire jtag_TDO,    // JTAG TDO引脚

    input wire spi_miso,     // SPI MISO引脚
    output wire spi_mosi,    // SPI MOSI引脚
    output wire spi_ss,      // SPI SS引脚
    output wire spi_clk      // SPI CLK引脚
    
    );
    wire rst_n;
    assign rst_n = rst;
//    wire clk;
//    assign clk = sys_clk;
//    reg clk_div;
    wire clk; 
    clk_wiz_0 clk_wiz_0_inst(
      .clk_in1(sys_clk),
//      .resetn(rst),
      .clk_out1(clk)
    );
//    always @ (posedge sys_clk) begin
//        if (!rst_n) begin
//            clk_div <= 1'b0;
//        end
//        else begin
//            clk_div <= ~clk_div;
//        end
//    end
    
//    assign clk = clk_div;

    
    
    always @ (posedge clk) begin
        if (!rst_n) begin
            over <= 1'b1;
            succ <= 1'b1;
        end else begin
            over <= ~riscv_core_inst.regfile_inst.rf[26];  // when = 1, run over
            succ <= ~riscv_core_inst.regfile_inst.rf[27];  // when = 1, run succ, otherwise fail
        end
    end
    assign halted_ind = 1'b1;

       // slave 0 interface
    wire[`BUS_WIDTH - 1:0] s0_addr_o;
    wire[`DATA_WIDTH - 1:0] s0_data_o;
    wire[`DATA_WIDTH - 1:0] s0_data_i;
    wire s0_req_o;
    wire s0_we_o;
    wire [`RAM_MASK_WIDTH - 1: 0]s0_wem;
    wire s0_addr_ok;
    wire s0_data_ok;

//    // slave 1 interface
//    wire[`BUS_WIDTH - 1:0]  s1_addr_o;
//    wire[`DATA_WIDTH - 1:0]  s1_data_o;
//    wire[`DATA_WIDTH - 1:0]  s1_data_i;
//    wire s1_we_o;
//    wire s4_wem;
//    wire s4_addr_ok;
//    wire s4_data_ok;

    // slave 2 interface
    wire[`BUS_WIDTH - 1:0]  s2_addr_o;
    wire[`DATA_WIDTH - 1:0] s2_data_o;
    wire[`DATA_WIDTH - 1:0]s2_data_i;
    wire s2_req_o;
    wire s2_we_o;
    wire [`RAM_MASK_WIDTH - 1: 0]s2_wem;
    wire s2_addr_ok;
    wire s2_data_ok;
        
    // slave 4 interface
    wire[`BUS_WIDTH - 1:0]  s4_addr_o;
    wire[`DATA_WIDTH - 1:0]s4_data_o;
    wire[`DATA_WIDTH - 1:0] s4_data_i;
    wire s4_req_o;
    wire s4_we_o;
    wire [`RAM_MASK_WIDTH - 1: 0]s4_wem;
    wire s4_addr_ok;
    wire s4_data_ok;

    wire [`BUS_WIDTH - 1:0]rom_address;
    wire [`DATA_WIDTH - 1:0]rom_rdata;
    wire [`BUS_WIDTH - 1:0]ram_address;
    wire [`DATA_WIDTH - 1:0]ram_rdata;
    wire [`DATA_WIDTH - 1:0]ram_wdata;
    wire [`RAM_MASK_WIDTH - 1:0]ram_wmask;
    wire ram_we;
    wire    rom_req;
    wire    ram_req;
    wire    mem_req;
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
    wire [7:0]core_int_flag;
    wire timer0_int;
    wire bus_hold_flag_o;
    wire mem_hold_flag_o;
    assign core_int_flag = {7'd0, timer0_int};
//    assign core_int_flag = {8'd0};
    riscv_core  riscv_core_inst(
        .clk(clk),
        .rst_n(rst_n),
        .mem_hold(mem_hold_flag_o),
        .external_int_flag(core_int_flag),
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
        .bus_hold_i(bus_hold_flag_o),
        .mem_hold_o(mem_hold_flag_o),
        .rom_address(rom_address),
        .rom_rdata(rom_rdata),
        .rom_addr_ok(rom_addr_ok),
        .rom_data_ok(rom_data_ok),
        .rom_req(rom_req),
    
        .ram_address(ram_address),
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

    // gpio
    wire[1:0] io_in;
    wire[31:0] gpio_ctrl;
    wire[31:0] gpio_data;
    // io0 out or not
    assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: 1'bz;
    assign io_in[0] = gpio[0];
    // io1 out or not
    assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: 1'bz;
    assign io_in[1] = gpio[1];
    
    // gpio模块例化
    gpio gpio_0(
        .clk(clk),
        .rst_n(rst_n),
        .req_i(s4_req_o),
        .we_i(s4_we_o),
        .addr_i(s4_addr_o),
        .data_i(s4_data_o),
        .data_o(s4_data_i),
        .addr_ok(s4_addr_ok),
        .data_ok(s4_data_ok),
        .wem(s4_wem),
        .io_pin_i(io_in),
        .reg_ctrl(gpio_ctrl),
        .reg_data(gpio_data)
    );
    
    
    // timer模块例化
    timer timer_0(
        .clk(clk),
        .rst_n(rst_n),
        .data_i(s2_data_o),
        .addr_i(s2_addr_o),
        .req_i(s2_req_o),
        .we_i(s2_we_o),
        .data_o(s2_data_i),
        .addr_ok(s2_addr_ok),
        .data_ok(s2_data_ok),
        .wem(s2_wem),
        .int_sig_o(timer0_int)
    );
        
        // rib模块例化
    bus_arbiter bus_arbiter_inst(
        .clk(clk),
        .rst_n(rst_n),
        // master 0 interface
        .m0_addr_i(mem_address),
        .m0_data_i(mem_wdata),
        .m0_data_o(mem_rdata),
        .m0_req_i(mem_req),
        .m0_we_i(mem_we),
        .m0_wem(mem_wmask),
        .m0_addr_ok(mem_addr_ok),
        .m0_data_ok(mem_data_ok),

        // slave 2 interface
        .s0_addr_o(s0_addr_o),
        .s0_data_o(s0_data_o),
        .s0_data_i(s0_data_i),
        .s0_req_o(s0_req_o),
        .s0_we_o(s0_we_o),
        .s0_wem(s0_wem),
        .s0_addr_ok(s0_addr_ok),
        .s0_data_ok(s0_data_ok),
        
        // slave 2 interface
        .s2_addr_o(s2_addr_o),
        .s2_data_o(s2_data_o),
        .s2_data_i(s2_data_i),
        .s2_req_o(s2_req_o),
        .s2_we_o(s2_we_o),
        .s2_wem(s2_wem),
        .s2_addr_ok(s2_addr_ok),
        .s2_data_ok(s2_data_ok),

        // slave 4 interface
        .s4_addr_o(s4_addr_o),
        .s4_data_o(s4_data_o),
        .s4_data_i(s4_data_i),
        .s4_req_o(s4_req_o),
        .s4_we_o(s4_we_o),
        .s4_wem(s4_wem),
        .s4_addr_ok(s4_addr_ok),
        .s4_data_ok(s4_data_ok),

        .hold_flag_o(bus_hold_flag_o)
    );
    
    
      srambus srambus_inst(
        .clk(clk),
        .rst_n(rst_n),
        .we(s0_we_o),
        .wem(s0_wem),
        .size(2'b11),
        .addr({2'b00,s0_addr_o[`BUS_WIDTH - 1:2]}),
        .datai(s0_data_o),
        .datao(s0_data_i),
        .req_i(s0_req_o),
        .mem_addr_ok(s0_addr_ok),
        .mem_data_ok(s0_data_ok)
    );
    
endmodule
