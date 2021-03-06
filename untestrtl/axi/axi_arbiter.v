

module axi_arbiter#(
  parameter   DATA_WIDTH  = 32,               //数据位宽
  parameter   ADDR_WIDTH  = 32,               //地址位宽              
  parameter   ID_WIDTH    = 6,                //ID位宽
  parameter   STRB_WIDTH  = (DATA_WIDTH/8)    //STRB位宽
)(
    // master 0
    // master 0 interface
    //ram
  	input                       ACLK,
	input      	                ARESETn,
    // master 0 interface
	input	   [ADDR_WIDTH-1:0] m0_AWADDR,
	input	   [3:0]            m0_AWLEN,
	input	   [2:0]            m0_AWSIZE,
	input	   [1:0]	        m0_AWBURST,
	input	   [ID_WIDTH -1 :0] m0_AWID,
	input	 	                m0_AWVALID,
	output    	                m0_AWREADY,
	
	input	   [DATA_WIDTH-1:0] m0_WDATA,
	input	   [STRB_WIDTH-1:0] m0_WSTRB,
	input		                m0_WLAST,
	input	   [ID_WIDTH -1 :0] m0_WID,
	input	  	                m0_WVALID,
	output    	                m0_WREADY,
	
	output     [1:0]            m0_BRESP,
	output     [ID_WIDTH -1 :0] m0_BID,
	output    	                m0_BVALID,
	input	  	                m0_BREADY,
	
	input	   [ADDR_WIDTH-1:0] m0_ARADDR,
	input	   [3:0]            m0_ARLEN,
	input	   [2:0]	        m0_ARSIZE,
	input	   [1:0]	        m0_ARBURST,
	input	   [ID_WIDTH -1 :0] m0_ARID,
	input	  	                m0_ARVALID,
	output    	                m0_ARREADY,
	
	output     [DATA_WIDTH-1:0]	m0_RDATA,
	output     [1:0]	        m0_RRESP,
	output    	                m0_RLAST,
	output     [ID_WIDTH -1 :0] m0_RID,
	output                      m0_RVALID,
	input	 	                m0_RREADY,

    // master 1 interface
	input	   [ADDR_WIDTH-1:0] m1_AWADDR,
	input	   [3:0]            m1_AWLEN,
	input	   [2:0]            m1_AWSIZE,
	input	   [1:0]	        m1_AWBURST,
	input	   [ID_WIDTH -1 :0] m1_AWID,
	input	 	                m1_AWVALID,
	output    	                m1_AWREADY,
	
	input	   [DATA_WIDTH-1:0] m1_WDATA,
	input	   [STRB_WIDTH-1:0] m1_WSTRB,
	input		                m1_WLAST,
	input	   [ID_WIDTH -1 :0] m1_WID,
	input	  	                m1_WVALID,
	output    	                m1_WREADY,
	
	output     [1:0]            m1_BRESP,
	output     [ID_WIDTH -1 :0] m1_BID,
	output    	                m1_BVALID,
	input	  	                m1_BREADY,
	
	input	   [ADDR_WIDTH-1:0] m1_ARADDR,
	input	   [3:0]            m1_ARLEN,
	input	   [2:0]	        m1_ARSIZE,
	input	   [1:0]	        m1_ARBURST,
	input	   [ID_WIDTH -1 :0] m1_ARID,
	input	  	                m1_ARVALID,
	output    	                m1_ARREADY,
	
	output     [DATA_WIDTH-1:0]	m1_RDATA,
	output     [1:0]	        m1_RRESP,
	output    	                m1_RLAST,
	output     [ID_WIDTH -1 :0] m1_RID,
	output                      m1_RVALID,
	input	 	                m1_RREADY,
	
    // master 2 interface
	input	   [ADDR_WIDTH-1:0] m2_AWADDR,
	input	   [3:0]            m2_AWLEN,
	input	   [2:0]            m2_AWSIZE,
	input	   [1:0]	        m2_AWBURST,
	input	   [ID_WIDTH -1 :0] m2_AWID,
	input	 	                m2_AWVALID,
	output    	                m2_AWREADY,
	
	input	   [DATA_WIDTH-1:0] m2_WDATA,
	input	   [STRB_WIDTH-1:0] m2_WSTRB,
	input		                m2_WLAST,
	input	   [ID_WIDTH -1 :0] m2_WID,
	input	  	                m2_WVALID,
	output    	                m2_WREADY,
	
	output     [1:0]            m2_BRESP,
	output     [ID_WIDTH -1 :0] m2_BID,
	output    	                m2_BVALID,
	input	  	                m2_BREADY,
	
	input	   [ADDR_WIDTH-1:0] m2_ARADDR,
	input	   [3:0]            m2_ARLEN,
	input	   [2:0]	        m2_ARSIZE,
	input	   [1:0]	        m2_ARBURST,
	input	   [ID_WIDTH -1 :0] m2_ARID,
	input	  	                m2_ARVALID,
	output    	                m2_ARREADY,
	
	output     [DATA_WIDTH-1:0]	m2_RDATA,
	output     [1:0]	        m2_RRESP,
	output    	                m2_RLAST,
	output     [ID_WIDTH -1 :0] m2_RID,
	output                      m2_RVALID,
	input	 	                m2_RREADY,
	
	//s0
    output     [ADDR_WIDTH-1:0] s0_AWADDR,
    output                [1:0] s0_AWBURST,
    output                [3:0]	s0_AWLEN,
    output   [STRB_WIDTH-1:0]   s0_WSTRB,
    output            [2:0]     s0_AWSIZE,
	output     [ID_WIDTH -1 :0] s0_AWID,
    output                      s0_AWVALID,
    input                       s0_AWREADY,
    
    output     [DATA_WIDTH-1:0] s0_WDATA,
    output                      s0_WLAST,
	output     [ID_WIDTH -1 :0] s0_WID,
    output                      s0_WVALID,
    input                       s0_WREADY,
    
    input  [1:0]                s0_BRESP,
	input     [ID_WIDTH -1 :0]  s0_BID,
    input                       s0_BVALID,
    output                      s0_BREADY,
    
    
    output     [ADDR_WIDTH-1:0] s0_ARADDR,
    output      [3:0]           s0_ARLEN,
    output      [2:0]           s0_ARSIZE,
    output      [1:0]           s0_ARBURST,
	output     [ID_WIDTH -1 :0] s0_ARID,
    output                      s0_ARVALID,
    input                       s0_ARREADY,
    
    input  [DATA_WIDTH-1:0]     s0_RDATA,
    input                       s0_RLAST,
    input  [1:0]                s0_RRESP,
	input     [ID_WIDTH -1 :0]  s0_RID,
    input                       s0_RVALID,
    output      	 		    s0_RREADY,
    
	//s1
    output     [ADDR_WIDTH-1:0] s1_AWADDR,
    output                [1:0] s1_AWBURST,
    output                [3:0]	s1_AWLEN,
    output   [STRB_WIDTH-1:0]   s1_WSTRB,
    output            [2:0]     s1_AWSIZE,
	output     [ID_WIDTH -1 :0] s1_AWID,
    output                      s1_AWVALID,
    input                       s1_AWREADY,
    
    output     [DATA_WIDTH-1:0] s1_WDATA,
    output                      s1_WLAST,
	output     [ID_WIDTH -1 :0] s1_WID,
    output                      s1_WVALID,
    input                       s1_WREADY,
    
    input  [1:0]                 s1_BRESP,
	input       [ID_WIDTH -1 :0] s1_BID,
    input                        s1_BVALID,
    output                       s1_BREADY,
    
    
    output     [ADDR_WIDTH-1:0]  s1_ARADDR,
    output      [3:0]            s1_ARLEN,
    output      [2:0]            s1_ARSIZE,
    output      [1:0]            s1_ARBURST,
	output      [ID_WIDTH -1 :0] s1_ARID,
    output                       s1_ARVALID,
    input                        s1_ARREADY,
    
    input  [DATA_WIDTH-1:0]      s1_RDATA,
    input                        s1_RLAST,
    input  [1:0]                 s1_RRESP,
	input       [ID_WIDTH -1 :0] s1_RID,
    input                        s1_RVALID,
    output      	 	     	 s1_RREADY,
    
     //s2
    output     [ADDR_WIDTH-1:0]  s2_AWADDR,
    output                [1:0]  s2_AWBURST,
    output                [3:0]  s2_AWLEN,
    output   [STRB_WIDTH-1:0]    s2_WSTRB,
    output            [2:0]      s2_AWSIZE,
	output      [ID_WIDTH -1 :0] s2_AWID,
    output                       s2_AWVALID,
    input                        s2_AWREADY,
    
    output     [DATA_WIDTH-1:0]  s2_WDATA,
    output                       s2_WLAST,
	output      [ID_WIDTH -1 :0] s2_WID,
    output                       s2_WVALID,
    input                        s2_WREADY,
    
    input  [1:0]                 s2_BRESP,
	input       [ID_WIDTH -1 :0] s2_BID,
    input                        s2_BVALID,
    output                       s2_BREADY,
    
    
    output    [ADDR_WIDTH-1:0]   s2_ARADDR,
    output      [3:0]            s2_ARLEN,
    output      [2:0]            s2_ARSIZE,
    output      [1:0]            s2_ARBURST,
	output      [ID_WIDTH -1 :0] s2_ARID,
    output                       s2_ARVALID,
    input                        s2_ARREADY,
    
    input  [DATA_WIDTH-1:0]      s2_RDATA,
    input                        s2_RLAST,
    input  [1:0]                 s2_RRESP,
	input       [ID_WIDTH -1 :0] s2_RID,
    input                        s2_RVALID,
    output      	 		     s2_RREADY
);

