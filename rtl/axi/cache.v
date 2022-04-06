`include "include.v"

module cache(
	input clk,
	input rst_n,
	//from core srambus
	input mem_req,
	input mem_we,
	input [`BUS_WIDTH - 1 : 0]mem_address,
	input [`RAM_MASK_WIDTH - 1 : 0]mem_wem,
	input [`DATA_WIDTH - 1 : 0]mem_wdata,
	output [`DATA_WIDTH - 1 : 0]mem_rdata,
	output cache_addr_ok,
	output cache_data_ok,
	input  mem_writing,
    input  [`BUS_WIDTH - 1 : 0]mem_last_write_address,
	//to mem,axi_bus,single channel used
	output [3:0]slave_id,
	output rd_req,
	input rd_rdy,
	output [3:0]rd_type,
	output [`BUS_WIDTH - 1 : 0]rd_addr,
	input ret_valid,
	input ret_last,
	input [`DATA_WIDTH - 1:0]ret_data,
	output wr_req,
	input wr_rdy,
	output [3:0]wr_type,
	output [`BUS_WIDTH - 1 : 0]wr_addr,
	output [`RAM_MASK_WIDTH - 1 : 0]wr_wstrb,
	//for word
	output [127: 0]wr_data

);
	//cache 2kB = 8 * 16 * 16  Byte = 32 * 16 * 4 BYTE  4 + 4 + 3  9 + 2   5 + 6
	//I cache 1kB = 4 * 16 * 16  Byte = 2 * 32 * 4 word  1 + 5 + 4  
	//total 64KB = 6 + 10 = 7 + 9 = 16 = 32 - 16 
	wire [22:0]block_tag_address;
//	wire [23:0]tagV_address;
	wire valid_cache_row;
	wire dirty_cache_row;
	wire [4:0]ext_mem_writing_index;
	wire [22:0]ext_mem_writing_tag_address;
	//total 9bit
	wire [4:0]block_index_address;
	//4 word 16 BYTE
	wire [3:0]block_bias;
	wire cache_req;
	wire uncache_req;
	
	
	//   cache_bank_32_23bit_way0_address;
//	reg [4:0] cache_tagv_32_23bit_way0_address;
	wire [4:0] cache_tagv_32_23bit_way0_address;
	wire [23:0]cache_tagv_32_23bit_way0_dout;
	wire [4:0] cache_tagv_32_23bit_way0_address_2;
	wire [23:0]cache_tagv_32_23bit_way0_dout_2;
	wire [23:0]cache_tagv_32_23bit_way0_din;
	wire cache_tagv_32_23bit_way0_we;
	
	//   cache_bank_32_23bit_way1_address;
