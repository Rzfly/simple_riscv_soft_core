`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/13 16:41:44
// Design Name: 
// Module Name: booth_2bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module carry_save_adder#(
    parameter DATA_WIDTH = 32
)(
        input [DATA_WIDTH - 1:0]a,
        input [DATA_WIDTH - 1:0]b,
        input [DATA_WIDTH - 1:0]c,
        output [DATA_WIDTH - 1:0]sum,
        output [DATA_WIDTH - 1:0]cout
    );
    
    genvar i;
    generate
        for(i = 0; i < DATA_WIDTH; i = i + 1)
        begin:three
            assign {cout[i],sum[i]} = a[i] + b[i] + c[i];            
        end
    endgenerate
    
endmodule


module booth_2bit#(
    parameter DATA_WIDTH = 34,
    parameter EXTEND_WIDTH = 33,
    parameter BIAS = 0
)(
        input [2:0]y,
        input [DATA_WIDTH - 1:0] num_double,
        input [DATA_WIDTH - 1:0] num_double_minus,
        input [DATA_WIDTH - 1:0] num_data_width,
        input [DATA_WIDTH - 1:0] num_minus,
    
        output [EXTEND_WIDTH + DATA_WIDTH - 1:0]num_booth_extend
    );
    
    
    wire y0;
    wire y1;
    wire y2;
    
    reg [DATA_WIDTH - 1:0]num_booth;
    assign num_booth_extend = {{EXTEND_WIDTH{num_booth[DATA_WIDTH - 1]}},num_booth} << BIAS;
    
    assign {y2,y1,y0} = y;
    
    always@(*)begin
        case({y2,y1,y0})
            3'b000:begin
                num_booth <= 'd0;
            end
            //+1
            3'b001:begin
                num_booth <= num_data_width;
            end
            //+1
            3'b010:begin
                num_booth <= num_data_width;
            end
            //+2
            3'b011:begin
                num_booth <= num_double;
            end
            //-2
            3'b100:begin
                num_booth <= num_double_minus;
            end
            //-1
            3'b101:begin
                num_booth <= num_minus;
            end
            //-1
            3'b110:begin
                num_booth <= num_minus;
            end
            3'b111:begin
                num_booth <= 'd0;
            end
            default:begin
                num_booth <= 'd0;
            end
        endcase
    end
endmodule