//****************************************************************************
//******************* aribter logic
//****************************************************************************
    localparam [3:0]slave_0 = 3'b001;
    localparam [3:0]slave_1 = 3'b011;
    localparam [3:0]slave_2 = 3'b111;
    
    //rom ram jtag
    localparam [3:0]master_0 = 3'b001;
    localparam [3:0]master_1 = 3'b011;
    localparam [3:0]master_2 = 3'b111;
    
    //jtag 100
    //ram   10
    //rom    1
    wire [2:0]master_AWID_pri = m0_AWID[ID_WIDTH - 1:ID_WIDTH - 3] | m1_AWID[ID_WIDTH - 1:ID_WIDTH - 3]| m2_AWID[ID_WIDTH - 1:ID_WIDTH - 3];
    wire [2:0]master_ARID_pri = m0_ARID[ID_WIDTH - 1:ID_WIDTH - 3] | m1_ARID[ID_WIDTH - 1:ID_WIDTH - 3]| m2_ARID[ID_WIDTH - 1:ID_WIDTH - 3];
    wire [2:0]master_WID_pri = m0_WID[ID_WIDTH - 1:ID_WIDTH - 3] | m1_WID[ID_WIDTH - 1:ID_WIDTH - 3] | m2_WID[ID_WIDTH - 1:ID_WIDTH - 3];
    wire [2:0]slave_AWID_pri = m0_AWID[2:0]  | m1_AWID[2:0]| m2_AWID[2:0] ;
    wire [2:0]slave_ARID_pri = m0_ARID[2:0]  | m1_ARID[2:0] | m2_ARID[2:0] ;
    wire [2:0]slave_WID_pri = m0_WID[2:0]  | m1_WID[2:0]  | m2_WID[2:0]  ;
    
    wire [2:0]master_RID_pri  = s0_RID[ID_WIDTH - 1:ID_WIDTH - 3] | s1_RID[ID_WIDTH - 1:ID_WIDTH - 3] | s2_RID[ID_WIDTH - 1:ID_WIDTH - 3];
    wire [2:0]master_BID_pri  = s0_BID[ID_WIDTH - 1:ID_WIDTH - 3] | s1_BID[ID_WIDTH - 1:ID_WIDTH - 3]| s2_BID[ID_WIDTH - 1:ID_WIDTH - 3];
    wire [2:0]slave_RID_pri  = s0_RID[2:0] | s1_RID[2:0] | s2_RID[2:0];
    wire [2:0]slave_BID_pri  = s0_BID[2:0] | s1_BID[2:0] | s2_BID[2:0];
    
    wire write_addr_m0 = (master_AWID_pri == master_0)?1'b1:1'b0;
    wire write_addr_m1 = (master_AWID_pri == master_1)?1'b1:1'b0;
    wire write_addr_m2 = (master_AWID_pri == master_2)?1'b1:1'b0;
    
    wire read_addr_m0 = (master_ARID_pri == master_0)?1'b1:1'b0;
    wire read_addr_m1 = (master_ARID_pri == master_1)?1'b1:1'b0;
    wire read_addr_m2 = (master_ARID_pri == master_2)?1'b1:1'b0;
    
    wire write_data_m0 = (master_WID_pri == master_0)?1'b1:1'b0;
    wire write_data_m1 = (master_WID_pri == master_1)?1'b1:1'b0;
    wire write_data_m2 = (master_WID_pri == master_2)?1'b1:1'b0;
        
    wire read_data_resp_s0 = ( slave_RID_pri == slave_0)?1'b1:1'b0;
    wire read_data_resp_s1 = ( slave_RID_pri == slave_1)?1'b1:1'b0;
    wire read_data_resp_s2 = ( slave_RID_pri == slave_2)?1'b1:1'b0;
    
    wire write_data_resp_s0 = ( slave_BID_pri == slave_0)?1'b1:1'b0;
    wire write_data_resp_s1 = ( slave_BID_pri == slave_1)?1'b1:1'b0;
    wire write_data_resp_s2 = ( slave_BID_pri == slave_2)?1'b1:1'b0;
    
    wire [ID_WIDTH - 1 :0] master_AWID = {6{write_addr_m0}} & m0_AWID | {6{write_addr_m1}} & m1_AWID | {6{write_addr_m2}} & m2_AWID;
    wire [ID_WIDTH - 1 :0] master_ARID = {6{read_addr_m0}} & m0_ARID | {6{read_addr_m1}} & m1_ARID | {6{read_addr_m2}} & m2_ARID;
    wire [ID_WIDTH - 1 :0] master_WID  = {6{write_data_m0}} & m0_WID | {6{write_data_m1}} & m1_WID | {6{write_data_m2}} & m2_WID;
    
    wire [ID_WIDTH - 1 :0] slave_RID = {6{read_data_resp_s0}} & s0_RID | {6{read_data_resp_s1}} & s1_RID | {6{read_data_resp_s2}} & s2_RID;
    wire [ID_WIDTH - 1 :0] slave_BID = {6{write_data_resp_s0}} & s0_BID | {6{write_data_resp_s1}} & s1_BID | {6{write_data_resp_s2}} & s2_BID;
    
    wire write_addr_slave_mem   =  (slave_AWID_pri == slave_0)?1'b1:1'b0;
    wire write_addr_slave_timer =  (slave_AWID_pri == slave_1)?1'b1:1'b0;
    wire write_addr_slave_gpio  =  (slave_AWID_pri == slave_2)?1'b1:1'b0;
    
    wire read_addr_slave_mem    = (slave_ARID_pri == slave_0)?1'b1:1'b0;
    wire read_addr_slave_timer  = (slave_ARID_pri == slave_1)?1'b1:1'b0;
    wire read_addr_slave_gpio   = (slave_ARID_pri == slave_2)?1'b1:1'b0;
    
    wire write_data_slave_mem   = (slave_WID_pri == slave_0)?1'b1:1'b0;
    wire write_data_slave_timer = (slave_WID_pri == slave_1)?1'b1:1'b0;
    wire write_data_slave_gpio  = (slave_WID_pri == slave_2)?1'b1:1'b0;
    
    wire write_resp_master_m0   =  (master_BID_pri == master_0)?1'b1:1'b0;
    wire write_resp_master_m1   =  (master_BID_pri == master_1)?1'b1:1'b0;
    wire write_resp_master_m2   =  (master_BID_pri == master_2)?1'b1:1'b0;
    
    
    wire read_resp_master_m0   =  (master_RID_pri == master_0)?1'b1:1'b0;
    wire read_resp_master_m1   =  (master_RID_pri == master_1)?1'b1:1'b0;
    wire read_resp_master_m2   =  (master_RID_pri == master_2)?1'b1:1'b0;
    
    
