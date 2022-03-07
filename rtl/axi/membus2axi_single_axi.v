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

module membus2axi_single_axi #(
  parameter   DATA_WIDTH  = 32,             //数据位宽
  parameter   ADDR_WIDTH  = 32,               //地址位宽              
  parameter   ID_WIDTH    = 6,               //ID位宽
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
	
    /********* SRAM *********/
	//数据输入
    input [`BUS_WIDTH - 1:0] rom_address,
    output [`DATA_WIDTH - 1: 0]  rom_rdata,
    output rom_addr_ok,
    output rom_data_ok,
    input rom_req,
    input jump_req,
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

    //=========================================================
	wire   [3:0]grant;
	wire   rom_read_disable;

	wire			      		mem_writing;
	wire 	[ADDR_WIDTH -1:0]  	mem_last_write_address;
	
	assign grant[3] = 0;
	assign grant[2] = ram_req && ram_we;
	
	assign grant[1] = ram_req && ram_re && !jump_req;
	assign grant[0] = rom_req && !ram_req;
	
	
	
	//********************write channel**********************
	wire   mem_wen;
	wire   [`RAM_MASK_WIDTH - 1: 0] mem_wmask;
	wire   [2:0]mem_awsize;
	wire   [`DATA_WIDTH - 1:0]mem_waddr;
	wire   [`BUS_WIDTH - 1:0]mem_wdata;
	wire   mem_write_addr_ok;
	wire   mem_write_data_ok;
	wire   mem_write_data_resp;
	wire  [ID_WIDTH - 1:0]mem_awid;
	assign mem_wen = grant[2] ;
	assign mem_waddr  = {`BUS_WIDTH{grant[2]}}& ram_address;
	assign mem_wdata  = ram_wdata;
	assign mem_awsize = 3'b010;
	assign mem_awid   = 6'b001001;
	assign mem_wmask = ram_wmask;
	assign mem_write_data_resp	= ram_data_resp;
	
	//********************read channel**********************
	wire  [`BUS_WIDTH - 1:0]mem_rdata;
	wire  mem_read_addr_ok;
	wire  mem_read_data_ok;
	wire  mem_read_data_resp;
	wire  [`BUS_WIDTH - 1:0]mem_raddr;
	wire  [ID_WIDTH - 1:0] mem_rid;
	wire  [ID_WIDTH - 1:0]mem_arid;
	wire  mem_ren;	

//	wire [2:0]mem_arsize;
//	assign mem_ren = grant[1] || grant[0] || grant[3];
//	assign mem_arsize = 3'b010;
//	assign mem_arid = {6{grant[1]}} & 6'b010001 | {6{grant[0]}} & 6'b001001 | {6{grant[3]}} & 6'b001001;
//	assign mem_raddr = {`BUS_WIDTH{grant[1]}}& ram_address | {`BUS_WIDTH{grant[0]}} & rom_address  | {`BUS_WIDTH{grant[3]}} & rom_address ;
//	//bug to fix
//	assign  mem_read_data_resp  = ram_data_resp | rom_data_resp;
	
	
	wire [2:0]mem_arsize;
	assign mem_ren = grant[1] || grant[0];
	assign mem_arsize = 3'b010;
	assign mem_arid = {6{grant[1]}} & 6'b010001 | {6{grant[0]}} & 6'b001001 ;
	assign mem_raddr = {`BUS_WIDTH{grant[1]}}& ram_address | {`BUS_WIDTH{grant[0]}} & rom_address  ;
	//bug to fix
	assign  mem_read_data_resp  = ram_data_resp | rom_data_resp;
	

	//********************sram channel**********************
	wire data_back2rom;
	wire data_back2ram;
	assign data_back2ram = (mem_rid == 6'b010001)?1'b1:1'b0;
	assign data_back2rom = (mem_rid == 6'b001001)?1'b1:1'b0;
	assign ram_rdata = {`DATA_WIDTH{data_back2ram}}& mem_rdata;
	assign rom_rdata = {`DATA_WIDTH{data_back2rom}}& mem_rdata;
	assign ram_addr_ok =  grant[1] & mem_read_addr_ok | grant[2] & mem_write_addr_ok;
	assign rom_addr_ok =  grant[0] & mem_read_addr_ok;
	assign ram_data_ok = data_back2ram & mem_read_data_ok | mem_write_data_ok;
	assign rom_data_ok = data_back2rom & mem_read_data_ok;
	
	//=========================================================
    //写鿚道例�?
    axi_w_channel_master#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)axi_w_channel_master_inst(
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


	    //interface to srambus_master
		.wen(mem_wen),
		.wmask(mem_wmask),
		.awsize(mem_awsize),
		.awaddr(mem_waddr),
		.wdata(mem_wdata),
		.awid(mem_awid),
		
		.waddr_ok(mem_write_addr_ok),
		.wdata_ok(mem_write_data_ok),
		.data_resp(mem_write_data_resp),
		.writing(mem_writing),
		.last_write_address(mem_last_write_address)
	);
		
	
	
	//=========================================================
	//读鿚道例�?
	axi_r_channel_master_no_fifo#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)axi_r_channel_master_no_fifo_inst(
		.ACLK(ACLK),
		.ARESETn(ARESETn),
		
		.ARADDR(ARADDR),
		.ARID(ARID),
		.ARLEN(ARLEN),
		.ARSIZE(ARSIZE),
		.ARBURST(ARBURST),
		.ARVALID(ARVALID),
		.ARREADY(ARREADY),
		
		.RDATA(RDATA),
		.RRESP(RRESP),
		.RLAST(RLAST),
		.RID(RID),
		.RVALID(RVALID),
		.RREADY(RREADY),
		
		.mem_writing(mem_writing),
		.mem_last_write_address(mem_last_write_address),
		.sram_rdata(mem_rdata),
		.ren(mem_ren),
		.rid(mem_rid),
		.arid(mem_arid),
		.arsize(mem_arsize),
		.araddr(mem_raddr),
		.raddr_ok(mem_read_addr_ok),
        .data_resp(mem_read_data_resp),    
		.rdata_ok(mem_read_data_ok)
	);
	

	

endmodule
