
//write first
`include "include.v"
module sram_bus_duelport_ram 
#(parameter DP = 2048,
  parameter FORCE_X2ZERO = 0,
  parameter DW = 32,
  parameter MW = 4,
  parameter AW = 32 
)
(
  input             clk, 
  input  			rst_n,
  input             cs, 
  input             req_a,
  input             req_b,
  input  [DW-1  :0] din_a, 
  input  [DW-1  :0] din_b, 
  input  [AW-1  :0] addr_a,
  input  [AW-1  :0] addr_b,
  input             we_a,
  input             we_b,
  input  [MW-1:0]   wem_a,
  input  [MW-1:0]   wem_b,
  output [DW-1:0]   dout_a,
  output [DW-1:0]   dout_b,
  output mem_addr_ok_a,
  output mem_data_ok_a,
  output mem_addr_ok_b,
  output mem_data_ok_b
  
);

    reg [DW-1:0] mem_r [0:DP-1];
    reg [AW-1:0]addr_a_r;
    reg [AW-1:0]addr_b_r;
    wire [MW-1:0] wen_a;
    wire [MW-1:0] wen_b;
    wire ren_a;
    wire ren_b;
	wire read_a_disable;
	assign read_a_disable = (addr_a == addr_b)?we_b:1'b0;
	
    reg read_data_ok_a;
    wire write_data_ok_a;
    reg read_data_ok_b;
    reg write_data_ok_b;
    assign mem_addr_ok_a = (!read_a_disable);
    assign mem_addr_ok_b = 1'b1 ;
	
	assign ren_a = rst_n & req_a & (!read_a_disable);
	assign ren_b = 1'b0;
	
    assign mem_data_ok_a = write_data_ok_a | read_data_ok_a;
    assign mem_data_ok_b = write_data_ok_b | read_data_ok_b;
    
    assign wen_a = 1'b0;
    assign wen_b = ({MW{rst_n & req_b & we_b}} & wem_b);
    
    always @(posedge clk)
    begin
        if(!rst_n)begin
            addr_a_r <= 0;   
            read_data_ok_a <= 1'b0;
        end
        else if (ren_a)begin
            addr_a_r <= addr_a;
            read_data_ok_a <= 1'b1;
        end
		else begin
            read_data_ok_a <= 1'b0;
        end
    end
	
    always @(posedge clk)
    begin
        if(!rst_n)begin
            addr_b_r <= 0;   
            read_data_ok_b <= 1'b0;
        end
        else if (ren_b)begin
            addr_b_r <= addr_b;
            read_data_ok_b <= 1'b1;
        end
		else begin
            read_data_ok_b <= 1'b0;
        end
    end
    
	assign write_data_ok_a = 1'b0;
	always @(posedge clk)
    begin
        if(~rst_n)begin
            write_data_ok_b <= 1'b0;
        end
        else if (wen_b)begin
            write_data_ok_b <= 1'b1;
        end
        else begin
            write_data_ok_b <= 1'b0;
        end
    end
	
    genvar i;
		
    generate
      for (i = 0; i < MW; i = i+1) begin :mem
        if((8*i+8) > DW ) begin: last
          always @(posedge clk) begin
            if (wen_a[i]) begin
               mem_r[addr_a][DW-1:8*i] <= din_a[DW-1:8*i];
            end
            else if (wen_b[i]) begin
               mem_r[addr_b][DW-1:8*i] <= din_b[DW-1:8*i];
            end
          end
        end
        else begin: non_last
          always @(posedge clk) begin
            if (wen_a[i]) begin
               mem_r[addr_a][8*i+7:8*i] <= din_a[8*i+7:8*i];
            end
            else if (wen_b[i]) begin
               mem_r[addr_b][8*i+7:8*i] <= din_b[8*i+7:8*i];
            end
          end
        end
      end
    endgenerate
    
  wire [DW-1:0] dout_pre_a;
  wire [DW-1:0] dout_pre_b;
  assign dout_pre_a = mem_r[addr_a_r];
  assign dout_pre_b = mem_r[addr_b_r];
  
  generate
   if(FORCE_X2ZERO == 1) begin: force_x_to_zero
      for (i = 0; i < DW; i = i+1) begin:force_x_gen 
          `ifndef SYNTHESIS//{
         assign dout_a[i] = (dout_pre_a[i] === 1'bx) ? 1'b0 : dout_pre_a[i];
         assign dout_b[i] = (dout_pre_b[i] === 1'bx) ? 1'b0 : dout_pre_b[i];
          `else//}{
         assign dout_a[i] = dout_pre_a[i];
         assign dout_b[i] = dout_pre_b[i];
          `endif//}
      end
   end
   else begin:no_force_x_to_zero
     assign dout_a = dout_pre_a;
     assign dout_b = dout_pre_b;
   end
  endgenerate

endmodule