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
module axi_r_channel_master_burster#(
  parameter   DATA_WIDTH  = `AXI_DATA_WIDTH,               //数据位宽
  parameter   ADDR_WIDTH  = `AXI_ADDR_WIDTH,               //地址位宽              
  parameter   ID_WIDTH    = `AXI_ID_WIDTH,                //ID位宽
  parameter   STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    /********* clock & reset *********/
	input                       ACLK,
	input      	                ARESETn,
	/******** AXI ********/
	//address                
	output reg [ADDR_WIDTH-1:0] ARADDR,
	output reg [3:0]            ARLEN,
	output reg [2:0]	        ARSIZE,
	output	reg  [1:0]	        ARBURST,
	output  reg [ID_WIDTH-1:0]   ARID,
	output 	     	            ARVALID,
	input    	                ARREADY,
	//data                
	input      [DATA_WIDTH-1:0]	RDATA,
    input      [1:0]	        RRESP,//can be ignored
	input    	                RLAST,
	input      [ID_WIDTH-1:0]	RID,
	input                       RVALID,
	output 	reg                 RREADY,
	/********** sram **********/
	input			      		mem_writing,
	input 	[ADDR_WIDTH -1:0]  	mem_last_write_address,
    output  reg [DATA_WIDTH-1:0]sram_rdata,
	output	reg [ID_WIDTH-1:0]	rid,
	input    					ren,
	input      [ID_WIDTH-1:0]	arid,
	input      [2:0]			arsize,
	input      [3:0]			arlen,
	input      [ADDR_WIDTH-1:0] araddr,
    input                       data_resp,
	output 					    raddr_ok,
	output 	reg 			    rdata_ok,
	output 	reg [3:0] 		    rdata_ptr
	
	
	
);  

    wire AXI_ADDR_OK;
	wire AXI_DATA_OK;
	wire AXI_DATA_LAST;
	assign AXI_ADDR_OK   = ARVALID && ARREADY;
	assign AXI_DATA_OK   = RVALID && RREADY;
	assign AXI_DATA_LAST = RLAST && RREADY;
	
	wire rom_read_disable;
	assign rom_read_disable = (ARADDR == mem_last_write_address)?mem_writing:1'b0;
	reg ARVALID_reg;
	assign ARVALID = ARVALID_reg && !rom_read_disable;
	
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
				if (ren && (next_rdata_state[0]))begin
					next_raddr_state <= raddr_state_req;
				end
				else begin
					next_raddr_state <= raddr_state_idle;
				end
			end
			// req_count[1] = max_req
			raddr_state_req:begin
				if ( AXI_ADDR_OK)begin
					next_raddr_state <= raddr_state_idle;
				end
				else begin
					next_raddr_state <= raddr_state_req;
				end
			end
			//never reach
			default:begin
				next_raddr_state <= raddr_state_idle;
			end
		endcase
	end
	
		
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			ARADDR <= 'd0;
			ARLEN <= 'd0;
			ARSIZE <= 'd0;
			ARBURST <= 'd0;
			ARID <= 'd0;
			ARVALID_reg <= 'd0;
		end
		else if( ren && raddr_state[0] && (next_rdata_state[0])) begin
			ARADDR <= araddr;
			ARLEN <= arlen;
			ARSIZE <= 3'b010;
			ARBURST <= 2'b01;
			ARID <= arid;
			ARVALID_reg <= 1'b1;
		end
		else if(AXI_ADDR_OK && raddr_state[1])begin
			ARADDR <= 'd0;
			ARLEN <= 'd0;
			ARSIZE <= 'd0;
			ARBURST <= 'd0;
			ARID <= 'd0;
			ARVALID_reg <= 'd0;
		end
		else begin
			ARADDR <= ARADDR;
			ARLEN <=  ARLEN;
			ARSIZE <= ARSIZE;
			ARBURST <= ARBURST;
			ARID <= ARID;
			ARVALID_reg <= ARVALID_reg;
		end
	end
	assign raddr_ok = raddr_state[0];
	
	
	//read data fsm
	always@(*)begin
		case(rdata_state)
			//receive req
			rdata_state_idle:begin
				if (AXI_ADDR_OK)begin
					next_rdata_state <= rdata_state_transfer;
				end
				else begin
					next_rdata_state <= rdata_state_idle;
				end
			end
			//reqing slave. data channel combines address channel
			rdata_state_transfer:begin
				if ( AXI_DATA_LAST && AXI_ADDR_OK)begin
					next_rdata_state <= rdata_state_transfer;
				end
				if ( AXI_DATA_LAST)begin
					next_rdata_state <= rdata_state_idle;
				end
				//if non last or req > 1, transfer
				else begin
					next_rdata_state <= rdata_state_transfer;
				end
			end	
			//never reach
			default:begin
				next_rdata_state <= rdata_state_idle;
			end
		endcase
	end
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			RREADY <= 'd0;
			rid <= 'd0;
			sram_rdata <= 'd0;
			rdata_ok  <= 'd0;
			rdata_ptr <= 'd0;
		end
		else if( rdata_state[0] && AXI_ADDR_OK)begin
			RREADY <= 1'b1;
			rid <= 'd0;
			sram_rdata <= 'd0;
			rdata_ok  <= 'd0;
			rdata_ptr <= 'd0;
		end
		else if( AXI_DATA_LAST && rdata_state[1] && AXI_ADDR_OK) begin
			RREADY <= 1'b1;
			rid <= RID;
			sram_rdata <= RDATA;
			rdata_ok  <= 'd1;
			rdata_ptr <= 'd0;
		end
		else if(AXI_DATA_LAST && rdata_state[1])begin
			RREADY <= 1'b0;
			rid <= RID;
			sram_rdata <= RDATA;
			rdata_ok  <= 'd1;
			rdata_ptr <= 'd0;
		end
		else if(AXI_DATA_OK && rdata_state[1])begin
			RREADY <= 1'b1;
			rid <= RID;
			sram_rdata <= RDATA;
			rdata_ok  <= 'd1;
			rdata_ptr <= rdata_ptr + 1;
		end
		else if(rdata_state[1])begin
			RREADY <= RREADY;
			rid <= RID;
			sram_rdata <= RDATA;
			rdata_ok  <= 'd0;
			rdata_ptr <= rdata_ptr;
		end
		else begin
			RREADY <= RREADY;
			rid <= 'd0;
			sram_rdata <= 'd0;
			rdata_ok  <= 'd0;
			rdata_ptr <= 'd0;
		end
	end
	
endmodule
