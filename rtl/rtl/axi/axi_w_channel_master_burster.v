`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2022 03:13:01 PM
// Design Name: 
// Module Name: axi_w_channel
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

//master
module axi_w_channel_master_buster#(
  parameter   DATA_WIDTH  = `AXI_DATA_WIDTH,               //数据位宽
  parameter   ADDR_WIDTH  = `AXI_ADDR_WIDTH,               //地址位宽              
  parameter   ID_WIDTH    = `AXI_ID_WIDTH,                //ID位宽
  parameter   STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    input ACLK,
    input ARESETn,
    
    //address
	output	reg[ADDR_WIDTH-1:0] AWADDR,
	output	reg[3:0]            AWLEN,	//nums. 0 = one transfer
	output	reg[2:0]            AWSIZE, //length. less than the width of bus b'010
	output	reg[1:0]	        AWBURST,//type.00 = fix address. 01 = incre address. 10 = wrap
	output	reg[ID_WIDTH - 1:0] AWID,
    output  reg                 AWVALID,
    input                		AWREADY,
    //data
	output	reg[DATA_WIDTH-1:0] WDATA,
    output  reg[STRB_WIDTH-1:0] WSTRB,//mask
    output  reg                 WLAST,
	output	   [ID_WIDTH - 1:0] WID,//match awid
    output  reg                 WVALID,
    input                       WREADY,
    //resp
    input  	   [1:0]            BRESP,//00 = OKAY
	input	   [ID_WIDTH - 1:0] BID,//match awid
    input                       BVALID,
    output  reg                 BREADY,
    
    //interface to sram_master
    input			        wen,
    input  [3:0]			wmask,
	input  [2:0]			awsize,    //3'b010
	input  [3:0]            awlen,
    input  [ADDR_WIDTH -1:0]			awaddr,
	input  [DATA_WIDTH-1:0]			wdata,
	output reg [3:0]	wdata_ptr,
	input   [ID_WIDTH - 1:0] awid,
	input                  data_resp,
	output                waddr_ok,
	output reg            wdata_ok,
	output			      writing,
	output reg[ADDR_WIDTH -1:0]  last_write_address
    );
    
	//no outstanding
	localparam waddr_state_idle        = 4'b0001;
	localparam waddr_state_req_full    = 4'b0010;
	localparam waddr_state_transfering = 4'b0100;
	localparam waddr_state_wait_over   = 4'b1000;
	
	//address and data channel
	reg [3:0]write_state;
	reg [3:0]next_write_state;
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			write_state <= waddr_state_idle;
		end
		else begin
			write_state <= next_write_state;
		end
	end
	
	wire AXI_ADDR_OK;
	wire AXI_DATA_OK;
	wire AXI_RESP_OK;
	wire AXI_LAST_OK;
	assign AXI_ADDR_OK = AWVALID && AWREADY;
	assign AXI_DATA_OK = WVALID && WREADY;
	assign AXI_LAST_OK = WLAST && WREADY;
	assign AXI_RESP_OK = BREADY && BVALID;
	
