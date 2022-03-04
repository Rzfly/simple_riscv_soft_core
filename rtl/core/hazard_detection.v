`include "include.v"

module hazard_detection(
    input read_mem_ex,
    input [`RD_WIDTH -1:0]rd_ex,    
    input [`RS1_WIDTH -1:0] rs1_id,
    input [`RS2_WIDTH -1:0] rs2_id,
    input forwording_invalid,
    input [`RD_WIDTH -1:0]rd_wb,    
    output stall
);

    wire stall_ld;
    assign stall_ld = ((( rd_ex ==  rs1_id) && (|rd_ex)) || (( rd_ex ==  rs2_id) && (|rd_ex))) ? read_mem_ex :1'b0;
    
    wire stall_reg;
	
	assign stall_reg = ((( rd_wb ==  rs1_id) && (|rd_wb)) || (( rd_wb ==  rs2_id) && (|rd_wb))) ?forwording_invalid:1'b0;
	assign stall = stall_reg | stall_ld;
	
endmodule