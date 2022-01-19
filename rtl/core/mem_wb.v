

`include "include.v"

module mem_wb(
    input clk,
    input rst_n,
    input [`DATA_WIDTH - 1:0]mem_read_data_i,
    input [`BUS_WIDTH - 1:0] mem_address_i,
    input [`RD_WIDTH - 1:0]  rd_mem,
    input [1:0]control_flow_i,
    output [`BUS_WIDTH - 1:0] mem_address_o,
    output [`DATA_WIDTH - 1:0]mem_read_data_o,
    output write_reg,
    output mem2reg,
    output [`RD_WIDTH - 1:0]rd_wb,
    input [2:0]ins_func3_i,
    output reg [2:0]ins_func3_o
);

//    reg [`DATA_WIDTH - 1:0]alu_res;
//    reg [`DATA_WIDTH - 1:0]mem_data;
    reg [`DATA_WIDTH - 1:0]mem_address;
    reg [1:0]control_flow;
    reg [`RD_WIDTH - 1:0]rd;
    always@(posedge clk)begin
        if(~rst_n)begin
//            mem_data <= 0;
            mem_address <= 0;
            control_flow <= 0;
            rd <= 0;            
            ins_func3_o <= 0;
        end
        else begin
//            mem_data <= mem_read_data_i;
                mem_address <= mem_address_i;
                control_flow <= control_flow_i;
                rd <= rd_mem;
                ins_func3_o <= ins_func3_i;
        end
    end
    
    // already delayed 
    assign mem_read_data_o = mem_read_data_i;
    assign mem_address_o = mem_address[`BUS_WIDTH - 1:0];
//    assign control_flow_o = control_flow[1:0];
    assign mem2reg = control_flow[1];
    assign write_reg = control_flow[0];
    assign rd_wb = rd;
    
endmodule