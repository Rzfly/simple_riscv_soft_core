`include "include.v"

module hazard_detection(
    input read_mem_ex,
    input [`RD_WIDTH -1:0]rd_ex,    
    input [`RS1_WIDTH -1:0] rs1_id,
    input [`RS2_WIDTH -1:0] rs2_id,
    output stall
);

    assign stall = ((( rd_ex ==  rs1_id) && (|rd_ex)) || (( rd_ex ==  rs2_id) && (|rd_ex))) ?read_mem_ex:1'b0;
	
endmodule