`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/02/26 15:12:55
// Design Name: 
// Module Name: sync_fifo_sim
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


module sync_fifo_sim(

    );
    
    reg clk;
    reg rst_n;
    reg [31:0]counter_w;
    wire [31:0] rdata;
    reg [31:0]counter_r;
    reg w_req;
    reg r_req;
    wire full;
    wire empty;
    initial
    begin
        clk <= 0;
        rst_n <= 0;
        w_req <= 0;
        r_req <= 0;
        counter_w <= 0;
        counter_r <= 0;
        #100
        rst_n <= 1;
        #200
        w_req = 1;
        #200 
        r_req = 1;
        #200 
        w_req = 0;
        #200 
        w_req = 1;
        #200 
        r_req = 0;
    end
    
    always #10 clk= ~clk;
    
    syc_fifo syc_fifo_inst (
	   .clk(clk),
	   .rst_n(rst_n),
	   .w_req(w_req),
	   .wdata(counter_w),
	   .full(full),
	   .rdata(rdata),
	   .r_req(r_req),
       .empty(empty)
    );

    always@(posedge clk)begin
        if(!rst_n)begin
            counter_w <= 0;
        end
        else if(w_req && !full)begin
            counter_w <= counter_w + 1;
        end
    end
    always@(posedge clk)begin
        if(!rst_n)begin
            counter_r <= 0;
        end
        else if(r_req && !empty)begin
            counter_r <= rdata;
        end
    end
    
    
endmodule
