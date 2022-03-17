`include "include.v"
module ex_commit(
    input clk,
    input rst_n,
    //NORMAL
    input csr_we_ex,
    input lui_type_ex,
    input [`DATA_WIDTH - 1:0]alu_res,
    input [`DATA_WIDTH - 1:0]csr_res,
    input [`DATA_WIDTH - 1:0]imm_res,
    //MUL
    input mult_type_ok,
    input [2:0]mult_control,
    input [`DATA_WIDTH - 1:0]signed_mult_resh,
    input [`DATA_WIDTH - 1:0]signed_mult_resl,
    input [`DATA_WIDTH - 1:0]unsigned_mult_resh,
    input [`DATA_WIDTH - 1:0]unsigned_mult_resl,
    output mult_rsp_ready,
    //MEM    
    input mem_addr_ok,
    input ram_req,
    //DIV
    input div_type_ok,
    input [2:0]div_control,
    input [`DATA_WIDTH - 1:0]signed_div_res,
    input [`DATA_WIDTH - 1:0]unsigned_div_res,
    input [`DATA_WIDTH - 1:0]signed_rem_res,
    input [`DATA_WIDTH - 1:0]unsigned_rem_res,
    output div_rsp_ready,
    //
    output [`DATA_WIDTH - 1:0]ex2wb_wdata,
    
    input valid_ex,
    input allow_in_wb,
    output to_wb_valid,
    output ready_go_ex,
    output allow_in_ex
 );
 
    //alu
    wire normal_type;
    //MEM
    wire mem_req_type;
    //DIV
    wire div_type;
    //MULT
    wire mult_type;
//    wire div_type;
    
    reg [`DATA_WIDTH - 1:0]mult_res;
    reg [`DATA_WIDTH - 1:0]div_res;
    
    always@(*)begin
    	case(div_control)
    		//invalid
    		3'b000:begin
		    div_res <= signed_div_res;
    		end
    		3'b001:begin
		    div_res <= unsigned_rem_res;    		
    		end
    		3'b010:begin
		    div_res <= unsigned_div_res;
    		end
    		//invalid
    		3'b011:begin
		    div_res <= signed_div_res;
    		end
    		//invalid
    		3'b100:begin
		    div_res <= signed_div_res;    		
    		end
    		3'b101:begin
    		    div_res <= signed_rem_res;  
    		end
    		3'b110:begin
    		    div_res <= signed_div_res;    		
    		end
    		//invalid
    		3'b111:begin
    		    div_res <= signed_div_res;    		
    		end
    		default:begin
    		    div_res <= signed_div_res;    			
    		end
    	endcase
    end
    
    always@(*)begin
    	case(mult_control)
    		//invalid
    		3'b000:begin
		    mult_res <= signed_mult_resl;
    		end
    		3'b001:begin
		    mult_res <= unsigned_mult_resh;    		
    		end
    		3'b010:begin
		    mult_res <= unsigned_mult_resl;
    		end
    		//invalid
    		3'b011:begin
		    mult_res <= signed_mult_resl;
    		end
    		//invalid
    		3'b100:begin
		    mult_res <= signed_mult_resl;    		
    		end
    		3'b101:begin
		    mult_res <= signed_mult_resh;
    		end
    		3'b110:begin
		    mult_res <= signed_mult_resl;		
    		end
    		//invalid
    		3'b111:begin
    		    mult_res <= signed_mult_resl;    		
    		end
    		default:begin
    		    mult_res <= signed_mult_resl;    			
    		end
    	endcase
    end
  
    assign div_type  = div_control[1] | div_control[0];
    
    assign mult_type = mult_control[1] | mult_control[0];
    
    assign mem_req_type = ram_req;
    
    assign normal_type = !( div_type || mult_type || csr_we_ex || lui_type_ex);
    
    assign normal_type_pass = !( div_type || mult_type || mem_req_type );
    
    assign ready_go_ex = 
	(mem_req_type & mem_addr_ok) 
    	| (mult_type & mult_type_ok)
    	| (div_type  & div_type_ok)
    	| (normal_type_pass); 
   
    assign  div_rsp_ready = allow_in_wb;
    assign  mult_rsp_ready = allow_in_wb;
    
    assign  to_wb_valid = valid_ex && ready_go_ex;
//    assign hold_pipe = !allow_in_wb;
    assign  allow_in_ex = !(valid_ex) || (ready_go_ex && allow_in_wb);
 
    
/*    wire [1:0]mem_address_mux_ex;
    assign mem_address_mux_ex={ csr_we_ex, lui_type_ex};
    mux3_switch2 #(.WIDTH(`DATA_WIDTH))
    mem_address_mux(
        .num0(alu_res),
        .num1(imm_res),
        //mem2reg
        .num2(csr_res),
        .switch(mem_address_mux_ex),
        .muxout(normal_res)
    );
 */   
 
    assign ex2wb_wdata = 
    	{`DATA_WIDTH{csr_we_ex}}    & csr_res
    |	{`DATA_WIDTH{lui_type_ex}}  & imm_res
    |	{`DATA_WIDTH{normal_type}}  & alu_res
    |	{`DATA_WIDTH{mult_type}}    & mult_res
    |   {`DATA_WIDTH{div_type}}     & div_res;
    
endmodule
