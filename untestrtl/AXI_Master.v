//=============================================================================
//
//Module Name:					AXI_Master.sv
//Department:					Xidian University
//Function Description:	        AXI总线模拟主机
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana	Verdvana	Verdvana		  			2020-3-13
//
//------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		
//
//=============================================================================

`timescale 1ns/1ns

module AXI_Master#(
    parameter   DATA_WIDTH  = 32,             //数据位宽
                ADDR_WIDTH  = 32,               //地址位宽              
                ID_WIDTH    = 4,               //ID位宽
                STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    input               ACLK,
    input      	        ARESETn,
    
    output reg [ADDR_WIDTH-1:0]   AWADDR,
    output  [1:0]    AWBURST,
    output reg [1:0]	AWLEN,
    output [STRB_WIDTH-1:0]   WSTRB,
    output reg          AWVALID,
    output [2:0]    AWSIZE,
    
    input               AWREADY,
    
    output reg [DATA_WIDTH-1:0] WDATA,
    output reg          WLAST,
    output reg          WVALID,
    input               WREADY,
    
    input  [1:0]        BRESP,
    input               BVALID,
    output reg          BREADY,
    
    
    output reg [ADDR_WIDTH-1:0]   ARADDR,
    output      [7:0]    ARLEN,
    output      [2:0]    ARSIZE,
    output      [1:0]    ARBURST,
    output reg          ARVALID,
    input               ARREADY,
    
    input  [DATA_WIDTH-1:0]     RDATA,
    input               RLAST,
    input               RVALID,
    input  [1:0]        RRESP,
    output reg	 		RREADY,
    
    input               en_w,
    input               en_r,
    input  [3:0]        awlen,
    input  [ADDR_WIDTH-1:0]       addr_start,
    output reg [DATA_WIDTH-1:0] data_r
);

    parameter   TCO =   0;
    assign ARBURST = 2'b01;//fixed 01 = incer
    assign AWBURST = 2'b01;//fixed
    assign  ARSIZE = 3'b010;//32BITS
    assign  AWSIZE = 3'b010;
    assign WSTRB = 4'b1111;//all enabled
    
    
    //=========================================================
    //写地址通道

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            AWVALID <= #TCO 0;
        else if(en_w)
            AWVALID <= #TCO 1;
        else if(AWREADY&&AWVALID)
            AWVALID <= #TCO 0;
        else
            AWVALID <= #TCO AWVALID;
    end

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            AWLEN <= #TCO 0;
        else if(en_w)
            AWLEN <= #TCO awlen;
        else
            AWLEN <= #TCO AWLEN;
    end


    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            AWADDR <= #TCO 0;
        else if(en_w)
            AWADDR <= #TCO addr_start;
        else if(AWREADY)
            AWADDR <= #TCO 0;
    end


    //=========================================================

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            WVALID <= #TCO 0;
        else if(AWREADY)
            WVALID <= #TCO 1;
        else if(WREADY&&WVALID&&WLAST)
            WVALID <= #TCO 0;
        else
            WVALID <= #TCO WVALID;
    end

    reg en_data_w;

    always@(*)begin
        if(AWREADY&&AWVALID)
            en_data_w = 1;
        else if(WLAST)
            en_data_w = 0;
        else
            en_data_w = en_data_w;
    end

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            WDATA <= #TCO 0;
        else if(en_data_w)
            WDATA <= #TCO WDATA+1;
        else
            WDATA <= #TCO 0;
    end

    reg [ADDR_WIDTH-1:0] cnt_addr;

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            cnt_addr <= #TCO 0;
        else if(WVALID) begin
            if(cnt_addr==AWLEN)
                cnt_addr <= #TCO 0;
            else
                cnt_addr <= #TCO cnt_addr+1;
        end
        else
            cnt_addr <= #TCO 0;
    end
        

    always@(*) begin
        if(WVALID)begin
            if(cnt_addr==AWLEN)
                WLAST = 1;
            else
                WLAST = 0;
        end
        else
            WLAST = 0;
    end

    //=========================================================
    //写响应通道

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            BREADY <= #TCO 0;
        else if(AWREADY)
            BREADY <= #TCO 1;
        else if(BVALID)
            BREADY <= #TCO 0;
        else
            BREADY <= #TCO BREADY;
    end


    //=========================================================
    //读地址通道

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            ARVALID <= #TCO 0;
        else if(en_r&&~ARVALID)
            ARVALID <= #TCO 1;
        else if(ARREADY&&ARVALID)
            ARVALID <= #TCO 0;
        else
            ARVALID <= #TCO ARVALID;
    end

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            ARADDR <= #TCO 0;
        else if(en_r)
            ARADDR <= #TCO addr_start;
        else
            ARADDR <= #TCO ARADDR;
    end

    //=========================================================


    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            RREADY <= #TCO 0;
        else if(ARVALID)
            RREADY <= #TCO 1;
        else if(RLAST)
            RREADY <= #TCO 0;
        else
            RREADY <= #TCO RREADY;
    end

    always@(posedge ACLK, negedge ARESETn)begin
        if(!ARESETn)
            data_r <= #TCO 0;
        else if(RREADY&&RVALID)
            data_r <= #TCO RDATA;
        else
            data_r <= #TCO 0;
    end

endmodule