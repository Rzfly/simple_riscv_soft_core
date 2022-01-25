
//write first
module sirv_duelport_ram 
#(parameter DP = 2048,
  parameter FORCE_X2ZERO = 0,
  parameter DW = 32,
  parameter MW = 4,
  parameter AW = 32 
)
(
  input             clk, 
  input  rst_n,
  input             cs,
  input  [DW-1  :0] din_a, 
  input  [DW-1  :0] din_b, 
  input  [AW-1  :0] addr_a,
  input  [AW-1  :0] addr_b,
  input             we_a,
  input             we_b,
  input  [MW-1:0]   wem_a,
  input  [MW-1:0]   wem_b,
  output [DW-1:0]   dout_a,
  output [DW-1:0]   dout_b
);

    reg [DW-1:0] mem_r [0:DP-1];
//    reg [AW-1:0] waddr_r;
    reg [AW-1:0] addr_a_r;
    reg [AW-1:0] addr_b_r;
    wire [MW-1:0] wen_a;
    wire [MW-1:0] wen_b;
    wire ren_a;
    wire ren_b;

//    assign ren = cs & (~we);
	assign ren_a = cs;
	assign ren_b = cs;
    assign wen_a = ({MW{cs & we_a}} & wem_a);
    assign wen_b = ({MW{cs & we_b}} & wem_b) & (~wen_a);
    
    integer j;
    initial begin
        for( j = 0; j < DP; j = j + 1)begin
            mem_r[j] <= 0;  
       end
    end

    genvar i;

    always @(posedge clk)
    begin
        if(~rst_n)begin
            addr_a_r <= 0;   
        end
        else if (ren_a)begin
            addr_a_r <= addr_a;
        end
    end

    always @(posedge clk)
    begin
        if(~rst_n)begin
            addr_b_r <= 0;        
        end
        else if (ren_b)begin
            addr_b_r <= addr_b;
        end
    end
    
	//write logic
//    generate
//      for (i = 0; i < MW; i = i+1) begin :mem
//        if((8*i+8) > DW ) begin: last
//          always @(posedge clk) begin
//            if(~rst_n)begin
//               mem_r[addr_a][DW-1:8*i] <= 0;
//               mem_r[addr_b][DW-1:8*i] <= 0;
//            end
//            else if (wen_a[i]) begin
//               mem_r[addr_a][DW-1:8*i] <= din_a[DW-1:8*i];
//            end
//            else if (wen_b[i]) begin
//               mem_r[addr_b][DW-1:8*i] <= din_b[DW-1:8*i];
//            end
//          end
//        end
//        else begin: non_last
//          always @(posedge clk) begin
//            if(~rst_n)begin
//               mem_r[addr_a][8*i+7:8*i] <= 0;
//               mem_r[addr_b][8*i+7:8*i] <= 0;
//            end
//            else if (wen_a[i]) begin
//               mem_r[addr_a][8*i+7:8*i] <= din_a[8*i+7:8*i];
//            end
//            else if (wen_b[i]) begin
//               mem_r[addr_b][8*i+7:8*i] <= din_b[8*i+7:8*i];
//            end
//          end
//        end
//      end
//    endgenerate
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