//**************************************************************************************	
// ******************** write addr channel
//**************************************************************************************	
    wire [ADDR_WIDTH - 1 :0] master_AWADDR = {32{write_addr_m0}} & m0_AWADDR | {32{write_addr_m1}} & m1_AWADDR | {32{write_addr_m2}} & m2_AWADDR;
	wire	   [3:0]          master_AWLEN   = {4{write_addr_m0}} & m0_AWLEN   | {4{write_addr_m1}} & m1_AWLEN | {4{write_addr_m2}} & m2_AWLEN;
	wire	   [2:0]         master_AWSIZE  = {3{write_addr_m0}} & m0_AWSIZE   | {3{write_addr_m1}} & m1_AWSIZE | {3{write_addr_m2}} & m2_AWSIZE;
	wire	   [1:0]	     master_AWBURST = {2{write_addr_m0}} & m0_AWBURST  | {2{write_addr_m1}} & m1_AWBURST | {2{write_addr_m2}} & m2_AWBURST;
	wire	 	             master_AWVALID = {{write_addr_m0}} & m0_AWVALID | {{write_addr_m1}} & m1_AWVALID | {{write_addr_m2}} & m2_AWVALID;

    wire slabe_AWREADY  = write_addr_slave_mem & s0_AWREADY |  write_addr_slave_timer & s1_AWREADY |  write_addr_slave_gpio & s2_AWREADY;
	//m0 answer
    assign m0_AWREADY      = slabe_AWREADY & write_addr_m0;
	//m1 answer
    assign m1_AWREADY      = slabe_AWREADY & write_addr_m1;
	//m2 answer
    assign m2_AWREADY      = slabe_AWREADY & write_addr_m2;
    
	//s0 req
    assign  s0_AWADDR                = (write_addr_slave_mem)?master_AWADDR:32'd0;
    assign  s0_AWBURST               = (write_addr_slave_mem)?master_AWBURST:'d0;
    assign  s0_AWLEN                 = (write_addr_slave_mem)?master_AWLEN:'d0;
    assign  s0_AWVALID               = (write_addr_slave_mem)?master_AWVALID:'d0;
    assign  s0_AWSIZE                 = (write_addr_slave_mem)?master_AWLEN:'d0;
    assign  s0_AWID                   = (write_addr_slave_mem)?master_AWID:'d0;
    
	//s1 req
    assign  s1_AWADDR                = (write_addr_slave_timer)?master_AWADDR:32'd0;
    assign  s1_AWBURST               = (write_addr_slave_timer)?master_AWBURST:'d0;
    assign  s1_AWLEN                 = (write_addr_slave_timer)?master_AWLEN:'d0;
    assign  s1_AWVALID               = (write_addr_slave_timer)?master_AWVALID:'d0;
    assign  s1_AWSIZE                 = (write_addr_slave_timer)?master_AWLEN:'d0;
    assign  s1_AWID                   = (write_addr_slave_timer)?master_AWID:'d0;
    
	//s2 req
    assign  s2_AWADDR                = (write_addr_slave_gpio)?master_AWADDR:32'd0;
    assign  s2_AWBURST               = (write_addr_slave_gpio)?master_AWBURST:'d0;
    assign  s2_AWLEN                 = (write_addr_slave_gpio)?master_AWLEN:'d0;
    assign  s2_AWVALID               = (write_addr_slave_gpio)?master_AWVALID:'d0;
    assign  s2_AWSIZE                = (write_addr_slave_gpio)?master_AWLEN:'d0;
    assign  s2_AWID                  = (write_addr_slave_gpio)?master_AWID:'d0;
    
