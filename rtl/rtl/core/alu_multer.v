
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 2022/03/08 17:13:24
//// Design Name: 
//// Module Name: diver
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//module alu_divider#(
//    parameter DATA_WIDTH = 32
//)(
//    input clk,
//    input rst_n,
//    input cancel,
//    input req_valid,
//    output req_ready,
//    output rsp_valid,
//    input rsp_ready,
//    input signed_div,
//    //end
//    input [DATA_WIDTH - 1:0]num1,
//    //sor
//    input [DATA_WIDTH - 1:0]num2,
//    output [DATA_WIDTH - 1:0]signed_div_res,
//    output [DATA_WIDTH - 1:0]unsigned_div_res,
//    output [DATA_WIDTH - 1:0]signed_rem_res,
//    output [DATA_WIDTH - 1:0]unsigned_rem_res
//    );
    
//    reg [2*DATA_WIDTH - 1:0] divide_end;
//    reg [DATA_WIDTH - 1:0] divide_sor;
//    reg divide_res_sign;
//    reg divide_rem_sign;
//    reg [DATA_WIDTH :0] result;
//    reg [4:0] div_ptr;
    
//    wire [DATA_WIDTH: 0] end_sub_sor;
    
    
//    wire num1_signed = signed_div & num1[DATA_WIDTH - 1];
//    wire num2_signed = signed_div & num2[DATA_WIDTH - 1];
    
    
//    wire [DATA_WIDTH - 1:0]abs_num1;
//    wire [DATA_WIDTH - 1:0]abs_num2;
    
//    assign abs_num1 = ({32{num1_signed}}^num1) + num1_signed;
//    assign abs_num2 = ({32{num2_signed}}^num2) + num2_signed;
    
//    wire s_res_signed = num1[DATA_WIDTH - 1] ^ num2[DATA_WIDTH - 1]  & signed_div;
//    wire r_res_signed = num1[DATA_WIDTH - 1]  & signed_div;

//    wire [DATA_WIDTH - 1 : 0]divide_end_33;
    
    
//    localparam state_idle = 3'b001;
//    localparam state_busy = 3'b010;
//    localparam state_back = 3'b100;
    
//    reg [2:0]state;
//    reg [2:0]next_state;
//    always@(posedge clk)begin
//        if(!rst_n)begin
//            state <= state_idle;
//        end
//        else begin
//            state <= next_state;
//        end
//    end
    
//    always@(*)begin
//        case(state)
//            state_idle:begin
//                if(req_valid && !cancel)begin
//                    next_state <= state_busy;
//                end
//                else begin
//                    next_state <= state_idle;        
//                end
//            end
//            state_busy:begin
//                if(div_ptr == 5'd0)begin
//                    next_state <= state_back;
//                end
//                else begin
//                    next_state <= state_busy;
//                end
//            end
//            state_back:begin
//                if(rsp_ready)begin
//                    next_state <= state_idle;        
//                end
//                else begin
//                    next_state <= state_back;
//                end
//            end
//            default:begin
//                next_state <= state_idle;
//            end
//        endcase        
//    end
    
//    assign divide_end_33 = divide_end[div_ptr+:DATA_WIDTH + 1];
//    assign end_sub_sor = divide_end_33 - {1'b0,divide_sor};
//    always@(posedge clk)begin
//        if(!rst_n)begin
//            divide_end <= 0;
//            divide_sor <= 0;
//            divide_res_sign <= 0;
//            divide_rem_sign <= 0;
//            result <= 0;
//            div_ptr <= 0;
//        end
//        else if(state[0] && req_valid)begin
            
//            divide_end <= {32'd0, abs_num1};
//            divide_sor <= abs_num2;
//            divide_res_sign <= s_res_signed;
//            divide_rem_sign <= r_res_signed;
//            div_ptr <= 31;
//            result <= 0;
//        end
//        // not enough
//        else if(state[1] && end_sub_sor[DATA_WIDTH])begin
//            divide_end <= divide_end;
//            divide_sor <= divide_sor;
//            result <= {result[DATA_WIDTH - 2:0],1'b0};
//            div_ptr <= div_ptr - 1;
//            divide_res_sign <= divide_res_sign;
//            divide_rem_sign <= divide_rem_sign;
//        end
//        else if(state[1] && (!end_sub_sor[DATA_WIDTH]))begin
//            divide_end[div_ptr+:DATA_WIDTH] <= end_sub_sor;        
//            divide_sor <= divide_sor;
//            result <= {result[DATA_WIDTH - 2:0],1'b1};
//            div_ptr <= div_ptr - 1;
//            divide_res_sign <= divide_res_sign;
//            divide_rem_sign <= divide_rem_sign;
//        end
//        else if(state[2] && rsp_ready)begin
//            divide_end <= 0;
//            divide_sor <= 0;
//            result <= 0;
//            div_ptr <= 0;
//            divide_res_sign <= 0;
//            divide_rem_sign <= 0;
//        end
//        else begin
//            divide_end <= divide_end;
//            divide_sor <= divide_sor;
//            result <= result;
//            div_ptr <= div_ptr;
//            divide_res_sign <= divide_res_sign;
//            divide_rem_sign <= divide_rem_sign;
//        end
//    end
    
    
//    assign signed_div_res  =  ({32{divide_res_sign}}^result) + divide_res_sign;
//    assign unsigned_div_res = result;
//    assign signed_rem_res   =  ({32{divide_rem_sign}} ^ divide_end[31:0]) + divide_rem_sign;
//    assign unsigned_rem_res = divide_end[31:0];
    
    
//    assign req_ready  = state[0];
//    assign rsp_valid  = state[2];
    
//endmodule
