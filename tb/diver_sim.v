`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/09 20:46:42
// Design Name: 
// Module Name: diver_sim
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


module diver_sim(

    );
    localparam DATA_WIDTH = 32;
        
    reg clk;
    reg  external_reset_n;
    wire rst_n;
    reg cancel;
    reg req_valid;
    wire req_ready;
    wire rsp_valid;
    wire req_mult_ready;
    wire rsp_mult_valid;
    reg rsp_ready;
    reg test_increase;
    reg signed_div;
    reg signed_mult_1;
    reg signed_mult_2;
    //end
    reg [DATA_WIDTH - 1:0]num1;
    //sor
    reg [DATA_WIDTH - 1:0]num2;
    
    wire signed_mult;
    wire signed_div;
    wire [DATA_WIDTH - 1:0]signed_div_res;
    wire [DATA_WIDTH - 1:0]unsigned_div_res;
    wire [DATA_WIDTH - 1:0]signed_rem_res;
    wire [DATA_WIDTH - 1:0]unsigned_rem_res;
    
    wire [DATA_WIDTH - 1:0]signed_mult_resh;
    wire [DATA_WIDTH - 1:0]unsigned_mult_resh;
    wire [DATA_WIDTH - 1:0]signed_mult_resl;
    wire [DATA_WIDTH - 1:0]unsigned_mult_resl;
    
    reg [2*DATA_WIDTH - 1:0]signed_mult_res_right;
    reg [2*DATA_WIDTH:0]both_mult_res_right;
    reg [2*DATA_WIDTH - 1:0]unsigned_mult_res_right;
    wire [2*DATA_WIDTH - 1:0]both_mult_res = {signed_mult_resh,signed_mult_resl};
    wire [2*DATA_WIDTH - 1:0]signed_mult_res = {signed_mult_resh,signed_mult_resl};
    wire [2*DATA_WIDTH - 1:0]unsigned_mult_res = {unsigned_mult_resh,unsigned_mult_resl};
    assign signed_mult = signed_mult_1 | signed_mult_2;
//    reg [DATA_WIDTH - 1:0]signed_div_res_right;
//    reg [DATA_WIDTH - 1:0]signed_div_rem_right;
  
    
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        external_reset_n = 0 ;
        req_valid = 1;
        rsp_ready = 1;
        cancel = 0;
        signed_div = 0;
        signed_mult_1 = 0;
        signed_mult_2 = 0;
        test_increase = 1;
        #66
        external_reset_n = 1 ;
        
        #1000
        test_increase = 0;
        #1000
        test_increase = 1;
        
    end
    
    
    always@(posedge clk)begin
        if(!rst_n)begin
            signed_mult_res_right <= 'd0;
            both_mult_res_right <= 'd0;
            unsigned_mult_res_right <= 'd0;
        end
        else if(req_valid && req_mult_ready)begin
            both_mult_res_right <= $signed(num1) * $signed({1'b0,num2});
            signed_mult_res_right <= $signed(num1) * $signed(num2);
            unsigned_mult_res_right <= num1 * num2;
        end
    end
    
    wire signed_mult_right = (signed_mult_res_right == signed_mult_res)?rsp_mult_valid && rsp_ready:'d0;
    wire unsigned_mult_right = (unsigned_mult_res_right == unsigned_mult_res)?rsp_mult_valid && rsp_ready:'d0;
    wire both_mult_right = (both_mult_res_right[2*DATA_WIDTH - 1:0] == both_mult_res)?rsp_mult_valid && rsp_ready:'d0;
 
    always@(posedge clk)begin
        if(!rst_n)begin
            num1 <= 32'h80000000;
            num2 <= 32'h80000000;
//            num2 <=  32'h00000000;
//            num1 <= 32'haaaaaaab;
//            num2 <=  32'h0002fe7d;
        end 
        else if(req_valid && req_mult_ready && test_increase)begin
           num1 <=  num1 + 32'h01000000 ;
           num2 <=  num2 + 32'h01000000 ;
        end
    end
    
    sync_reset sync_reset_inst(
        .clk(clk),
        .external_reset_n(external_reset_n),
        .sys_rst_n(rst_n)
    );
    
    diver diver_inst(
        .clk(clk),
        .rst_n(rst_n),
        .cancel(cancel),
        .req_valid(req_valid),
        .req_ready(req_ready),
        .rsp_valid(rsp_valid),
        .rsp_ready(rsp_ready),
        .signed_div(signed_div),
        //end
        .num_1(num1),
        //sor
        .num_2(num2),
        .signed_div_res(signed_div_res),
        .unsigned_div_res(unsigned_div_res),
        .signed_rem_res(signed_rem_res),
        .unsigned_rem_res(unsigned_rem_res)
    );
        
        
//    multer multer_inst(
//        .clk(clk),
//        .rst_n(rst_n),
//        .cancel(cancel),
//        .req_valid(req_valid),
//        .req_ready(req_mult_ready),
//        .rsp_valid(rsp_mult_valid),
//        .rsp_ready(rsp_ready),
//        .signed_mult(signed_mult),
//        //end
//        .num_1(num1),
//        //sor
//        .num_2(num2),
//        .signed_mult_resh(signed_mult_resh),
//        .unsigned_mult_resh(unsigned_mult_resh),
//        .signed_mult_resl(signed_mult_resl),
//        .unsigned_mult_resl(unsigned_mult_resl)
//    );
    
    
    multer_top multer_top_inst(
        .clk(clk),
        .rst_n(rst_n),
        .cancel(cancel),
        .req_valid(req_valid),
        .req_ready(req_mult_ready),
        .rsp_valid(rsp_mult_valid),
        .rsp_ready(rsp_ready),
        .signed_mult_num_1(signed_mult_1),
        .signed_mult_num_2(signed_mult_2),
        .num_1(num1),
        .num_2(num2),
        .signed_mult_resh_d(signed_mult_resh),
        .unsigned_mult_resh_d(unsigned_mult_resh),
        .signed_mult_resl_d(signed_mult_resl),
        .unsigned_mult_resl_d(unsigned_mult_resl)
    );
    
endmodule
