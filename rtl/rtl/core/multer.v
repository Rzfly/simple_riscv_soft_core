`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/10 14:16:28
// Design Name: 
// Module Name: multer
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
//`define ADD_TREE
//`define DSP
`define WALLACE_TREE

module multer #(
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,
    input cancel,
    input signed_mult_num_1,
    input signed_mult_num_2,
    input [DATA_WIDTH - 1:0]num_1,
    input [DATA_WIDTH - 1:0]num_2,
    output [DATA_WIDTH - 1:0]signed_mult_resh,
    output [DATA_WIDTH - 1:0]signed_mult_resl,
    output [DATA_WIDTH - 1:0]unsigned_mult_resh,
    output [DATA_WIDTH - 1:0]unsigned_mult_resl
    );
    
`ifdef WALLACE_TREE
    //33bit
    wire [DATA_WIDTH:0]num_2_extend;
    wire num_1_extend_sign;
    wire num_2_extend_sign;
    
//    assign num_1_extend_sign = num_1[DATA_WIDTH - 1] & signed_mult;
//    assign num_2_extend_sign = num_2[DATA_WIDTH - 1] & signed_mult;
    
    assign num_1_extend_sign = num_1[DATA_WIDTH - 1] & signed_mult_num_1;
    assign num_2_extend_sign = num_2[DATA_WIDTH - 1] & signed_mult_num_2;
    
    wire [DATA_WIDTH + 1:0] num_1_double;
    wire [DATA_WIDTH + 1:0] num_1_double_minus;
//    wire [DATA_WIDTH:0] num_1_data_width;
    wire [DATA_WIDTH + 1:0] num_1_data_width_plus1  ;
    wire [DATA_WIDTH + 1:0] num_1_minus;
    
