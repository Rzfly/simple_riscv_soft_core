`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2022 02:50:53 PM
// Design Name: 
// Module Name: axi_sram_sim
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


module axi_sram_sim(

    );
    
    
    parameter   DATA_WIDTH  = 32;
    parameter   ADDR_WIDTH  = 16;     
    parameter   ID_WIDTH    = 1;
    parameter    STRB_WIDTH  = (DATA_WIDTH/8);
    

    reg clk;
    reg reset_n;
    
    wire  ACLK;
	wire  ARESETn;
	wire	   [ADDR_WIDTH-1:0] AWADDR;
	wire	   [7:0]            AWLEN;
	wire	   [2:0]            AWSIZE;
	wire	   [1:0]	        AWBURST;
	wire	 	                AWVALID;
	wire    	                AWREADY;
	wire	   [DATA_WIDTH-1:0] WDATA;
	wire	   [STRB_WIDTH-1:0] WSTRB;
	wire		                WLAST;
	wire	  	                WVALID;
	wire    	                WREADY;
	wire     [1:0]            BRESP;
	wire    	                BVALID;
	wire	  	                BREADY;
	wire	   [ADDR_WIDTH-1:0] ARADDR;
	wire	   [7:0]            ARLEN;
	wire	   [2:0]	        ARSIZE;
	wire	   [1:0]	        ARBURST;
	wire	  	                ARVALID;
	wire    	                ARREADY;
	wire     [DATA_WIDTH-1:0]	RDATA;
	wire     [1:0]	        RRESP;
	wire    	                RLAST;
	wire                      RVALID;
	wire	 	                RREADY;

//    reg                       bist_en;
//    reg                       dft_en;
//    wire                       bist_done;
//    wire   [7:0]               bist_fail;

    reg                       en_w;
    reg                       en_r;
    reg    [7:0]              awlen;
    reg    [7:0]              arlen;
    reg  [ADDR_WIDTH-1:0]     addr_start;

    wire  [DATA_WIDTH-1:0]      data_r;

    assign                      AWLEN = awlen;
    assign                      ARLEN = arlen;

    AXI_Master#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)u1_AXI_Master(
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        //write address
        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        .AWLEN(AWLEN),
        .AWSIZE(AWSIZE), //length. less than the width of bus b'010
        .AWBURST(AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
        //write data
        .WDATA(WDATA),
        .WSTRB(WSTRB),
        .WVALID(WVALID),
        .WLAST(WLAST),
        .WREADY(WREADY),
        //write resp
        .BRESP(BRESP),
        .BREADY(BREADY),
        .BVALID(BVALID),
        //read address
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        //read data
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RLAST(RLAST),
        .RVALID(RVALID),
        .RREADY(RREADY),
        
        .en_w(en_w),
        .en_r(en_r),
        .awlen(awlen),
        .addr_start(addr_start),
        .data_r(data_r)
	);

    AXI_SRAM#(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.ID_WIDTH(ID_WIDTH),
		.STRB_WIDTH(DATA_WIDTH/8)
	)u1_AXI_Sram(
	    .ACLK(ACLK),
        .ARESETn(ARESETn),
        //write address
        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        .AWLEN(AWLEN),
        .AWSIZE(AWSIZE), //length. less than the width of bus b'010
        .AWBURST(AWBURST),//type.00 = fix address. 01 = incre address. 10 = wrap
        //write data
        .WDATA(WDATA),
        .WSTRB(WSTRB),
        .WVALID(WSTRB),
        .WLAST(WLAST),
        .WREADY(WREADY),
        //write resp
        .BRESP(BRESP),
        .BREADY(BREADY),
        .BVALID(BVALID),
        //read address
        .ARADDR(ARADDR),
        .ARLEN(ARLEN),
        .ARSIZE(ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        //read data
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RLAST(RLAST),
        .RVALID(RVALID),
        .RREADY(RREADY)
//        .bist_en(bist_en),
//        .dft_en(dft_en),
//        .bist_done(bist_done),
//        .bist_fail0(bist_fail0)
	);


    //=========================================================
    //常量
    parameter   PERIOD  =   20, //时钟周期
                TCO     =   0;  //寄存器延迟

    //=========================================================
    //时钟激励
    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk;
    end

    assign ACLK = clk;
    //=========================================================
    //复位&初始化任务
    task task_init;
    begin
        reset_n     = 0;
        //初始化
        en_w        = 0;
        en_r        = 0;
        awlen       = 8'b0000_1111;    //写入/读取数据次数
        addr_start  = 0;
//        AWSIZE      = 2;
//        ARSIZE      = 2;
//        bist_en     = 0;
//        dft_en      = 0;


        //复位
        #PERIOD;#PERIOD;
        reset_n = 1;
        #PERIOD;#PERIOD;
        #2;//输入延迟
    end
    endtask
    assign ARESETn = reset_n;
    //=========================================================
    //0号主机写任务
    task task_m_w(  input [ADDR_WIDTH-1:0] addr,
                    input [7:0] len);
    begin
        addr_start = addr;
        awlen      = len;
        en_w       = 1;
        #PERIOD;
        en_w       = 0;
        #200;
    end
    endtask

    //=========================================================
    //0号主机读任务
    task task_m_r(  input [ADDR_WIDTH-1:0] addr,
                    input [7:0] len);
    begin
        addr_start = addr;
        arlen      = len;
        en_r       = 1;
        #PERIOD;
        en_r       = 0;
        #200;
    end
    endtask
        initial begin
        //复位&初始化
        task_init;

        //0号主机给0号从机写入和读取
        task_m_w(5,0);

        task_m_w(1000,3);

        task_m_w(45,7);



        task_m_r(5,0);

        task_m_r(1000,3);



        #400;
        $stop;
    end
    
    
endmodule