//**************************************************************************************	
// ******************** write data channel
//**************************************************************************************	
	wire	   [DATA_WIDTH-1:0] master_WDATA = {32{write_data_m0}} & m0_WDATA | {32{write_data_m1}} & m1_WDATA | {32{write_data_m2}} & m2_WDATA;
	wire	   [STRB_WIDTH-1:0] master_WSTRB = {4{write_data_m0}} & m0_WSTRB | {4{write_data_m1}} & m1_WSTRB   | {4{write_data_m2}} & m2_WSTRB;
	wire		                master_WLAST =  {{write_data_m0}} & m0_WLAST | {{write_data_m1}} & m1_WLAST   | {{write_data_m2}} & m2_WLAST;
	wire	  	                master_WVALID = {{write_data_m0}} & m0_WVALID | {{write_data_m1}} & m1_WVALID   | {{write_data_m2}} & m2_WVALID;

    wire slave_WREADY  = write_data_slave_mem & s0_WREADY |  write_data_slave_timer & s1_WREADY |  write_data_slave_gpio & s2_WREADY;
	//m0 answer looping?
    assign m0_WREADY      = slave_WREADY & write_data_m0;
	//m1 answer
    assign m1_WREADY      = slave_WREADY & write_data_m1;
	//m2 answer
    assign m2_WREADY      = slave_WREADY & write_data_m2;
    
	//s0 data
    assign  s0_WDATA               = (write_data_slave_mem)?master_WDATA:32'd0;
    assign  s0_WSTRB               = (write_data_slave_mem)?master_WSTRB:'d0;
    assign  s0_WLAST               = (write_data_slave_mem)?master_WLAST:'d0;
    assign  s0_WVALID               = (write_data_slave_mem)?master_WVALID :'d0;
    assign  s0_WID                  = (write_data_slave_mem)?master_WID:'d0;
    
	//s1 data
    assign  s1_WDATA               = (write_data_slave_timer)?master_WDATA:32'd0;
    assign  s1_WSTRB               = (write_data_slave_timer)?master_WSTRB:'d0;
    assign  s1_WLAST               = (write_data_slave_timer)?master_WLAST:'d0;
    assign  s1_WVALID               = (write_data_slave_timer)?master_WVALID :'d0;
    assign  s1_WID                  = (write_data_slave_timer)?master_WID:'d0;
    
	//s2 data
    assign  s2_WDATA               = (write_data_slave_gpio)?master_WDATA:32'd0;
    assign  s2_WSTRB               = (write_data_slave_gpio)?master_WSTRB:'d0;
    assign  s2_WLAST               = (write_data_slave_gpio)?master_WLAST:'d0;
    assign  s2_WVALID               = (write_data_slave_gpio)?master_WVALID :'d0;
    assign  s2_WID                  = (write_data_slave_gpio)?master_WID:'d0;
    
