`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/08 17:13:24
// Design Name: 
// Module Name: diver
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


module diver#(
    parameter DATA_WIDTH = 32
)(
    input clk,
    input rst_n,
    input cancel,
    input req_valid,
    output req_ready,
    output rsp_valid,
    input rsp_ready,
    //end
    input [DATA_WIDTH - 1:0]num_1,
    //sor
    input [DATA_WIDTH - 1:0]num_2,
    input signed_div,
    output [DATA_WIDTH - 1:0]signed_div_res,
    output [DATA_WIDTH - 1:0]unsigned_div_res,
    output [DATA_WIDTH - 1:0]signed_rem_res,
    output [DATA_WIDTH - 1:0]unsigned_rem_res
    );
    
    reg [DATA_WIDTH - 1:0]num_1_d;
    reg [DATA_WIDTH - 1:0]num_2_d;
    reg signed_div_d;
    
    
    reg [2*DATA_WIDTH - 1:0] divide_end;
    reg [DATA_WIDTH - 1:0] divide_sor;
    reg divide_res_sign;
    reg divide_rem_sign;
    reg [DATA_WIDTH :0] result;
    reg [4:0] div_ptr;
    wire req_ok;
    wire rsp_ok;
    wire [DATA_WIDTH: 0] end_sub_sor;
    wire [DATA_WIDTH - 1:0]abs_num1;
    wire [DATA_WIDTH - 1:0]abs_num2;
    
    wire [DATA_WIDTH - 1 : 0]divide_end_33;
    
    localparam state_idle = 4'b0001;
    localparam state_init = 4'b0010;
    localparam state_busy = 4'b0100;
    localparam state_back = 4'b1000;
    
    reg [3:0]state;
    reg [3:0]next_state;
    
    assign req_ok = req_valid && req_ready && !cancel;
    assign rsp_ok = rsp_valid && rsp_ready;   
        
    assign rsp_valid = state[3];
    assign req_ready = state[0];
    
    wire reuse_div;
    assign reuse_div = (num_1 == num_1_d) && (num_2 == num_2_d) && (signed_div == signed_div_d);
        
    wire num1_signed = signed_div_d & num_1_d[DATA_WIDTH - 1];
    wire num2_signed = signed_div_d & num_2_d[DATA_WIDTH - 1];
   
    wire s_res_signed_pre = (num_1[DATA_WIDTH - 1] ^ num_2[DATA_WIDTH - 1]) & signed_div;
    wire r_res_signed_pre = num_1[DATA_WIDTH - 1]  & signed_div;
//    wire s_res_signed = (num_1_d[DATA_WIDTH - 1] ^ num_2_d[DATA_WIDTH - 1])  & signed_div_d;
//    wire r_res_signed = num_1_d[DATA_WIDTH - 1]  & signed_div_d;
    reg s_res_signed;
    reg r_res_signed;
    wire div_exceed = end_sub_sor[DATA_WIDTH];
    assign abs_num1 = ({32{num1_signed}}^num_1_d) + num1_signed;
    assign abs_num2 = ({32{num2_signed}}^num_2_d) + num2_signed;
    wire dividend_zero;
    wire dividsor_zero;
    assign dividend_zero = (num_1 == 'd0)?1'b1:1'b0;
    assign dividsor_zero = (num_2 == 'd0)?1'b1:1'b0;
    wire divide_overflow;
    assign divide_overflow = (num_1 == 32'h80000000) && (num_2 == 32'hffffffff) && signed_div;
        
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
                if(req_ok && dividsor_zero)begin
                    next_state <= state_back;
                end
                else if(req_ok && divide_overflow)begin
                    next_state <= state_back;
                end
                else if(req_ok && reuse_div)begin
                    next_state <= state_back;
                end
                else if(req_ok)begin
                    next_state <= state_init;
                end
                else begin
                    next_state <= state_idle;        
                end
            end
            state_init:begin
                if(cancel)begin
                    next_state <= state_idle;
                end
                else begin
                    next_state <= state_busy;
                end
            end
            state_busy:begin
                if(cancel)begin
                    next_state <= state_idle;
                end
                else if(div_ptr == 5'd0)begin
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
            default:begin
                next_state <= state_idle;
            end
        endcase        
    end
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            num_1_d <= 'd0;
            num_2_d <= 'd0;
            signed_div_d <= 'd0;
            s_res_signed <= 'd0;
            r_res_signed <= 'd0;
        end
        else if(req_ok)begin
            num_1_d <= num_1;
            num_2_d <= num_2;
            signed_div_d <= signed_div;  
            s_res_signed <=  s_res_signed_pre;
            r_res_signed <=  r_res_signed_pre;
        end
        else begin
            num_1_d <= num_1_d;
            num_2_d <= num_2_d;
            signed_div_d <= signed_div_d; 
            s_res_signed <= s_res_signed;
            r_res_signed <= r_res_signed;           
        end
    end
    
    assign divide_end_33 = divide_end[div_ptr+:DATA_WIDTH + 1];
    assign end_sub_sor = divide_end_33 - {1'b0,divide_sor};
    always@(posedge clk)begin
        if(!rst_n)begin
            divide_end <= 0;
            divide_sor <= 0;
            divide_res_sign <= 0;
            divide_rem_sign <= 0;
            result <= 0;
            div_ptr <= 0;
        end
        else if(state[0] && req_ok && dividsor_zero )begin
            divide_end <= {32'd0, num_1};
            divide_sor <= 0;
            divide_res_sign <= 'd0;
            divide_rem_sign <= 'd0;
            div_ptr <= 0;
            result <= 32'hffffffff;
        end
        else if(state[0] && req_ok && divide_overflow )begin
            divide_end <= 0;
            divide_sor <= 0;
            divide_res_sign <= s_res_signed_pre;
            divide_rem_sign <= r_res_signed_pre;
            div_ptr <= 0;
            result <= 32'h80000000;
        end
        else if(state[1])begin
            divide_end <= {32'd0, abs_num1};
            divide_sor <= abs_num2;
            divide_res_sign <= s_res_signed;
            divide_rem_sign <= r_res_signed;
            div_ptr <= 31;
            result <= 0;
        end
        // not enough
        else if(state[2] &&  div_exceed)begin
            divide_end <= divide_end;
            divide_sor <= divide_sor;
            result <= {result[DATA_WIDTH - 2:0],1'b0};
            div_ptr <= div_ptr - 1;
            divide_res_sign <= divide_res_sign;
            divide_rem_sign <= divide_rem_sign;
        end
        else if(state[2] && (!div_exceed))begin
            divide_end[div_ptr+:DATA_WIDTH] <= end_sub_sor;        
            divide_sor <= divide_sor;
            result <= {result[DATA_WIDTH - 2:0],1'b1};
            div_ptr <= div_ptr - 1;
            divide_res_sign <= divide_res_sign;
            divide_rem_sign <= divide_rem_sign;
        end
        //  7 /-3 = 7/3
        //   00000111
        // - 0011
        // res 0 rem 00000111  
        //   00000111
        // -  0011
        // res 0 rem 00000111  
        //   00000111
        // -   0011
        // res 0 rem 00000111  
        //   00000111
        // -    0011
        // res 1 rem 00000001  
        //   00000001
        // -     0011
        // res 0 rem 00000001  
        else begin
            divide_end <= divide_end;
            divide_sor <= divide_sor;
            result <= result;
            div_ptr <= div_ptr;
            divide_res_sign <= divide_res_sign;
            divide_rem_sign <= divide_rem_sign;
        end
    end
    
    
    assign signed_div_res  =  ({32{divide_res_sign}} ^ result) + divide_res_sign;
    assign unsigned_div_res = result;
    assign signed_rem_res   =  ({32{divide_rem_sign}} ^ divide_end[31:0]) + divide_rem_sign;
    assign unsigned_rem_res = divide_end[31:0];
      
endmodule
