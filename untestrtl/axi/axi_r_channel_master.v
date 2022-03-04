`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2022 04:41:57 PM
// Design Name: 
// Module Name: axi_r_channel
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

//smaster
module axi_r_channel_master#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH    = 6,
    parameter STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    /********* clock & reset *********/
	input                       ACLK,
	input      	                ARESETn,
	/******** AXI ********/
	//address                
	output  	[ADDR_WIDTH-1:0] ARADDR,
	output  	[3:0]            ARLEN,
	output  	[2:0]	        ARSIZE,
	output	   [1:0]	        ARBURST,
	output  	[ID_WIDTH-1:0]   ARID,
	output 	    	            ARVALID,
	input    	                ARREADY,
	//data                
	input      [DATA_WIDTH-1:0]	RDATA,
    input      [1:0]	        RRESP,//can be ignored
	input    	                RLAST,
	input      [ID_WIDTH-1:0]	RID,
	input                       RVALID,
	output 	                    RREADY,
	/********** sram **********/
    output     [DATA_WIDTH-1:0]	sram_rdata,
	output	   [ID_WIDTH-1:0]	rid,
	input    					ren,
	input      [ID_WIDTH-1:0]	arid,
	input      [2:0]			arsize,
	input      [ADDR_WIDTH-1:0] araddr,
    input                       data_resp,
	output 						raddr_ok,
	output 						rdata_ok
);  

	
	//=========================================================
    //中间信号
	// reg	[15:0]	araddr_start;	//起始地址
	// reg	[15:0]	araddr_stop;	//终止地址（不加起始地�?�?
	// reg	[15:0]	araddr_cnt;		//地址计数�?
	// reg	[8:0]	araddr_step;	//地址步进长度
	// reg			araddr_cnt_flag;//地址累加标志
	// reg [7:0]	arlen;			//awlen

	//outstanding = 1
	// localparam max_req = 2;
    wire AXI_ADDR_OK;
	wire AXI_DATA_OK;
	wire AXI_DATA_LAST;
	assign AXI_ADDR_OK   = ARVALID && ARREADY;
	assign AXI_DATA_OK   = RVALID && RREADY;
	assign AXI_DATA_LAST = RLAST && RREADY;
	
	
    wire [DATA_WIDTH+ID_WIDTH + 2:0] read_req_info_i;
    wire [DATA_WIDTH+ID_WIDTH + 2:0] req_info_fifo_o;
	wire req_fifo_fetch_req;
	wire req_fifo_full;
	wire req_fifo_write_enable;
	wire req_fifo_read_enable;
    wire req_fifo_empty;
	assign read_req_info_i = {araddr, arid, arsize};
	assign {ARADDR, ARID, ARSIZE} = req_info_fifo_o;
	assign ARLEN = 0;
	assign ARBURST = 0;
	assign ARVALID = req_fifo_read_enable;
	assign raddr_ok = req_fifo_write_enable;
	assign req_fifo_fetch_req = AXI_ADDR_OK;
	
	syc_fifo #(
		.DATA_WIDTH(DATA_WIDTH+ID_WIDTH + 3),
		.DEPTH(2),
		.PTR_LENGTH(2)
	)read_req_fifo (
	   .clk(ACLK),
	   .rst_n(ARESETn),
	   .w_req(ren),//ok
	   .wdata(read_req_info_i),//ok
       .write_enable(req_fifo_write_enable),
	   .full(req_fifo_full),//
	   .rdata(req_info_fifo_o),
	   .r_req(req_fifo_fetch_req),
       .read_enable(req_fifo_read_enable),
       .empty(req_fifo_empty)
    );
	
	
    wire [DATA_WIDTH+ID_WIDTH - 1:0] read_data_info_i;
    wire [DATA_WIDTH+ID_WIDTH - 1:0] data_info_fifo_o;
	wire data_fifo_write_enable;
	wire data_fifo_fetch_enable;
	wire data_fifo_full;
	wire data_fifo_empty;
	assign read_data_info_i = {RDATA, RID};
	
	syc_fifo #(
		.DATA_WIDTH(DATA_WIDTH+ID_WIDTH),
		.DEPTH(2),
		.PTR_LENGTH(2)
	)read_data_fifo (
	   .clk(ACLK),
	   .rst_n(ARESETn),
	   .w_req(AXI_DATA_OK),// about fsm
	   .wdata(read_data_info_i), //ok
	   
       .write_enable(data_fifo_write_enable),
       .read_enable(data_fifo_fetch_enable),
       
	   .full(data_fifo_full),	//ok
	   .rdata(data_info_fifo_o),//ok
	   .r_req(data_resp),//ok
       .empty(data_fifo_empty)//ok
    );
	assign {sram_rdata, rid} = data_info_fifo_o;
	assign rdata_ok = data_fifo_fetch_enable;
	assign RREADY = (data_fifo_write_enable) ;// to be updated
	

	
	localparam raddr_state_idle = 2'b01;
	localparam raddr_state_req  = 2'b10;
	// localparam raddr_state_full = 3'b100;

	localparam rdata_state_idle      = 2'b01;
	localparam rdata_state_transfer  = 2'b10;

	
	//address and data channel
	reg [1:0]raddr_state;
	reg [1:0]next_raddr_state;
	
	//response channel
	reg [1:0]rdata_state;
	reg [1:0]next_rdata_state;
	
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			raddr_state <= raddr_state_idle;
			rdata_state <= rdata_state_idle;
		end
		else begin
			raddr_state <= next_raddr_state;
			rdata_state <= next_rdata_state;
		end
	end

	//read req fsm
	always@(*)begin
		case(raddr_state)
			//receive req
			raddr_state_idle:begin
				if (AXI_ADDR_OK)begin
					next_raddr_state <= raddr_state_req;
				end
				else begin
					next_raddr_state <= raddr_state_idle;
				end
			end
			// req_count[1] = max_req
			raddr_state_req:begin
				if ( AXI_DATA_LAST && AXI_ADDR_OK)begin
					next_raddr_state <= raddr_state_req;
				end
				else begin
					next_raddr_state <= raddr_state_idle;
				end
			end
			//never reach
			default:begin
				next_raddr_state <= raddr_state_idle;
			end
		endcase
	end
	
	//read data fsm
	always@(*)begin
		case(rdata_state)
			//receive req
			rdata_state_idle:begin
				if (AXI_ADDR_OK)begin
					rdata_state <= rdata_state_transfer;
				end
				else begin
					rdata_state <= rdata_state_idle;
				end
			end
			//reqing slave. data channel combines address channel
			rdata_state_transfer:begin
				if ( AXI_DATA_LAST && AXI_ADDR_OK)begin
					rdata_state <= rdata_state_transfer;
				end
				//if non last or req > 1, transfer
				else begin
					rdata_state <= rdata_state_idle;
				end
			end	
			//never reach
			default:begin
				rdata_state <= rdata_state_idle;
			end
		endcase
	end

endmodule
