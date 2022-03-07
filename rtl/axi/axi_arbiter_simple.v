

module axi_arbiter_simple#(
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
    wire [2:0]master_AWID_pri = m1_AWID[ID_WIDTH - 1:ID_WIDTH - 3] ;
    wire [2:0]master_ARID_pri = m0_ARID[ID_WIDTH - 1:ID_WIDTH - 3] | m1_ARID[ID_WIDTH - 1:ID_WIDTH - 3];
    wire [2:0]master_WID_pri = m1_WID[ID_WIDTH - 1:ID_WIDTH - 3];
    wire [2:0]slave_AWID_pri = m1_AWID[2:0];
    wire [2:0]slave_ARID_pri = m0_ARID[2:0]  | m1_ARID[2:0] ;
    wire [2:0]slave_WID_pri  = m1_WID[2:0]  ;
    
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
    
    wire [ID_WIDTH - 1 :0] master_AWID = {6{write_addr_m1}} & m1_AWID ;
    wire [ID_WIDTH - 1 :0] master_ARID = {6{read_addr_m0}} & m0_ARID | {6{read_addr_m1}} & m1_ARID;
    wire [ID_WIDTH - 1 :0] master_WID  = {6{write_data_m1}} & m1_WID ;
    
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
    wire [ADDR_WIDTH - 1 :0] master_AWADDR =  {32{write_addr_m1}} & m1_AWADDR;
	wire	   [3:0]          master_AWLEN = {4{write_addr_m1}} & m1_AWLEN ;
	wire	   [2:0]         master_AWSIZE  = {3{write_addr_m1}} & m1_AWSIZE ;
	wire	   [1:0]	     master_AWBURST =  {2{write_addr_m1}} & m1_AWBURST ;
	wire	 	             master_AWVALID ={{write_addr_m1}} & m1_AWVALID ;

    wire slabe_AWREADY  = write_addr_slave_mem & s0_AWREADY |  write_addr_slave_timer & s1_AWREADY |  write_addr_slave_gpio & s2_AWREADY;
    
	//m1 answer
    assign m1_AWREADY      = slabe_AWREADY & write_addr_m1;
    
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
	wire	   [DATA_WIDTH-1:0] master_WDATA = {32{write_data_m1}} & m1_WDATA ;
	wire	   [STRB_WIDTH-1:0] master_WSTRB = {4{write_data_m1}} & m1_WSTRB ;
	wire		                master_WLAST = {{write_data_m1}} & m1_WLAST;
	wire	  	                master_WVALID ={{write_data_m1}} & m1_WVALID;

    wire slave_WREADY  = write_data_slave_mem & s0_WREADY |  write_data_slave_timer & s1_WREADY |  write_data_slave_gpio & s2_WREADY;

	//m1 answer
    assign m1_WREADY      = slave_WREADY & write_data_m1;
    
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
    wire [ADDR_WIDTH - 1 :0] master_ARADDR = {32{read_addr_m0}} & m0_ARADDR | {32{read_addr_m1}} & m1_ARADDR;
	wire	   [3:0]         master_ARLEN   = {4{read_addr_m0}} & m0_ARLEN   | {4{read_addr_m1}} & m1_ARLEN;
	wire	   [2:0]         master_ARSIZE  = {3{read_addr_m0}} & m0_ARSIZE   | {3{read_addr_m1}} & m1_ARSIZE;
	wire	   [1:0]	     master_ARBURST = {2{read_addr_m0}} & m0_ARBURST  | {2{read_addr_m1}} & m1_ARBURST ;
	wire	 	             master_ARVALID = {{read_addr_m0}} & m0_ARVALID | {{read_addr_m1}} & m1_ARVALID;

    wire slave_ARREADY   =   read_addr_slave_mem & s0_ARREADY |  read_addr_slave_timer & s1_ARREADY |  read_addr_slave_gpio & s2_ARREADY;
    
	//m1 answer
    assign m0_ARREADY      = slave_ARREADY & read_addr_m0;
	//m1 answer
    assign m1_ARREADY      = slave_ARREADY & read_addr_m1;
    
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

    wire master_RREADY   =   read_resp_master_m0 & m0_RREADY |  read_resp_master_m1 & m1_RREADY ;
   
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
    
    
	
