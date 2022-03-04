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
//`define PLL
//`define JTAG

module soc_top(
    input wire sys_clk,
    input wire rst_ext_i,

    output reg over,         // 测试是否完成信号
    output reg succ,         // 测试是否成功信号

    output wire halted_ind,  // jtag是否已经halt住CPU信号

    input wire uart_debug_pin, // 串口下载使能引脚

    output wire uart_tx_pin, // UART发�?�引�?
    input wire uart_rx_pin,  // UART接收引脚
    inout wire[1:0] gpio,    // GPIO引脚

    input wire jtag_TCK,     // JTAG TCK引脚
    input wire jtag_TMS,     // JTAG TMS引脚
    input wire jtag_TDI,     // JTAG TDI引脚
    output wire jtag_TDO,    // JTAG TDO引脚

    input wire spi_miso,     // SPI MISO引脚
    output wire spi_mosi,    // SPI MOSI引脚
    output wire spi_ss,      // SPI SS引脚
    output wire spi_clk      // SPI CLK引脚
    
    );
    wire rst_n;
    
//    wire clk;
//    assign clk = sys_clk;
    
`ifdef PLL
    wire clk;
    wire locked;
    reg lock_save;
    reg rst_internal;
    clk_wiz_0 clk_wiz_0_inst(
      .clk_in1(sys_clk),
      .resetn(rst_ext_i),
      .clk_out1(clk),
      .locked(locked)
    );
    always@(posedge clk or negedge rst_ext_i)begin
        if(!rst_ext_i)begin
            lock_save <= 0;
        end
        else begin
            lock_save <= locked;
        end
    end
    
    always@(posedge clk or negedge rst_ext_i)begin
        if(!rst_ext_i)begin
            rst_internal <= 1'b0;
        end
        else if(locked && !lock_save)begin
            rst_internal <= 1'b1;
        end
        else if(!lock_save)begin
            rst_internal <= 1'b0;
        end
        else begin
            rst_internal <= rst_internal;
        end
    end
 `else
    wire clk;
    assign clk          = sys_clk;
    wire rst_internal;
    assign rst_internal = rst_ext_i;
 `endif

    
    wire jtag_rst_n;
    wire jtag_reset_req_o;
  // ��λ����ģ������
    rst_ctrl u_rst_ctrl(
        .clk(clk),
        .rst_ext_i(rst_internal),
 `ifdef JTAG
        .rst_jtag_i(jtag_reset_req_o),
 `else
        .rst_jtag_i(1'b0),
 `endif
        .core_rst_n_o(rst_n),
        .jtag_rst_n_o(jtag_rst_n)
    );
    
    always @ (posedge clk) begin
        if (!rst_n) begin
            over <= 1'b1;
            succ <= 1'b1;
        end else begin
            over <= ~riscv_core_inst.regfile_inst.rf[26];  // when = 1, run over
            succ <= ~riscv_core_inst.regfile_inst.rf[27];  // when = 1, run succ, otherwise fail
        end
    end


