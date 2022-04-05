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
module axi2srambus #(
  parameter   DATA_WIDTH  = `AXI_DATA_WIDTH,               //数据位宽
  parameter   ADDR_WIDTH  = `AXI_ADDR_WIDTH,               //地址位宽              
  parameter   ID_WIDTH    = `AXI_ID_WIDTH,                //ID位宽
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
	output     	                AWREADY,
	
	input	   [DATA_WIDTH-1:0] WDATA,
	input	   [STRB_WIDTH-1:0] WSTRB,
	input		                WLAST,
	input	   [ID_WIDTH -1 :0] WID,
	input	  	                WVALID,
	output    	                WREADY,
	
	output     [ID_WIDTH -1 :0] BID,
	output     [1:0]            BRESP,
	output reg	                BVALID,
	input	  	                BREADY,
	
	input	   [ADDR_WIDTH-1:0] ARADDR,
	input	   [3:0]            ARLEN,
	input	   [2:0]	        ARSIZE,
	input	   [1:0]	        ARBURST,
	input	   [ID_WIDTH -1 :0] ARID,
	input	  	                ARVALID,
	output    	                ARREADY,
	
	output reg [DATA_WIDTH-1:0]	RDATA,
	output     [1:0]	        RRESP,
	output reg	                RLAST,
	output     [ID_WIDTH -1 :0] RID,
	output reg                  RVALID,
	input	 	                RREADY,
	
    /********* SRAM BUS *********/
	//数据输入
    output reg [`BUS_WIDTH - 1:0]     mem_address,
    input [`DATA_WIDTH - 1: 0]    mem_rdata,
    output reg [`DATA_WIDTH - 1: 0]   mem_wdata,
    output reg [`RAM_MASK_WIDTH - 1: 0]mem_wmask,
    output reg mem_req,
    output reg mem_we,
    input mem_addr_ok,
    input mem_data_ok,
    output mem_data_ok_resp
);  

    wire WRITE_ADDR_OK;
    wire READ_ADDR_OK;
	wire WRITE_RESP_OK;
	wire WRITE_DATA_OK;
	wire READ_DATA_OK;
	wire READ_LAST_OK;
	wire WRITE_LAST_OK;
	assign READ_ADDR_OK   = ARVALID && ARREADY;
	assign READ_DATA_OK   = RVALID && RREADY;
	assign READ_LAST_OK   = RLAST && RREADY;
	
	assign WRITE_LAST_OK    = WLAST && WREADY;
	assign WRITE_DATA_OK    = WVALID && WREADY;
	assign WRITE_ADDR_OK   = AWVALID && AWREADY;
	assign WRITE_RESP_OK   = BVALID && BREADY;

	localparam  state_idle       = 5'b00001;
    localparam  state_write_busy = 5'b00010;
    localparam  state_read_busy  = 5'b00100;
    localparam  state_write_back = 5'b01000;
    localparam  state_read_back  = 5'b10000;
    
	wire read_req;
	wire write_req;
	wire req_i;
	
	assign read_req = ARVALID;
	assign write_req = AWVALID;


    reg [4:0] state;
    reg [4:0] next_state;
    	
//    assign mem_data_ok_resp = state[4] && mem_data_ok || state[3] && mem_data_ok;
    assign mem_data_ok_resp = state[4]|| state[3];
	assign BRESP   = 2'd0;
	assign RRESP   = 2'd0;
	

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
                if(write_req )begin
                    next_state <= state_write_busy;
                end
                else if(read_req) begin
                    next_state <= state_read_busy;
                end
                else begin
                    next_state <= state_idle;
                end
            end
            state_write_busy:begin
                if( mem_req && mem_addr_ok) begin
                    next_state <= state_write_back;
                end
                else begin
                    next_state <= state_write_busy;
                end
            end
            state_read_busy:begin
                if( mem_req && mem_addr_ok) begin
                    next_state <= state_read_back;
                end
                else begin
                    next_state <= state_read_busy;
                end
            end
            state_write_back:begin
                if( WRITE_RESP_OK) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_write_back;
                end
            end
            state_read_back:begin
                if( READ_DATA_OK) begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_read_back;
                end
            end
            default:begin
                next_state <= state_idle;
            end
        endcase
    end


	reg [ID_WIDTH - 1 :0]BID_temp;
	assign BID = (BVALID)?BID_temp:'d0;
	
	reg [ID_WIDTH - 1 :0]RID_temp;
	assign RID = (RVALID)?RID_temp:'d0;
	assign AWREADY = state[0];
	assign ARREADY = state[0] & !AWVALID;
	
	reg [ADDR_WIDTH - 1 :0]write_addr;
	
    always@(posedge ACLK)begin
		if(!ARESETn)begin
	       	BVALID  <= 1'b0;
			BID_temp <= 0;
			write_addr <= 0;
		end
		else if( state[0] && WRITE_ADDR_OK)begin
	       	BVALID  <= 1'b0;
			BID_temp <= AWID;
			write_addr <= AWADDR;
		end
		else if( state[1] && WRITE_LAST_OK)begin
	       	BVALID  <= 1'b0;
			BID_temp <= BID_temp;
			write_addr <= 0;
		end
		else if( state[3] && mem_data_ok)begin
	       	BVALID  <= 1'b1;
			BID_temp <= BID_temp;
			write_addr <= 0;
		end
		else if( state[3] && WRITE_RESP_OK)begin
	       	BVALID  <= 1'b0;
			BID_temp <= 0;
			write_addr <= 0;
		end
		else begin
	       	BVALID  <= BVALID;
			BID_temp <= BID_temp;
			write_addr <= write_addr;
	    end
	end
	assign WREADY = (WID == BID_temp)?state[1]:1'b0;
	
    always@(posedge ACLK)begin
		if(!ARESETn)begin
			mem_req   <= 1'b0;
			mem_we  <= 1'b0;
			mem_wmask <= 4'd0;
			mem_wdata  <= 32'd0;	
			mem_address <= 32'd0;
	       	RDATA  <= 32'd0;	
	       	RLAST   <= 1'b0;
	       	RVALID  <= 1'b0;
			RID_temp <= {ID_WIDTH{1'b0}};
		end
		else if( state[0] && WRITE_ADDR_OK)begin
			mem_req   <= 1'b0;
			mem_we  <= 1'b0;
			mem_wmask <= 4'd0;
			mem_wdata  <= 32'd0;	
			mem_address <= 32'd0;
	       	RDATA  <= 32'd0;	
	       	RLAST   <= 1'b0;
	       	RVALID  <= 1'b0;
			RID_temp <= {ID_WIDTH{1'b0}};
		end
		else if( state[0] && READ_ADDR_OK ) begin
			mem_req   <= 1'b1;
			mem_we  <= 1'b0;
			mem_wmask <= 4'd0;
			mem_wdata  <= 32'd0;	
			mem_address <= ARADDR;	
	       	RDATA  <= 32'd0;
	       	RLAST   <= 1'b0;
	       	RVALID  <= 1'b0;
			RID_temp <= ARID;
		end
		//only last data is writen
        else if( state[1] && WRITE_LAST_OK)begin
            mem_req   <= 1'b1;
			mem_we  <= 1'b1;
			mem_wmask <= WSTRB;
			mem_wdata  <= WDATA;	
			mem_address <= write_addr;
	       	RDATA  <= 32'd0;	
	       	RLAST   <= 1'b0;
	       	RVALID  <= 1'b0;
			RID_temp <= RID_temp;
		end
		else if(state[1] && mem_addr_ok || state[2] && mem_addr_ok )begin
			mem_req   <= 1'b0;
			mem_we  <= 1'b0;
			mem_wmask <= 4'd0;
			mem_wdata  <= 32'd0;	
			mem_address <= 32'd0;	
	       	RDATA  <= 32'd0;	
	       	RLAST   <= 1'b0;
	       	RVALID  <= 1'b0;
			RID_temp <= RID_temp;
		end 
		else if(state[1] || state[2])begin
			mem_req   <= 1'b0;
			mem_we  <= 1'b0;
			mem_wmask <= 4'd0;
			mem_wdata  <= 32'd0;	
			mem_address <= 32'd0;	
	       	RDATA  <= 32'd0;	
	       	RLAST   <= 1'b0;
	       	RVALID  <= 1'b0;
			RID_temp <= RID_temp;
		end 
		//write resp
		else if(state[3] && mem_data_ok )begin
			mem_req   <= 1'b0;
			mem_we  <= 1'b0;
			mem_wmask <= 4'd0;
			mem_wdata  <= 32'd0;	
			mem_address <= 32'd0;	
	       	RDATA  <= 32'd0;	
	       	RLAST   <= 1'b0;
	       	RVALID  <= 1'b0;
			RID_temp <= {ID_WIDTH{1'b0}};
		end
		//read resp 
	    else if(state[4] && mem_data_ok )begin
			mem_req   <= 1'b0;
			mem_we  <= 1'b0;
			mem_wmask <= 4'd0;
			mem_wdata  <= 32'd0;	
			mem_address <= 32'd0;	
	       	RDATA   <= mem_rdata;	
	       	RLAST   <= 1'b1;
	       	RVALID  <= 1'b1;
			RID_temp <= RID_temp;
		end
		else if( WRITE_RESP_OK && state[3]|| state[4] && READ_DATA_OK)begin
			mem_req   <= 1'b0;
			mem_we  <= 1'b0;
			mem_wmask <= 4'd0;
			mem_wdata  <= 32'd0;	
			mem_address <= 32'd0;	
	       	RDATA  <=  32'd0;	
	       	RLAST   <=  1'b0;
	       	RVALID  <=  1'b0;
			RID_temp <=  {ID_WIDTH{1'b0}};
		end
	    else  begin
			mem_req   <= mem_req;
			mem_we  <= mem_we;
			mem_wmask <= mem_wmask;
			mem_wdata  <= mem_wdata;	
			mem_address <= mem_address;	
	       	RDATA  <= RDATA;	
	       	RLAST   <= RLAST;
	       	RVALID  <= RVALID;
			RID_temp <= RID_temp;
	    end
	end
	
endmodule