//**************************************************************************************	
// ******************** write resp channel
//**************************************************************************************	
  

	wire	 [1:0]   slave_BRESP  = {2{write_data_resp_s0}} & s0_BRESP   | {2{write_data_resp_s1}} & s1_BRESP | {2{write_data_resp_s2}} & s2_BRESP;
	wire	         slave_BVALID = {write_data_resp_s0} & s0_BVALID   | {write_data_resp_s1} & s1_BVALID | {write_data_resp_s2} & s2_BVALID;
	
	
    wire master_BREADY = write_resp_master_m1 & m1_BREADY;

	//s0 answer
    assign s0_BREADY      = master_BREADY & write_data_resp_s0;
	//s1 answer
    assign s1_BREADY      = master_BREADY & write_data_resp_s1;
	//s2 answer
    assign s2_BREADY      = master_BREADY & write_data_resp_s2;
    
    
	//m1 resP
    assign  m1_BRESP                 = (write_resp_master_m1)?slave_BRESP:'d0;
    assign  m1_BID                   = (write_resp_master_m1)?slave_BID:'d0;
    assign  m1_BVALID                = (write_resp_master_m1)?slave_BVALID:'d0;
    
    
endmodule

    
  // axi_arbiter_simple#(
    // .DATA_WIDTH(32),
    // .ADDR_WIDTH(32), 
    // .STRB_WIDTH(4), 
    // .ID_WIDTH(6)
    // )axi_arbiter_simple_inst(
        // .ACLK(clk),
        // .ARESETn(rst_n),
             
         // .m0_ARADDR(m0_ARADDR),
         // .m0_ARLEN(m0_ARLEN),
         // .m0_ARSIZE(m0_ARSIZE),
         // .m0_ARBURST(m0_ARBURST),
         // .m0_ARID(m0_ARID),
         // .m0_ARVALID(m0_ARVALID),
         // .m0_ARREADY(m0_ARREADY),
         
         // .m0_RDATA(m0_RDATA),
         // .m0_RRESP(m0_RRESP),
         // .m0_RLAST(m0_RLAST),
         // .m0_RID(m0_RID),
         // .m0_RVALID(m0_RVALID),
         // .m0_RREADY(m0_RREADY),

         // .m1_AWADDR(m1_AWADDR),
         // .m1_AWLEN(m1_AWLEN),
         // .m1_AWSIZE(m1_AWSIZE),
         // .m1_AWBURST(m1_AWBURST),
         // .m1_AWID(m1_AWID),
         // .m1_AWVALID(m1_AWVALID),
         // .m1_AWREADY(m1_AWREADY),
        
         // .m1_WDATA(m1_WDATA),
         // .m1_WSTRB(m1_WSTRB),
         // .m1_WLAST(m1_WLAST),
         // .m1_WID(m1_WID),
         // .m1_WVALID(m1_WVALID),
         // .m1_WREADY(m1_WREADY),
        
         // .m1_BRESP(m1_BRESP),
         // .m1_BID(m1_BID),
         // .m1_BVALID(m1_BVALID),
         // .m1_BREADY(m1_BREADY),
        
         // .m1_ARADDR(m1_ARADDR),
         // .m1_ARLEN(m1_ARLEN),
         // .m1_ARSIZE(m1_ARSIZE),
         // .m1_ARBURST(m1_ARBURST),
         // .m1_ARID(m1_ARID),
         // .m1_ARVALID(m1_ARVALID),
         // .m1_ARREADY(m1_ARREADY),
        
	     // .m1_RDATA(m1_RDATA),
	     // .m1_RRESP(m1_RRESP),
	     // .m1_RLAST(m1_RLAST),
	     // .m1_RID(m1_RID),
	     // .m1_RVALID(m1_RVALID),
	     // .m1_RREADY(m1_RREADY),

       	 // .s0_AWADDR(s0_AWADDR),
       	 // .s0_AWBURST(s0_AWBURST),
    	 // .s0_AWLEN(s0_AWLEN),
    	 // .s0_WSTRB(s0_WSTRB),
    	 // .s0_AWSIZE(s0_AWSIZE),
    	 // .s0_AWID(s0_AWID),
    	 // .s0_AWVALID(s0_AWVALID),
         // .s0_AWREADY(s0_AWREADY),
         // .s0_WDATA(s0_WDATA),
         // .s0_WLAST(s0_WLAST),
         // .s0_WID(s0_WID),
         // .s0_WVALID(s0_WVALID),
         // .s0_WREADY(s0_WREADY),
    
         // .s0_BRESP(s0_BRESP),
         // .s0_BID(s0_BID),
         // .s0_BVALID(s0_BVALID),
         // .s0_BREADY(s0_BREADY),
    
         // .s0_ARADDR(s0_ARADDR),
         // .s0_ARLEN(s0_ARLEN),
         // .s0_ARSIZE(s0_ARSIZE),
         // .s0_ARBURST(s0_ARBURST),
         // .s0_ARID(s0_ARID),
         // .s0_ARVALID(s0_ARVALID),
         // .s0_ARREADY(s0_ARREADY),
    
         // .s0_RDATA(s0_RDATA),
         // .s0_RLAST(s0_RLAST),
         // .s0_RRESP(s0_RRESP),
         // .s0_RID(s0_RID),
         // .s0_RVALID(s0_RVALID),
         // .s0_RREADY(s0_RREADY),
    
	    // //s1
	     // .s1_AWADDR(s1_AWADDR),
	     // .s1_AWBURST(s1_AWBURST),
	     // .s1_AWLEN(s1_AWLEN),
	     // .s1_WSTRB(s1_WSTRB),
	     // .s1_AWSIZE(s1_AWSIZE),
	     // .s1_AWID(s1_AWID),
	     // .s1_AWVALID(s1_AWVALID),
	     // .s1_AWREADY(s1_AWREADY),
    
         // .s1_WDATA(s1_WDATA),
         // .s1_WLAST(s1_WLAST),
         // .s1_WID(s1_WID),
         // .s1_WVALID(s1_WVALID),
         // .s1_WREADY(s1_WREADY),
    
         // .s1_BRESP(s1_BRESP),
         // .s1_BID(s1_BID),
         // .s1_BVALID(s1_BVALID),
         // .s1_BREADY(s1_BREADY),
    
         // .s1_ARADDR(s1_ARADDR),
         // .s1_ARLEN(s1_ARLEN),
         // .s1_ARSIZE(s1_ARSIZE),
         // .s1_ARBURST(s1_ARBURST),
         // .s1_ARID(s1_ARID),
         // .s1_ARVALID(s1_ARVALID),
         // .s1_ARREADY(s1_ARREADY),
    
         // .s1_RDATA(s1_RDATA),
         // .s1_RLAST(s1_RLAST),
         // .s1_RRESP(s1_RRESP),
         // .s1_RID(s1_RID),
         // .s1_RVALID(s1_RVALID),
         // .s1_RREADY(s1_RREADY),
     
        // //s2
         // .s2_AWADDR(s2_AWADDR),
         // .s2_AWBURST(s2_AWBURST),
         // .s2_AWLEN(s2_AWLEN),
         // .s2_WSTRB(s2_WSTRB),
         // .s2_AWSIZE(s2_AWSIZE),
         // .s2_AWID(s2_AWID),
         // .s2_AWVALID(s2_AWVALID),
         // .s2_AWREADY(s2_AWREADY),
        
        // .s2_WDATA(s2_WDATA),
        // .s2_WLAST(s2_WLAST),
        // .s2_WID(s2_WID),
        // .s2_WVALID(s2_WVALID),
        // .s2_WREADY(s2_WREADY),
    
        // .s2_BRESP(s2_BRESP),
        // .s2_BID(s2_BID),
        // .s2_BVALID(s2_BVALID),
        // .s2_BREADY(s2_BREADY),
    
        // .s2_ARADDR(s2_ARADDR),
        // .s2_ARLEN(s2_ARLEN),
        // .s2_ARSIZE(s2_ARSIZE),
        // .s2_ARBURST(s2_ARBURST),
        // .s2_ARID(s2_ARID),
        // .s2_ARVALID(s2_ARVALID),
        // .s2_ARREADY(s2_ARREADY),
    
        // .s2_RDATA(s2_RDATA),
        // .s2_RLAST(s2_RLAST),
        // .s2_RRESP(s2_RRESP),
        // .s2_RID(s2_RID),
        // .s2_RVALID(s2_RVALID),
        // .s2_RREADY(s2_RREADY)
// );