//    // master 0 interface
//    wire[`BUS_WIDTH - 1:0]  m0_addr_i;
//    wire[`DATA_WIDTH - 1:0] m0_data_i;
//    wire[`DATA_WIDTH - 1:0] m0_data_o;
//    wire m0_req_i;
//    wire m0_we_i;
//    wire [`RAM_MASK_WIDTH - 1: 0]m0_wem;
//    wire m0_addr_ok;
//    wire m0_data_ok;

    // jtag
    wire jtag_halt_req_o;
    wire[`RD_WIDTH - 1:0]  jtag_reg_addr_o;
    wire[`DATA_WIDTH - 1:0] jtag_reg_data_o;
    wire jtag_reg_we_o;
    wire[`DATA_WIDTH - 1:0] jtag_reg_data_i;
    assign halted_ind = ~jtag_halt_req_o;

    // master 2 interface
    wire[`BUS_WIDTH - 1:0]  m2_addr_i;
    wire[`DATA_WIDTH - 1:0] m2_data_i;
    wire[`DATA_WIDTH - 1:0] m2_data_o;
    wire m2_req_i;
    wire m2_we_i;
    wire [`RAM_MASK_WIDTH - 1: 0]m2_wem;
    wire m2_addr_ok;
    wire m2_data_ok;
    
//    // master 3 interface
//    wire[`BUS_WIDTH - 1:0] m3_addr_i;
//    wire[`DATA_WIDTH - 1:0] m3_data_i;
//    wire[`DATA_WIDTH - 1:0] m3_data_o;
//    wire m3_req_i;
//    wire m3_we_i;
//    wire [`RAM_MASK_WIDTH - 1: 0]m3_wem;
//    wire m3_addr_ok;
//    wire m3_data_ok;
    
   // slave 0 interface
    wire[`BUS_WIDTH - 1:0] s0_addr_o;
    wire[`DATA_WIDTH - 1:0] s0_data_o;
    wire[`DATA_WIDTH - 1:0] s0_data_i;
    wire s0_req_o;
    wire s0_we_o;
    wire [`RAM_MASK_WIDTH - 1: 0]s0_wem;
    wire s0_addr_ok;
    wire s0_data_ok;

    
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
    wire    ram_we;
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
        //bus
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
        .ram_data_ok(ram_data_ok),
//        .mem_hold(mem_hold_flag_o),
        //int
        .external_int_flag(core_int_flag)//   
