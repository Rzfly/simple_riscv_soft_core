module multer_top#(
    parameter DATA_WIDTH = 32
)(
	input clk,
	input rst_n,
	input cancel,
	input req_valid,
	output req_ready,
	output rsp_valid,
	input rsp_ready,
	input [4:0]rs1_ex,
	input [4:0]rs2_ex,
	input [4:0]rd_ex,
    input signed_mult_num_1,
    input signed_mult_num_2,
	input [DATA_WIDTH - 1:0]num_1,
	input [DATA_WIDTH - 1:0]num_2,
	output reg [DATA_WIDTH - 1:0]signed_mult_resh_d,
	output reg [DATA_WIDTH - 1:0]signed_mult_resl_d,
	output reg [DATA_WIDTH - 1:0]unsigned_mult_resh_d,
	output reg [DATA_WIDTH - 1:0]unsigned_mult_resl_d
);
    localparam state_idle = 3'b001;
    localparam state_busy = 3'b010;
    localparam state_back = 3'b100;
    
    reg [2:0]state;
    reg [2:0]next_state;
    
    (* keep = "true" *)reg signed_mult_num_1_d;
    (* keep = "true" *)reg signed_mult_num_2_d;
    (* keep = "true" *)reg [DATA_WIDTH - 1:0]num_1_d;
    (* keep = "true" *)reg [DATA_WIDTH - 1:0]num_2_d;
    
	wire [DATA_WIDTH - 1:0]signed_mult_resh;
	wire [DATA_WIDTH - 1:0]signed_mult_resl;
	wire [DATA_WIDTH - 1:0]unsigned_mult_resh;
	wire [DATA_WIDTH - 1:0]unsigned_mult_resl;
    reg mult_over;
    wire req_ok;
    wire rsp_ok;
  
    assign req_ok = req_valid && req_ready && !cancel;
    assign rsp_ok = rsp_valid && rsp_ready;   
    
    assign rsp_valid = state[2];
    assign req_ready = state[0];
//    assign req_ready = state[0] | state[2] & rsp_ready;

        
    wire reuse_mult;
//    assign reuse_mult = (num_1 == num_1_d) && (num_2 == num_2_d) && (signed_mult == signed_mult_d);
    assign reuse_mult = (num_1 == num_1_d)
     && (num_2 == num_2_d)
     && (signed_mult_num_1 == signed_mult_num_1_d)
     && (signed_mult_num_2 == signed_mult_num_2_d)
     && !(rd_ex == rs2_ex)
     && !(rd_ex == rs1_ex);
     
	
    always@(posedge clk)begin
        if(!rst_n)begin
            state <= state_idle;
        end
        else begin
            state <= next_state;
        end
    end
    
    
    always@(*)begin
        case(state)
            state_idle:begin
                if(req_ok && reuse_mult)begin
                    next_state <= state_back;
                end
                else if(req_ok)begin
                    next_state <= state_busy;
                end
                else begin
                    next_state <= state_idle;        
                end
            end
            state_busy:begin
                if(cancel)begin
                    next_state <= state_idle;
                end
                else if(mult_over)begin
                    next_state <= state_back;
                end
                else begin
                    next_state <= state_busy;
                end
            end
            state_back:begin
                if(rsp_ok)begin 
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_back;
                end
            end
//                if(rsp_ok && req_ok && reuse_mult)begin
//                    next_state <= state_back;        
//                end
//                else if(rsp_ok && req_ok)begin
//                    next_state <= state_busy;        
//                end
//                else if(rsp_ok)begin 
//                    next_state <= state_idle;
//                end
//                else begin
//                    next_state <= state_back;
//                end
            default:begin
                next_state <= state_idle;
            end
        endcase        
    end
    
    always@(posedge clk)begin
    	if(!rst_n)begin
    		signed_mult_num_1_d <= 'd0;
    		signed_mult_num_2_d <= 'd0;
    		num_1_d <= 'd0;
    		num_2_d <= 'd0;
    	end    
//        else if(req_ok && !reuse_mult)begin
        else if(req_ok)begin
        	signed_mult_num_1_d <= signed_mult_num_1;
        	signed_mult_num_2_d <= signed_mult_num_2;
    		num_1_d <= num_1;
    		num_2_d <= num_2;
    	end
    	else begin
        	signed_mult_num_1_d <= signed_mult_num_1_d;
        	signed_mult_num_2_d <= signed_mult_num_2_d;
    		num_1_d <= num_1_d;
    		num_2_d <= num_2_d;
    	end
    end
    
    multer multer_inst(
    	.clk(clk),
    	.rst_n(rst_n),
    	.cancel(cancel),
        .signed_mult_num_1(signed_mult_num_1_d),
        .signed_mult_num_2(signed_mult_num_2_d),
    	.num_1(num_1_d),
    	.num_2(num_2_d),
    	.signed_mult_resh(signed_mult_resh),
    	.signed_mult_resl(signed_mult_resl),
    	.unsigned_mult_resh(unsigned_mult_resh),
    	.unsigned_mult_resl(unsigned_mult_resl)
    );
    
    always@(posedge clk)begin
    	if(!rst_n)begin
    	    mult_over <= 'd0;
	   	end
    	else if(state[1] && !mult_over) begin
    	    mult_over <= 1'd1;
	    end
	    else begin
	        mult_over <= 1'd0;	       
	    end
    end
    
    always@(posedge clk)begin
    	if(!rst_n)begin
	    	signed_mult_resh_d <= 'd0;
	    	signed_mult_resl_d <= 'd0;
	    	unsigned_mult_resh_d <= 'd0;
	    	unsigned_mult_resl_d <= 'd0; 
    	end
    	else if( mult_over ) begin
	    	signed_mult_resh_d <= signed_mult_resh;
	    	signed_mult_resl_d <= signed_mult_resl;
	    	unsigned_mult_resh_d <= unsigned_mult_resh;
	    	unsigned_mult_resl_d <= unsigned_mult_resl; 
    	end
    	else begin
	    	signed_mult_resh_d <= signed_mult_resh_d;
	    	signed_mult_resl_d <= signed_mult_resl_d;
	    	unsigned_mult_resh_d <= unsigned_mult_resh_d;
	    	unsigned_mult_resl_d <= unsigned_mult_resl_d; 
    	end
    end
    
endmodule