//	assign wdata_ok = wresp_state[1] && BVALID;
	assign waddr_ok = write_state[0];

	//write data fsm
	always@(*)begin
		case(write_state)
			//receive req
			waddr_state_idle:begin
				if (wen)begin
					next_write_state <= waddr_state_req_full;
				end
				else begin
					next_write_state <= waddr_state_idle;
				end
			end
			//reqing slave. data channel combines address channel
			waddr_state_req_full:begin
				if(AXI_ADDR_OK) begin
					next_write_state <= waddr_state_transfering;
				end
				else begin
					next_write_state <= waddr_state_req_full;
				end
			end
			waddr_state_transfering:begin
				if ( AXI_LAST_OK )begin
					next_write_state <= waddr_state_wait_over;
				end
				else begin
					next_write_state <= waddr_state_transfering;
				end
			end
			//write over
			waddr_state_wait_over:begin
                if( AXI_RESP_OK )begin
					next_write_state <= waddr_state_idle;
				end
				else begin
					next_write_state <= waddr_state_wait_over;
				end
			end
			//never reach
			default:begin
				next_write_state <= waddr_state_idle;
			end
		endcase
	end

	//write_fsm
    always@(posedge ACLK)begin
		if(!ARESETn)begin
			BREADY   <= 0;
		end
		else if( write_state[0])begin
			BREADY   <= 0;
		end
		else if( write_state[3] && AXI_RESP_OK && wen)begin
			BREADY   <= 0;
		end
		else if( write_state[3] && AXI_RESP_OK)begin
			BREADY   <= 0;
		end
		else if( write_state[3] || write_state[1] || write_state[2])begin
			BREADY   <= data_resp;
		end
		else begin
			BREADY   <= BREADY;
	   end
	end
	
		//write_fsm
    always@(posedge ACLK)begin
		if(!ARESETn)begin
			wdata_ok <= 0;
		end
		else if( write_state[0] || write_state[1] || write_state[2])begin
			wdata_ok <= 0;
		end
		else if( write_state[3] && AXI_RESP_OK)begin
			wdata_ok <= 1;
		end
		else begin
			wdata_ok <= wdata_ok;
	   end
	end
	
	reg [ID_WIDTH - 1:0] WID_TEMP;
	// reg [ID_WIDTH - 1:0] WDATA_TEMP;
	wire wlast;
	reg  [3:0]awlen_temp;
	assign wlast = (wdata_ptr == awlen_temp)?1'b1:1'b0;
	//write_fsm
    always@(posedge ACLK)begin
		if(!ARESETn)begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			awlen_temp <= 0;
			AWLEN    <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WDATA    <= 0;
			WID_TEMP <= 0;
			WSTRB    <= 0;
			WVALID   <= 0;
			WLAST    <= 0;
			WID_TEMP <= 0;
			wdata_ptr <= 0;
			last_write_address <= 0;
		end
		//idle or wait
		else if( write_state[0] && wen )begin
			AWADDR	 <= awaddr;
			AWVALID  <= 1;
			AWID     <= awid;
			AWLEN    <= awlen;
			awlen_temp <= awlen;
			AWSIZE   <= awsize;
			AWBURST  <= 2'b01;
			
			WDATA    <= wdata;
			WID_TEMP <= awid;
			WSTRB    <= wmask;
			WVALID   <= 0;
			WLAST    <= 0;	
			wdata_ptr <= 0;
			last_write_address <= awaddr;
		end
		else if( write_state[0])begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			AWLEN    <= 0;
			awlen_temp <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WID_TEMP <= 0;
			WDATA    <= 0;
			WSTRB    <= 0;
			WVALID   <= 0;
			WLAST    <= 0;
			wdata_ptr <= 0;
			last_write_address <= 0;
		end

		else if( write_state[1] && AXI_ADDR_OK)begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			awlen_temp <= awlen_temp;
			AWLEN    <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WID_TEMP <= WID_TEMP;
			WDATA    <= WDATA;
			WSTRB    <= WSTRB;
			WVALID   <= 1'b1;
			WLAST    <= wlast;
			wdata_ptr <= 0;
			last_write_address <= last_write_address;
		end
		else if( write_state[2] && AXI_LAST_OK)begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			awlen_temp <= awlen_temp;
			AWLEN    <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WID_TEMP <= WID_TEMP;
			WDATA    <= WDATA;
			WSTRB    <= WSTRB;
			WVALID   <= 1'b0;
			WLAST    <= wlast;
			wdata_ptr <= wdata_ptr + 1;
			last_write_address <= last_write_address;
		end
        else if( write_state[2] && AXI_DATA_OK)begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			awlen_temp <= awlen_temp;
			AWLEN    <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WID_TEMP <= WID_TEMP;
			WDATA    <= WDATA;
			WSTRB    <= WSTRB;
			WVALID   <= 1'b1;
			WLAST    <= wlast;
			wdata_ptr <= wdata_ptr + 1;
			last_write_address <= last_write_address;
		end
		else if( write_state[3] && AXI_RESP_OK && wen)begin
			AWADDR	 <= awaddr;
			AWVALID  <= 1;
			AWID     <= awid;
			awlen_temp <= awlen;
			AWLEN    <= awlen;
			AWSIZE   <= awsize;
			AWBURST  <= 2'b01;
			
			WDATA    <= wdata;
			WID_TEMP <= awid;
			WSTRB    <= wmask;
			WVALID   <= 0;
			WLAST    <= 0;	
			wdata_ptr <= 0;
			last_write_address <= awaddr;
		end
		else if( write_state[3])begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			awlen_temp <= 0;
			AWLEN    <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WID_TEMP <= 0;
			WDATA    <= 0;
			WSTRB    <= 0;
			WVALID   <= 0;
			WLAST    <= 0;
			wdata_ptr <= 0;
			last_write_address <= 0;
		end
		else begin
			AWADDR	 <= AWADDR;
			AWVALID  <= AWVALID;
			AWID     <= AWID;
			awlen_temp <= awlen_temp;
			AWLEN    <= AWLEN;
			AWSIZE   <= AWSIZE;
			AWBURST  <= AWBURST;
			
			WID_TEMP <= WID_TEMP;
			WDATA    <= WDATA;
			WSTRB    <= WSTRB;
			WVALID   <= WVALID;
			WLAST    <= WLAST;
			wdata_ptr <= wdata_ptr;
			last_write_address <= last_write_address;
	   end
	end

	assign WID  = (write_state[2])?WID_TEMP:{ID_WIDTH{1'b0}};
	assign writing = write_state[3] || write_state[2] || write_state[1];
	
endmodule
