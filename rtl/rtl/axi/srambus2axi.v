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

module srambus2axi #(
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
	input   	                ARREADY,
    // read data channel
	input     [DATA_WIDTH-1:0]	RDATA,
	input     [1:0]	        	RRESP,
	input    	                RLAST,
	input     [ID_WIDTH-1:0]	RID,
	input                       RVALID,
	output	 	                RREADY,
    /********* SRAMbus *********/    
    input [`BUS_WIDTH - 1:0]mem_address,
	output [`BUS_WIDTH - 1:0]last_write_address,
    input [`DATA_WIDTH - 1: 0]mem_wdata,
    input [`RAM_MASK_WIDTH - 1: 0]mem_wmask,
    output [`DATA_WIDTH - 1: 0]  mem_rdata,
    output mem_addr_ok,
    output mem_data_ok,
    input mem_data_resp,
	output writing,
	input [2:0]mem_size,
	input [2:0]match_id,
    input mem_req,
    input mem_ren,
    input mem_wen
);  

    //=========================================================
    // write channel
	wire			    		wen;
	wire  [3:0]					wmask;
	wire  [2:0]					awsize;
	wire  [3:0]					awlen;
	wire  [ADDR_WIDTH - 1:0]		awaddr;
	wire  [DATA_WIDTH - 1:0] 		wdata;
	wire   [ID_WIDTH - 1:0]    	awid;
	wire                		waddr_ok;
	wire                		wdata_ok;
    wire [3:0]	  wdata_ptr;
    assign awlen = 4'd0;
    //=========================================================
    // read channel
	wire     [DATA_WIDTH-1:0]	sram_rdata;
	wire	   [ID_WIDTH-1:0]	rid;
	wire    					ren;
	wire      [ID_WIDTH-1:0]	arid;
	wire      [2:0]				arsize;
	wire  [3:0]					arlen;
	wire      [ADDR_WIDTH-1:0]  araddr;
	wire 						raddr_ok;
	wire 						rdata_ok;
    wire [3:0]	  rdata_ptr;
    assign arlen = 4'd0;
	
    //=========================================================
    //写�?�道例化
    axi_w_channel_master_buster#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)axi_w_channel_master_buster_inst(
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
		.wen(wen),
		.wmask(wmask),
		.awsize(awsize),
		.awlen(awlen),
		.awaddr(awaddr),
		.wdata(wdata),
		.wdata_ptr(wdata_ptr),
		
		.awid(awid),
		.waddr_ok(waddr_ok),
		.wdata_ok(wdata_ok),
		.data_resp(mem_data_resp),
		.writing(writing),
		.last_write_address(last_write_address)
	);
	
		//=========================================================
		//读�?�道例化
	axi_r_channel_master_burster#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)axi_r_channel_master_burster_inst(
		.ACLK(ACLK),
		.ARESETn(ARESETn),
		
		.ARADDR(ARADDR),
		.ARLEN(ARLEN),
		.ARSIZE(ARSIZE),
		.ARBURST(ARBURST),
		.RDATA(RDATA),
		.ARID(ARID),
		.ARVALID(ARVALID),
		.ARREADY(ARREADY),
		
		.RRESP(RRESP),
		.RLAST(RLAST),
		.RID(RID),
		.RVALID(RVALID),
		.RREADY(RREADY),

	    .mem_writing(1'b0),
	    .mem_last_write_address(32'd0),
		.sram_rdata(sram_rdata),
		.ren(ren),
		.rid(rid),
		.arid(arid),
		.arsize(arsize),
		.arlen(arlen),
		.araddr(araddr),
		.data_resp(mem_data_resp),
		.raddr_ok(raddr_ok),
		.rdata_ok(rdata_ok),
		.rdata_ptr(rdata_ptr)
	);
	
	//mme
    localparam [3:0]slave_0   = 4'b0000;
    localparam [3:0]slave_1   = 4'b0001;
    //timer
    localparam [3:0]slave_2   = 4'b0010;
    //uart
    localparam [3:0]slave_3   = 4'b0011;
    //gpio
    localparam [3:0]slave_4   = 4'b0100;
    
    
    wire [1:0]grant;
	wire slave_mem   = ((mem_address[31:28] == slave_0) || (mem_address[31:28] == slave_1))?1'b1:1'b0;
    wire slave_timer = ((mem_address[31:28] == slave_2) )?1'b1:1'b0;
    wire slave_uart  = ((mem_address[31:28] == slave_3))?1'b1:1'b0;
    wire slave_gpio  = ((mem_address[31:28] == slave_4))?1'b1:1'b0;
	
	wire [ADDR_WIDTH -1:0] mem_address_remap     = {{4'h0}, {mem_address[27:0]}};
	//upper 16KB
	wire [ADDR_WIDTH -1:0] mem_address_final;
//	wire [ADDR_WIDTH -1:0] mem_address_add;
//	assign mem_address_add = mem_address_remap + 32'h00000000;
//	assign mem_address_final =  (mem_address[31:28] == slave_1 )?mem_address_add:mem_address_remap;
	assign mem_address_final =  mem_address_remap;
	
	wire [3:0]slave_id 			= { slave_gpio, slave_gpio|slave_uart, slave_gpio|slave_timer|slave_uart, slave_gpio|slave_timer|slave_mem|slave_uart};
	wire [ID_WIDTH - 1:0]axi_id = {match_id,slave_id};
	
	//read mem
	assign ren    = mem_req && mem_ren && !mem_wen;
	assign araddr = mem_address_final;
	assign arid   = axi_id;
	assign arsize = mem_size;
	
	//write mem
	assign wen    = mem_req && mem_wen;
	assign awaddr = mem_address_final;
	assign awsize = mem_size;
	assign wmask  = mem_wmask;
	assign awid = axi_id;
	assign wdata  = mem_wdata;
	
	assign mem_addr_ok  = mem_wen && waddr_ok || mem_ren && raddr_ok;
	assign mem_data_ok  = wdata_ok || (rdata_ok);
	assign mem_rdata    = sram_rdata;	
	
endmodule
