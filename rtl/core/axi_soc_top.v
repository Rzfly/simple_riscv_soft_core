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
`define JTAG

module axi_soc_top(
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
    
    // slave 0 interface
    wire[`BUS_WIDTH - 1:0] s0_addr_o;
    wire[`DATA_WIDTH - 1:0] s0_data_o;
    wire[`DATA_WIDTH - 1:0] s0_data_i;
    wire s0_req_o;
    wire s0_we_o;
    wire [`RAM_MASK_WIDTH - 1: 0]s0_wem;
    wire s0_addr_ok;
    wire s0_data_ok;
  
    // slave 1 interface
    wire[`BUS_WIDTH - 1:0]  s1_addr_o;
    wire[`DATA_WIDTH - 1:0] s1_data_o;
    wire[`DATA_WIDTH - 1:0]s1_data_i;
    wire s1_req_o;
    wire s1_we_o;
    wire [`RAM_MASK_WIDTH - 1: 0]s1_wem;
    wire s1_addr_ok;
    wire s1_data_ok;
    
    // slave 2 interface
    wire[`BUS_WIDTH - 1:0]  s2_addr_o;
    wire[`DATA_WIDTH - 1:0] s2_data_o;
    wire[`DATA_WIDTH - 1:0] s2_data_i;
    wire s2_req_o;
    wire s2_we_o;
    wire [`RAM_MASK_WIDTH - 1: 0]s2_wem;
    wire s2_addr_ok;
    wire s2_data_ok;
        
    // slave 3 interface
    wire[`BUS_WIDTH - 1:0]  s3_addr_o;
    wire[`DATA_WIDTH - 1:0] s3_data_o;
    wire[`DATA_WIDTH - 1:0] s3_data_i;
    wire s3_req_o;
    wire s3_we_o;
    wire [`RAM_MASK_WIDTH - 1: 0]s3_wem;
    wire s3_addr_ok;
    wire s3_data_ok;
    
    
    localparam  ADDR_WIDTH = `BUS_WIDTH;
    localparam  DATA_WIDTH = `DATA_WIDTH;
    localparam  STRB_WIDTH = `RAM_MASK_WIDTH;
    localparam  ID_WIDTH   = `AXI_ID_WIDTH;
    
    //master 0 axi if
	wire     [ADDR_WIDTH - 1:0] m0_AWADDR;
	wire	   [3:0]            m0_AWLEN;
	wire       [2:0]            m0_AWSIZE;
	wire       [1:0]	        m0_AWBURST;
	wire       [ID_WIDTH -1 :0] m0_AWID;
	wire                       m0_AWVALID;
	wire       	                m0_AWREADY;
	
	wire      [DATA_WIDTH-1:0] m0_WDATA;
	wire          [STRB_WIDTH-1:0] m0_WSTRB;
	wire       	                m0_WLAST;
	wire          [ID_WIDTH -1 :0] m0_WID;
	wire                    m0_WVALID;
	wire                      m0_WREADY;
	
	wire        [1:0]            m0_BRESP;
	wire        [ID_WIDTH -1 :0] m0_BID;
	wire                       m0_BVALID;
	wire       	                m0_BREADY;
	
	wire          [ADDR_WIDTH-1:0] m0_ARADDR;
	wire        [3:0]            m0_ARLEN;
	wire        [2:0]	        m0_ARSIZE;
	wire         [1:0]	        m0_ARBURST;
	wire        [ID_WIDTH -1 :0] m0_ARID;
	wire         	                m0_ARVALID;
	wire        	                m0_ARREADY;
	
	wire         [DATA_WIDTH-1:0]	m0_RDATA;
	wire         [1:0]	        m0_RRESP;
	wire        	                m0_RLAST;
	wire         [ID_WIDTH -1 :0] m0_RID;
	wire                           m0_RVALID;
	wire                      m0_RREADY;
	
    //master 1 axi if
	wire         [ADDR_WIDTH-1:0] m1_AWADDR;
	wire         [3:0]            m1_AWLEN;
	wire          [2:0]            m1_AWSIZE;
	wire        [1:0]	        m1_AWBURST;
	wire         [ID_WIDTH -1 :0] m1_AWID;
	wire                       m1_AWVALID;
	wire                    m1_AWREADY;
	
	wire         [DATA_WIDTH-1:0] m1_WDATA;
	wire         [STRB_WIDTH-1:0] m1_WSTRB;
	wire       	                m1_WLAST;
	wire         [ID_WIDTH -1 :0] m1_WID;
	wire       	                m1_WVALID;
	wire                      m1_WREADY;
	
	wire        [1:0]            m1_BRESP;
	wire        [ID_WIDTH -1 :0] m1_BID;
	wire                     m1_BVALID;
	wire                       m1_BREADY;
	
	wire       [ADDR_WIDTH-1:0] m1_ARADDR;
	wire       	   [3:0]            m1_ARLEN;
	wire         [2:0]	        m1_ARSIZE;
	wire         [1:0]	        m1_ARBURST;
	wire        [ID_WIDTH -1 :0] m1_ARID;
	wire       	                m1_ARVALID;
	wire                    m1_ARREADY;
	
	wire        [DATA_WIDTH-1:0]	m1_RDATA;
	wire         [1:0]	        m1_RRESP;
	wire                     m1_RLAST;
	wire         [ID_WIDTH -1 :0] m1_RID;
	wire                      m1_RVALID;
	wire       	                m1_RREADY;
	
    //master 2 axi if
	wire       [ADDR_WIDTH-1:0] m2_AWADDR;
	wire        [3:0]            m2_AWLEN;
	wire         [2:0]            m2_AWSIZE;
	wire         [1:0]	        m2_AWBURST;
	wire        [ID_WIDTH -1 :0] m2_AWID;
	wire       	                m2_AWVALID;
	wire       	                m2_AWREADY;
	
	wire         [DATA_WIDTH-1:0] m2_WDATA;
	wire       [STRB_WIDTH-1:0] m2_WSTRB;
	wire                      m2_WLAST;
	wire       [ID_WIDTH -1 :0] m2_WID;
	wire       	                m2_WVALID;
	wire                  m2_WREADY;
	
	wire        [1:0]            m2_BRESP;
	wire         [ID_WIDTH -1 :0] m2_BID;
	wire                       m2_BVALID;
	wire                       m2_BREADY;
	
	wire        [ADDR_WIDTH-1:0] m2_ARADDR;
	wire        [3:0]            m2_ARLEN;
	wire        [2:0]	        m2_ARSIZE;
	wire        [1:0]	        m2_ARBURST;
	wire          [ID_WIDTH -1 :0] m2_ARID;
	wire       	                m2_ARVALID;
	wire       	                m2_ARREADY;
	
	wire         [DATA_WIDTH-1:0]	m2_RDATA;
	wire         [1:0]	        m2_RRESP;
	wire       	                m2_RLAST;
	wire          [ID_WIDTH -1 :0] m2_RID;
	wire                         m2_RVALID;
	wire                    m2_RREADY;
	
	
    //slave 0 axi if
	wire         [ADDR_WIDTH-1:0] s0_AWADDR;
	wire                  [1:0] s0_AWBURST;
	wire                 [3:0]	s0_AWLEN;
	wire        [STRB_WIDTH-1:0]   s0_WSTRB;
	wire                [2:0]     s0_AWSIZE;
	wire        [ID_WIDTH -1 :0] s0_AWID;
	wire                        s0_AWVALID;
	wire                       s0_AWREADY;
	
	wire          [DATA_WIDTH-1:0] s0_WDATA;
	wire                          s0_WLAST;
	wire       [ID_WIDTH -1 :0] s0_WID;
	wire                        s0_WVALID;
	wire                    s0_WREADY;
	
	wire       [1:0]                s0_BRESP;
	wire         [ID_WIDTH -1 :0]  s0_BID;
	wire                        s0_BVALID;
	wire                       s0_BREADY;
	
	wire         [ADDR_WIDTH-1:0] s0_ARADDR;
	wire        [3:0]           s0_ARLEN;
	wire        [2:0]           s0_ARSIZE;
	wire        [1:0]           s0_ARBURST;
	wire         [ID_WIDTH -1 :0] s0_ARID;
	wire                         s0_ARVALID;
	wire                       s0_ARREADY;
	
	wire        [DATA_WIDTH-1:0]     s0_RDATA;
	wire                        s0_RLAST;
	wire        [1:0]                s0_RRESP;
	wire        [ID_WIDTH -1 :0]  s0_RID;
	wire                       s0_RVALID;
	wire        		    s0_RREADY;
	
    //slave 1 axi if
	wire        [ADDR_WIDTH-1:0] s1_AWADDR;
	wire                  [1:0] s1_AWBURST;
	wire                 [3:0]	s1_AWLEN;
	wire         [STRB_WIDTH-1:0]   s1_WSTRB;
	wire            [2:0]     s1_AWSIZE;
	wire        [ID_WIDTH -1 :0] s1_AWID;
	wire                      s1_AWVALID;
	wire                  s1_AWREADY;
	
	wire         [DATA_WIDTH-1:0] s1_WDATA;
	wire                        s1_WLAST;
	wire        [ID_WIDTH -1 :0] s1_WID;
	wire                      s1_WVALID;
	wire                          s1_WREADY;
	
	wire       [1:0]                 s1_BRESP;
	wire        [ID_WIDTH -1 :0] s1_BID;
	wire                     s1_BVALID;
	wire                   s1_BREADY;
	
	wire        [ADDR_WIDTH-1:0]  s1_ARADDR;
	wire       [3:0]            s1_ARLEN;
	wire          [2:0]            s1_ARSIZE;
	wire        [1:0]            s1_ARBURST;
	wire         [ID_WIDTH -1 :0] s1_ARID;
	wire                           s1_ARVALID;
	wire                          s1_ARREADY;
	
	wire        [DATA_WIDTH-1:0]      s1_RDATA;
	wire                            s1_RLAST;
	wire       [1:0]                 s1_RRESP;
	wire         [ID_WIDTH -1 :0] s1_RID;
	wire                       s1_RVALID;
	wire       	 	     	 s1_RREADY;

    //slave 2 axi if
	wire        [ADDR_WIDTH-1:0]  s2_AWADDR;
	wire                 [1:0]  s2_AWBURST;
	wire                 [3:0]  s2_AWLEN;
	wire         [STRB_WIDTH-1:0]    s2_WSTRB;
	wire              [2:0]      s2_AWSIZE;
	wire        [ID_WIDTH -1 :0] s2_AWID;
	wire                         s2_AWVALID;
	wire                       s2_AWREADY;
	
	wire        [DATA_WIDTH-1:0]  s2_WDATA;
	wire                         s2_WLAST;
	wire         [ID_WIDTH -1 :0] s2_WID;
	wire                       s2_WVALID;
	wire                       s2_WREADY;
	
	wire        [1:0]                 s2_BRESP;
	wire          [ID_WIDTH -1 :0] s2_BID;
	wire                     s2_BVALID;
	wire                     s2_BREADY;
	
	wire        [ADDR_WIDTH-1:0]   s2_ARADDR;
	wire            [3:0]            s2_ARLEN;
	wire        [2:0]            s2_ARSIZE;
	wire        [1:0]            s2_ARBURST;
	wire         [ID_WIDTH -1 :0] s2_ARID;
	wire                        s2_ARVALID;
	wire                         s2_ARREADY;
	
	wire        [DATA_WIDTH-1:0]      s2_RDATA;
	wire                          s2_RLAST;
	wire        [1:0]                 s2_RRESP;
	wire        [ID_WIDTH -1 :0] s2_RID;
	wire                    s2_RVALID;
	wire       		         s2_RREADY;
    //slave3 axi if
	wire        [ADDR_WIDTH-1:0]  s3_AWADDR;
	wire                 [1:0]  s3_AWBURST;
	wire                 [3:0]  s3_AWLEN;
	wire         [STRB_WIDTH-1:0]    s3_WSTRB;
	wire              [2:0]      s3_AWSIZE;
	wire        [ID_WIDTH -1 :0] s3_AWID;
	wire                         s3_AWVALID;
	wire                       s3_AWREADY;
	
	wire        [DATA_WIDTH-1:0]  s3_WDATA;
	wire                         s3_WLAST;
	wire         [ID_WIDTH -1 :0] s3_WID;
	wire                       s3_WVALID;
	wire                       s3_WREADY;
	
	wire        [1:0]                 s3_BRESP;
	wire          [ID_WIDTH -1 :0] s3_BID;
	wire                     s3_BVALID;
	wire                     s3_BREADY;
	
	wire        [ADDR_WIDTH-1:0]   s3_ARADDR;
	wire            [3:0]            s3_ARLEN;
	wire        [2:0]            s3_ARSIZE;
	wire        [1:0]            s3_ARBURST;
	wire         [ID_WIDTH -1 :0] s3_ARID;
	wire                        s3_ARVALID;
	wire                         s3_ARREADY;
	
	wire        [DATA_WIDTH-1:0]      s3_RDATA;
	wire                          s3_RLAST;
	wire        [1:0]                 s3_RRESP;
	wire        [ID_WIDTH -1 :0] s3_RID;
	wire                    s3_RVALID;
	wire       		         s3_RREADY;
    
    wire [`BUS_WIDTH - 1:0]rom_address;
    wire [`DATA_WIDTH - 1:0]rom_rdata;
    wire [`BUS_WIDTH - 1:0]ram_address;
    wire [`DATA_WIDTH - 1:0]ram_rdata;
    wire [`DATA_WIDTH - 1:0]ram_wdata;
    wire [`RAM_MASK_WIDTH - 1:0]ram_wmask;
    wire    ram_we;
    wire    ram_re;
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
    wire ram_data_resp;
    wire rom_data_resp;
    wire jump_req;
    assign core_int_flag = {7'd0, timer0_int};
//    assign core_int_flag = {8'd0};
    riscv_core  riscv_core_inst(
        .clk(clk),
        .rst_n(rst_n),
        //bus
        .rom_address(rom_address),
        .rom_rdata(rom_rdata),
        .mem_rdata_br_type(mem_rdata_br_type),
        .ram_address(ram_address),
        .ram_rdata(ram_rdata),
        .ram_wdata(ram_wdata),
        .ram_wmask(ram_wmask),
        .ram_req(ram_req),
        .rom_req(rom_req),
        .ram_we(ram_we),
        .ram_re(ram_re),
        .rom_addr_ok(rom_addr_ok),
        .jump_req(jump_req),
        .rom_data_ok(rom_data_ok),
        .ram_addr_ok(ram_addr_ok),
        .ram_data_ok(ram_data_ok),
        .ram_data_resp(ram_data_resp),
        .rom_data_resp(rom_data_resp),
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

    membus2axi_cache#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)membus2axi_cache_inst(
		.ACLK(clk),
		.ARESETn(rst_n),
		
		.AWADDR(m1_AWADDR),
		.AWLEN(m1_AWLEN),
		.AWSIZE(m1_AWSIZE), //length. less than the width of bus b'010
		.AWBURST(m1_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.AWID(m1_AWID),
		.AWVALID(m1_AWVALID),
		.AWREADY(m1_AWREADY),
		
		.WDATA(m1_WDATA),
		.WSTRB(m1_WSTRB),
		.WLAST(m1_WLAST),
		.WID(m1_WID),
		.WVALID(m1_WVALID),
		.WREADY(m1_WREADY),
		
		.BRESP(m1_BRESP),
		.BID(m1_BID),
		.BVALID(m1_BVALID),
		.BREADY(m1_BREADY),

		.ARADDR(m1_ARADDR),
		.ARLEN(m1_ARLEN),
		.ARSIZE(m1_ARSIZE),
		.ARBURST(m1_ARBURST),
		.ARID(m1_ARID),
		.ARVALID(m1_ARVALID),
		.ARREADY(m1_ARREADY),
		
		.RDATA(m1_RDATA),
		.RRESP(m1_RRESP),
		.RLAST(m1_RLAST),
		.RID(m1_RID),
		.RVALID(m1_RVALID),
		.RREADY(m1_RREADY),

    	.m0_AWADDR(m0_AWADDR),
		.m0_AWLEN(m0_AWLEN),
		.m0_AWSIZE(m0_AWSIZE), //length. less than the width of bus b'010
		.m0_AWBURST(m0_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.m0_AWID(m0_AWID),
		.m0_AWVALID(m0_AWVALID),
		.m0_AWREADY(m0_AWREADY),
		
		.m0_WDATA(m0_WDATA),
		.m0_WSTRB(m0_WSTRB),
		.m0_WLAST(m0_WLAST),
		.m0_WID(m0_WID),
		.m0_WVALID(m0_WVALID),
		.m0_WREADY(m0_WREADY),
		
		.m0_BRESP(m0_BRESP),
		.m0_BID(m0_BID),
		.m0_BVALID(m0_BVALID),
		.m0_BREADY(m0_BREADY),
		
		.m0_ARADDR(m0_ARADDR),
		.m0_ARLEN(m0_ARLEN),
		.m0_ARSIZE(m0_ARSIZE),
		.m0_ARBURST(m0_ARBURST),
		.m0_ARID(m0_ARID),
		.m0_ARVALID(m0_ARVALID),
		.m0_ARREADY(m0_ARREADY),
		
		.m0_RDATA(m0_RDATA),
		.m0_RRESP(m0_RRESP),
		.m0_RLAST(m0_RLAST),
		.m0_RID(m0_RID),
		.m0_RVALID(m0_RVALID),
		.m0_RREADY(m0_RREADY),

	    //interface to srambus_master
        .rom_address(rom_address),
        .rom_rdata(rom_rdata),
        .mem_rdata_br_type(mem_rdata_br_type),
        .rom_addr_ok(rom_addr_ok),
        .rom_data_ok(rom_data_ok),
        .rom_req(rom_req),
        .rom_data_resp(rom_data_resp),
        
        .ram_address(ram_address),
        .ram_wdata(ram_wdata),
        .ram_wmask(ram_wmask),
        .ram_rdata(ram_rdata),
        .ram_addr_ok(ram_addr_ok),
        .ram_data_ok(ram_data_ok),
        .ram_data_resp(ram_data_resp),
        .ram_req(ram_req),
        .ram_re(ram_re),
        .ram_we(ram_we)
	);
    

  axi_arbiter_full#(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH), 
    .ID_WIDTH(ID_WIDTH)
    )axi_arbiter_full_inst(
        .ACLK(clk),
        .ARESETn(rst_n),
        
        .m0_AWADDR(m0_AWADDR),
        .m0_AWLEN(m0_AWLEN),
        .m0_AWSIZE(m0_AWSIZE),
        .m0_AWBURST(m0_AWBURST),
        .m0_AWID(m0_AWID),
        .m0_AWVALID(m0_AWVALID),
        .m0_AWREADY(m0_AWREADY),
        
        .m0_WDATA(m0_WDATA),
        .m0_WSTRB(m0_WSTRB),
        .m0_WLAST(m0_WLAST),
        .m0_WID(m0_WID),
        .m0_WVALID(m0_WVALID),
        .m0_WREADY(m0_WREADY),
        
        .m0_BRESP(m0_BRESP),
        .m0_BID(m0_BID),
        .m0_BVALID(m0_BVALID),
        .m0_BREADY(m0_BREADY),
        
        .m0_ARADDR(m0_ARADDR),
        .m0_ARLEN(m0_ARLEN),
        .m0_ARSIZE(m0_ARSIZE),
        .m0_ARBURST(m0_ARBURST),
        .m0_ARID(m0_ARID),
        .m0_ARVALID(m0_ARVALID),
        .m0_ARREADY(m0_ARREADY),
        
        .m0_RDATA(m0_RDATA),
        .m0_RRESP(m0_RRESP),
        .m0_RLAST(m0_RLAST),
        .m0_RID(m0_RID),
        .m0_RVALID(m0_RVALID),
        .m0_RREADY(m0_RREADY),
        
        .m1_AWADDR(m1_AWADDR),
        .m1_AWLEN(m1_AWLEN),
        .m1_AWSIZE(m1_AWSIZE),
        .m1_AWBURST(m1_AWBURST),
        .m1_AWID(m1_AWID),
        .m1_AWVALID(m1_AWVALID),
        .m1_AWREADY(m1_AWREADY),
        
        .m1_WDATA(m1_WDATA),
        .m1_WSTRB(m1_WSTRB),
        .m1_WLAST(m1_WLAST),
        .m1_WID(m1_WID),
        .m1_WVALID(m1_WVALID),
        .m1_WREADY(m1_WREADY),
        
        .m1_BRESP(m1_BRESP),
        .m1_BID(m1_BID),
        .m1_BVALID(m1_BVALID),
        .m1_BREADY(m1_BREADY),
        
        .m1_ARADDR(m1_ARADDR),
        .m1_ARLEN(m1_ARLEN),
        .m1_ARSIZE(m1_ARSIZE),
        .m1_ARBURST(m1_ARBURST),
        .m1_ARID(m1_ARID),
        .m1_ARVALID(m1_ARVALID),
        .m1_ARREADY(m1_ARREADY),
        
        .m1_RDATA(m1_RDATA),
        .m1_RRESP(m1_RRESP),
        .m1_RLAST(m1_RLAST),
        .m1_RID(m1_RID),
        .m1_RVALID(m1_RVALID),
        .m1_RREADY(m1_RREADY),
        
        
        .m2_AWADDR(m2_AWADDR),
        .m2_AWLEN(m2_AWLEN),
        .m2_AWSIZE(m2_AWSIZE),
        .m2_AWBURST(m2_AWBURST),
        .m2_AWID(m2_AWID),
        .m2_AWVALID(m2_AWVALID),
        .m2_AWREADY(m2_AWREADY),
        
        .m2_WDATA(m2_WDATA),
        .m2_WSTRB(m2_WSTRB),
        .m2_WLAST(m2_WLAST),
        .m2_WID(m2_WID),
        .m2_WVALID(m2_WVALID),
        .m2_WREADY(m2_WREADY),
        .m2_BRESP(m2_BRESP),
        .m2_BID(m2_BID),
        .m2_BVALID(m2_BVALID),
        .m2_BREADY(m2_BREADY),
        
        .m2_ARADDR(m2_ARADDR),
        .m2_ARLEN(m2_ARLEN),
        .m2_ARSIZE(m2_ARSIZE),
        .m2_ARBURST(m2_ARBURST),
        .m2_ARID(m2_ARID),
        .m2_ARVALID(m2_ARVALID),
        .m2_ARREADY(m2_ARREADY),
        .m2_RDATA(m2_RDATA),
        .m2_RRESP(m2_RRESP),
        .m2_RLAST(m2_RLAST),
        .m2_RID(m2_RID),
        .m2_RVALID(m2_RVALID),
        .m2_RREADY(m2_RREADY),
        
        .s0_AWADDR(s0_AWADDR),
        .s0_AWBURST(s0_AWBURST),
        .s0_AWLEN(s0_AWLEN),
        .s0_WSTRB(s0_WSTRB),
        .s0_AWSIZE(s0_AWSIZE),
        .s0_AWID(s0_AWID),
        .s0_AWVALID(s0_AWVALID),
        .s0_AWREADY(s0_AWREADY),
        .s0_WDATA(s0_WDATA),
        .s0_WLAST(s0_WLAST),
        .s0_WID(s0_WID),
        .s0_WVALID(s0_WVALID),
        .s0_WREADY(s0_WREADY),
        
        .s0_BRESP(s0_BRESP),
        .s0_BID(s0_BID),
        .s0_BVALID(s0_BVALID),
        .s0_BREADY(s0_BREADY),
        
        .s0_ARADDR(s0_ARADDR),
        .s0_ARLEN(s0_ARLEN),
        .s0_ARSIZE(s0_ARSIZE),
        .s0_ARBURST(s0_ARBURST),
        .s0_ARID(s0_ARID),
        .s0_ARVALID(s0_ARVALID),
        .s0_ARREADY(s0_ARREADY),
        
        .s0_RDATA(s0_RDATA),
        .s0_RLAST(s0_RLAST),
        .s0_RRESP(s0_RRESP),
        .s0_RID(s0_RID),
        .s0_RVALID(s0_RVALID),
        .s0_RREADY(s0_RREADY),
        
        //s1
        .s1_AWADDR(s1_AWADDR),
        .s1_AWBURST(s1_AWBURST),
        .s1_AWLEN(s1_AWLEN),
        .s1_WSTRB(s1_WSTRB),
        .s1_AWSIZE(s1_AWSIZE),
        .s1_AWID(s1_AWID),
        .s1_AWVALID(s1_AWVALID),
        .s1_AWREADY(s1_AWREADY),
        
        .s1_WDATA(s1_WDATA),
        .s1_WLAST(s1_WLAST),
        .s1_WID(s1_WID),
        .s1_WVALID(s1_WVALID),
        .s1_WREADY(s1_WREADY),
        
        .s1_BRESP(s1_BRESP),
        .s1_BID(s1_BID),
        .s1_BVALID(s1_BVALID),
        .s1_BREADY(s1_BREADY),
        
        .s1_ARADDR(s1_ARADDR),
        .s1_ARLEN(s1_ARLEN),
        .s1_ARSIZE(s1_ARSIZE),
        .s1_ARBURST(s1_ARBURST),
        .s1_ARID(s1_ARID),
        .s1_ARVALID(s1_ARVALID),
        .s1_ARREADY(s1_ARREADY),
        
        .s1_RDATA(s1_RDATA),
        .s1_RLAST(s1_RLAST),
        .s1_RRESP(s1_RRESP),
        .s1_RID(s1_RID),
        .s1_RVALID(s1_RVALID),
        .s1_RREADY(s1_RREADY),
        
        //s2
        .s2_AWADDR(s2_AWADDR),
        .s2_AWBURST(s2_AWBURST),
        .s2_AWLEN(s2_AWLEN),
        .s2_WSTRB(s2_WSTRB),
        .s2_AWSIZE(s2_AWSIZE),
        .s2_AWID(s2_AWID),
        .s2_AWVALID(s2_AWVALID),
        .s2_AWREADY(s2_AWREADY),
        
        .s2_WDATA(s2_WDATA),
        .s2_WLAST(s2_WLAST),
        .s2_WID(s2_WID),
        .s2_WVALID(s2_WVALID),
        .s2_WREADY(s2_WREADY),
        
        .s2_BRESP(s2_BRESP),
        .s2_BID(s2_BID),
        .s2_BVALID(s2_BVALID),
        .s2_BREADY(s2_BREADY),
        
        .s2_ARADDR(s2_ARADDR),
        .s2_ARLEN(s2_ARLEN),
        .s2_ARSIZE(s2_ARSIZE),
        .s2_ARBURST(s2_ARBURST),
        .s2_ARID(s2_ARID),
        .s2_ARVALID(s2_ARVALID),
        .s2_ARREADY(s2_ARREADY),
        
        .s2_RDATA(s2_RDATA),
        .s2_RLAST(s2_RLAST),
        .s2_RRESP(s2_RRESP),
        .s2_RID(s2_RID),
        .s2_RVALID(s2_RVALID),
        .s2_RREADY(s2_RREADY),
        
         //s3
        .s3_AWADDR(s3_AWADDR),
        .s3_AWBURST(s3_AWBURST),
        .s3_AWLEN(s3_AWLEN),
        .s3_WSTRB(s3_WSTRB),
        .s3_AWSIZE(s3_AWSIZE),
        .s3_AWID(s3_AWID),
        .s3_AWVALID(s3_AWVALID),
        .s3_AWREADY(s3_AWREADY),
        
        .s3_WDATA(s3_WDATA),
        .s3_WLAST(s3_WLAST),
        .s3_WID(s3_WID),
        .s3_WVALID(s3_WVALID),
        .s3_WREADY(s3_WREADY),
        
        .s3_BRESP(s3_BRESP),
        .s3_BID(s3_BID),
        .s3_BVALID(s3_BVALID),
        .s3_BREADY(s3_BREADY),
        
        .s3_ARADDR(s3_ARADDR),
        .s3_ARLEN(s3_ARLEN),
        .s3_ARSIZE(s3_ARSIZE),
        .s3_ARBURST(s3_ARBURST),
        .s3_ARID(s3_ARID),
        .s3_ARVALID(s3_ARVALID),
        .s3_ARREADY(s3_ARREADY),
        
        .s3_RDATA(s3_RDATA),
        .s3_RLAST(s3_RLAST),
        .s3_RRESP(s3_RRESP),
        .s3_RID(s3_RID),
        .s3_RVALID(s3_RVALID),
        .s3_RREADY(s3_RREADY)
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
    
    gpio gpio_0(
        .clk(clk),
        .rst_n(rst_n),
        .req_i(s3_req_o),
        .we_i(s3_we_o),
        .addr_i(s3_addr_o),
        .data_i(s3_data_o),
        .data_o(s3_data_i),
        .addr_ok(s3_addr_ok),
        .data_ok(s3_data_ok),
        .wem(s3_wem),
        .io_pin_i(io_in),
        .reg_ctrl(gpio_ctrl),
        .reg_data(gpio_data)
    );
    
    axi2srambus#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)axi2srambus_gpio_inst(
		.ACLK(clk),
		.ARESETn(rst_n),
		
		.AWADDR(s3_AWADDR),
		.AWLEN(s3_AWLEN),
		.AWSIZE(s3_AWSIZE), //length. less than the width of bus b'010
		.AWBURST(s3_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.AWID(s3_AWID),
		.AWVALID(s3_AWVALID),
		.AWREADY(s3_AWREADY),
		
		.WDATA(s3_WDATA),
		.WSTRB(s3_WSTRB),
		.WLAST(s3_WLAST),
		.WID(s3_WID),
		.WVALID(s3_WVALID),
		.WREADY(s3_WREADY),
		
		.BRESP(s3_BRESP),
		.BID(s3_BID),
		.BVALID(s3_BVALID),
		.BREADY(s3_BREADY),

		.ARADDR(s3_ARADDR),
		.ARLEN(s3_ARLEN),
		.ARSIZE(s3_ARSIZE),
		.ARBURST(s3_ARBURST),
		.ARID(s3_ARID),
		.ARVALID(s3_ARVALID),
		.ARREADY(s3_ARREADY),
		
		.RDATA(s3_RDATA),
		.RRESP(s3_RRESP),
		.RLAST(s3_RLAST),
		.RID(s3_RID),
		.RVALID(s3_RVALID),
		.RREADY(s3_RREADY),

		.mem_address(s3_addr_o),
		.mem_wdata(s3_data_o),
		.mem_rdata(s3_data_i),
		.mem_wmask(s3_wem),
		.mem_req(s3_req_o),
		.mem_we(s3_we_o),
		.mem_addr_ok(s3_addr_ok),
		.mem_data_ok(s3_data_ok)
	);	

    // timer模块例化
    timer timer_0(
        .clk(clk),
        .rst_n(rst_n),
        .data_i(s1_data_o),
        .addr_i(s1_addr_o),
        .req_i(s1_req_o),
        .we_i(s1_we_o),
        .data_o(s1_data_i),
        .addr_ok(s1_addr_ok),
        .data_ok(s1_data_ok),
        .wem(s1_wem),
        .int_sig_o(timer0_int)
    );
    
    axi2srambus#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)axi2srambus_timer_inst(
		.ACLK(clk),
		.ARESETn(rst_n),
		
		.AWADDR(s1_AWADDR),
		.AWLEN(s1_AWLEN),
		.AWSIZE(s1_AWSIZE), //length. less than the width of bus b'010
		.AWBURST(s1_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.AWID(s1_AWID),
		.AWVALID(s1_AWVALID),
		.AWREADY(s1_AWREADY),
		
		.WDATA(s1_WDATA),
		.WSTRB(s1_WSTRB),
		.WLAST(s1_WLAST),
		.WID(s1_WID),
		.WVALID(s1_WVALID),
		.WREADY(s1_WREADY),
		
		.BRESP(s1_BRESP),
		.BID(s1_BID),
		.BVALID(s1_BVALID),
		.BREADY(s1_BREADY),

		.ARADDR(s1_ARADDR),
		.ARLEN(s1_ARLEN),
		.ARSIZE(s1_ARSIZE),
		.ARBURST(s1_ARBURST),
		.ARID(s1_ARID),
		.ARVALID(s1_ARVALID),
		.ARREADY(s1_ARREADY),
		
		.RDATA(s1_RDATA),
		.RRESP(s1_RRESP),
		.RLAST(s1_RLAST),
		.RID(s1_RID),
		.RVALID(s1_RVALID),
		.RREADY(s1_RREADY),
		
		.mem_address(s1_addr_o),
		.mem_wdata(s1_data_o),
		.mem_rdata(s1_data_i),
		.mem_wmask(s1_wem),
		.mem_req(s1_req_o),
		.mem_we(s1_we_o),
		.mem_addr_ok(s1_addr_ok),
		.mem_data_ok(s1_data_ok)
	);	
	
	wire s2_rsp_ready_i;
    uart uart_inst(
        .clk(clk),
        .rst_n(rst_n),
        .data_i(s2_data_o),
        .addr_i(s2_addr_o),
        .sel_i(s2_wem),
        .we_i(s2_we_o),
        .data_o(s2_data_i),  
        .req_valid_i(s2_req_o),
        .req_ready_o(s2_addr_ok),
        .rsp_valid_o(s2_data_ok),
        .rsp_ready_i(s2_rsp_ready_i),
        .tx_pin(uart_tx_pin),
        .rx_pin(uart_rx_pin)
    );
    
    axi2srambus#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)axi2srambus_uart_inst(
		.ACLK(clk),
		.ARESETn(rst_n),
		
		.AWADDR(s2_AWADDR),
		.AWLEN(s2_AWLEN),
		.AWSIZE(s2_AWSIZE), //length. less than the width of bus b'010
		.AWBURST(s2_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.AWID(s2_AWID),
		.AWVALID(s2_AWVALID),
		.AWREADY(s2_AWREADY),
		
		.WDATA(s2_WDATA),
		.WSTRB(s2_WSTRB),
		.WLAST(s2_WLAST),
		.WID(s2_WID),
		.WVALID(s2_WVALID),
		.WREADY(s2_WREADY),
		
		.BRESP(s2_BRESP),
		.BID(s2_BID),
		.BVALID(s2_BVALID),
		.BREADY(s2_BREADY),

		.ARADDR(s2_ARADDR),
		.ARLEN(s2_ARLEN),
		.ARSIZE(s2_ARSIZE),
		.ARBURST(s2_ARBURST),
		.ARID(s2_ARID),
		.ARVALID(s2_ARVALID),
		.ARREADY(s2_ARREADY),
		
		.RDATA(s2_RDATA),
		.RRESP(s2_RRESP),
		.RLAST(s2_RLAST),
		.RID(s2_RID),
		.RVALID(s2_RVALID),
		.RREADY(s2_RREADY),
		
		.mem_address(s2_addr_o),
		.mem_wdata(s2_data_o),
		.mem_rdata(s2_data_i),
		.mem_wmask(s2_wem),
		.mem_req(s2_req_o),
		.mem_we(s2_we_o),
		.mem_addr_ok(s2_addr_ok),
		.mem_data_ok(s2_data_ok),
		.mem_data_ok_resp(s2_rsp_ready_i)
	);	
    

    wire m2_rsp_rdy_i;
`ifdef JTAG
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
        assign m2_req_i = 1'b0;
        assign m2_we_i = 1'b0;
        assign m2_wem  = 'd0;
        assign m2_addr_i  = 'd0;
        assign m2_data_i  = 'd0;
		assign m2_rsp_rdy_i = 'd0;
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
    srambus2axi#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)srambus2axi_jtag_inst(
		.ACLK(clk),
		.ARESETn(rst_n),
		
		.AWADDR(m2_AWADDR),
		.AWLEN(m2_AWLEN),
		.AWSIZE(m2_AWSIZE), //length. less than the width of bus b'010
		.AWBURST(m2_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.AWID(m2_AWID),
		.AWVALID(m2_AWVALID),
		.AWREADY(m2_AWREADY),
		
		.WDATA(m2_WDATA),
		.WSTRB(m2_WSTRB),
		.WLAST(m2_WLAST),
		.WID(m2_WID),
		.WVALID(m2_WVALID),
		.WREADY(m2_WREADY),
		
		.BRESP(m2_BRESP),
		.BID(m2_BID),
		.BVALID(m2_BVALID),
		.BREADY(m2_BREADY),

		.ARADDR(m2_ARADDR),
		.ARLEN(m2_ARLEN),
		.ARSIZE(m2_ARSIZE),
		.ARBURST(m2_ARBURST),
		.ARID(m2_ARID),
		.ARVALID(m2_ARVALID),
		.ARREADY(m2_ARREADY),
		
		.RDATA(m2_RDATA),
		.RRESP(m2_RRESP),
		.RLAST(m2_RLAST),
		.RID(m2_RID),
		.RVALID(m2_RVALID),
		.RREADY(m2_RREADY),

	    //interface to srambus_master
		.mem_req(m2_req_i),
		.mem_wen(m2_we_i),
		.mem_ren(1'b1),
		.mem_wmask(m2_wem),
		.mem_size(3'b010),
		.mem_address(m2_addr_i),
		.match_id(3'b111),
		.mem_data_resp(m2_rsp_rdy_i),
		.mem_wdata(m2_data_i),
		.mem_rdata(m2_data_o),
		.mem_addr_ok(m2_addr_ok),
		.mem_data_ok(m2_data_ok)
	);
//	wire ARREADY_test;
   axi_duelport_bram#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)axi_duelport_bram_inst(
		.ACLK(clk),
		.ARESETn(rst_n),
		
		.AWADDR(s0_AWADDR),
		.AWLEN(s0_AWLEN),
		.AWSIZE(s0_AWSIZE), //length. less than the width of bus b'010
		.AWBURST(s0_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.AWID(s0_AWID),
		.AWVALID(s0_AWVALID),
		.AWREADY(s0_AWREADY),
		
		.WDATA(s0_WDATA),
		.WSTRB(s0_WSTRB),
		.WLAST(s0_WLAST),
		.WID(s0_WID),
		.WVALID(s0_WVALID),
		.WREADY(s0_WREADY),
		
		.BRESP(s0_BRESP),
		.BID(s0_BID),
		.BVALID(s0_BVALID),
		.BREADY(s0_BREADY),

		.ARADDR(s0_ARADDR),
		.ARLEN(s0_ARLEN),
		.ARSIZE(s0_ARSIZE),
		.ARBURST(s0_ARBURST),
		.ARID(s0_ARID),
		.ARVALID(s0_ARVALID),
		.ARREADY(s0_ARREADY),
		
		.RDATA(s0_RDATA),
		.RRESP(s0_RRESP),
		.RLAST(s0_RLAST),
		.RID(s0_RID),
		.RVALID(s0_RVALID),
		.RREADY(s0_RREADY)
	);

endmodule
