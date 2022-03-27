`include "include.v"
module cache2axi#(
  parameter   DATA_WIDTH  = `AXI_DATA_WIDTH,               //数据位宽
  parameter   ADDR_WIDTH  = `AXI_ADDR_WIDTH,               //地址位宽              
  parameter   ID_WIDTH    = `AXI_ID_WIDTH,                //ID位宽
  parameter   STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
  )(
	input ACLK,
	input ARESETn,
	//from master
	input [2:0]master_id,
	input [3:0]slave_id,
	//read channel
	input rd_req,
	input [3:0]rd_type,
	input [`BUS_WIDTH - 1 : 0]rd_addr,
	output rd_rdy,
	output ret_valid,
	output ret_last,
	output [`DATA_WIDTH - 1:0]ret_data,
	//write channel
	input                      wr_req,
	input [3:0]                wr_type,
	input [`BUS_WIDTH - 1 : 0] wr_addr,
	input [`RAM_MASK_WIDTH - 1 : 0]wr_wstrb,
	//for word
	input  [127: 0]            wr_data,
	output                     wr_rdy,
	input			      	    ext_mem_writing,
	input 	[ADDR_WIDTH -1:0]  	ext_last_write_address,
	
	output   			      		mem_writing,
	output reg [ADDR_WIDTH -1:0]  	last_write_address,
	
	//to slave
    //address
	output	reg[ADDR_WIDTH-1:0] AWADDR,
	output	reg[3:0]            AWLEN,
	output	reg[2:0]            AWSIZE, 
	output	reg[1:0]	        AWBURST,
	output	reg[ID_WIDTH - 1:0] AWID,
	output  reg                 AWVALID,
	input                       AWREADY,
    //data
	output	reg[DATA_WIDTH-1:0] WDATA,
    output  reg[STRB_WIDTH-1:0] WSTRB,//mask
   	output  reg                 WLAST,
	output	   [ID_WIDTH - 1:0] WID,//match awid
    output  reg                 WVALID,
    input                       WREADY,
    //resp
   	input      [1:0]            BRESP,//00 = OKAY
	input	   [ID_WIDTH - 1:0] BID,//match awid
    input                       BVALID,
   	output  reg                 BREADY,
   	
    //address                
	output reg [ADDR_WIDTH-1:0] ARADDR,
	output reg [3:0]            ARLEN,
	output reg [2:0]	     ARSIZE,
	output reg  [1:0]	     ARBURST,
	output reg [ID_WIDTH-1:0]   ARID,
	output 	     	     ARVALID,
	input    	                ARREADY,
	//data                
	input      [DATA_WIDTH-1:0]	RDATA,
   	input      [1:0]	        RRESP,//can be ignored
	input    	                RLAST,
	input      [ID_WIDTH-1:0]	RID,
	input                       RVALID,
	output reg                  RREADY
);

//*************************************************************
//	cache write channel
//*************************************************************
	//no outstanding
	localparam waddr_state_idle        = 4'b0001;
	localparam waddr_state_req_full    = 4'b0010;
	localparam waddr_state_transfering = 4'b0100;
	localparam waddr_state_wait_over   = 4'b1000;
	
	wire WRITE_ADDR_OK;
	wire WRITE_DATA_OK;
	wire WRITE_RESP_OK;
	wire WRITE_LAST_OK;
	assign WRITE_ADDR_OK = AWVALID && AWREADY;
	assign WRITE_DATA_OK = WVALID && WREADY;
	assign WRITE_LAST_OK = WLAST && WREADY;
	assign WRITE_RESP_OK = BREADY && BVALID;
	reg [ID_WIDTH - 1:0] WID_TEMP;
	// reg [ID_WIDTH - 1:0] WDATA_TEMP;
	//address and data channel
	reg [3:0]write_state;
	reg [3:0]next_write_state;
	reg [31:0]cache_wr_data_d[3:0];
	reg [1:0]w_ptr_end;
	reg [2:0]wr_type_d;
	reg [1:0]wdata_ptr;
	wire [1:0]wdata_ptr_next;
	wire [3:0]awlen;
	wire wlast_next;
	
	wire [ID_WIDTH - 1:0]axi_awid;
	wire [ID_WIDTH - 1:0]axi_wid;

	assign awlen = wr_type;
	
	assign wdata_ptr_next = wdata_ptr + 1;
	assign axi_awid = {master_id, slave_id};
	assign axi_wid = {master_id, slave_id};

	always@(*)begin
		case(wr_type_d)
			3'b000:begin
				w_ptr_end <= 2'b00;
			end
			3'b001:begin
				w_ptr_end <= 2'b00;
			end
			3'b010:begin
				w_ptr_end <= 2'b00;
			end
			3'b100:begin
				w_ptr_end <= 2'b11;
			end
			default:begin
				w_ptr_end <= 2'b00;
			end
		endcase
	end
	assign wlast_next = (w_ptr_end == wdata_ptr)?1'b1:1'b0;
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			cache_wr_data_d[0] <= 'd0;
			cache_wr_data_d[1] <= 'd0;
			cache_wr_data_d[2] <= 'd0;
			cache_wr_data_d[3] <= 'd0;
			wr_type_d <= 'd0;
		end
		else if(wr_req && wr_rdy)begin
			cache_wr_data_d[0] <= wr_data[31:0];
			cache_wr_data_d[1] <= wr_data[63:32];
			cache_wr_data_d[2] <= wr_data[95:64];
			cache_wr_data_d[3] <= wr_data[127:96];
			wr_type_d <= wr_type;
		end
	end
	
	always@(posedge ACLK)begin
		if(!ARESETn)begin
			write_state <= waddr_state_idle;
		end
		else begin
			write_state <= next_write_state;
		end
	end
	
