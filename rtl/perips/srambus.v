
`include "include.v"

module srambus(
    input clk,
    input rst_n,
    input req_i,
    input we,
    input [1:0]size,// 0 = 1 bytes, 1 = 2 bytes, 2 = 4 bytes. always set to 2
    input [`BUS_WIDTH - 1:0]addr,
    input [`DATA_WIDTH - 1:0]datai,
    output [`DATA_WIDTH - 1:0]datao,
    input [`RAM_MASK_WIDTH - 1:0]wem,
    output mem_addr_ok,
    output mem_data_ok
);
    
`ifdef DRAM
 sirv_sim_ram #(
    .FORCE_X2ZERO(0),
    .DP(`MEMORY_DEPTH),
    .DW(`DATA_WIDTH),
    .MW(`RAM_MASK_WIDTH),
    .AW(`DATA_WIDTH) 
  )sirv_sim_ram_inst(
    .clk (clk ),
    .rst_n (rst_n ),
    .cs  (req_i),
    .we  (we  ),
    .addr(addr),
    .din (datai ),
    .wem (wem),
    .dout(datao),
    .mem_addr_ok(mem_addr_ok),
    .mem_data_ok(mem_data_ok)
  );
`else

    wire [`RAM_MASK_WIDTH-1:0] wmask;
    wire ren;
    wire wen;

    reg read_data_ok;
    reg write_data_ok;
    assign mem_addr_ok = 1'b1;
    assign mem_data_ok = write_data_ok | read_data_ok;
    
    assign ren = req_i & (~we);
    assign wen = req_i & (we);
    assign wmask = {`RAM_MASK_WIDTH{wen}} & wem;
    
    always @(posedge clk)
    begin
        if(!rst_n)begin
            read_data_ok <= 1'b0;
        end
        else if (ren)begin
            read_data_ok <= 1'b1;
        end
        else begin
            read_data_ok <= 1'b0;
        end
    end
    
    always @(posedge clk)
    begin
        if(!rst_n)begin
            write_data_ok <= 1'b0;
        end
        else if (wen)begin
            write_data_ok <= 1'b1;
        end
        else begin
            write_data_ok <= 1'b0;
        end
    end
    
    blk_mem_gen_0 blk_mem_gen_0_inst(
        .clka(clk),
        .addra(addr),
        .dina(datai),
        .douta(datao),
        .wea(wmask)
    );
`endif

    
endmodule