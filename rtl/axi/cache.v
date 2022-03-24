`include "include.v"

module cache(
	input clk,
	input rst_n,
	//from core srambus
	input mem_req,
	input w_req,
	input [`BUS_WIDTH - 1 : 0]mem_address,
	input [`RAM_MASK_WIDTH - 1 : 0]wem,
	input [`DATA_WIDTH - 1 : 0]mem_wdata,
	output [`DATA_WIDTH - 1 : 0]mem_rdata,
	output cache_addr_ok,
	output cache_data_ok,
	//to mem,axi_bus,single channel used
	output rd_req,
	output [2:0]rd_type,
	output [`BUS_WIDTH - 1 : 0]rd_addr,
	input rd_rdy,
	input ret_valid,
	input [1:0]ret_last,
	input [`DATA_WIDTH - 1:0]ret_data,
	output wr_req,
	output [2:0]wr_type,
	output [`BUS_WIDTH - 1 : 0]wr_addr,
	output [`RAM_MASK_WIDTH - 1 : 0]wr_wstrb,
	//for word
	output [127: 0]wr_data,
	input wr_rdy

);


	//cache 2kB = 8 * 16 * 16  Byte = 32 * 16 * 4 BYTE  4 + 4 + 3  9 + 2   5 + 6
	//I cache 1kB = 4 * 16 * 16  Byte = 2 * 32 * 4 word  1 + 5 + 4  
	//total 64KB = 6 + 10 = 7 + 9 = 16 = 32 - 16 
	wire [22:0]tag_address;
	wire [23:0]tagV_address;
	wire valid_cache_row;
	wire dirty_cache_row;
	wire [6:0]true_block_tag_address;
	//total 9bit
	wire [4:0]block_index_address;
	//4 word 16 BYTE
	wire [3:0]block_bias;
	wire cache_req;
	wire uncache_req;
	
	
	//   cache_bank_32_23bit_way0_address;
	wire [4:0] cache_tagv_32_23bit_way0_address;
	wire [23:0]cache_tagv_32_23bit_way0_dout;
	wire [23:0]cache_tagv_32_23bit_way0_din;
	wire cache_tagv_32_23bit_way0_we;
	
	//   cache_bank_32_23bit_way1_address;
	wire [4:0] cache_tagv_32_23bit_way1_address;
	wire [23:0]cache_tagv_32_23bit_way1_dout;
	wire [23:0]cache_tagv_32_23bit_way1_din;
	wire cache_tagv_32_23bit_way1_we;
	
	//cache_bank_32_word_way0;
	wire [4:0] cache_bank_32_word_way0_bank0_address;
	wire [31:0]cache_bank_32_word_way0_bank0_dout;
	wire [31:0]cache_bank_32_word_way0_bank0_din;
	wire cache_bank_32_word_way0_bank0_we;
	wire [4:0] cache_bank_32_word_way0_bank1_address;
	wire [31:0]cache_bank_32_word_way0_bank1_dout;
	wire [31:0]cache_bank_32_word_way0_bank1_din;
	wire cache_bank_32_word_way0_bank1_we;
	wire [4:0] cache_bank_32_word_way0_bank2_address;
	wire [31:0]cache_bank_32_word_way0_bank2_dout;
	wire [31:0]cache_bank_32_word_way0_bank2_din;
	wire cache_bank_32_word_way0_bank2_we;
	wire [4:0] cache_bank_32_word_way0_bank3_address;
	wire [31:0]cache_bank_32_word_way0_bank3_dout;
	wire [31:0]cache_bank_32_word_way0_bank3_din;
	wire cache_bank_32_word_way0_bank3_we;
	
	//cache_bank_32_word_way1;
	wire [4:0] cache_bank_32_word_way1_bank0_address;
	wire [31:0]cache_bank_32_word_way1_bank0_dout;
	wire [31:0]cache_bank_32_word_way1_bank0_din;
	wire cache_bank_32_word_way1_bank0_we;
	wire [4:0] cache_bank_32_word_way1_bank1_address;
	wire [31:0]cache_bank_32_word_way1_bank1_dout;
	wire [31:0]cache_bank_32_word_way1_bank1_din;
	wire cache_bank_32_word_way1_bank1_we;
	wire [4:0] cache_bank_32_word_way1_bank2_address;
	wire [31:0]cache_bank_32_word_way1_bank2_dout;
	wire [31:0]cache_bank_32_word_way1_bank2_din;
	wire cache_bank_32_word_way1_bank2_we;
	wire [4:0] cache_bank_32_word_way1_bank3_address;
	wire [31:0]cache_bank_32_word_way1_bank3_dout;
	wire [31:0]cache_bank_32_word_way1_bank3_din;
	wire cache_bank_32_word_way1_bank3_we;
	
	//control signal
	wire cache_way0_req_hit;
	wire cache_way1_req_hit;
	wire cache_req_hit;
	wire cache_req_not_hit;
	wire uncache_req_complete;
	wire replace_req_ok;
	wire replace_data_ok;
	wire refill_req_ok;
	wire refill_data_ok;
	wire cache_write_miss;
	wire cache_read_miss;
	assign cache_req_hit = cache_way0_req_hit | cache_way1_req_hit;
	assign replace_req_ok = 1'b1;
	assign cache_req_not_hit = !cache_req_hit;
	assign block_tag_address    = mem_address[`BUS_WIDTH - 1: 9];
	assign block_index_address  = mem_address[8:4];
	assign block_bias           = mem_address[3:0];

    reg  [31: 0]mem_address_d;
	reg  [31: 0]req_hit_rdata;
	reg  [3:0]wem_d;
	wire [31: 0]uncache_rdata;
	wire [22: 0]block_tag_address_d;
	wire [4: 0]block_index_address_d;
	wire [3: 0]block_bias_d;
	wire way0_write_req;
	wire way1_write_req;
	wire way0_bank0_write_req;
	wire way0_bank1_write_req;
	wire way0_bank2_write_req;
	wire way0_bank3_write_req;
	wire way1_bank0_write_req;
	wire way1_bank1_write_req;
	wire way1_bank2_write_req;
	wire way1_bank3_write_req;
	
	//memory
    localparam [3:0]slave_0   = 4'b0000;
    localparam [3:0]slave_1   = 4'b0001;
    wire slave_mem   = ((mem_address[31:28] == slave_0) || (mem_address[31:28] == slave_1))?1'b1:1'b0;
   
	assign block_tag_address_d   = mem_address_d[31:9];
	assign block_index_address_d = mem_address_d[8:4];
	assign block_bias_d          = mem_address_d[3:0];
	assign cache_req   = mem_req && (slave_mem);
	assign uncache_req = mem_req && !slave_mem;
	
	
	assign cache_way0_req_hit = (block_tag_address_d == cache_tagv_32_23bit_way0_dout[22:0]) 
	   &&  (cache_tagv_32_23bit_way0_dout[23] == 1'b1); //valid
	
	assign cache_way1_req_hit = (block_tag_address_d == cache_tagv_32_23bit_way1_dout[22:0]) 
	   &&  (cache_tagv_32_23bit_way1_dout[23] == 1'b1); //valid
		
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
		
	assign mem_rdata = {32{cache_req_hit}} & req_hit_rdata | {32{uncache_req_complete}} & uncache_rdata;
	
	localparam cache_state_idle 	   = 5'b00001;
	localparam cache_state_hit		   = 5'b00010;
	localparam cache_state_miss 	   = 5'b00100;
	localparam cache_state_replace 	   = 5'b01000;
	localparam cache_state_refill	   = 5'b10000;
	
	localparam cache_write_idle 	   = 2'b01;
	localparam cache_write_busy 	   = 2'b10;
	
	reg [4:0]cache_state;
	reg [4:0]next_cache_state;
	
	reg [1:0]write_state;
	reg [1:0]next_write_state;

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
	
	
	always@(*)begin
		case(cache_state)
			cache_state_idle:begin
				if( cache_req && cache_req_hit)begin
					next_cache_state <= cache_state_hit;
				end
				else begin
					next_cache_state <= cache_state_idle;
				end
			end
			cache_state_hit:begin
				if(cache_req_hit && mem_req)begin
					next_cache_state <= cache_state_hit;
				end
				else if(mem_req)begin
					next_cache_state <= cache_state_miss;
				end
				else begin
					next_cache_state <= cache_state_idle;
				end
			end
			cache_state_miss:begin
				if(cache_write_miss && replace_req_ok)begin
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
				if(replace_data_ok)begin
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
	
	cache_tagv_32_23bit cache_tagv_32_23bit_way0(
        .a(cache_tagv_32_23bit_way0_address),      // input wire [4 : 0] a
        .d(cache_tagv_32_23bit_way0_din),      // input wire [31 : 0] d
        .clk(clk),  // input wire clk
        .we(cache_tagv_32_23bit_way0_we),    // input wire we
        .spo(cache_tagv_32_23bit_way0_dout)  // output wire [31 : 0] spo
	);
	
	cache_tagv_32_23bit cache_tagv_32_23bit_way1(
        .a(cache_tagv_32_23bit_way1_address),      // input wire [4 : 0] a
        .d(cache_tagv_32_23bit_way1_din),      // input wire [31 : 0] d
        .clk(clk),  // input wire clk
        .we(cache_tagv_32_23bit_way1_we),    // input wire we
        .spo(cache_tagv_32_23bit_way1_dout)  // output wire [31 : 0] spo
	);
	
	reg [31:0]cache_way0_dirty;
	reg [31:0]cache_way1_dirty;
	always@(posedge clk)begin
	   if(!rst_n)begin
	       cache_way0_dirty <=  32'd0;
	       cache_way1_dirty <=  32'd0;
	   end
	   else if(way0_write_req | way1_write_req)begin
	       cache_way0_dirty[block_index_address] <= way0_write_req;
	       cache_way1_dirty[block_index_address] <= way1_write_req;
	   end
	end
	
	single_port_ram cache_bank_32_word_way0_bank0(
	    .clk(clk),
	    .din(cache_bank_32_word_way0_bank0_din), 
	    .addr(cache_bank_32_word_way0_bank0_address),
        .dout(cache_bank_32_word_way0_bank0_dout),
        .cs(1'b1),
        .we(wr_req),
        .wem(wem_d)
	);
	
	
	single_port_ram cache_bank_32_word_way0_bank1(
	    .clk(clk),
	    .din(cache_bank_32_word_way0_bank1_din), 
	    .addr(cache_bank_32_word_way0_bank1_address),
        .dout(cache_bank_32_word_way0_bank1_dout),
        .cs(1'b1),
        .we(wr_req),
        .wem(wem_d)
	);
	
	
	single_port_ram cache_bank_32_word_way0_bank2(
	    .clk(clk),
	    .din(cache_bank_32_word_way0_bank2_din), 
	    .addr(cache_bank_32_word_way0_bank2_address),
        .dout(cache_bank_32_word_way0_bank2_dout),
        .cs(1'b1),
        .we(wr_req),
        .wem(wem_d)
	);
	
	
	single_port_ram cache_bank_32_word_way0_bank3(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank0_din), 
	    .addr(cache_bank_32_word_way1_bank0_address),
        .dout(cache_bank_32_word_way1_bank0_dout),
        .cs(1'b1),
        .we(wr_req),
        .wem(wem_d)
	);
	
	single_port_ram cache_bank_32_word_way1_bank0(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank0_din), 
	    .addr(cache_bank_32_word_way1_bank0_address),
        .dout(cache_bank_32_word_way1_bank0_dout),
        .cs(1'b1),
        .we(wr_req),
        .wem(wem_d)
	);
	
	single_port_ram cache_bank_32_word_way1_bank1(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank1_din), 
	    .addr(cache_bank_32_word_way1_bank1_address),
        .dout(cache_bank_32_word_way1_bank1_dout),
        .cs(1'b1),
        .we(wr_req),
        .wem(wem_d)
	);
	
	single_port_ram cache_bank_32_word_way1_bank2(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank2_din), 
	    .addr(cache_bank_32_word_way1_bank2_address),
        .dout(cache_bank_32_word_way1_bank2_dout),
        .cs(1'b1),
        .we(wr_req),
        .wem(wem_d)
	);
	
	single_port_ram cache_bank_32_word_way1_bank3(
	    .clk(clk),
	    .din(cache_bank_32_word_way1_bank3_din), 
	    .addr(cache_bank_32_word_way1_bank3_address),
        .dout(cache_bank_32_word_way1_bank3_dout),
        .cs(1'b1),
        .we(wr_req),
        .wem(wem_d)
	);
	
	assign cache_tagv_32_23bit_way0_address = block_index_address;
	assign cache_tagv_32_23bit_way1_address = block_index_address;
	
	assign cache_bank_32_word_way0_bank0_address = block_index_address;
	assign cache_bank_32_word_way0_bank1_address = block_index_address;
	assign cache_bank_32_word_way0_bank2_address = block_index_address;
	assign cache_bank_32_word_way0_bank3_address = block_index_address;
	
	assign cache_bank_32_word_way1_bank0_address = block_index_address;
	assign cache_bank_32_word_way1_bank1_address = block_index_address;
	assign cache_bank_32_word_way1_bank2_address = block_index_address;
	assign cache_bank_32_word_way1_bank3_address = block_index_address;
	
	
	
endmodule