//**************************************************************************************	
// ******************** read addr channel
//**************************************************************************************	
    wire [ADDR_WIDTH - 1 :0] master_ARADDR = {32{read_addr_m0}} & m0_ARADDR | {32{read_addr_m1}} & m1_ARADDR | {32{read_addr_m2}} & m2_ARADDR;
	wire	   [3:0]         master_ARLEN   = {4{read_addr_m0}} & m0_ARLEN   | {4{read_addr_m1}} & m1_ARLEN | {4{read_addr_m2}} & m2_ARLEN;
	wire	   [2:0]         master_ARSIZE  = {3{read_addr_m0}} & m0_ARSIZE   | {3{read_addr_m1}} & m1_ARSIZE | {3{read_addr_m2}} & m2_ARSIZE;
	wire	   [1:0]	     master_ARBURST = {2{read_addr_m0}} & m0_ARBURST  | {2{read_addr_m1}} & m1_ARBURST | {2{read_addr_m2}} & m2_ARBURST;
	wire	 	             master_ARVALID = {{read_addr_m0}} & m0_ARVALID | {{read_addr_m1}} & m1_ARVALID | {{read_addr_m2}} & m2_ARVALID;

    wire slave_ARREADY   =   read_addr_slave_mem & s0_ARREADY |  read_addr_slave_timer & s1_ARREADY |  read_addr_slave_gpio & s2_ARREADY;
    
	//m0 answer
    assign m0_ARREADY      = slave_ARREADY & read_addr_m0;
	//m1 answer
    assign m1_ARREADY      = slave_ARREADY & read_addr_m1;
	//m2 answer
    assign m2_ARREADY      = slave_ARREADY & read_addr_m2;
    
	//s0 req
    assign  s0_ARADDR                = (read_addr_slave_mem)?master_ARADDR:32'd0;
    assign  s0_ARBURST               = (read_addr_slave_mem)?master_ARBURST:'d0;
    assign  s0_ARLEN                 = (read_addr_slave_mem)?master_ARLEN:'d0;
    assign  s0_ARVALID               = (read_addr_slave_mem)?master_ARVALID:'d0;
    assign  s0_ARSIZE                = (read_addr_slave_mem)?master_ARLEN:'d0;
    assign  s0_ARID                  = (read_addr_slave_mem)?master_ARID:'d0;
    
	//s1 req
    assign  s1_ARADDR                = (read_addr_slave_timer)?master_ARADDR:32'd0;
    assign  s1_ARBURST               = (read_addr_slave_timer)?master_ARBURST:'d0;
    assign  s1_ARLEN                 = (read_addr_slave_timer)?master_ARLEN:'d0;
    assign  s1_ARVALID               = (read_addr_slave_timer)?master_ARVALID:'d0;
    assign  s1_ARSIZE                = (read_addr_slave_timer)?master_ARLEN:'d0;
    assign  s1_ARID                  = (read_addr_slave_timer)?master_ARID:'d0;
    
	//s2 req
    assign  s2_ARADDR                = (read_addr_slave_gpio)?master_ARADDR:32'd0;
    assign  s2_ARBURST               = (read_addr_slave_gpio)?master_ARBURST:'d0;
    assign  s2_ARLEN                 = (read_addr_slave_gpio)?master_ARLEN:'d0;
    assign  s2_ARVALID               = (read_addr_slave_gpio)?master_ARVALID:'d0;
    assign  s2_ARSIZE                = (read_addr_slave_gpio)?master_ARLEN:'d0;
    assign  s2_ARID                  = (read_addr_slave_gpio)?master_ARID:'d0;
	
	