//	assign wdata_ok = wresp_state[1] && BVALID;
	assign wr_rdy = write_state[0];

	//write data fsm
	always@(*)begin
		case(write_state)
			//receive req
			waddr_state_idle:begin
				if (wr_req && wr_rdy)begin
					next_write_state <= waddr_state_req_full;
				end
				else begin
					next_write_state <= waddr_state_idle;
				end
			end
			//reqing slave. data channel combines address channel
			waddr_state_req_full:begin
				if(WRITE_ADDR_OK) begin
					next_write_state <= waddr_state_transfering;
				end
				else begin
					next_write_state <= waddr_state_req_full;
				end
			end
			waddr_state_transfering:begin
				if ( WRITE_LAST_OK )begin
					next_write_state <= waddr_state_wait_over;
				end
				else begin
					next_write_state <= waddr_state_transfering;
				end
			end
			//write over
			waddr_state_wait_over:begin
                if( WRITE_RESP_OK )begin
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
		else if( write_state[3] && WRITE_RESP_OK)begin
			BREADY   <= 0;
		end
		else if( write_state[3] || write_state[1] || write_state[2])begin
			BREADY   <= 1'b1;
		end
		else begin
			BREADY   <= BREADY;
	   end
	end
	
    //write_fsm
//    always@(posedge ACLK)begin
//		if(!ARESETn)begin
//			wdata_ok <= 0;
//		end
//		else if( write_state[0] || write_state[1] || write_state[2])begin
//			wdata_ok <= 0;
//		end
//		else if( write_state[3] && WRITE_RESP_OK)begin
//			wdata_ok <= 1;
//		end
//		else begin
//			wdata_ok <= wdata_ok;
//	   end
//	end
	
	//write_fsm
    always@(posedge ACLK)begin
		if(!ARESETn)begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
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
		else if( write_state[0] && wr_req )begin
			AWADDR	 <= wr_addr;
			AWVALID  <= 1;
			AWID     <= axi_awid;
			AWLEN    <= awlen;
			AWSIZE   <= 3'b010;
			AWBURST  <= 2'b01;
			
			WDATA    <= 'd0;
			WID_TEMP <= axi_wid;
			WSTRB    <= wr_wstrb;
			WVALID   <= 0;
			WLAST    <= 0;	
			wdata_ptr <= 0;
			last_write_address <= wr_addr;
		end
		else if( write_state[0])begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
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
		else if( write_state[1] && WRITE_ADDR_OK)begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			AWLEN    <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WID_TEMP <= WID_TEMP;
			WDATA    <= cache_wr_data_d[wdata_ptr];
			WSTRB    <= WSTRB;
			WVALID   <= 1'b1;
			WLAST    <= wlast_next;
			wdata_ptr <= wdata_ptr_next;
			last_write_address <= last_write_address;
		end
		else if( write_state[2] && WRITE_LAST_OK)begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			AWLEN    <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WID_TEMP <= 'd0;
			WDATA    <= 'd0;
			WSTRB    <= 'd0;
			WVALID   <= 1'b0;
			WLAST    <= 1'b0;
			wdata_ptr <= 'd0;
			last_write_address <= last_write_address;
		end
        	else if( write_state[2] && WRITE_DATA_OK)begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
			AWLEN    <= 0;
			AWSIZE   <= 0;
			AWBURST  <= 2'b00;
			
			WID_TEMP <= WID_TEMP;
			WDATA    <= cache_wr_data_d[wdata_ptr];
			WSTRB    <= WSTRB;
			WVALID   <= 1'b1;
			WLAST    <= wlast_next;
			wdata_ptr <= wdata_ptr_next;
			last_write_address <= last_write_address;
		end
		else if( write_state[3])begin
			AWADDR	 <= 0;
			AWVALID  <= 0;
			AWID     <= 0;
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
	assign mem_writing = write_state[3] || write_state[2] || write_state[1];

