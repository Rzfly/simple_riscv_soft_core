
`include "include.v"

module ram_wdata_mask(
	input [1:0]mem_waddr_index,
	input [`DATA_WIDTH - 1:0]mem_write_data,
	input [`FUNC3_WIDTH - 1:0]mask_type,
	input ram_we,
    output reg memory_access_missalign,
	output reg [`DATA_WIDTH - 1:0]mem_write_data_mask,
	output reg [`RAM_MASK_WIDTH - 1:0]mem_wmask
);


    wire [7:0] ram_wdata_byte;
    assign ram_wdata_byte = mem_write_data[7:0];
    wire [15:0]ram_wdata_half_word;
    assign ram_wdata_half_word = mem_write_data[15:0];
    wire [31:0]ram_wdata_word;
    assign ram_wdata_word = mem_write_data[31:0];
    reg [3:0]ram_wbyte;
    reg [1:0]ram_whalfword;
    reg ram_wword;
	wire [`FUNC3_WIDTH - 1:0]ins_func3_ex;
	assign ins_func3_ex =  mask_type;
    always@(*)begin
        if( (ins_func3_ex ==  3'b000))begin
            case(mem_waddr_index)
                2'b00:begin
                    ram_wbyte <= {3'b000,ram_we};
                end
                2'b01:begin
                    ram_wbyte <= {2'b00,ram_we, 1'b0};
                end
                2'b10:begin
                    ram_wbyte <= {1'b0,ram_we, 2'b00};
                end
                2'b11:begin
                    ram_wbyte <= {ram_we, 3'b000};
                end
                default:begin
                    ram_wbyte <= 4'b0000;
                end
            endcase
        end
        else begin
            ram_wbyte <= 4'b0000;
        end
        if((ins_func3_ex ==  3'b001))begin
            case(mem_waddr_index)
                2'b00:begin
                    ram_whalfword <=  {1'b0,ram_we};
                    memory_access_missalign <= 1'b0;
                end
                2'b01:begin
                    ram_whalfword <=  {1'b0,ram_we};
                    memory_access_missalign <= ram_we;
                end
                2'b10:begin
                    ram_whalfword <=  {ram_we, 1'b0};
                    memory_access_missalign <= 1'b0;
                end
                2'b11:begin
                    ram_whalfword <=  {ram_we, 1'b0};
                    memory_access_missalign <= ram_we;
                end
                default:begin
                    ram_whalfword <= 2'b00;
                    memory_access_missalign <= 1'b0;
                end
            endcase
        end
        else begin
            ram_whalfword <= 2'b00;
            memory_access_missalign <= 1'b0;
        end
        if((ins_func3_ex ==  3'b010))begin
            case(mem_waddr_index)
                2'b00:begin
                    ram_wword <= {ram_we};
                    memory_access_missalign <= 1'b0;
                end
                2'b01:begin
                    ram_wword <= {ram_we};
                    memory_access_missalign <= ram_we;
                end
                2'b10:begin
                    ram_wword <= {ram_we};
                    memory_access_missalign <= ram_we;
                end
                2'b11:begin
                    ram_wword <= {ram_we};
                    memory_access_missalign <= ram_we;
                end
                default:begin
                    ram_wword <= {ram_we};
                    memory_access_missalign <= 1'b0;
                end
            endcase
        end
        else begin
            ram_wword <= 1'b0;
            memory_access_missalign <= 1'b0;
        end
    end
              
    always@(*)begin
            case(ins_func3_ex)
            //SB
             3'b000:begin
                    mem_wmask <= ram_wbyte;
                    mem_write_data_mask[31:24] = (ram_wbyte[3])?ram_wdata_byte:8'd0;
                    mem_write_data_mask[23:16] = (ram_wbyte[2])?ram_wdata_byte:8'd0;
                    mem_write_data_mask[15:8] = (ram_wbyte[1])?ram_wdata_byte:8'd0;
                    mem_write_data_mask[7:0] = (ram_wbyte[0])?ram_wdata_byte:8'd0;
             end
            //SH
             3'b001:begin
                    mem_wmask <= {{2{ram_whalfword[1]}},{2{ram_whalfword[0]}}};
                    mem_write_data_mask[31:16] = (ram_whalfword[1])?ram_wdata_half_word:16'd0;
                    mem_write_data_mask[15:0] = (ram_whalfword[0])?ram_wdata_half_word:16'd0;
             end
             3'b010:begin
                    mem_wmask <= {4{ram_wword}};
                    mem_write_data_mask <= ram_wdata_word;
             end
             default:begin
                   mem_wmask <= 4'b0000;
                   mem_write_data_mask <= 32'd0;
             end
         endcase
    end
    
endmodule