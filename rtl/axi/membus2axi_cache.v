`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2022 05:10:04 PM
// Design Name: 
// Module Name: axi_slave_if
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

module membus2axi_cache #(
  parameter   DATA_WIDTH  = `AXI_DATA_WIDTH,               //数据位宽
  parameter   ADDR_WIDTH  = `AXI_ADDR_WIDTH,               //地址位宽              
  parameter   ID_WIDTH    = `AXI_ID_WIDTH,                //ID位宽
  parameter   STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    /********* clock & reset *********/
	input                       ACLK,
	input      	                ARESETn,
	/******** AXI ********/
    // write address channel
	output	   [ADDR_WIDTH-1:0] AWADDR,
	output	   [3:0]            AWLEN,
	output	   [2:0]            AWSIZE,
	output	   [1:0]	        AWBURST,
	output     [ID_WIDTH-1:0]   AWID,
	output	 	                AWVALID,
	input    	                AWREADY,
    // write data channel
	output	   [DATA_WIDTH-1:0] WDATA,
	output	   [STRB_WIDTH-1:0] WSTRB,
	output		                WLAST,
	output	   [ID_WIDTH-1:0]   WID,
	output	  	                WVALID,
	input    	                WREADY,
    // write resp channel
	input      [1:0]            BRESP,
	input      [ID_WIDTH-1:0]   BID,
	input    	                BVALID,
	output	  	                BREADY,
    // read address channel
	output	   [ADDR_WIDTH-1:0] ARADDR,
	output	   [3:0]            ARLEN,
	output	   [2:0]	        ARSIZE,
	output	   [1:0]	        ARBURST,
	output	   [ID_WIDTH-1:0]   ARID,
	output	  	                ARVALID,
	input    	                ARREADY,
    // read data channel
	input     [DATA_WIDTH-1:0]	RDATA,
	input     [1:0]	        	RRESP,
	input    	                RLAST,
	input     [ID_WIDTH-1:0]	RID,
	input                       RVALID,
	output	 	                RREADY,
	
	//write channel 2
    output	   [ADDR_WIDTH-1:0] m0_AWADDR,
	output	   [3:0]            m0_AWLEN,	//nums. 0 = one transfer
	output	   [2:0]            m0_AWSIZE, //length. less than the width of bus b'010
	output	   [1:0]	        m0_AWBURST,//type.00 = fix address. 01 = incre address. 10 = wrap
	output	   [ID_WIDTH - 1:0] m0_AWID,
    output                      m0_AWVALID,
    input                		m0_AWREADY,
    //data
	output	   [DATA_WIDTH-1:0] m0_WDATA,
    output     [STRB_WIDTH-1:0] m0_WSTRB,//mask
    output                      m0_WLAST,
	output	   [ID_WIDTH - 1:0] m0_WID,//match awid
    output                      m0_WVALID,
    input                       m0_WREADY,
    //resp
    input  	   [1:0]            m0_BRESP,//00 = OKAY
	input	   [ID_WIDTH - 1:0] m0_BID,//match awid
    input                       m0_BVALID,
    output                      m0_BREADY,
    
	// read address channel 2
	output	   [ID_WIDTH-1:0]   m0_ARID,
	output	   [ADDR_WIDTH-1:0] m0_ARADDR,
	output	   [3:0]            m0_ARLEN,
	output	   [2:0]	        m0_ARSIZE,
	output	   [1:0]	        m0_ARBURST,
	output	  	                m0_ARVALID,
	input    	                m0_ARREADY,
	
    // read data channel 2
	input     [ID_WIDTH-1:0]	m0_RID,
	input     [DATA_WIDTH-1:0]	m0_RDATA,
	input     [1:0]	        	m0_RRESP,
	input    	                m0_RLAST,
	input                       m0_RVALID,
	output	 	                m0_RREADY,
	
    /********* SRAM *********/
	//数据输入
    input [`BUS_WIDTH - 1:0] rom_address,
    output [`DATA_WIDTH - 1: 0]  rom_rdata,
    output rom_addr_ok,
    output rom_data_ok,
    input rom_req,
    input rom_data_resp,
    input [`BUS_WIDTH - 1:0]ram_address,
    input [`DATA_WIDTH - 1: 0]ram_wdata,
    input [`RAM_MASK_WIDTH - 1: 0]ram_wmask,
    output [`DATA_WIDTH - 1: 0]    ram_rdata,
    input ram_data_resp,
    output ram_addr_ok,
    output ram_data_ok,
    input ram_req,
    input ram_re,
    input ram_we
);  
    wire mem_writing;
    wire [`BUS_WIDTH - 1:0]mem_last_write_address;
    
    //=========================================================
	//ram access
    srambus2axi#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)srambus2axi_inst(
		.ACLK(ACLK),
		.ARESETn(ARESETn),
		
		.AWADDR(AWADDR),
		.AWLEN(AWLEN),
		.AWSIZE(AWSIZE), //length. less than the width of bus b'010
		.AWBURST(AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.AWID(AWID),
		.AWVALID(AWVALID),
		.AWREADY(AWREADY),
		
		.WDATA(WDATA),
		.WSTRB(WSTRB),
		.WLAST(WLAST),
		.WID(WID),
		.WVALID(WVALID),
		.WREADY(WREADY),
		
		.BRESP(BRESP),
		.BID(BID),
		.BVALID(BVALID),
		.BREADY(BREADY),

		.ARADDR(ARADDR),
		.ARLEN(ARLEN),
		.ARSIZE(ARSIZE),
		.ARBURST(ARBURST),
		.ARID(ARID),
		.ARVALID(ARVALID),
		.ARREADY(ARREADY),
		
		.RDATA(RDATA),
		.RRESP(RRESP),
		.RLAST(RLAST),
		.RID(RID),
		.RVALID(RVALID),
		.RREADY(RREADY),

	    //interface to srambus_master
		.mem_req(ram_req),
		.mem_wen(ram_we),
		.mem_ren(ram_re),
		.mem_wmask(ram_wmask),
		.mem_size(3'b010),
		.mem_address(ram_address),
		.match_id(3'b011),
		.mem_wdata(ram_wdata),
		.mem_rdata(ram_rdata),
		.mem_addr_ok(ram_addr_ok),
		.mem_data_ok(ram_data_ok),
        .mem_data_resp(ram_data_resp),    
		.writing(mem_writing),
		.last_write_address(mem_last_write_address)
	);
		
		
//    wire [ID_WIDTH - 1:0]mem_rid;
//    wire [3:0]rom_rdata_ptr;
    wire [3:0]cache_slave_id;
	wire rd_req;
	wire rd_rdy;
	wire [3:0]rd_type;
	wire [`BUS_WIDTH - 1 : 0]rd_addr;
	wire ret_valid;
	wire ret_last;
	wire [`DATA_WIDTH - 1:0]ret_data;
	wire wr_req;
	wire wr_rdy;
	wire [3:0]wr_type;
	wire [`BUS_WIDTH - 1 : 0]wr_addr;
	wire [`RAM_MASK_WIDTH - 1 : 0]wr_wstrb;
	wire [127: 0]wr_data;
	
	//=========================================================
	
	
	cache cache_inst(
        .clk(ACLK),
        .rst_n(ARESETn),
        
        .mem_req(rom_req),
        .mem_we(1'b0),
        .mem_address(rom_address),
        .mem_wem(4'd0),
        .mem_wdata(32'd0),
        .mem_rdata(rom_rdata),     
        .mem_writing(mem_writing),
        .mem_last_write_address(mem_last_write_address),
        
        .cache_addr_ok(rom_addr_ok),
        .cache_data_ok(rom_data_ok),
        .slave_id(cache_slave_id),
        .rd_req(rd_req),
        .rd_rdy(rd_rdy),
        .rd_type(rd_type),
        .rd_addr(rd_addr),
        .ret_valid(ret_valid),
        .ret_last(ret_last),
        .ret_data(ret_data),
        .wr_req(wr_req),
        .wr_rdy(wr_rdy),
        .wr_type(wr_type),
        .wr_addr(wr_addr),
        .wr_wstrb(wr_wstrb),
        .wr_data(wr_data)
    );

    cache2axi#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	) cache2axi_inst(
        .ACLK(ACLK),
		.ARESETn(ARESETn),
		
        .master_id(3'b001),
        .slave_id(cache_slave_id),
	    .rd_req(rd_req),
	    .rd_type(rd_type),
	    .rd_addr(rd_addr),
	    .rd_rdy(rd_rdy),
	    .ret_valid(ret_valid),
        .ret_last(ret_last),
        .ret_data(ret_data),
        .wr_req(wr_req),
        .wr_type(wr_type),
        .wr_addr(wr_addr),
        .wr_wstrb(wr_wstrb),
        .wr_data(wr_data),
        .wr_rdy(wr_rdy),
        .ext_mem_writing(mem_writing),
        .ext_last_write_address(mem_last_write_address),
	    .mem_writing(),
	    .last_write_address(),
	    
        .AWADDR(m0_AWADDR),
		.AWLEN(m0_AWLEN),
		.AWSIZE(m0_AWSIZE), //length. less than the width of bus b'010
		.AWBURST(m0_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
		.AWID(m0_AWID),
		.AWVALID(m0_AWVALID),
		.AWREADY(m0_AWREADY),
		
		.WDATA(m0_WDATA),
		.WSTRB(m0_WSTRB),
		.WLAST(m0_WLAST),
		.WID(m0_WID),
		.WVALID(m0_WVALID),
		.WREADY(m0_WREADY),
		
		.BRESP(m0_BRESP),
		.BID(m0_BID),
		.BVALID(m0_BVALID),
		.BREADY(m0_BREADY),
		
		.ARADDR(m0_ARADDR),
		.ARID(m0_ARID),
		.ARLEN(m0_ARLEN),
		.ARSIZE(m0_ARSIZE),
		.ARBURST(m0_ARBURST),
		.ARVALID(m0_ARVALID),
		.ARREADY(m0_ARREADY),
		
		.RDATA(m0_RDATA),
		.RRESP(m0_RRESP),
		.RLAST(m0_RLAST),
		.RID(m0_RID),
		.RVALID(m0_RVALID),
		.RREADY(m0_RREADY)
    );

endmodule
