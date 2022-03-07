`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2022 04:41:57 PM
// Design Name: 
// Module Name: axi_r_channel
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

//slave
module axi_r_channel#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH    = 4,
    parameter STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    /********* clock & reset *********/
	input                       ACLK,
	input      	                ARESETn,
	/******** AXI ********/
	//address                
//	input	   [ID_WIDTH-1:0]   ARID,
	input	   [ADDR_WIDTH-1:0] ARADDR,
	input	   [7:0]            ARLEN,
	input	   [2:0]	        ARSIZE,
	input	   [1:0]	        ARBURST,
	input	  	                ARVALID,
	output reg	                ARREADY,
	//data                
//	output reg [ID_WIDTH-1:0]	RID,
	output reg [DATA_WIDTH-1:0]	RDATA,
	//no single channel
	output reg [1:0]	        RRESP,
	output reg	                RLAST,
	output reg                  RVALID,
	input	 	                RREADY,
	/********** sram **********/
    input      [31:0]	        sram_rdata,
	output reg					ren,
	output reg [2:0]			arsize,
	output reg [15:0]			araddr
);  

    //=========================================================
    //常量定义
    parameter   TCO     =   0;  //寄存器延时

	//=========================================================
    //中间信号
	reg	[15:0]	araddr_start;	//起始地址
	reg	[15:0]	araddr_stop;	//终止地址（不加起始地址）
	reg	[15:0]	araddr_cnt;		//地址计数器
	reg	[8:0]	araddr_step;	//地址步进长度
	reg			araddr_cnt_flag;//地址累加标志
	reg [7:0]	arlen;			//awlen


    //======================================================================
    //握手

	//----------------------------------------------------------------------
    //ARREADY响应
	always@( posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			ARREADY	<= #TCO 0;
		else if(ARVALID&&!ARREADY)
			ARREADY <= #TCO 1;
		else
			ARREADY	<= #TCO 0;
	end

	//----------------------------------------------------------------------
    //RVALID输出
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			RVALID	<= #TCO 0;
		else if(ARREADY)
			RVALID	<= #TCO 1;
		else if(RLAST)
			RVALID	<= #TCO 0;
		else
			RVALID	<= #TCO RVALID;
	end

    //======================================================================
    //参数寄存	
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)begin
			araddr_start	<= #TCO 0;
			arlen			<= #TCO 0;
			arsize			<= #TCO 0;
		end
		else if(ARVALID)begin
			araddr_start	<= #TCO ARADDR[15:0];	//起始地址寄存
			arlen			<= #TCO ARLEN;			//突发长度寄存
			arsize			<= #TCO ARSIZE;			//数据宽度寄存
		end
		else begin
			araddr_start	<= #TCO araddr_start;
			arlen			<= #TCO arlen;
			arsize			<= #TCO arsize;
		end
	end


	//----------------------------------------------------------------------
    //RLAST输出
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			RLAST	<= #TCO 0;
		else if(RREADY)
			if(araddr_cnt==araddr_stop)
				RLAST	<= #TCO 1;
			else
				RLAST	<= #TCO 0;
		else
			RLAST	<= #TCO 0;
	end

	//======================================================================
    //读地址累加
	//assign	araddr_step	= 2**arsize;        	//计算步进
	always@(*) begin
		case(arsize)
			3'h0:	araddr_step = 16'h1;
			3'h1:	araddr_step = 16'h2;
			3'h2:	araddr_step = 16'h4;
			default:araddr_step = 16'h1;
		endcase
	end

	//assign	araddr_stop = arlen*araddr_step;	//计算步进次数
	always@(*) begin
		case(arsize)
			3'h0:	araddr_stop = {8'h0,arlen};
			3'h1:	araddr_stop = {7'h0,arlen,1'b0};
			3'h2:	araddr_stop = {6'h0,arlen,2'b0};
			default:araddr_stop = {8'h0,arlen};
		endcase
	end

	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			araddr_cnt_flag	<= #TCO 0;
		else if(ARVALID)
			araddr_cnt_flag	<= #TCO 1;
		else if(arlen==0)
			araddr_cnt_flag	<= #TCO 0;
		else if(araddr_cnt==araddr_stop)
			araddr_cnt_flag	<= #TCO 0;
	end

	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			araddr_cnt	<= #TCO 0;
		else if(araddr_cnt_flag)
			araddr_cnt	<= #TCO araddr_cnt + araddr_step;
		else
			araddr_cnt	<= #TCO 0;
	end


    //======================================================================
    //输出信号
	
	//----------------------------------------------------------------------
    //使能
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			ren	<= #TCO 0;
		else if(RREADY&&(araddr_cnt==arlen))
			ren	<= #TCO 0;
		else if(ARVALID)
			ren	<= #TCO 1;
		else
			ren	<= #TCO ren;
	end


	//----------------------------------------------------------------------
    //读地址

	always@(*) begin
		araddr = araddr_start + araddr_cnt;
	end

//	//----------------------------------------------------------------------
//    //读数据
//	always@(posedge ACLK, negedge ARESETn)begin
//		if(!ARESETn)
//			RDATA	<= #TCO 0;
//		else if(RREADY)
//			RDATA	<= #TCO sram_rdata;
//		else
//			RDATA	<= #TCO RDATA;
//	end
	//----------------------------------------------------------------------
    //读数据
	always@(*)begin
		if(!ARESETn)
			RDATA	= #TCO 0;
		else if(RREADY)
			RDATA	= #TCO sram_rdata;
		else
			RDATA	= #TCO RDATA;
	end
	

	//======================================================================
	//其他信号

	//----------------------------------------------------------------------
    //回应
	always@(*) begin
		RRESP = 0;
	end
endmodule