//	reg [4:0] cache_tagv_32_23bit_way1_address;
	wire [4:0] cache_tagv_32_23bit_way1_address_2;
	wire [23:0]cache_tagv_32_23bit_way1_dout_2;
	wire [4:0] cache_tagv_32_23bit_way1_address;
	wire [23:0]cache_tagv_32_23bit_way1_dout;
	wire [23:0]cache_tagv_32_23bit_way1_din;
	wire cache_tagv_32_23bit_way1_we;
	
	//cache_bank_32_word_way0;
	wire [31:0] cache_bank_32_word_way0_bank0_address;
	wire [31:0]cache_bank_32_word_way0_bank0_dout;
	reg [31:0]cache_bank_32_word_way0_bank0_din;
	wire cache_bank_32_word_way0_bank0_we;
	reg [3:0]cache_bank_32_word_way0_bank0_wem;
	wire [31:0] cache_bank_32_word_way0_bank1_address;
	wire [31:0]cache_bank_32_word_way0_bank1_dout;
	reg [31:0]cache_bank_32_word_way0_bank1_din;
	wire cache_bank_32_word_way0_bank1_we;
	reg [3:0]cache_bank_32_word_way0_bank1_wem;
	wire [31:0] cache_bank_32_word_way0_bank2_address;
	wire [31:0]cache_bank_32_word_way0_bank2_dout;
	reg [31:0]cache_bank_32_word_way0_bank2_din;
	wire cache_bank_32_word_way0_bank2_we;
	reg [3:0]cache_bank_32_word_way0_bank2_wem;
	wire [31:0] cache_bank_32_word_way0_bank3_address;
	wire [31:0]cache_bank_32_word_way0_bank3_dout;
	reg [31:0]cache_bank_32_word_way0_bank3_din;
	wire cache_bank_32_word_way0_bank3_we;
	reg [3:0]cache_bank_32_word_way0_bank3_wem;
	
	//cache_bank_32_word_way1;
	wire [31:0] cache_bank_32_word_way1_bank0_address;
	wire [31:0]cache_bank_32_word_way1_bank0_dout;
	reg [31:0]cache_bank_32_word_way1_bank0_din;
	wire cache_bank_32_word_way1_bank0_we;
	reg [3:0]cache_bank_32_word_way1_bank0_wem;
	wire [31:0] cache_bank_32_word_way1_bank1_address;
	wire [31:0]cache_bank_32_word_way1_bank1_dout;
	reg [31:0]cache_bank_32_word_way1_bank1_din;
	wire cache_bank_32_word_way1_bank1_we;
	reg [3:0]cache_bank_32_word_way1_bank1_wem;
	wire [31:0] cache_bank_32_word_way1_bank2_address;
	wire [31:0]cache_bank_32_word_way1_bank2_dout;
	reg [31:0]cache_bank_32_word_way1_bank2_din;
	wire cache_bank_32_word_way1_bank2_we;
	reg [3:0]cache_bank_32_word_way1_bank2_wem;
	wire [31:0] cache_bank_32_word_way1_bank3_address;
	wire [31:0]cache_bank_32_word_way1_bank3_dout;
	reg [31:0]cache_bank_32_word_way1_bank3_din;
	wire cache_bank_32_word_way1_bank3_we;
	reg [3:0]cache_bank_32_word_way1_bank3_wem;
	reg way0_bank0_write_req;
	reg way0_bank1_write_req;
	reg way0_bank2_write_req;
	reg way0_bank3_write_req;
	reg way1_bank0_write_req;
	reg way1_bank1_write_req;
	reg way1_bank2_write_req;
	reg way1_bank3_write_req;
	reg [31:0]cache_way0_dirty;
	reg [31:0]cache_way1_dirty;
	
	//control signal
	wire cache_way0_req_hit;
	wire cache_way1_req_hit;
	wire cache_way0_writing_hazard;
	wire cache_way1_writing_hazard;
	wire cache_req_hit;
	reg cache_req_hit_d;
	reg cache_way0_req_hit_d;
	reg cache_way1_req_hit_d;
	wire cache_req_not_hit;
	wire cache_miss;
//	wire cache_miss_d;
//	wire uncache_req_complete;
	wire replace_req_ok;
	reg replace_data_ok;
	wire refill_req_ok;
	wire refill_data_ok;
	reg cache_write_miss;
	reg cache_read_miss;
	reg cache_replace_order;

    reg  [31: 0]mem_address_d;
    reg  [31: 0]mem_wdata_d;
    reg  [`BUS_WIDTH - 1 : 0]rd_addr_d;
    reg  [`BUS_WIDTH - 1 : 0]wr_addr_d;
    reg  [3:0]rd_type_d;
    reg  [3:0]wr_type_d;
    wire [3:0]slave_id_decode;
    reg  [3:0]slave_id_d;
	reg  [31: 0]req_hit_rdata;
