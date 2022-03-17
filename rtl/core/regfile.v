	
`include "include.v"

module regfile(
	input wire clk,
	input wire rst_n,
	input wire we,
	input wire[`RS2_WIDTH - 1:0] rs2,
	input wire[`RS1_WIDTH - 1:0] rs1,
	input wire[`RD_WIDTH - 1:0] wa,
	input wire[`DATA_WIDTH - 1:0] wd,
	output wire[`DATA_WIDTH - 1:0] rd1_data,rd2_data,
    // from jtag
    input wire jtag_we_i,
    input wire[`RD_WIDTH - 1:0] jtag_addr_i,
    input wire[`DATA_WIDTH - 1:0]jtag_data_i,
    // to jtag
    output [`DATA_WIDTH - 1:0] jtag_data_o,
    //to next pipe
    output reg allow_in_regfile,
    //processing
    input valid_wb,
    input ready_go_wb
);

    wire write_enable;
    assign write_enable = we & valid_wb & ready_go_wb & (|wa);
    wire forward_rs1;
    assign forward_rs1 = (wa == rs1)?write_enable:1'b0;
    wire forward_rs2;
    assign forward_rs2 = (wa == rs2)?write_enable:1'b0;
    
	reg [`DATA_WIDTH - 1:0] rf[31:0];
    integer i;
//    //��֤����д���?
//	always @(negedge clk) begin
//        if(~rst_n)begin
//            for(i = 0 ; i < 32 ; i = i + 1 )begin
//			     rf[i] <= 0;
//            end 
//        end
//		else if(we) begin
//			 rf[wa] <= wd;
//		end
//	end
    //��֤����д���?
	always @(posedge clk) begin
        if(rst_n)begin
            if( (write_enable == 1'b1) &&  (wa != 5'd0)) begin
                rf[wa] <= wd;
            end
            else if ((jtag_we_i == 1'b1) && (jtag_addr_i !=  5'd0)) begin
                rf[jtag_addr_i] <= jtag_data_i;
            end
        end
	end
	wire [`DATA_WIDTH - 1:0] rd1_data_temp;
	wire [`DATA_WIDTH - 1:0] rd2_data_temp;
	
	always@(posedge clk)begin
	   if(!rst_n)begin
	       allow_in_regfile <= 1'b0;
	   end
	   else begin
	       allow_in_regfile <= 1'b1;
	   end
	end
	
	//by default, x0 reg is set to be zero.
	assign rd1_data_temp = (rs1 != 0) ? rf[rs1] : 0;
	assign rd2_data_temp = (rs2 != 0) ? rf[rs2] : 0;
	assign jtag_data_o = (jtag_addr_i != 0)? rf[jtag_addr_i] : 0;
	
	assign rd1_data = (forward_rs1)?wd:rd1_data_temp;
	assign rd2_data = (forward_rs2)?wd:rd2_data_temp;
endmodule
	