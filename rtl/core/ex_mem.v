

`include "include.v"

module ex_mem(
    input clk,
    input rst_n,
    input [`DATA_WIDTH - 1:0]alu_res_i,
    input [`DATA_WIDTH - 1:0]imm_i,
//    output [`DATA_WIDTH - 1:0]imm_o,
    //note that width of instuction and data is not sure to be the same
    output [`BUS_WIDTH - 1:0]mem_address_o,
    output [`DATA_WIDTH - 1:0]mem_write_data_o,
    input [3:0]control_flow_i,
    output [1:0]control_flow_o,
    output mem_write,
    output mem_read,
    input [`RD_WIDTH - 1:0]rd_ex,
    output [`RD_WIDTH - 1:0]rd_mem
    );
    
//    reg [`DATA_WIDTH - 1:0]alu_res;
    reg [`DATA_WIDTH - 1:0]imm;
    reg [`DATA_WIDTH - 1:0]mem_address;
    reg [3:0]control_flow;
    reg [`RD_WIDTH - 1:0]rd;
    always@(posedge clk)begin
        if(rst_n)begin
//            alu_res <= 0;
            imm <= 0;
            mem_address <= 0;
            control_flow <= 0;
            rd <= 0;            
        end
        else begin
//            alu_res <= alu_res_i;
            imm <= imm_i;
            mem_address <= alu_res_i;
            control_flow <= control_flow_i;
            rd <= rd_ex;
        end
    end
    
    assign mem_write_data_o = imm;
    assign mem_address_o = mem_address[`BUS_WIDTH - 1:0];
    assign control_flow_o = control_flow[1:0];
    assign rd_mem = rd;
    assign  mem_write = control_flow[3];
    assign  mem_read = control_flow[2];
    
endmodule