`ifdef JTAG
        ,
        .jtag_reg_addr_i(jtag_reg_addr_o),
        .jtag_reg_data_i(jtag_reg_data_o),
        .jtag_reg_we_i(jtag_reg_we_o),
        .jtag_reg_data_o(jtag_reg_data_i),
        .jtag_halt_flag_i(jtag_halt_req_o)
`else
        ,
         //jtag
        .jtag_reg_addr_i(5'd0),
        .jtag_reg_data_i(32'd0),
        .jtag_reg_we_i(1'b0),
        .jtag_reg_data_o(jtag_reg_data_i),
        .jtag_halt_flag_i(1'b0)
        //jtag
`endif
    );

//    mem_arbiter mem_arbiter_inst(
//        .clk(clk),
//        .rst_n(rst_n),
////        .bus_hold_i(bus_hold_flag_o),
////        .mem_hold_o(mem_hold_flag_o),
//        .rom_address(rom_address),
//        .rom_rdata(rom_rdata),
//        .rom_addr_ok(rom_addr_ok),
//        .rom_data_ok(rom_data_ok),
//        .rom_req(rom_req),
    
//        .ram_address(ram_address),
//        .ram_wdata(ram_wdata),
//        .ram_wmask(ram_wmask),
//        .ram_rdata(ram_rdata),
//        .ram_addr_ok(ram_addr_ok),
//        .ram_data_ok(ram_data_ok),
//        .ram_req(ram_req),
//        .ram_we(ram_we),
    
//        .mem_address(mem_address),
//        .mem_rdata(mem_rdata),
//        .mem_wdata(mem_wdata),
//        .mem_wmask(mem_wmask),
//        .mem_req(mem_req),
//        .mem_we(mem_we),
//        .mem_addr_ok(mem_addr_ok),
//        .mem_data_ok(mem_data_ok)
//    );

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

        // master 0 interface rom 
        .m0_addr_i(rom_address),
        .m0_data_i(32'd0),
        .m0_data_o(rom_rdata),
        .m0_req_i(rom_req),
        .m0_we_i(1'b0),
        .m0_wem(4'd0),
        .m0_addr_ok(rom_addr_ok),
        .m0_data_ok(rom_data_ok),
        
        // master 0 interface ram
        .m1_addr_i(ram_address),
        .m1_data_i(ram_wdata),
        .m1_data_o(ram_rdata),
        .m1_req_i(ram_req),
        .m1_we_i(ram_we),
        .m1_wem(ram_wmask),
        .m1_addr_ok(ram_addr_ok),
        .m1_data_ok(ram_data_ok),

`ifdef JTAG
        .m2_addr_i(m2_addr_i),
        .m2_data_i(m2_data_i),
        .m2_data_o(m2_data_o),
        .m2_req_i(m2_req_i),
        .m2_we_i(m2_we_i),
        .m2_wem(m2_wem),
        .m2_addr_ok(m2_addr_ok),
        .m2_data_ok(m2_data_ok),
`else
        .m2_addr_i(32'd0),
        .m2_data_i(32'd0),
        .m2_data_o(m2_data_o),
        .m2_req_i(1'b0),
        .m2_we_i(1'b0),
        .m2_wem(4'd0),
        .m2_addr_ok(m2_addr_ok),
        .m2_data_ok(m2_data_ok),
`endif
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
    
    
//    // 串口下载模块例化
//    uart_debug u_uart_debug(
//        .clk(clk),
//        .rst(rst_n),
//        .debug_en_i(uart_debug_pin),
//        .req_o(m3_req_i),
//        .mem_we_o(m3_we_i),
//        .mem_addr_o(m3_addr_i),
//        .mem_wdata_o(m3_data_i),
//        .mem_rdata_i(m3_data_o)
//    );
    
    
`ifdef JTAG
        wire m2_rsp_rdy_i;
         // jtagģ������
        jtag_top #(
            .DMI_ADDR_BITS(6),
            .DMI_DATA_BITS(32),
            .DMI_OP_BITS(2)
        ) u_jtag_top(
            .clk(clk),
            .jtag_rst_n(jtag_rst_n),
            .jtag_pin_TCK(jtag_TCK),
            .jtag_pin_TMS(jtag_TMS),
            .jtag_pin_TDI(jtag_TDI),
            .jtag_pin_TDO(jtag_TDO),
            .reg_we_o(jtag_reg_we_o),
            .reg_addr_o(jtag_reg_addr_o),
            .reg_wdata_o(jtag_reg_data_o),
            .reg_rdata_i(jtag_reg_data_i),
            .mem_we_o(m2_we_i),
            .mem_addr_o(m2_addr_i),
            .mem_wdata_o(m2_data_i),
            .mem_rdata_i(m2_data_o),
            .mem_sel_o(m2_wem),
            .req_valid_o(m2_req_i),
            .req_ready_i(m2_addr_ok),
            .rsp_valid_i(m2_data_ok),
            .rsp_ready_o(m2_rsp_rdy_i),
            .halt_req_o(jtag_halt_req_o),
            .reset_req_o(jtag_reset_req_o)
        );
`else
//    wire m2_rsp_rdy_i;
//     // jtagģ������
//    jtag_top #(
//        .DMI_ADDR_BITS(6),
//        .DMI_DATA_BITS(32),
//        .DMI_OP_BITS(2)
//    ) u_jtag_top(
//        .clk(clk),
//        .jtag_rst_n(jtag_rst_n),
//        .jtag_pin_TCK(jtag_TCK),
//        .jtag_pin_TMS(jtag_TMS),
//        .jtag_pin_TDI(jtag_TDI),
//        .jtag_pin_TDO(jtag_TDO),
//        .reg_we_o(jtag_reg_we_o),
//        .reg_addr_o(jtag_reg_addr_o),
//        .reg_wdata_o(jtag_reg_data_o),
//        .reg_rdata_i(jtag_reg_data_i),
//        .mem_we_o(m2_we_i),
//        .mem_addr_o(m2_addr_i),
//        .mem_wdata_o(m2_data_i),
//        .mem_rdata_i(m2_data_o),
//        .mem_sel_o(m2_wem),
//        .req_valid_o(m2_req_i),
//        .req_ready_i(m2_addr_ok),
//        .rsp_valid_i(m2_data_ok),
//        .rsp_ready_o(m2_rsp_rdy_i),
//        .halt_req_o(jtag_halt_req_o),
//        .reset_req_o(jtag_reset_req_o)
//    );
`endif
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