//	reg  [3:0]wem_d;
//	wire [31: 0]uncache_rdata;
	wire [22: 0]block_tag_address_d;
	wire [4: 0]block_index_address_d;
	wire [3: 0]block_bias_d;
	wire [127: 0]way0_wr_data;
	wire [127: 0]way1_wr_data;
	wire next_refill_way;
	wire way0_write_req;
	wire way1_write_req;
	wire way0_refill_req;
	wire way1_refill_req;
	wire req_handshake_ok;
	reg uncache_req_d;
	reg cache_req_d;
	reg mem_we_d;
	reg [3:0]refill_index;
	reg [`RAM_MASK_WIDTH - 1 : 0]mem_wem_d;
	wire direct_index_state;
	wire [4:0]ram_bank_address_selection;
	wire [4:0]tagv_address_selection;
	
	//memory
    localparam [3:0]slave_0   = 4'b0000;
    localparam [3:0]slave_1   = 4'b0001;
    //timer
    localparam [3:0]slave_2   = 4'b0010;
    //uart
    localparam [3:0]slave_3   = 4'b0011;
    //gpio
    localparam [3:0]slave_4   = 4'b0100;

    wire slave_mem   = ((mem_address[31:28] == slave_0) || (mem_address[31:28] == slave_1))?1'b1:1'b0;
    wire slave_timer = ((mem_address[31:28] == slave_2) )?1'b1:1'b0;
    wire slave_uart  = ((mem_address[31:28] == slave_3))?1'b1:1'b0;
    wire slave_gpio  = ((mem_address[31:28] == slave_4))?1'b1:1'b0;

    assign slave_id_decode = { 
        slave_gpio,
        slave_gpio|slave_uart,
        slave_gpio|slave_timer|slave_uart,
        slave_gpio|slave_timer|slave_mem|slave_uart
    };
    
    
	localparam cache_state_idle 	   = 5'b00001;
	localparam cache_state_lookup      = 5'b00010;
	localparam cache_state_miss 	   = 5'b00100;
	localparam cache_state_replace 	   = 5'b01000;
	localparam cache_state_refill	   = 5'b10000;
	
	localparam cache_write_idle 	   = 2'b01;
	localparam cache_write_busy 	   = 2'b10;
	
	reg [4:0]cache_state;
	reg [4:0]next_cache_state;
	
	reg [1:0]write_state;
	reg [1:0]next_write_state;

	
	assign tagv_address_selection = (cache_req_not_hit && cache_state[1])?block_index_address_d:block_index_address;	
	assign ram_bank_address_selection = (direct_index_state)?block_index_address:block_index_address_d;	
	assign valid_cache_row = (cache_way0_req_hit || cache_way1_req_hit);
   	assign cache_req_hit = cache_req_d && valid_cache_row;
	assign cache_req_not_hit = cache_req_d && ( !valid_cache_row );
   	assign req_handshake_ok = cache_addr_ok && mem_req;
	assign replace_req_ok = wr_req & wr_rdy;	
	assign refill_req_ok = rd_req & rd_rdy;
	assign cache_miss = cache_req_not_hit || uncache_req_d;
	assign block_tag_address     = {4'd0, mem_address[`BUS_WIDTH - 5: 9]};
	assign block_index_address   = mem_address[8:4];
	assign ext_mem_writing_index = mem_last_write_address[8:4];
	assign ext_mem_writing_tag_address = {4'd0, mem_last_write_address[`BUS_WIDTH - 5: 9]};
	assign block_bias            = mem_address[3:0];
    assign slave_id              = slave_id_d;
	assign block_tag_address_d   = mem_address_d[31:9];
	assign block_index_address_d = mem_address_d[8:4];
	assign block_bias_d          = mem_address_d[3:0];
	assign cache_req   = req_handshake_ok && (slave_mem);
	assign uncache_req = req_handshake_ok && !slave_mem;
	
	assign dirty_cache_row = (cache_replace_order)?cache_way1_dirty[block_index_address_d]:cache_way0_dirty[block_index_address_d];
	
	assign cache_way0_req_hit = (block_tag_address_d == cache_tagv_32_23bit_way0_dout[22:0]) 
	   &&  (cache_tagv_32_23bit_way0_dout[23] == 1'b1); //valid
	
	assign cache_way1_req_hit = (block_tag_address_d == cache_tagv_32_23bit_way1_dout[22:0]) 
	   &&  (cache_tagv_32_23bit_way1_dout[23] == 1'b1); //valid
		   
	assign cache_tagv_32_23bit_way0_address_2 = ext_mem_writing_index;
	assign cache_tagv_32_23bit_way1_address_2 = ext_mem_writing_index;
			   
    assign cache_way0_writing_hazard = (ext_mem_writing_tag_address == cache_tagv_32_23bit_way0_dout_2[22:0]) 
	   &&  (cache_tagv_32_23bit_way0_dout_2[23] == 1'b1) && mem_writing; //valid
	
	assign cache_way1_writing_hazard = (ext_mem_writing_tag_address == cache_tagv_32_23bit_way1_dout_2[22:0]) 
	   &&  (cache_tagv_32_23bit_way1_dout_2[23] == 1'b1) && mem_writing; //valid
		     
	assign way0_refill_req = ret_valid && !uncache_req_d && !cache_replace_order;
	assign way1_refill_req = ret_valid && !uncache_req_d && cache_replace_order;
	
    always@(*)begin
        case(block_bias_d[3:2])
            2'b00:begin
                req_hit_rdata <= {32{cache_way0_req_hit}} & cache_bank_32_word_way0_bank0_dout 
                    | {32{cache_way1_req_hit}} & cache_bank_32_word_way1_bank0_dout;
            end
            2'b01:begin
                req_hit_rdata <= {32{cache_way0_req_hit}} & cache_bank_32_word_way0_bank1_dout 
                    | {32{cache_way1_req_hit}} & cache_bank_32_word_way1_bank1_dout;
            end
            2'b10:begin
                req_hit_rdata <= {32{cache_way0_req_hit}} & cache_bank_32_word_way0_bank2_dout 
                    | {32{cache_way1_req_hit}} & cache_bank_32_word_way1_bank2_dout;
            end
            2'b11:begin
                req_hit_rdata <= {32{cache_way0_req_hit}} & cache_bank_32_word_way0_bank3_dout 
                    | {32{cache_way1_req_hit}} & cache_bank_32_word_way1_bank3_dout;
            end
            default:begin
                req_hit_rdata <= 'd0;
            end
        endcase
    end

	always@(posedge clk)begin
		if(!rst_n)begin
			cache_state <= cache_state_idle;
			write_state <= cache_write_idle;
		end
		else begin
			cache_state <= next_cache_state;
			write_state <= next_write_state;
		end
	end
	
    always@(posedge clk)begin
		if(!rst_n)begin
			cache_write_miss <= 1'b0;
			cache_read_miss  <= 1'b0;
			wr_addr_d <= 'd0;
			rd_addr_d <= 'd0;
			wr_type_d <= 'd0;
			rd_type_d <= 'd0;
		end
		else if(cache_state[0] | cache_state[1])begin
			cache_write_miss <= cache_miss && mem_we_d;
			cache_read_miss  <= cache_miss && !mem_we_d;
			wr_addr_d <= {block_tag_address_d, block_index_address_d, 4'd0};
			rd_addr_d <= {block_tag_address_d, block_index_address_d, 4'd0};
			wr_type_d <= (uncache_req_d)?4'b0000:4'b0011;
			rd_type_d <= (uncache_req_d)?4'b0000:4'b0011;
		end
		else begin
			cache_write_miss <= cache_write_miss;
			cache_read_miss  <= cache_read_miss;
			wr_addr_d <= wr_addr_d;
			rd_addr_d <= rd_addr_d;
			wr_type_d <= wr_type_d;
			rd_type_d <= rd_type_d;
		end
	end
	
    always@(posedge clk)begin
        if(!rst_n)begin
            cache_replace_order <= 1'b0;
        end
		else if( cache_req_not_hit )begin
			cache_replace_order <= next_refill_way;
		end
		else begin
			cache_replace_order <= cache_replace_order;
		end
	end
	
	assign rd_req = (cache_read_miss && cache_state[2]) || ( cache_write_miss && cache_state[2] );
	assign wr_req = (cache_write_miss || (cache_read_miss && dirty_cache_row)) && cache_state[2];
	
	assign rd_type = rd_type_d;
	assign wr_type = wr_type_d;
	assign wr_addr = wr_addr_d;
	assign rd_addr = rd_addr_d;
	assign refill_data_ok = ret_last;
	assign way0_wr_data = {
        cache_bank_32_word_way0_bank3_dout,
        cache_bank_32_word_way0_bank2_dout,
        cache_bank_32_word_way0_bank1_dout,
        cache_bank_32_word_way0_bank0_dout
	};
	
	assign way1_wr_data = {
        cache_bank_32_word_way1_bank3_dout,
        cache_bank_32_word_way1_bank2_dout,
        cache_bank_32_word_way1_bank1_dout,
        cache_bank_32_word_way1_bank0_dout
	};
	
	assign wr_data = (cache_replace_order)?way1_wr_data:way0_wr_data;
	
	always@(*)begin
		case(cache_state)
			cache_state_idle:begin
				if( cache_req)begin
					next_cache_state <= cache_state_lookup;
				end
				else begin
					next_cache_state <= cache_state_idle;
				end
			end
			cache_state_lookup:begin
                if(cache_req_hit && cache_req)begin
					next_cache_state <= cache_state_lookup;
				end
				else if( cache_req_hit)begin
					next_cache_state <= cache_state_idle;
				end
				else if( cache_req_not_hit)begin
					next_cache_state <= cache_state_miss;
				end
				else begin
				    //never occur
					next_cache_state <= cache_state_lookup;
				end
			end
			cache_state_miss:begin
				if((cache_write_miss || (cache_read_miss && dirty_cache_row)) && replace_req_ok)begin
					next_cache_state <= cache_state_replace;
				end
				if(cache_read_miss && refill_req_ok)begin
					next_cache_state <= cache_state_refill;
				end
				else begin
					next_cache_state <= cache_state_miss;
				end
			end
			cache_state_replace:begin
			     //inclue uncache_req
			    if( cache_write_miss )begin
					next_cache_state <= cache_state_idle;
			    end
				else if(replace_data_ok)begin
					next_cache_state <= cache_state_refill;
				end
				else begin
					next_cache_state <= cache_state_replace;
				end
			end
			cache_state_refill:begin
			    if(refill_data_ok)begin
					next_cache_state <= cache_state_idle;
				end
				else begin
					next_cache_state <= cache_state_refill;
				end
			end
			default:begin
				next_cache_state <= cache_state_idle;
			end
		endcase
	end
	
		
	always@(*)begin
		case(write_state)
			cache_write_idle:begin
				if(cache_write_miss && replace_req_ok)begin
					next_write_state <= cache_write_busy;
				end
				else begin
					next_write_state <= cache_write_idle;
				end
			end
			cache_write_busy:begin
				if(replace_data_ok)begin
					next_write_state <= cache_write_idle;
				end
				else begin
					next_write_state <= cache_write_busy;
				end
			end
			default:begin
				next_write_state <= cache_write_idle;
			end
		endcase
	end	
	
	cache_tagv_32_24bit_dram cache_tagv_32_23bit_way0(
        .a(cache_tagv_32_23bit_way0_address),      // input wire [4 : 0] a
        .a_2(cache_tagv_32_23bit_way0_address_2),      // input wire [4 : 0] a
        .d(cache_tagv_32_23bit_way0_din),      // input wire [31 : 0] d
        .clk(clk),  // input wire clk
        .rst_n(rst_n),
        .we(cache_tagv_32_23bit_way0_we),    // input wire we
        .spo(cache_tagv_32_23bit_way0_dout),  // output wire [31 : 0] spo
	    .spo_2(cache_tagv_32_23bit_way0_dout_2)  // output wire [31 : 0] spo
	);
	
	cache_tagv_32_24bit_dram cache_tagv_32_23bit_way1(
        .a(cache_tagv_32_23bit_way1_address),      // input wire [4 : 0] a
        .a_2(cache_tagv_32_23bit_way1_address_2),      // input wire [4 : 0] a
        .d(cache_tagv_32_23bit_way1_din),      // input wire [31 : 0] d
        .clk(clk),  // input wire clk
        .rst_n(rst_n),
        .we(cache_tagv_32_23bit_way1_we),    // input wire we
        .spo(cache_tagv_32_23bit_way1_dout),  // output wire [31 : 0] spo
	    .spo_2(cache_tagv_32_23bit_way1_dout_2)  // output wire [31 : 0] spo
	);
	
	assign way0_write_req =  cache_way0_req_hit && mem_we_d;
	always@(posedge clk)begin
	   if(!rst_n)begin
	       cache_way0_dirty <=  32'd0;
	   end
	   else if(way0_write_req)begin
	       cache_way0_dirty[block_index_address_d] <= 1'b1;
	   end
	   else if(replace_data_ok && !cache_replace_order)begin
	       cache_way0_dirty[block_index_address_d] <= 1'b0;
	   end
	end
	
	assign way1_write_req =  cache_way1_req_hit && mem_we_d;
    always@(posedge clk)begin
	   if(!rst_n)begin
	       cache_way1_dirty <=  32'd0;
	   end
	   else if( way1_write_req)begin
	       cache_way1_dirty[block_index_address_d] <= 1'b1;
	   end
	   else if( replace_data_ok && cache_replace_order)begin
	       cache_way1_dirty[block_index_address_d] <= 1'b0;
	   end
	end
	
	single_port_ram cache_bank_32_word_way0_bank0(
	    .clk(clk),
	    .din(cache_bank_32_word_way0_bank0_din), 
	    .addr(cache_bank_32_word_way0_bank0_address),
        .dout(cache_bank_32_word_way0_bank0_dout),
        .cs(1'b1),
        .we(cache_bank_32_word_way0_bank0_we),
        .wem(cache_bank_32_word_way0_bank0_wem)
	);
	
	
	single_port_ram cache_bank_32_word_way0_bank1(
	    .clk(clk),
	    .din(cache_bank_32_word_way0_bank1_din), 
	    .addr(cache_bank_32_word_way0_bank1_address),
        .dout(cache_bank_32_word_way0_bank1_dout),
        .cs(1'b1),
        .we(cache_bank_32_word_way0_bank1_we),
        .wem(cache_bank_32_word_way0_bank1_wem)
	);
	
	
	single_port_ram cache_bank_32_word_way0_bank2(
	    .clk(clk),
	    .din(cache_bank_32_word_way0_bank2_din), 
	    .addr(cache_bank_32_word_way0_bank2_address),
        .dout(cache_bank_32_word_way0_bank2_dout),
        .cs(1'b1),
        .we(cache_bank_32_word_way0_bank2_we),
        .wem(cache_bank_32_word_way0_bank2_wem)
	);
	
	
	single_port_ram cache_bank_32_word_way0_bank3(
	    .clk(clk),
	    .din(cache_bank_32_word_way0_bank3_din), 
	    .addr(cache_bank_32_word_way0_bank3_address),
        .dout(cache_bank_32_word_way0_bank3_dout),
        .cs(1'b1),
        .we(cache_bank_32_word_way0_bank3_we),
        .wem(cache_bank_32_word_way0_bank3_wem)
	);
	
	single_port_ram cache_bank_32_word_way1_bank0(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank0_din), 
	    .addr(cache_bank_32_word_way1_bank0_address),
        .dout(cache_bank_32_word_way1_bank0_dout),
        .cs(1'b1),
        .we(cache_bank_32_word_way1_bank0_we),
        .wem(cache_bank_32_word_way1_bank0_wem)
	);
	
	single_port_ram cache_bank_32_word_way1_bank1(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank1_din), 
	    .addr(cache_bank_32_word_way1_bank1_address),
        .dout(cache_bank_32_word_way1_bank1_dout),
        .cs(1'b1),
        .we(cache_bank_32_word_way1_bank1_we),
        .wem(cache_bank_32_word_way1_bank1_wem)
	);
	
	single_port_ram cache_bank_32_word_way1_bank2(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank2_din), 
	    .addr(cache_bank_32_word_way1_bank2_address),
        .dout(cache_bank_32_word_way1_bank2_dout),
        .cs(1'b1),
        .we(cache_bank_32_word_way1_bank2_we),
        .wem(cache_bank_32_word_way1_bank2_wem)
	);
	
	single_port_ram cache_bank_32_word_way1_bank3(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank3_din), 
	    .addr(cache_bank_32_word_way1_bank3_address),
        .dout(cache_bank_32_word_way1_bank3_dout),
        .cs(1'b1),
        .we(cache_bank_32_word_way1_bank3_we),
        .wem(cache_bank_32_word_way1_bank3_wem)
	);
	
	assign direct_index_state = (cache_state[0] | cache_state[1]);
	
	//hazard lookup write
	assign cache_tagv_32_23bit_way0_address = (cache_way0_writing_hazard)?ext_mem_writing_index:tagv_address_selection;
	assign cache_tagv_32_23bit_way0_din = (cache_way0_writing_hazard)?24'd0:{1'b1,block_tag_address_d};
    assign cache_tagv_32_23bit_way0_we  = cache_req_not_hit && !next_refill_way || cache_way0_writing_hazard;
    
	assign cache_tagv_32_23bit_way1_address = (cache_way1_writing_hazard)?ext_mem_writing_index:tagv_address_selection;
	assign cache_tagv_32_23bit_way1_din = (cache_way1_writing_hazard)?24'd0:{1'b1,block_tag_address_d};
    assign cache_tagv_32_23bit_way1_we  = cache_req_not_hit && next_refill_way || cache_way1_writing_hazard;
	
	assign cache_bank_32_word_way0_bank0_address = {27'd0,ram_bank_address_selection};
	assign cache_bank_32_word_way0_bank1_address = {27'd0,ram_bank_address_selection};
	assign cache_bank_32_word_way0_bank2_address = {27'd0,ram_bank_address_selection};
	assign cache_bank_32_word_way0_bank3_address = {27'd0,ram_bank_address_selection};
	
	assign cache_bank_32_word_way1_bank0_address = {27'd0,ram_bank_address_selection};
	assign cache_bank_32_word_way1_bank1_address = {27'd0,ram_bank_address_selection};
	assign cache_bank_32_word_way1_bank2_address = {27'd0,ram_bank_address_selection};
	assign cache_bank_32_word_way1_bank3_address = {27'd0,ram_bank_address_selection};
	
	
	assign cache_bank_32_word_way0_bank0_we = way0_bank0_write_req;
	assign cache_bank_32_word_way0_bank1_we = way0_bank1_write_req;
	assign cache_bank_32_word_way0_bank2_we = way0_bank2_write_req;
	assign cache_bank_32_word_way0_bank3_we = way0_bank3_write_req;
	
	assign cache_bank_32_word_way1_bank0_we = way1_bank0_write_req;
	assign cache_bank_32_word_way1_bank1_we = way1_bank1_write_req;
	assign cache_bank_32_word_way1_bank2_we = way1_bank2_write_req;
	assign cache_bank_32_word_way1_bank3_we = way1_bank3_write_req;
	
	wire [3:0]write_bank_selection_d;
    assign write_bank_selection_d[0] = (block_bias_d[3:2] == 2'b00)?1'b1:1'b0;
	assign write_bank_selection_d[1] = (block_bias_d[3:2] == 2'b01)?1'b1:1'b0;
	assign write_bank_selection_d[2] = (block_bias_d[3:2] == 2'b10)?1'b1:1'b0;
	assign write_bank_selection_d[3] = (block_bias_d[3:2] == 2'b11)?1'b1:1'b0;

    always@(*)begin
        case({way0_write_req, way0_refill_req})
            2'b10:begin
                way0_bank0_write_req <= write_bank_selection_d[0];
                way0_bank1_write_req <= write_bank_selection_d[1];
                way0_bank2_write_req <= write_bank_selection_d[2];
                way0_bank3_write_req <= write_bank_selection_d[3];
                cache_bank_32_word_way0_bank0_wem <= mem_wem_d;
                cache_bank_32_word_way0_bank1_wem <= mem_wem_d;
                cache_bank_32_word_way0_bank2_wem <= mem_wem_d;
                cache_bank_32_word_way0_bank3_wem <= mem_wem_d;
                cache_bank_32_word_way0_bank0_din <= mem_wdata_d;
                cache_bank_32_word_way0_bank1_din <= mem_wdata_d;
                cache_bank_32_word_way0_bank2_din <= mem_wdata_d;
                cache_bank_32_word_way0_bank3_din <= mem_wdata_d;
            end
            2'b01:begin
                way0_bank0_write_req <= refill_index[0] ;
                way0_bank1_write_req <= refill_index[1] ;
                way0_bank2_write_req <= refill_index[2] ;
                way0_bank3_write_req <= refill_index[3] ;
                cache_bank_32_word_way0_bank0_din <= ret_data;
                cache_bank_32_word_way0_bank1_din <= ret_data;
                cache_bank_32_word_way0_bank2_din <= ret_data;
                cache_bank_32_word_way0_bank3_din <= ret_data;
                cache_bank_32_word_way0_bank0_wem <= 4'b1111;
                cache_bank_32_word_way0_bank1_wem <= 4'b1111;
                cache_bank_32_word_way0_bank2_wem <= 4'b1111;
                cache_bank_32_word_way0_bank3_wem <= 4'b1111;
            end
            default:begin
                way0_bank0_write_req <= 1'b0;
                way0_bank1_write_req <= 1'b0;
                way0_bank2_write_req <= 1'b0;
                way0_bank3_write_req <= 1'b0;
                cache_bank_32_word_way0_bank0_din <= 'd0;
                cache_bank_32_word_way0_bank1_din <= 'd0;
                cache_bank_32_word_way0_bank2_din <= 'd0;
                cache_bank_32_word_way0_bank3_din <= 'd0;
                cache_bank_32_word_way0_bank0_wem <= 'd0;
                cache_bank_32_word_way0_bank1_wem <= 'd0;
                cache_bank_32_word_way0_bank2_wem <= 'd0;
                cache_bank_32_word_way0_bank3_wem <= 'd0;
            end
        endcase
    end   
    
    always@(*)begin
        case({way1_write_req, way1_refill_req})
            2'b10:begin
                way1_bank0_write_req <= write_bank_selection_d[0];
                way1_bank1_write_req <= write_bank_selection_d[1];
                way1_bank2_write_req <= write_bank_selection_d[2];
                way1_bank3_write_req <= write_bank_selection_d[3];
                cache_bank_32_word_way1_bank0_wem <= mem_wem_d;
                cache_bank_32_word_way1_bank1_wem <= mem_wem_d;
                cache_bank_32_word_way1_bank2_wem <= mem_wem_d;
                cache_bank_32_word_way1_bank3_wem <= mem_wem_d;
                cache_bank_32_word_way1_bank0_din <= mem_wdata_d;
                cache_bank_32_word_way1_bank1_din <= mem_wdata_d;
                cache_bank_32_word_way1_bank2_din <= mem_wdata_d;
                cache_bank_32_word_way1_bank3_din <= mem_wdata_d;
            end
            2'b01:begin
                way1_bank0_write_req <= refill_index[0] ;
                way1_bank1_write_req <= refill_index[1] ;
                way1_bank2_write_req <= refill_index[2] ;
                way1_bank3_write_req <= refill_index[3] ;
                cache_bank_32_word_way1_bank0_din <= ret_data;
                cache_bank_32_word_way1_bank1_din <= ret_data;
                cache_bank_32_word_way1_bank2_din <= ret_data;
                cache_bank_32_word_way1_bank3_din <= ret_data;
                cache_bank_32_word_way1_bank0_wem <= 4'b1111;
                cache_bank_32_word_way1_bank1_wem <= 4'b1111;
                cache_bank_32_word_way1_bank2_wem <= 4'b1111;
                cache_bank_32_word_way1_bank3_wem <= 4'b1111;
            end
            default:begin
                way1_bank0_write_req <= 1'b0;
                way1_bank1_write_req <= 1'b0;
                way1_bank2_write_req <= 1'b0;
                way1_bank3_write_req <= 1'b0;
                cache_bank_32_word_way1_bank0_din <= 'd0;
                cache_bank_32_word_way1_bank1_din <= 'd0;
                cache_bank_32_word_way1_bank2_din <= 'd0;
                cache_bank_32_word_way1_bank3_din <= 'd0;
                cache_bank_32_word_way1_bank0_wem <= 'd0;
                cache_bank_32_word_way1_bank1_wem <= 'd0;
                cache_bank_32_word_way1_bank2_wem <= 'd0;
                cache_bank_32_word_way1_bank3_wem <= 'd0;
            end
        endcase
    end       
     
	always@(posedge clk)begin
	   if(!rst_n)begin
            refill_index <= 4'd0;
	   end
	   else if(refill_req_ok)begin
            refill_index <= 4'b0001;
       end
       else if(ret_valid)begin
            refill_index <= {refill_index[2:0],1'b0};
       end
       else begin
            refill_index <= refill_index;
       end
	end
	
	always@(posedge clk) begin
        if(!rst_n)begin
            uncache_req_d <= 1'b0;
            cache_req_d   <= 1'b0;
        end
        else if(req_handshake_ok)begin
            uncache_req_d <= uncache_req;
            cache_req_d   <= cache_req;
        end
        else if(cache_data_ok)begin
            uncache_req_d <= 1'b0;
            cache_req_d   <= 1'b0;
        end
        else begin
            uncache_req_d <= uncache_req_d;
            cache_req_d   <= cache_req_d;
        end
	end
	
    always@(posedge clk) begin
        if(!rst_n)begin
            cache_req_d   <= 1'b0;
        end
        else if(req_handshake_ok)begin
            cache_req_d   <= cache_req;
        end
        else begin
            cache_req_d   <= 1'b0;
        end
	end
	
		
	always@(posedge clk) begin
        if(!rst_n)begin
            mem_address_d <=  'd0;
	        mem_wem_d     <=  'd0;
	        slave_id_d    <=  'd0;
	        mem_we_d      <=  'd0;
	        mem_wdata_d   <=  'd0;
        end
        else if(req_handshake_ok)begin
            mem_address_d <= {4'd0,mem_address[27:0]};
	        mem_wem_d     <= mem_wem;
	        slave_id_d    <= slave_id_decode; 
	        mem_we_d      <= mem_we;
	        mem_wdata_d   <= mem_wdata;
        end
        else if(cache_state[0] || cache_state[1])begin
            mem_address_d <= mem_address_d;
	        mem_wem_d     <= mem_wem_d;
	        slave_id_d    <= slave_id_d;
	        mem_we_d      <= 'd0;
	        mem_wdata_d   <= mem_wdata_d;
        end
        else begin
            mem_address_d <= mem_address_d;
            mem_wem_d     <= mem_wem;
	        slave_id_d    <= slave_id_d; 
	        mem_we_d      <= mem_we_d;
	        mem_wdata_d   <= mem_wdata_d;
        end
	end
	assign wr_wstrb = mem_wem_d;
	
	always@(posedge clk)begin
	   if(!rst_n)begin
	       replace_data_ok <= 'd0;
	   end
	   else begin
	       replace_data_ok <= replace_req_ok;
	   end
	end
	
	assign cache_addr_ok = (cache_state[0] || (cache_state[1] && cache_req_hit));
	assign cache_data_ok = (cache_state[1] && cache_req_hit) || (ret_valid && (write_bank_selection_d == refill_index));
	assign mem_rdata     = ({32{cache_state[1] && cache_req_hit}} & req_hit_rdata) | ({32{ret_valid}} & ret_data);
	
	lfsr lfsr_inst(
	   .clk(clk),
	   .rst_n(rst_n),
	   .pn_seq(next_refill_way)
	);
	
endmodule