//*************************************************************
//	cache read channel
//*************************************************************
	
    wire READ_ADDR_OK;
	wire READ_DATA_OK;
	wire READ_DATA_LAST;
	assign READ_ADDR_OK   = ARVALID && ARREADY;
	assign READ_DATA_OK   = RVALID && RREADY;
	assign READ_DATA_LAST = RLAST && RREADY;
	
	wire rom_read_disable;
	assign rom_read_disable = (ARADDR == ext_last_write_address)?ext_mem_writing:1'b0;
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
	wire [3:0]arlen;
	reg [1:0] rdata_ptr;
	wire [1:0]rdata_ptr_next;
	reg ret_valid_reg;
	reg ret_last_reg;
	reg [`DATA_WIDTH - 1:0]ret_data_reg;
	
	wire [ID_WIDTH - 1:0]axi_arid;
	reg [ID_WIDTH - 1:0]axi_rid;
	
	assign axi_arid = {master_id, slave_id};
	assign rdata_ptr_next = rdata_ptr + 1;
	assign arlen = rd_type;
	assign ret_valid = ret_valid_reg;
	assign rd_rdy = raddr_state[0] & rdata_state[0];
	assign ret_last = ret_last_reg;
	assign ret_data = ret_data_reg;

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
				if (rd_req && rd_rdy && (rdata_state[0]))begin
					next_raddr_state <= raddr_state_req;
				end
				else begin
					next_raddr_state <= raddr_state_idle;
				end
			end
			// req_count[1] = max_req
			raddr_state_req:begin
				if ( READ_ADDR_OK)begin
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
		else if( rd_req && rd_rdy && (rdata_state[0])) begin
			ARADDR <= rd_addr;
			ARLEN <= arlen;
			ARSIZE <= 3'b010;
			ARBURST <= 2'b01;
			ARID <= axi_arid;
			ARVALID_reg <= 1'b1;
		end
		else if(READ_ADDR_OK && raddr_state[1])begin
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
	
	
	//read data fsm
	always@(*)begin
		case(rdata_state)
			//receive req
			rdata_state_idle:begin
				if (READ_ADDR_OK)begin
					next_rdata_state <= rdata_state_transfer;
				end
				else begin
					next_rdata_state <= rdata_state_idle;
				end
			end
			//reqing slave. data channel combines address channel
			rdata_state_transfer:
				if ( READ_DATA_LAST)begin
					next_rdata_state <= rdata_state_idle;
				end
				//if non last or req > 1, transfer
				else begin
					next_rdata_state <= rdata_state_transfer;
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
			ret_valid_reg <= 'd0;
			ret_last_reg <= 'd0;
			ret_data_reg <= 'd0;
			rdata_ptr <= 'd0;
		end
        else begin
            case(rdata_state)
                rdata_state_idle:begin
                    if(READ_ADDR_OK)begin
                        RREADY <= 1'b1;
                        ret_valid_reg <= ret_valid_reg;
                        ret_last_reg <= ret_last_reg;
                        ret_data_reg <= ret_data_reg;
                        rdata_ptr <= rdata_ptr;
                    end
                    else begin
                        RREADY <= 1'b0;
                        ret_valid_reg <= 'd0;
                        ret_last_reg <= 'd0;
                        ret_data_reg <= 'd0;
                        rdata_ptr <= 'd0;
                    end
                end
                rdata_state_transfer:begin
                	if(READ_DATA_LAST) begin
                        RREADY <= 1'b0;
                        ret_valid_reg <= 1'b1;
                        ret_last_reg <= RLAST;
                        ret_data_reg <= RDATA;
                        rdata_ptr <= 'd0;
                    end
                    else if(READ_DATA_OK)begin
                        RREADY <= RREADY;
                        ret_valid_reg <= 1'b1;
                        ret_last_reg <= ret_last_reg;
                        ret_data_reg <= RDATA;
                        rdata_ptr <= rdata_ptr_next;
                    end
                    else begin
                        RREADY       <= RREADY;
                        ret_valid_reg <= 1'b0;
                        ret_last_reg <= ret_last_reg;
                        ret_data_reg <= ret_data_reg;
                        rdata_ptr    <= rdata_ptr;
                    end
                end
                default:begin
                    RREADY        <= RREADY;
                    ret_valid_reg <= ret_valid_reg;
                    ret_last_reg  <= ret_last_reg;
                    ret_data_reg  <= ret_data_reg;
                    rdata_ptr     <= rdata_ptr;            
                end
            endcase
        end
    end	


endmodule
