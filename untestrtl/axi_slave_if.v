`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2022 05:10:04 PM
// Design Name: 
// Module Name: axi_slave_if
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


module axi_slave_if#(
  parameter   DATA_WIDTH  = 32,             //数据位宽
  parameter   ADDR_WIDTH  = 32,               //地址位宽              
  parameter   ID_WIDTH    = 1,               //ID位宽
  parameter   STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    /********* clock & reset *********/
	input                       ACLK,
	input      	                ARESETn,
	/******** AXI ********/
    // write address channel
//	input      [ID_WIDTH-1:0]   AWID,
	input	   [ADDR_WIDTH-1:0] AWADDR,
	input	   [7:0]            AWLEN,
	input	   [2:0]            AWSIZE,
	input	   [1:0]	        AWBURST,
//	input	  	                AWLOCK,
//	input	   [3:0]	        AWCACHE,
//	input	   [2:0]	        AWPROT,
//	input	   [3:0]	        AWQOS,
//	input	   [3:0]            AWREGION,
//	input	   [USER_WIDTH-1:0]	AWUSER,
	input	 	                AWVALID,
	output    	                AWREADY,
    // write data channel
//	input	   [ID_WIDTH-1:0]   WID,
	input	   [DATA_WIDTH-1:0] WDATA,
	input	   [STRB_WIDTH-1:0] WSTRB,
	input		                WLAST,
//	input	   [USER_WIDTH-1:0]	WUSER,
	input	  	                WVALID,
	output    	                WREADY,
    // write resp channel
//	output     [ID_WIDTH-1:0]   BID,
	output     [1:0]            BRESP,
//	output     [USER_WIDTH-1:0]	BUSER,
	output    	                BVALID,
	input	  	                BREADY,
    // read address channel
//	input	   [ID_WIDTH-1:0]   ARID,
	input	   [ADDR_WIDTH-1:0] ARADDR,
	input	   [7:0]            ARLEN,
	input	   [2:0]	        ARSIZE,
	input	   [1:0]	        ARBURST,
//	input	  	                ARLOCK,
//	input	   [3:0]	        ARCACHE,
//	input	   [2:0]            ARPROT,
//	input	   [3:0]	        ARQOS,
//	input	   [3:0]	        ARREGION,
//	input	   [USER_WIDTH-1:0]	ARUSER,
	input	  	                ARVALID,
	output    	                ARREADY,
    // read data channel
//	output     [ID_WIDTH-1:0]	RID,
	output     [DATA_WIDTH-1:0]	RDATA,
	output     [1:0]	        RRESP,
	output    	                RLAST,
//	output     [USER_WIDTH-1:0] RUSER,
	output                      RVALID,
	input	 	                RREADY,
    /********* SRAM *********/
	//数据输入
    input      [7:0]	        sram_q0, // 8bits
    input      [7:0]	        sram_q1,
    input      [7:0]	        sram_q2,
    input      [7:0]	        sram_q3,
//    input      [7:0]	        sram_q4,
//    input      [7:0]	        sram_q5,
//    input      [7:0]	        sram_q6,
//    input      [7:0]	        sram_q7,
	//控制信号
    output    	   	            sram_we,      // 0:write, 1:read
    output     [12:0]	        sram_addr_out,
    output     [31:0]           sram_wdata,     //写sram数据
	output     [31:0]           sram_rdata,
    output     [3:0]	        sram_wmask
);  

    //=========================================================
    //常量定义
    parameter   TCO     =   1;  //寄存器延时

    //=========================================================
    //中间信号
	wire					wen;
	wire [2:0]  			awsize;
	wire [15:0]			awaddr;
	wire [31:0]			wdata;

	wire					ren;
	wire [2:0] 			arsize;
	wire [15:0]			araddr;

    //=========================================================
    //sram信号
	wire [15:0]			    sram_addr;	//读写地址
	wire [2:0]				sram_size;	//读写数据宽度
	wire 					bank_sel;	//两组sram片选
	reg [3:0]				sram_csn;	//四片sram片选

    //=========================================================
    //写通道例化
    axi_w_channel#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)u_axi_w_channel(
	   .ACLK(ACLK),
	   .ARESETn(ARESETn),
       .AWADDR(AWADDR),
       .AWVALID(AWVALID),
       .AWREADY(AWREADY),
       .AWLEN(AWLEN),
       .AWSIZE(AWSIZE), //length. less than the width of bus b'010
       .AWBURST(AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
       .WDATA(WDATA),
       .WSTRB(WSTRB),
       .WVALID(WSTRB),
       .WLAST(WLAST),
       .WREADY(WREADY),
       .BRESP(BRESP),
       .BREADY(BREADY),
       .BVALID(BVALID),
       .wen(wen),
       .wmask(wmask),
       .awsize(awsize),
       .awaddr(awaddr),
       .wdata(wdata)
	);

    //=========================================================
    //读通道例化
	axi_r_channel#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)u_axi_r_channel(
	    .ACLK(ACLK),
	    .ARESETn(ARESETn),
	    .ARADDR(ARADDR),
	    .ARLEN(ARLEN),
	    .ARSIZE(ARSIZE),
	    .ARBURST(ARBURST),
	    .ARVALID(ARVALID),
	    .ARREADY(ARREADY),
	    .RDATA(RDATA),
	    .RRESP(RRESP),
	    .RLAST(RLAST),
	    .RVALID(RVALID),
	    .RREADY(RREADY),
	    .sram_rdata(sram_rdata),
	    .ren(ren),
	    .arsize(arsize),
	    .araddr(araddr)
	   );


	//=========================================================
	//sram信号生成
	assign 	sram_we 	= wen? 1 : 0;				//读写使能：0为写，1为读；默认为1
	assign  bank_sel = sram_addr[15]? 1'b0 : 1'b1;	//根据读写地址最高位判断是哪一组

	//=========================================================
	//读写mux
	assign	sram_addr 	= sram_we ? awaddr: araddr;//读写地址
	assign 	sram_size	= sram_we ? awsize: arsize;//读写数据宽度

	//=========================================================
	//片选
	always @ (*) begin
		if(sram_size == 3'b000)begin		//8bit
			case(sram_addr[1:0])
				2'b00: 	sram_csn = 4'b0001;
        		2'b01: 	sram_csn = 4'b0010;
        		2'b10: 	sram_csn = 4'b0100;
        		2'b11: 	sram_csn = 4'b1000;
				default:sram_csn = 4'b0000;
			endcase
		end
		else if(sram_size == 3'b001)begin	//16bit
			case(sram_addr[1])
				1'b0:	sram_csn = 4'b0011;
				1'b1:	sram_csn = 4'b1100;
				default:sram_csn = 4'b0000;
			endcase
		end
		else if(sram_size == 3'b010) 		//32bit
			sram_csn = 4'b1111;
		else
			sram_csn = 4'b0000;
	end

    assign  sram_wmask  = sram_csn;
    
	//=========================================================
	//读写地址、数据
	assign 	sram_addr_out = sram_addr[14:2];
	assign 	sram_wdata 	= wdata;
//	assign  sram_rdata 	= (bank_sel) ?  
//                          {sram_q3, sram_q2, sram_q1, sram_q0} :
//                          {sram_q7, sram_q6, sram_q5, sram_q4} ;

	assign  sram_rdata 	= {sram_q3, sram_q2, sram_q1, sram_q0};
endmodule
