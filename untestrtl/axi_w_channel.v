`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2022 03:13:01 PM
// Design Name: 
// Module Name: axi_w_channel
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
module axi_w_channel#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH    = 4,
    parameter STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    input ACLK,
    input ARESETn,
    
    //address
	input	   [ADDR_WIDTH-1:0] AWADDR,
    input                       AWVALID,
    output  reg                 AWREADY,
//	input	   [ID_WIDTH - 1:0] AWID,
	input	   [7:0]            AWLEN,	//nums. 0 = one transfer
	input	   [2:0]            AWSIZE, //length. less than the width of bus b'010
	input	   [1:0]	        AWBURST,//type.00 = fix address. 01 = incre address. 10 = wrap
    //data
	input	   [DATA_WIDTH-1:0] WDATA,
    input      [STRB_WIDTH-1:0] WSTRB,//mask
    input                       WVALID,
    input                       WLAST,
    output  reg                 WREADY,
//	input	   [ID_WIDTH - 1:0] WID,//match awid
    //resp
//	output	reg[ID_WIDTH - 1:0] BID,//match awid
    output  reg[1:0]            BRESP,//00 = OKAY
    input                       BREADY,
    output  reg                 BVALID,
    
    //interface to sram
    output reg					wen,
    output reg [3:0]			wmask,
	output reg [2:0]			awsize,
	output reg [15:0]			awaddr,
	output reg [31:0]			wdata
    );
    
      //常量定义
    parameter   TCO     =   0;  	//寄存器延时

	//=========================================================
    //中间信号
	reg	    [15:0]	awaddr_start;	//起始地址
	reg     [15:0]	awaddr_stop;	//终止地址（不加起始地址）
	reg	    [15:0]	awaddr_cnt;		//地址计数器
	reg	    [8:0]	awaddr_step;	//地址步进长度
	reg			    awaddr_cnt_flag;//地址累加标志
	reg     [7:0]	awlen;			//awlen
    
    always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			AWREADY	<= #TCO 0;
		else if( AWVALID && !AWREADY)
			AWREADY	<= #TCO 1;
		else
			AWREADY	<= #TCO 0;
	end

	//----------------------------------------------------------------------
    //WREADY回应
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			WREADY	<= #TCO 0;
		else if( AWREADY )
			WREADY	<= #TCO 1;
		else if( WVALID && WLAST)
			WREADY	<= #TCO 0;	
		else
			WREADY	<= #TCO WREADY;
	end

	//----------------------------------------------------------------------
    //BVALID回应
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			BVALID	<= #TCO 0;
		else if( ~BVALID && WLAST)
			BVALID	<= #TCO 1;
		else
			BVALID	<= #TCO 0;
	end

    //======================================================================
    //参数寄存	
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)begin
			awaddr_start	<= #TCO 0;
			awlen			<= #TCO 0;
			awsize			<= #TCO 0;
		end
		else if(AWVALID)begin
			awaddr_start	<= #TCO AWADDR[15:0];	//起始地址寄存
			awlen			<= #TCO AWLEN;			//突发长度寄存
			awsize			<= #TCO AWSIZE;			//数据宽度寄存
		end
		else begin
			awaddr_start	<= #TCO awaddr_start;
			awlen			<= #TCO awlen;
			awsize			<= #TCO awsize;
		end
	end


	//======================================================================
    //写地址累加
	//assign	awaddr_step	= 2**awsize;			//计算步进
	always@(*) begin
		case(awsize)
		    //one byte
			3'h0:	awaddr_step = 16'h1;
			3'h1:	awaddr_step = 16'h2;
			//for bytes
			3'h2:	awaddr_step = 16'h4;
			default:awaddr_step = 16'h1;
		endcase
	end

	//assign	awaddr_stop = awlen*awaddr_step;	//计算步进次数
	always@(*) begin
		case(awsize)
		    //once one byte
			3'h0:	awaddr_stop = {8'h0,awlen};
		    //once two byte
			3'h1:	awaddr_stop = {7'h0,awlen,1'b0};
		    //once three byte
			3'h2:	awaddr_stop = {6'h0,awlen,2'b0};
			default:awaddr_stop = {8'h0,awlen};
		endcase
	end


	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			awaddr_cnt_flag	<= #TCO 0;
		else if(AWVALID)
			awaddr_cnt_flag = #TCO 1;
		else if(awlen == 0)
			awaddr_cnt_flag = #TCO 0;
		else if(awaddr_cnt == awaddr_stop)
			awaddr_cnt_flag = #TCO 0;
	end

	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			awaddr_cnt	<= #TCO 0;
//awvalid    awvalid           awvalid
//wvalid     wvalid            wvalid
//           awready           awready
//           awaddr_cnt_flag   awaddr_cnt_flag
//                             wready
//                             wen
//                             awaddr               awaddr(update)
//                             awaddr_cnt(update)
		else if(awaddr_cnt_flag)
			awaddr_cnt	<= #TCO awaddr_cnt + awaddr_step;
		else
			awaddr_cnt	<= #TCO 0;
	end


	//======================================================================
	//输出信号

	//----------------------------------------------------------------------
    //使能
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			wen	<= #TCO 0;
		else if(WLAST)
			wen	<= #TCO 0;
        //two cycles after AWVALID high, but why not WREADY?
		else if(AWREADY)
			wen	<= #TCO 1;
		else
			wen	<= #TCO wen;
	end

	//----------------------------------------------------------------------
    //写数据
	always@(*)begin
		case(awsize)
			3'b000:	wdata = {24'b0,WDATA[7:0]};	//8bit
			3'b001:	wdata = {16'b0,WDATA[15:0]};//16bit
			3'b010:	wdata = WDATA[31:0];		//32bit
			default:wdata = WDATA[31:0];
		endcase
	end


	//----------------------------------------------------------------------
    //写地址
	always@(posedge ACLK, negedge ARESETn)begin
		if(!ARESETn)
			awaddr	<= #TCO 0;
		else
			awaddr 	<= #TCO awaddr_start + awaddr_cnt;
	end

	//======================================================================
	//其他信号

	//----------------------------------------------------------------------
    //回应
	always @(*) begin
		BRESP = 0;
	end

	

endmodule
