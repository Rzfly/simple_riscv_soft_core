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
module AXI_DUELPORTSRAM #(
  parameter   DATA_WIDTH  = 32,               //数据位宽
  parameter   ADDR_WIDTH  = 32,               //地址位宽              
  parameter   ID_WIDTH    = 6,                //ID位宽
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
	input	 	                RREADY
	
);  

	wire  [DATA_WIDTH - 1  :0] din_a = 'd0;
	reg  [DATA_WIDTH - 1  :0] din_b; 
	reg  [ADDR_WIDTH - 1  :0] addr_a;
	reg  [ADDR_WIDTH - 1  :0] addr_b;
	wire             we_a = 'd0;
	reg             req_a;
	reg             we_b;
	reg             req_b;
	wire  [STRB_WIDTH - 1:0]   wem_a = 'd0;
	reg  [STRB_WIDTH - 1:0]   wem_b;
	wire [DATA_WIDTH - 1:0]   dout_a;
	wire [DATA_WIDTH - 1:0]   dout_b;
	wire mem_addr_ok_a;
	wire mem_data_ok_a;
	wire mem_addr_ok_b;
	wire mem_data_ok_b;
	
	wire read_req;
	wire write_req;
	assign read_req = ARVALID;
	assign write_req = AWVALID && WVALID;

	
    wire WRITE_ADDR_OK;
    wire READ_ADDR_OK;
	wire WRITE_RESP_OK;
	wire READ_DATA_OK;
	assign READ_ADDR_OK   = ARVALID && ARREADY;
	assign READ_DATA_OK   = RVALID && RREADY;
	assign WRITE_ADDR_OK   = AWVALID && AWREADY && WVALID && WREADY;
	assign WRITE_RESP_OK   = BVALID && BREADY;
	
	reg [ID_WIDTH - 1 :0]BID_temp;
	reg [ID_WIDTH - 1 :0]RID_temp;

	
	localparam write_state_idle = 3'b001;
	localparam write_state_busy = 3'b010;
	localparam write_state_back = 3'b100;
	
	localparam read_state_idle = 3'b001;
	localparam read_state_busy = 3'b010;
	localparam read_state_back = 3'b100;
	
	reg [2:0]write_state;
	reg [2:0]next_write_state;
	
	reg [2:0]read_state;
	reg [2:0]next_read_state;
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			write_state <= write_state_idle;
			read_state  <= read_state_idle;
		end
		else begin
			write_state <= next_write_state;
			read_state  <= next_read_state;
		end
	end
	
    assign read_req = ARVALID;	
    always@(*)begin
	    case(read_state) 
	       read_state_idle:begin
	           if(read_req)begin
        			next_read_state <= read_state_busy;
	           end
	           else begin
        			next_read_state <= read_state_idle;
	           end
	       end
	       read_state_busy:begin
	           if(mem_addr_ok_a)begin
        			next_read_state <= read_state_back;
	           end
	           else begin
        			next_read_state <= read_state_busy;
	           end
	       end
           read_state_back:begin
	           if(READ_DATA_OK && read_req)begin
        			next_read_state <= read_state_busy;
	           end
	           else if(READ_DATA_OK && !read_req)begin
        			next_read_state <= read_state_idle;
	           end
	           else begin
        			next_read_state <= read_state_back;
	           end
	       end
	       default:begin
                next_read_state <= read_state_idle;
	       end
	    endcase
	end
	
    always@(posedge ACLK)begin
		if(!ARESETn)begin
			req_a   <= 1'b0;
			addr_a  <= 'd0;	
			RID_temp <=  'd0;
		end
		else if(read_state[0] && read_req)begin
			req_a   <= 1'b1;
			addr_a  <= ARADDR;	
			RID_temp <= ARID;
		end
		else if(read_state[1] && READ_ADDR_OK)begin
			req_a   <= 1'b0;
			addr_a  <= 'd0;	
			RID_temp <= RID_temp;
		end
		else if(read_state[2] && READ_DATA_OK && read_req)begin
			req_a   <= 1'b1;
			addr_a  <= ARADDR;	
			RID_temp <= ARID;
		end
	    else begin
			req_a   <= req_a;
			addr_a  <= addr_a;	
			RID_temp <= RID_temp;
	    end
	end
	
	
	assign RID = (read_state[2])?RID_temp:'d0;
    assign RRESP = 'd0;
	assign RVALID = (read_state[2])?1'b1:1'b0;
	assign RLAST  = (read_state[2])?1'b1:1'b0;
	assign RDATA  =(read_state[2])?dout_a:'d0;
	assign ARREADY = read_state[1] & mem_addr_ok_a;
	
	assign write_req = AWVALID && WVALID;
	always@(*)begin
	    case(write_state) 
	       write_state_idle:begin
	           if(write_req)begin
        			next_write_state <= write_state_busy;
	           end
	           else begin
        			next_write_state <= write_state_idle;
	           end
	       end
	       write_state_busy:begin
	           if(  mem_addr_ok_b)begin
        			next_write_state <= write_state_back;
	           end
	           else begin
        			next_write_state <= write_state_busy;
	           end
	       end
           write_state_back:begin
	           if(WRITE_RESP_OK && write_req)begin
        			next_write_state <= write_state_busy;
	           end
	           else if(WRITE_RESP_OK && !write_req)begin
        			next_write_state <= write_state_idle;
	           end
	           else begin
        			next_write_state <= write_state_back;
	           end
	       end
	       default:begin
                next_write_state <= write_state_idle;
	       end
	    endcase
	end
	
    always@(posedge ACLK)begin
		if(!ARESETn)begin
			req_b   <= 1'b0;
			we_b  <= 1'b0;
			wem_b <= 'd0;
			din_b  <= 'd0;	
			addr_b  <= 'd0;	
			BID_temp <= 'd0;	
		end
		else if(write_state[0] && write_req)begin
			req_b   <= 1'b1;
			we_b  <= 1'b1;
			wem_b <= WSTRB;
			din_b  <= WDATA;	
			addr_b  <= AWADDR;	
			BID_temp <= AWID;
		end
		else if(write_state[1] && WRITE_ADDR_OK)begin
			req_b   <= 1'b0;
			we_b  <= 'd0;	
			wem_b <= 'd0;
			din_b  <= 'd0;	
			addr_b  <= 'd0;	
			BID_temp <= BID_temp;
		end
		else if(write_state[2] && WRITE_RESP_OK && write_req)begin
			req_b   <= 1'b1;
			we_b  <= 1'b1;
			wem_b <= WSTRB;
			din_b  <= WDATA;	
			addr_b  <= AWADDR;	
			BID_temp <= AWID;
		end
	    else begin
			req_b   <= req_b;
			we_b  <= we_b;
			wem_b <= wem_b;
			din_b  <= din_b;	
			addr_b  <= addr_b;	
			BID_temp <= BID_temp;
	    end
	end
		
	assign AWREADY = write_state[1] & mem_addr_ok_b;
	assign WREADY = write_state[1] & mem_addr_ok_b;
	assign BID = (write_state[2])?BID_temp:'d0;
	assign BID = BID_temp;
    assign BRESP = 'd0;
	assign BVALID =(write_state[2])?1'b1:1'b0;
	
	sirv_duelport_ram #(
		.FORCE_X2ZERO(0),
		.DP(`MEMORY_DEPTH),
		.DW(`DATA_WIDTH),
		.MW(`RAM_MASK_WIDTH),
		.AW(`DATA_WIDTH) 
	)sirv_duelport_ram_inst(
		.clk (ACLK ),
		.rst_n (ARESETn ),
		.cs  (1'b1),
		.req_a(read_req),
		.we_a  (we_a),
		.addr_a({2'b00,addr_a[`BUS_WIDTH - 1:2]}),
		.din_a (din_a ),
		.wem_a (wem_a),
		.dout_a(dout_a),
		.mem_addr_ok_a(mem_addr_ok_a),
		.mem_data_ok_a(mem_data_ok_a),
		.req_b(write_req),
		.we_b  (we_b  ),
		.addr_b({2'b00,addr_b[`BUS_WIDTH - 1:2]}),
		.din_b (din_b ),
		.wem_b (wem_b),
		.dout_b(dout_b),
		.mem_addr_ok_b(mem_addr_ok_b),
		.mem_data_ok_b(mem_data_ok_b)
	);

endmodule