//    assign num_1_data_width       = {num_1_extend_sign,num_1};
    assign num_1_data_width_plus1 = {num_1_extend_sign, num_1_extend_sign,num_1};
    assign num_1_double       = {num_1_extend_sign, num_1, 1'b0};
    assign num_1_minus        = (~ num_1_data_width_plus1) + 'd1;
    assign num_1_double_minus = (~ num_1_double) + 'd1;

//    assign num_1_double       = {num_1,1'b0};
//    assign num_1_double       = {num_1_extend_sign,num_1 << 1};
    //67bit = 
    wire [2*DATA_WIDTH + 2 : 0] num1_minus_extend = {{33{num_1_minus[DATA_WIDTH + 1]}}, num_1_minus};
    //33bit
    assign num_2_extend = {num_2_extend_sign, num_2};
    //67bit
    wire [2*DATA_WIDTH + 2 :0]partition_sum[16:0];
    // x(0 ~ 33) y (0 ~ 32)
    // y * x = x << 31 * (~y32) + x << 30 * (y31) + x<< 29 * (y30)...
    // = x<< 31 * (~2y32 + y31 + y30) + x<< 29 * (~2y30 + y29 + y28)
    // + ...
    // + x << 1 * (-2y2 + y1 + y0)
    // (total 16)
    // + x << -1 * (-2y0 + y-1 + y-2) = x * -y0
    // (total 17 part)
    
    
    // y * x = x << 32 * (~y33) + x << 31 * (y32) + x<< 30 * (y31)...
    // = x<< 31 * (~2y33 + y32 + y31) + x<< 29 * (~2y31 + y29 + y28)
    // + ...
    // + x << 1 * (-2y2 + y1 + y0)
    // (total 16)
    // + x << -1 * (-2y0 + y-1 + y-2) = x * -y0
    // (total 17 part)
    
    genvar j;
    generate
        for(j = 0;j < 16;j = j + 1)
        begin:booth
            booth_2bit #(
                .DATA_WIDTH(DATA_WIDTH + 2),
                .EXTEND_WIDTH(DATA_WIDTH + 1),
                .BIAS(2*j + 1)
            )booth_2bit_inst(
                //begin from y0
                .y(num_2_extend[2*j +: 3]),
                .num_double(num_1_double),
                .num_double_minus(num_1_double_minus),
                .num_data_width(num_1_data_width_plus1),
                .num_minus(num_1_minus),
                .num_booth_extend(partition_sum[j+1])
                );         
        end
    endgenerate
    
    assign partition_sum[0] = (num_2_extend[0])?num1_minus_extend:'d0;
                
    //67bit
    wire [16:0]partition_sum_T[2*DATA_WIDTH + 2:0];
    genvar i;
    generate
        for(i = 0;i <= (2*DATA_WIDTH + 2);i = i + 1)
        begin:T_matrix
            assign partition_sum_T[i] = {
                partition_sum[16][i],
                partition_sum[15][i],
                partition_sum[14][i],
                partition_sum[13][i],
                partition_sum[12][i],
                partition_sum[11][i],
                partition_sum[10][i],
                partition_sum[9][i],
                partition_sum[8][i],
                partition_sum[7][i],
                partition_sum[6][i],
                partition_sum[5][i],
                partition_sum[4][i],
                partition_sum[3][i],
                partition_sum[2][i],
                partition_sum[1][i],
                partition_sum[0][i]};   
        end
    endgenerate
    
    wire [2*DATA_WIDTH + 2:0]carry_vector;
    wire [2*DATA_WIDTH + 2:0]sum_vector;
    
    wire [4:0]carry_layer1_o [2*DATA_WIDTH + 2:0];
    wire [4:0]carry_layer2_i [2*DATA_WIDTH + 2:0];

    wire [3:0]carry_layer2_o [2*DATA_WIDTH + 2:0];
    
    wire [3:0]carry_layer3_i [2*DATA_WIDTH + 2:0];
    wire [1:0]carry_layer3_o [2*DATA_WIDTH + 2:0];
    
    wire [1:0]carry_layer4_i [2*DATA_WIDTH + 2:0];
    wire [1:0]carry_layer4_o [2*DATA_WIDTH + 2:0];
    
    wire [1:0]carry_layer5_i [2*DATA_WIDTH + 2:0];
    wire carry_layer5_o [2*DATA_WIDTH + 2:0];
    
    wire carry_layer6_i [2*DATA_WIDTH + 2:0];
    
    
    assign carry_layer2_i[0] = 5'd0;
    assign carry_layer3_i[0] = 4'd0;
    assign carry_layer4_i[0] = 2'd0;
    assign carry_layer5_i[0] = 2'd0;
    assign carry_layer6_i[0] = 1'd0;
    assign carry_vector[0]   = 1'b0;
    wallace_tree_full wallace_tree_full_inst_first(
        .clk(clk),
        .rst_n(rst_n),
        .cancel(cancel),
        .num_in(partition_sum_T[0]),
        .carry_layer1_o(carry_layer1_o[0]),
        .carry_layer2_i(carry_layer2_i[0]),
        .carry_layer2_o(carry_layer2_o[0]),
        .carry_layer3_i(carry_layer3_i[0]),
        .carry_layer3_o(carry_layer3_o[0]),
        .carry_layer4_i(carry_layer4_i[0]),
        .carry_layer4_o(carry_layer4_o[0]),
        .carry_layer5_i(carry_layer5_i[0]),
        .carry_layer5_o(carry_layer5_o[0]),
        .carry_layer6_i(carry_layer6_i[0]),
        .c_out(carry_vector[1]),
        .s_out(sum_vector[0])
    );  
    
    genvar k;
    generate
        for(k = 1;k < (2*DATA_WIDTH + 2);k = k + 1)
        begin:tree
            assign carry_layer2_i[k] = carry_layer1_o [k-1];
            assign carry_layer3_i[k] = carry_layer2_o [k-1];
            assign carry_layer4_i[k] = carry_layer3_o [k-1];
            assign carry_layer5_i[k] = carry_layer4_o [k-1];
            assign carry_layer6_i[k] = carry_layer5_o [k-1];
    
            wallace_tree_full wallace_tree_full_inst(
                .clk(clk),
                .rst_n(rst_n),
                .cancel(cancel),
                .num_in(partition_sum_T[k]),
                .carry_layer1_o(carry_layer1_o[k]),
                .carry_layer2_i(carry_layer2_i[k]),
                .carry_layer2_o(carry_layer2_o[k]),
                .carry_layer3_i(carry_layer3_i[k]),
                .carry_layer3_o(carry_layer3_o[k]),
                .carry_layer4_i(carry_layer4_i[k]),
                .carry_layer4_o(carry_layer4_o[k]),
                .carry_layer5_i(carry_layer5_i[k]),
                .carry_layer5_o(carry_layer5_o[k]),
                .carry_layer6_i(carry_layer6_i[k]),
                .c_out(carry_vector[k+1]),
                .s_out(sum_vector[k])
            );  
        end
    endgenerate
        
    assign carry_layer2_i[2*DATA_WIDTH + 2] = carry_layer1_o [2*DATA_WIDTH + 1];
    assign carry_layer3_i[2*DATA_WIDTH + 2] = carry_layer2_o [2*DATA_WIDTH + 1];
    assign carry_layer4_i[2*DATA_WIDTH + 2] = carry_layer3_o [2*DATA_WIDTH + 1];
    assign carry_layer5_i[2*DATA_WIDTH + 2] = carry_layer4_o [2*DATA_WIDTH + 1];
    assign carry_layer6_i[2*DATA_WIDTH + 2] = carry_layer5_o [2*DATA_WIDTH + 1];

    wallace_tree_full wallace_tree_full_inst_last(
        .clk(clk),
        .rst_n(rst_n),
        .cancel(cancel),
        .num_in(partition_sum_T[2*DATA_WIDTH + 2]),
        .carry_layer1_o(carry_layer1_o[2*DATA_WIDTH + 2]),
        .carry_layer2_i(carry_layer2_i[2*DATA_WIDTH + 2]),
        .carry_layer2_o(carry_layer2_o[2*DATA_WIDTH + 2]),
        .carry_layer3_i(carry_layer3_i[2*DATA_WIDTH + 2]),
        .carry_layer3_o(carry_layer3_o[2*DATA_WIDTH + 2]),
        .carry_layer4_i(carry_layer4_i[2*DATA_WIDTH + 2]),
        .carry_layer4_o(carry_layer4_o[2*DATA_WIDTH + 2]),
        .carry_layer5_i(carry_layer5_i[2*DATA_WIDTH + 2]),
        .carry_layer5_o(carry_layer5_o[2*DATA_WIDTH + 2]),
        .carry_layer6_i(carry_layer6_i[2*DATA_WIDTH + 2]),
        .c_out(),
        .s_out(sum_vector[2*DATA_WIDTH + 2])
    );  
    
    wire [2*DATA_WIDTH + 2:0]signed_mult_result = sum_vector  + carry_vector;
    wire [2*DATA_WIDTH - 1:0]unsigned_mult_result = signed_mult_result[2*DATA_WIDTH - 1:0];
    
    
    assign signed_mult_resh = signed_mult_result[2*DATA_WIDTH - 1:DATA_WIDTH];
    assign signed_mult_resl = signed_mult_result[DATA_WIDTH - 1:0];
    assign unsigned_mult_resh = unsigned_mult_result[2*DATA_WIDTH - 1:DATA_WIDTH];
    assign unsigned_mult_resl = unsigned_mult_result[DATA_WIDTH - 1:0];