//**************************************************************************************	
// ******************** read resp channel
//**************************************************************************************	
	
    wire [ADDR_WIDTH - 1 :0]slave_RDATA = {32{read_data_resp_s0}} & s0_RDATA | {32{read_data_resp_s1}} & s1_RDATA | {32{read_data_resp_s2}} & s2_RDATA;
	wire	 [1:0]           slave_RRESP = {2{read_data_resp_s0}} & s0_RRESP | {2{read_data_resp_s1}} & s1_RRESP | {2{read_data_resp_s2}} & s2_RRESP;
	wire	     	       slave_RLAST = {{read_data_resp_s0}} & s0_RLAST  | {{read_data_resp_s1}} & s1_RLAST | {{read_data_resp_s2}} & s2_RLAST;
	wire	            slave_RVALID   = {{read_data_resp_s0}} & s0_RVALID   | {{read_data_resp_s1}} & s1_RVALID | {{read_data_resp_s2}} & s2_RVALID;

    wire master_RREADY   =   read_resp_master_m0 & m0_RREADY |  read_resp_master_m1 & m1_RREADY |  read_resp_master_m2 & m2_RREADY;
   
	//s0 answer
    assign s0_RREADY      = master_RREADY & read_data_resp_s0;
	//s1 answer
    assign s1_RREADY      = master_RREADY & read_data_resp_s1;
	//s2 answer
    assign s2_RREADY      = master_RREADY & read_data_resp_s2;
    
	//m0 resp
    assign  m0_RDATA                 = (read_resp_master_m0)?slave_RDATA:32'd0;
    assign  m0_RRESP                 = (read_resp_master_m0)?slave_RRESP:'d0;
    assign  m0_RLAST                 = (read_resp_master_m0)?slave_RLAST:'d0;
    assign  m0_RID                   = (read_resp_master_m0)?slave_RID:'d0;
    assign  m0_RVALID                = (read_resp_master_m0)?slave_RVALID:'d0;
    
	//m1 resp
    assign  m1_RDATA                 = (read_resp_master_m1)?slave_RDATA:32'd0;
    assign  m1_RRESP                 = (read_resp_master_m1)?slave_RRESP:'d0;
    assign  m1_RLAST                 = (read_resp_master_m1)?slave_RLAST:'d0;
    assign  m1_RID                   = (read_resp_master_m1)?slave_RID:'d0;
    assign  m1_RVALID                = (read_resp_master_m1)?slave_RVALID:'d0;
    
	//m2 resp
    assign  m2_RDATA                 = (read_resp_master_m2)?slave_RDATA:32'd0;
    assign  m2_RRESP                 = (read_resp_master_m2)?slave_RRESP:'d0;
    assign  m2_RLAST                 = (read_resp_master_m2)?slave_RLAST:'d0;
    assign  m2_RID                   = (read_resp_master_m2)?slave_RID:'d0;
    assign  m2_RVALID                = (read_resp_master_m2)?slave_RVALID:'d0;
    
    
	
