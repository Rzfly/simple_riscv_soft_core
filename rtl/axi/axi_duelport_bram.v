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
module axi_duelport_bram #(
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
	output   	                WREADY,
	
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
	output                      ARREADY,
	
	output     [DATA_WIDTH-1:0]	RDATA,
	output     [1:0]	        RRESP,
	output    	                RLAST,
	output     [ID_WIDTH -1 :0] RID,
	output                      RVALID,
	input	 	                RREADY
	
);  
    wire READ_ADDR_OK;
	wire READ_DATA_OK;
	wire READ_LAST_OK;
    wire WRITE_ADDR_OK;
	wire WRITE_DATA_OK;
	wire WRITE_RESP_OK;
	wire WRITE_LAST_OK;
	
	assign READ_ADDR_OK   = ARVALID && ARREADY;
	assign READ_DATA_OK   = RVALID && RREADY;
	assign READ_LAST_OK   = RLAST && RREADY;
	assign WRITE_ADDR_OK   = AWVALID && AWREADY;
	assign WRITE_DATA_OK   = WVALID && WREADY;
	assign WRITE_LAST_OK   = WLAST && WREADY;
	assign WRITE_RESP_OK   = BVALID && BREADY;


//====================================================================
//========== write channel
//====================================================================

	localparam write_state_idle = 3'b001;
	localparam write_state_busy = 3'b010;
	localparam write_state_back = 3'b100;
	
	reg [2:0]write_state;
	reg [2:0]next_write_state;
		
	// axi reg
	reg [ADDR_WIDTH-1:0]write_start_addr;
	reg [ADDR_WIDTH-1:0]write_burst_addr;
	reg 		[8:0]	write_burst_step;
	reg 	 [ADDR_WIDTH-1:0]awaddr_stop_addr;
	reg    				    [3:0]	awlen;
	reg     				[2:0]	awsize;
	wire 			      	        wen;			
	reg  [ID_WIDTH - 1:0]BID_temp;
	
	// sram bus
	wire [ADDR_WIDTH-1:0]	    addr_a;
	wire [DATA_WIDTH-1:0]		din_a;
	wire [DATA_WIDTH-1:0]	    dout_a;
	wire     [ADDR_WIDTH-1:0]write_mem_addr;
	wire [3:0]		wea;
