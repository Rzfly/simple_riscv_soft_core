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
	output reg 	                AWREADY,
	
	input	   [DATA_WIDTH-1:0] WDATA,
	input	   [STRB_WIDTH-1:0] WSTRB,
	input		                WLAST,
	input	   [ID_WIDTH -1 :0] WID,
	input	  	                WVALID,
	output reg	                WREADY,
	
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
	output  reg                 ARREADY,
	
	output reg [DATA_WIDTH-1:0]	RDATA,
	output     [1:0]	        RRESP,
	output reg	                RLAST,
	output     [ID_WIDTH -1 :0] RID,
	output reg                 RVALID,
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
	           if(READ_ADDR_OK)begin
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
	           if(READ_DATA_OK)begin
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
			addr_a  <= 32'd0;	
			RVALID <= 1'b0;
			RLAST <= 1'b0;
			ARREADY <= 1'b0;
			RDATA   <= 32'd0;
			RID_temp <= {ID_WIDTH{1'b0}};
		end
		//handshake ok
		else if(read_state[0] & READ_ADDR_OK)begin
			req_a   <= 1'b1;
			addr_a  <= ARADDR;
			ARREADY <= 1'b0;
			RVALID <= 1'b0;
			RLAST <= 1'b0;
			RDATA   <= 32'd0;
			RID_temp <= ARID;
		end
		//hold valid
		else if(read_state[0] & read_req)begin
			req_a   <= 1'b0;
			addr_a  <= 32'd0;	
			ARREADY <= 1'b1;
			RVALID <= 1'b0;
			RLAST <= 1'b0;
			RDATA   <= 32'd0;
			RID_temp <= {ID_WIDTH{1'b0}};
		end
		else if(read_state[1] && mem_addr_ok_a)begin
			req_a   <= 1'b0;
			addr_a  <= addr_a;
			ARREADY <= 1'b0;
			RVALID <= 1'b0;
			RLAST <= 1'b0;
			RDATA   <= 32'd0;
			RID_temp <= RID_temp;
		end
		else if(read_state[2] && mem_data_ok_a)begin
			req_a   <= 1'b0;
			addr_a  <= addr_a;
			ARREADY <= 1'b0;
			RVALID <= 1'b1;
			RLAST <= 1'b1;
			RDATA   <= dout_a;
			RID_temp <= RID_temp;
		end
		else if(read_state[2] && READ_DATA_OK && read_req)begin
			req_a   <= 1'b0;
			addr_a  <= 32'd0;	
			ARREADY <= 1'b1;
			RVALID <= 1'b0;
			RLAST <= 1'b0;
			RDATA   <= 32'd0;
			RID_temp <= {ID_WIDTH{1'b0}};
		end
		else if(read_state[2] && READ_DATA_OK )begin
			req_a   <= 1'b0;
			addr_a  <= 32'd0;	
			ARREADY <= 1'b0;
			RVALID <= 1'b0;
			RLAST <= 1'b0;
			RDATA   <= 32'd0;
			RID_temp <= {ID_WIDTH{1'b0}};
	    end
	    else begin
			req_a   <= req_a;
			addr_a  <= addr_a;	
			ARREADY <= ARREADY;
			RVALID <= RVALID;
			RLAST <= RLAST;
			RDATA   <= RDATA;
			RID_temp <= RID_temp;
	    end
	end
	
	assign RID = (RVALID)?RID_temp:'d0;
    assign RRESP = 2'd0;
	
	assign write_req = AWVALID && WVALID;
	always@(*)begin
	    case(write_state) 
	       write_state_idle:begin
	           if( WRITE_ADDR_OK)begin
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
	           if(WRITE_RESP_OK)begin
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
			wem_b <= 4'd0;
			din_b  <= 32'd0;	
			addr_b  <= 32'd0;	
			BID_temp <=  {ID_WIDTH{1'b0}};	
			AWREADY <= 1'd0;
			WREADY <= 1'd0;	
			BVALID <= 1'd0;	
		end
		else if(write_state[0] && WRITE_ADDR_OK)begin
			req_b   <= 1'b1;
			we_b  <= 1'b1;
			wem_b <= WSTRB;
			din_b  <= WDATA;	
			addr_b  <=  AWADDR;
			BID_temp <= AWID;
			AWREADY <= 1'b0;
			WREADY <= 1'b0;	
			BVALID <= 1'd0;	
		end
		else if(write_state[0] && write_req)begin
			req_b   <= 1'b0;
			we_b  <= 1'b0;
			wem_b <= 4'd0;
			din_b  <= 32'd0;	
			addr_b  <=  32'd0;
			BID_temp <= {ID_WIDTH{1'b0}};	
			AWREADY <= 1'b1;
			WREADY <= 1'b1;	
			BVALID <= 1'd0;	
		end
		else if(write_state[1] && mem_addr_ok_b)begin
			req_b   <= 1'b0;
			we_b  <= 1'b0;
			wem_b <= 4'd0;
			din_b  <= 32'd0;	
			addr_b  <= 32'd0;
			BID_temp <= BID_temp;
			AWREADY <= 1'b0;
			WREADY <= 1'b0;	
			BVALID <= 1'd0;	
		end
		else if(write_state[2] && mem_data_ok_b)begin
			req_b   <= 1'b0;
			we_b  <= 1'b0;
			wem_b <= 4'd0;
			din_b  <= 32'd0;	
			addr_b  <= 32'd0;
			BID_temp <= BID_temp;
			AWREADY <= 1'b0;
			WREADY <= 1'b0;	
			BVALID <= 1'd1;	
		end
		else if(write_state[2] && WRITE_RESP_OK && write_req)begin
			req_b   <= 1'b0;
			we_b  <= 1'b0;
			wem_b <= 4'd0;
			din_b  <= 32'd0;	
			addr_b  <=  32'd0;
			BID_temp <= {ID_WIDTH{1'b0}};
			AWREADY <= 1'b1;
			WREADY <= 1'b1;	
			BVALID <= 1'd0;	
		end
		else if(write_state[2] && WRITE_RESP_OK )begin
			req_b   <= 1'b0;
			we_b  <= 1'b0;
			wem_b <= 4'd0;
			din_b  <= 32'd0;	
			addr_b  <= 32'd0;
			BID_temp <= {ID_WIDTH{1'b0}};
			AWREADY <= 1'b0;
			WREADY <= 1'b0;	
			BVALID <= 1'd0;	
		end
	    else begin
			req_b   <= req_b;
			we_b  <= we_b;
			wem_b <= wem_b;
			din_b  <= din_b;	
			addr_b  <= addr_b;	
			BID_temp <= BID_temp;
			AWREADY <= AWREADY;
			WREADY <= WREADY;	
			BVALID <= BVALID;	
	    end
	end
		
	assign BID = (BVALID)?BID_temp:'d0;
    assign BRESP = 2'd0;
	
	sram_bus_duelport_ram #(
		.FORCE_X2ZERO(0),
		.DP(`MEMORY_DEPTH),
		.DW(`DATA_WIDTH),
		.MW(`RAM_MASK_WIDTH),
		.AW(`DATA_WIDTH) 
	)sirv_duelport_ram_inst(
		.clk (ACLK ),
		.rst_n (ARESETn ),
		.cs  (1'b1),
		.req_a(req_a),
		.we_a  (we_a),
		.addr_a({2'b00,addr_a[`BUS_WIDTH - 1:2]}),
		.din_a (din_a ),
		.wem_a (wem_a),
		.dout_a(dout_a),
		.mem_addr_ok_a(mem_addr_ok_a),
		.mem_data_ok_a(mem_data_ok_a),
		.req_b(req_b),
		.we_b  (we_b  ),
		.addr_b({2'b00,addr_b[`BUS_WIDTH - 1:2]}),
		.din_b (din_b ),
		.wem_b (wem_b),
		.dout_b(dout_b),
		.mem_addr_ok_b(mem_addr_ok_b),
		.mem_data_ok_b(mem_data_ok_b)
	);

endmodule

//		wire ARREADY_test;
//   AXI_DUELPORTSRAM#(
//		.DATA_WIDTH(DATA_WIDTH),
//		.ADDR_WIDTH(ADDR_WIDTH),
//		.ID_WIDTH(ID_WIDTH),
//		.STRB_WIDTH(DATA_WIDTH/8)
//	)AXI_DUELPORTSRAM_inst(
//		.ACLK(clk),
//		.ARESETn(rst_n),
		
//		.AWADDR(m1_AWADDR),
//		.AWLEN(m1_AWLEN),
//		.AWSIZE(m1_AWSIZE), //length. less than the width of bus b'010
//		.AWBURST(m1_AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
//		.AWID(m1_AWID),
//		.AWVALID(m1_AWVALID),
//		.AWREADY(m1_AWREADY),
		
//		.WDATA(m1_WDATA),
//		.WSTRB(m1_WSTRB),
//		.WLAST(m1_WLAST),
//		.WID(m1_WID),
//		.WVALID(m1_WVALID),
//		.WREADY(m1_WREADY),
		
//		.BRESP(m1_BRESP),
//		.BID(m1_BID),
//		.BVALID(m1_BVALID),
//		.BREADY(m1_BREADY),

//		.ARADDR(m1_ARADDR),
//		.ARLEN(m1_ARLEN),
//		.ARSIZE(m1_ARSIZE),
//		.ARBURST(m1_ARBURST),
//		.ARID(m1_ARID),
//		.ARVALID(m1_ARVALID),
//		.ARREADY(m1_ARREADY),
		
//		.RDATA(m1_RDATA),
//		.RRESP(m1_RRESP),
//		.RLAST(m1_RLAST),
//		.RID(m1_RID),
//		.RVALID(m1_RVALID),
//		.RREADY(m1_RREADY)
//	);
	
    