`endif 

   
`ifdef ADD_TREE 
    
    reg [2*DATA_WIDTH - 1:0]signed_mult_res;
    wire [2*DATA_WIDTH - 1:0]unsigned_mult_res;
    
    integer i;
    always@(num_1 or num_2)
    begin   
        signed_mult_res = 0;
        for(i = 1; i < DATA_WIDTH ; i = i + 1)begin
            if(num_2[i-1])begin
                signed_mult_res = signed_mult_res + num_1 << (i - 1);
            end
        end
    end
    
    assign req_ready = 1'b1;
    assign rsp_valid = 1'b1;
    assign unsigned_mult_res = signed_mult_res[2*DATA_WIDTH - 1:0];
    assign signed_mult_resh  = signed_mult_res[2*DATA_WIDTH - 1:DATA_WIDTH];
    assign signed_mult_resl  = signed_mult_res[DATA_WIDTH - 1:0];
    assign unsigned_mult_resh  = unsigned_mult_res[2*DATA_WIDTH - 1:DATA_WIDTH];
    assign unsigned_mult_resl  = unsigned_mult_res[DATA_WIDTH - 1:0];
`endif
      
          
     
`ifdef DSP
          
    localparam state_idle = 3'b001;
    localparam state_busy = 3'b010;
    localparam state_back = 3'b100;
    
    wire [2*DATA_WIDTH - 1:0]signed_mult_res;
    wire [2*DATA_WIDTH - 1:0]unsigned_mult_res;
    
    reg [2:0]state;
    reg [2:0]next_state;
    
    reg [DATA_WIDTH - 1:0] mult_1;
    reg [DATA_WIDTH - 1:0] mult_2;
    always@(posedge clk)begin
        if(!rst_n)begin
            state <= state_idle;
        end
        else begin
            state <= next_state;
        end
    end
    
    wire mult_over;
    assign mult_over = 1'b1;
    always@(*)begin
        case(state)
            state_idle:begin
                if(req_valid && !cancel)begin
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
                if(rsp_ready)begin
                    next_state <= state_idle;        
                end
                else begin
                    next_state <= state_back;
                end
            end
            default:begin
                next_state <= state_idle;
            end
        endcase        
    end
    
    always@(posedge clk)begin
        if(!rst_n)begin
            mult_1 <= 32'd0;
            mult_2 <= 32'd0;
        end
        else if(state[0] && req_valid)begin
            mult_1 <= num_1;
            mult_2 <= num_2;
        end
        else if(state[2] && rsp_ready)begin
            mult_1 <= 32'd0;
            mult_2 <= 32'd0;
        end
        else begin
            mult_1 <= mult_1;
            mult_2 <= mult_2;
        end
    end
    
    assign signed_mult_res = $signed(mult_1) * $signed(mult_2);
    assign unsigned_mult_res = mult_1 * mult_2;
    
    assign signed_mult_resh = signed_mult_res[2*DATA_WIDTH -  1:DATA_WIDTH];
    assign signed_mult_resl = signed_mult_res[DATA_WIDTH - 1:0];
    assign unsigned_mult_resh = unsigned_mult_res[2*DATA_WIDTH -  1:DATA_WIDTH];
    assign unsigned_mult_resl = unsigned_mult_res[DATA_WIDTH - 1:0];
    
    
    assign req_ready  = state[0];
    assign rsp_valid  = state[2];
 
 `endif
     
endmodule
