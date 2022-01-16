

`include "include.v"

module mem_wb(
    input clk,
    input rst_n,
    input [`DATA_WIDTH - 1:0]mem_read_data_i,
    input [`BUS_WIDTH - 1:0]mem_ram_address_i,
    output [`BUS_WIDTH - 1:0]mem_ram_address_o,
    output [`DATA_WIDTH - 1:0]wb_data,
    input [1:0]control_flow_i,
    output write_reg,
    output mem2reg,
    input [`RD_WIDTH - 1:0]rd_mem,
    output [`RD_WIDTH - 1:0]rd_wb
);

//    reg [`DATA_WIDTH - 1:0]alu_res;
//    reg [`DATA_WIDTH - 1:0]mem_data;
    reg [`DATA_WIDTH - 1:0]mem_address;
    reg [1:0]control_flow;
    reg [`RD_WIDTH - 1:0]rd;
    always@(posedge clk)begin
        if(rst_n)begin
//            mem_data <= 0;
            mem_address <= 0;
            control_flow <= 0;
            rd <= 0;            
        end
        else begin
//            mem_data <= mem_read_data_i;
                mem_address <= mem_ram_address_i;
                control_flow <= control_flow_i;
            if(write_reg)begin
                rd <= rd_mem;
            end
            else begin
                  rd <= 0;
            end
        end
    end
    
    // already delayed 
    assign wb_data = mem_read_data_i;
    assign mem_ram_address_o = mem_address[`BUS_WIDTH - 1:0];
//    assign control_flow_o = control_flow[1:0];
    assign write_reg = control_flow[1];
    assign mem2reg = control_flow[0];
    assign rd_wb = rd;
    
endmodule