//	assign write_blocking = 1'b0;
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			write_state <= write_state_idle;
		end
		else begin
			write_state <= next_write_state;
		end
	end
	
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
	           if(  WRITE_LAST_OK && (write_burst_addr == awaddr_stop_addr) )begin
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
		
	
	
    //======================================================================
    //鍙傛暟�?�勫�?	
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)begin
			write_start_addr	<= 0;
			awlen				<= 0;
			awsize				<= 0;
			BID_temp            <= {ID_WIDTH{1'b0}};
		end
		else if(WRITE_ADDR_OK)begin
			write_start_addr	<= AWADDR;
			awlen			    <= AWLEN;
			awsize			    <= AWSIZE;
			BID_temp            <= AWID;
		end
		else if(write_state[1])begin
			write_start_addr	<= write_start_addr;
			awlen			    <= awlen;
			awsize			    <= awsize;
			BID_temp            <= BID_temp;
		end
		else if(write_state[2])begin
			write_start_addr	<= 'd0;
			awlen				<= 'd0;
			awsize				<= 'd0;
			BID_temp            <= BID_temp;
		end
		else begin
			write_start_addr	<= 'd0;
			awlen				<= 'd0;
			awsize				<= 'd0;
			BID_temp            <= {ID_WIDTH{1'b0}};
		end
	end
	
	always@(*) begin
		case(awsize)
		    //one byte
			3'h0:	write_burst_step = 16'h1;
			3'h1:	write_burst_step = 16'h2;
			//for bytes
			3'h2:	write_burst_step = 16'h4;
			default:write_burst_step = 16'h1;
		endcase
	end

	always@(*) begin
		case(awsize)
		    //once one byte
			3'h0:	awaddr_stop_addr = {28'd0,awlen};
		    //once two byte
			3'h1:	awaddr_stop_addr = {27'd0,awlen,1'b0};
		    //once four byte
			3'h2:	awaddr_stop_addr = {26'd0,awlen,2'b0};
			default:awaddr_stop_addr = {28'd0,awlen};
		endcase
	end
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			write_burst_addr <= 'd0;
		end
		else if(wen)begin
			write_burst_addr <= write_burst_addr + write_burst_step;
		end
		// else if(write_burst_addr == awaddr_stop_addr)begin
			// write_burst_addr <= 'd0;
		// end
		else if(write_state[1])begin
			write_burst_addr <= write_burst_addr;
		end
		else begin
			write_burst_addr <= 'd0;
		end
	end
	
	assign write_mem_addr = write_start_addr + write_burst_addr;
	assign wen =  WVALID & WREADY;
	assign WREADY = (BID_temp == WID)?write_state[1]:1'b0;
	assign AWREADY = write_state[0];
	
	assign BVALID  = write_state[2];
	assign BRESP   = 2'd0;
	assign BID = (BVALID)?BID_temp:'d0;

	assign addr_a = write_mem_addr;
	assign din_a  = WDATA;
	assign wea    = WSTRB & {4{wen}};		


//====================================================================
//========== read channel
//====================================================================
	
	localparam read_state_idle  = 2'b01;
	localparam read_state_busy  = 2'b10;
	
	reg [1:0]read_state;
	reg [1:0]next_read_state;
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			read_state  <= read_state_idle;
		end
		else begin
			read_state  <= next_read_state;
		end
	end
	
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
	           if(READ_LAST_OK)begin
        			next_read_state <= read_state_idle;
	           end
	           else begin
        			next_read_state <= read_state_busy;
	           end
	       end
	       default:begin
                next_read_state <= read_state_idle;
	       end
	    endcase
	end
	
	//axi regs
	reg [ID_WIDTH - 1 :0]RID_temp;
	reg	[ADDR_WIDTH - 1:0]	read_start_addr;	
	reg [ADDR_WIDTH - 1:0]  read_burst_addr;
	reg	[ADDR_WIDTH - 1:0]	read_burst_stop_addr;	
	reg [ADDR_WIDTH - 1:0]  read_burst_step;
	reg [3:0]				arlen;			
	reg [2:0]				arsize;
	reg [3:0]               fifo2master_ptr;
	// reg [3:0]               mem2fifo_ptr;		
	
	//sram bus
	reg 					mem2fifo_ptr_wen;
	wire 					fifo2master_fetch_enable;
	wire [ADDR_WIDTH - 1:0] 	dout_b;	
	wire [ADDR_WIDTH - 1:0] 	read_mem_addr;	
	wire [ADDR_WIDTH - 1:0] addr_b;
	reg enb;
	
	
	always@(*) begin
		case(arsize)
			3'h0:	read_burst_step = 32'h1;
			3'h1:	read_burst_step = 32'h2;
			3'h2:	read_burst_step = 32'h4;
			default:read_burst_step = 32'h1;
		endcase
	end

	//assign	araddr_stop = arlen*araddr_step;	//璁＄畻姝ヨ繘娆℃�?
	always@(*) begin
		case(arsize)
			3'h0:	read_burst_stop_addr = {28'h0,arlen};
			3'h1:	read_burst_stop_addr = {27'h0,arlen,1'b0};
			3'h2:	read_burst_stop_addr = {26'h0,arlen,2'b0};
			default:read_burst_stop_addr = {28'h0,arlen};
		endcase
	end

	
	assign fifo2master_fetch_enable = READ_DATA_OK;
	

//	assign enb = (read_burst_addr == read_burst_stop_addr)?1'b0:read_state[1];
	assign read_mem_addr = read_start_addr + read_burst_addr;
	assign addr_b = read_mem_addr;
//	assign addr_b = {2'b00,read_mem_addr[ADDR_WIDTH-1:2]};
	// wire addr_collid;
	// wire read_blocking;
    // assign addr_collid    = (addr_a == addr_b)?1'b1:1'b0;
	// assign read_blocking  = addr_collid && write_state[1];
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			mem2fifo_ptr_wen <= 1'b0;
		end
		else begin
			mem2fifo_ptr_wen <= enb;
		end
	end
	

	
    always@(posedge ACLK)begin
		if(!ARESETn)begin
			read_start_addr	<= 'd0;
			arlen				<= 'd0;
			arsize				<= 'd0;
			RID_temp <= 0;
		end
		else if(READ_ADDR_OK && read_state[0])begin
			read_start_addr	    <= ARADDR;
			arlen				<= ARLEN;
			arsize				<= ARSIZE;
			RID_temp            <= ARID;
		end
		else if(read_state[1] && READ_LAST_OK)begin
			read_start_addr	    <= 'd0;
			arlen				<= 'd0;
			arsize				<= 'd0;
			RID_temp            <= 0;
		end
		else begin
			read_start_addr	    <= read_start_addr;
			arlen			    <= arlen;
			arsize			    <= arsize;
			RID_temp            <= RID_temp;
		end
	end
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			read_burst_addr <= 'd0;
			enb <= 1'b0;
		end	
		else if(READ_ADDR_OK && read_state[0])begin
			read_burst_addr <= 'd0;
			enb <= 1'b1;
		end
		else if((read_burst_addr == read_burst_stop_addr) && read_state[1])begin
			read_burst_addr <= read_burst_addr;
			enb <= 1'b0;
		end
		else if(read_state[1])begin
			read_burst_addr <= read_burst_addr + read_burst_step;
			enb <= 1'b1;
		end
		else begin
			read_burst_addr <= 'd0;
			enb <= 1'b0;
		end
	end
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			fifo2master_ptr <= 'd0;
		end
		else if(READ_LAST_OK && fifo2master_fetch_enable)begin
			fifo2master_ptr <= 'd0;
		end
		else if(fifo2master_fetch_enable)begin
			fifo2master_ptr <= fifo2master_ptr + 4'b1;
		end
		else begin
			fifo2master_ptr <= fifo2master_ptr;
		end
	end
	
	assign RLAST = (fifo2master_ptr == arlen)?RVALID:1'b0;
		
//	always@(posedge ACLK)begin
//		if(!ARESETn)begin
//			RLAST  <= 'd0;
//		end
//		else if((fifo2master_ptr == 4'b1110) && fifo2master_fetch_enable)begin
//			RLAST <= RVALID;
//		end
//		else if((fifo2master_ptr == 4'b1111) && fifo2master_fetch_enable)begin
//			RLAST <= 1'b0;
//		end
//		else begin
//			RLAST <= RLAST;
//		end
//	end
	assign ARREADY = read_state[0];
	assign RID = (RVALID)?RID_temp:'d0;
    assign RRESP = 2'd0;
	
	
    syc_fifo #(
		.DATA_WIDTH(32),
		.DEPTH(16),
		.PTR_LENGTH(5)
	)syc_fifo_inst(
		.clk(ACLK),
		.rst_n(ARESETn),
		.wdata(dout_b),
		.w_address(),
		.w_req(mem2fifo_ptr_wen),
		.write_enable(),
		.full(),
		.rdata(RDATA),
		.r_address(),
		.r_req(fifo2master_fetch_enable),
		.read_enable(RVALID),
		.empty()
	);



//=================================================================================
//memory itself
`ifdef DRAM
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
		.req_a(1'b1),
		.we_a  (1'b0),
		.addr_a({2'b00,addr_b[`BUS_WIDTH - 1:2]}),
		.din_a (32'd0 ),
		.wem_a (4'd0),
		.dout_a(dout_b),
		.req_b(1'b1),
		.we_b  (wen  ),
		.addr_b({2'b00,addr_a[`BUS_WIDTH - 1:2]}),
		.din_b (din_a ),
		.wem_b (wea),
		.dout_b(dout_a)
	);

`else
	blk_mem_gen_1 blk_mem_gen_1_48KB (
		.clka(ACLK),    // input wire clka
//		.ena(1'b1),      // input wire ena
		.wea(wea),      // input wire [3 : 0] wea
		.addra(addr_a),  // input wire [14 : 0] addra
		.dina(din_a),    // input wire [31 : 0] dina
		.clkb(ACLK),    // input wire clkb
//		.rstb(!ARESETn),    // input wire rstb
//		.enb(1'b1),      // input wire enb
		.addrb(addr_b),  // input wire [14 : 0] addrb
		.doutb(dout_b)  // output wire [31 : 0] doutb
	);
`endif

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
	
    