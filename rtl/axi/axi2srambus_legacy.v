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

//duel port
module axi2srambus_legacy #(
  parameter   DATA_WIDTH  = 32,               //数据位宽
  parameter   ADDR_WIDTH  = 32,               //地址位宽              
  parameter   ID_WIDTH    = 4,                //ID位宽
  parameter   STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
  	input                       ACLK,
	input      	                ARESETn,
	
	input	   [ADDR_WIDTH-1:0] AWADDR,
	input	   [3:0]            AWLEN,
	input	   [2:0]            AWSIZE,
	input	   [1:0]	        AWBURST,
	input	   [ID_WIDTH -1 :0] AWID,
	input	 	                AWVALID,
	output    	                AWREADY,
	
	input	   [DATA_WIDTH-1:0] WDATA,
	input	   [STRB_WIDTH-1:0] WSTRB,
	input		                WLAST,
	input	   [ID_WIDTH -1 :0] WID,
	input	  	                WVALID,
	output    	                WREADY,
	
	output     [ID_WIDTH -1 :0] BID,
	output     [1:0]            BRESP,
	output    	                BVALID,
	input	  	                BREADY,
	
	input	   [ADDR_WIDTH-1:0] ARADDR,
	input	   [3:0]            ARLEN,
	input	   [2:0]	        ARSIZE,
	input	   [1:0]	        ARBURST,
	input	   [ID_WIDTH -1 :0] ARID,
	input	  	                ARVALID,
	output    	                ARREADY,
	
	output     [DATA_WIDTH-1:0]	RDATA,
	output     [1:0]	        RRESP,
	output    	                RLAST,
	output     [ID_WIDTH -1 :0] RID,
	output                      RVALID,
	input	 	                RREADY,
	
    /********* SRAM BUS *********/
	//数据输入
    output[`BUS_WIDTH - 1:0]     mem_address,
    input [`DATA_WIDTH - 1: 0]    mem_rdata,
    output[`DATA_WIDTH - 1: 0]   mem_wdata,
    output [`RAM_MASK_WIDTH - 1: 0]mem_wmask,
    output mem_req,
    output mem_we,
    input mem_addr_ok,
    input mem_data_ok
);  

	wire AXI_WADDR_OK;
	wire AXI_WDATA_OK;
	wire AXI_RADDR_OK;
	wire AXI_RDATA_OK;
	wire AXI_RESP_OK;
	assign AXI_WADDR_OK = AWVALID && AWREADY;
	assign AXI_WDATA_OK = WVALID && WREADY;
	assign AXI_RADDR_OK = ARVALID && ARREADY;
	assign AXI_RDATA_OK = RVALID && RREADY;
	assign AXI_RESP_OK = BREADY && BVALID;

	localparam  state_idle  = 3'b001;
    localparam state_write = 3'b010;
    localparam state_read  = 3'b100;
    
	wire read_req;
	wire write_req;
	wire req_i;
	
	assign read_req = ARVALID;
	assign write_req = AWVALID && WVALID;
	assign req_i = read_req || write_req;
		
	assign read_req = ARVALID;
	assign write_req = AWVALID && WVALID;
	assign req_i = read_req || write_req;
	
	assign mem_address  = (write_req)?AWADDR:ARADDR;
	assign mem_wdata 	= WDATA;
    assign mem_wmask   	= WSTRB;
    assign mem_req = req_i;
    assign mem_we  = write_req;

	
    
    reg [2:0] state;
    reg [2:0] next_state;
    	
    assign ARREADY = (write_req)?1'b0:next_state[2];
    assign AWREADY = (write_req)?next_state[1]:1'b0;
	//to be updated
    assign WREADY  = (write_req)?next_state[1]:1'b0;
	
	
	assign BVALID  = (state[1])?mem_data_ok:1'b0;
	assign BRESP   = 'd0;
	
	assign RVALID  = (state[2])?mem_data_ok:1'b0;
    assign RDATA   = mem_rdata;
	assign RRESP   = 'd0;
	assign RLAST   = RVALID;
	
	
	
	
	
	
	

    always@(posedge ACLK)
    begin
        if ( !ARESETn )
        begin;
            state <= state_idle;
        end
        else begin
            state <= next_state;
        end
    end

    always@(*)begin
        case(state)
            state_idle:begin
                if(write_req && mem_addr_ok )begin
                    next_state <= state_write;
                end
                else if(read_req && mem_addr_ok ) begin
                    next_state <= state_read;
                end
                else begin
                    next_state <= state_idle;
                end
            end
            state_write:begin
                if( mem_data_ok && mem_addr_ok && write_req ) begin
                    next_state <= state_write;
                end
                else if(mem_data_ok && mem_addr_ok && read_req) begin
                    next_state <= state_read;
                end    
				else if(mem_data_ok) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_write;
                end
            end
            state_read:begin
                if( mem_data_ok && mem_addr_ok && write_req ) begin
                    next_state <= state_write;
                end
                else if(mem_data_ok && mem_addr_ok && read_req) begin
                    next_state <= state_read;
                end
				else if(mem_data_ok) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_read;
                end
            end
            default:begin
                next_state <= state_idle;
            end
        endcase
    end


	reg [ID_WIDTH - 1 :0]BID_temp;
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			BID_temp <= 0;
		end
		else if(AXI_WADDR_OK)begin
			BID_temp <= AWID;
		end
		else begin
			BID_temp <= BID_temp;
		end
	end
	assign BID = (BVALID)?BID_temp:'d0;
	
	reg [ID_WIDTH - 1 :0]RID_temp;
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			RID_temp <= 0;
		end
		else if(AXI_RADDR_OK)begin
			RID_temp <= ARID;
		end
		else begin
			RID_temp <= RID_temp;
		end
	end
	assign RID = (RVALID)?BID_temp:'d0;
	
	
endmodule
