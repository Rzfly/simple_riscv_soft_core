//`include "include.v"

////module rom #(
////    parameter DEPTH = `MEMORY_DEPTH
////)(
////    input clk,
////    input we,
////    input rst_n,
////    input [`MEMORY_DEPTH - 1:0]addr,
////    input [`DATA_WIDTH - 1:0]datai,
////    output [`DATA_WIDTH - 1:0]datao
////);

////    instruction_rom instruction_rom_inst(
////        .a(addr),
////        .spo(datao)
////    );

////endmodule


//module rom (
//    input wire clk,
//    input wire rst_n,

//    input wire we_i,                   // write enable
//    //pc in
//    input wire[ 31 :0]addr_i,    // addr
//    input wire[`DATA_WIDTH - 1:0] data_i,

//    output reg[`DATA_WIDTH - 1:0] data_o         // read data

//    );



//    reg[`DATA_WIDTH - 1:0] _rom[0 : 4095 ];
//    integer j;
//    initial begin
//        for( j = 0; j < 4096; j = j + 1)begin
//            _rom[j] <= 0;  
//       end
//    end
//    always @ (posedge clk) begin
//        if (we_i == 1'b1) begin
//            _rom[addr_i[31:2]] <= data_i;
//        end
//    end

//    always @ (*) begin
//        if (rst_n == `RstEnable) begin
//            data_o <= 0;
//        end else begin
//            data_o <= _rom[addr_i[31:2]];
//        end
//    end
    
//endmodule