//**************************************************************************************	
// ******************** write resp channel
//**************************************************************************************	
  

	wire	 [1:0]   slave_BRESP  = {2{write_data_resp_s0}} & s0_BRESP   | {2{write_data_resp_s1}} & s1_BRESP | {2{write_data_resp_s2}} & s2_BRESP;
	wire	         slave_BVALID = {{write_data_resp_s0}} & s0_RVALID   | {{write_data_resp_s1}} & s1_RVALID | {{write_data_resp_s2}} & s2_RVALID;
	
	
    wire master_BREADY = write_resp_master_m0 & m0_BREADY |  write_resp_master_m1 & m1_BREADY |  write_resp_master_m2 & m2_BREADY;

	//s0 answer
    assign s0_BREADY      = master_BREADY & write_data_resp_s0;
	//s1 answer
    assign s1_BREADY      = master_BREADY & write_data_resp_s1;
	//s2 answer
    assign s2_BREADY      = master_BREADY & write_data_resp_s2;
    
	//m0 resp
    assign  m0_BRESP                 = (write_resp_master_m0)?slave_BRESP:'d0;
    assign  m0_BID                   = (write_resp_master_m0)?slave_BID:'d0;
    assign  m0_BVALID                = (write_resp_master_m0)?slave_BVALID:'d0;
    
	//m1 resP
    assign  m1_BRESP                 = (write_resp_master_m1)?slave_BRESP:'d0;
    assign  m1_BID                   = (write_resp_master_m1)?slave_BID:'d0;
    assign  m1_BVALID                = (write_resp_master_m1)?slave_BVALID:'d0;
    
	//m2 resp
    assign  m2_BRESP                 = (write_resp_master_m2)?slave_BRESP:'d0;
    assign  m2_BID                   = (write_resp_master_m2)?slave_BID:'d0;
    assign  m2_BVALID                = (write_resp_master_m2)?slave_BVALID:'d0;
    
    
endmodule