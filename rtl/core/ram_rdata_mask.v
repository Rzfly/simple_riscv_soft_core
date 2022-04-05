
`include "include.v"

module ram_rdata_mask(
	input [1:0]mem_raddr_index,
	input [`DATA_WIDTH - 1:0]mem_read_data,
	input [`FUNC3_WIDTH - 1:0]mask_type,
	output reg [`DATA_WIDTH - 1:0]mem_read_data_mask
);

    always@(*)begin
        case (mask_type)
            //LB
            3'b000:begin
                case(mem_raddr_index)
                    2'b00: begin
                        mem_read_data_mask = {{24{mem_read_data[7]}}, mem_read_data[7:0]};
                    end
                    2'b01: begin
                        mem_read_data_mask = {{24{mem_read_data[15]}}, mem_read_data[15:8]};
                    end
                    2'b10: begin
                        mem_read_data_mask = {{24{mem_read_data[23]}}, mem_read_data[23:16]};
                    end
                    default: begin
                        mem_read_data_mask = {{24{mem_read_data[31]}}, mem_read_data[31:24]};
                    end
                endcase               
            end
            //LH
            3'b001:begin
                case(mem_raddr_index)
                    2'b00: begin
                        mem_read_data_mask = {{16{mem_read_data[15]}}, mem_read_data[15:0]};
                    end
                    default: begin
                        mem_read_data_mask = {{16{mem_read_data[31]}}, mem_read_data[31:16]}; 
                    end
                endcase     
            end
            //LW
            3'b010:begin
				case(mem_raddr_index)
                    default: begin
						mem_read_data_mask = mem_read_data; 
                    end
                endcase
            end
            //LBU
            3'b100:begin
                case(mem_raddr_index)
                    2'b00: begin
                        mem_read_data_mask = {24'b0, mem_read_data[7:0]};
                    end
                    2'b01: begin
                        mem_read_data_mask = {24'b0, mem_read_data[15:8]};
                    end
                    2'b10: begin
                        mem_read_data_mask = {24'b0, mem_read_data[23:16]};
                    end
                    default: begin
                        mem_read_data_mask = {24'b0, mem_read_data[31:24]};
                    end
                endcase
            end
            //LHU
            3'b101:begin
                case(mem_raddr_index)
                    2'b00: begin
                        mem_read_data_mask = {16'b0, mem_read_data[15:0]};
                    end
                    default: begin
                        mem_read_data_mask = {16'b0, mem_read_data[31:16]}; 
                    end
                endcase    
            end
            default:begin
                mem_read_data_mask = mem_read_data;
            end
        endcase
    end
    
endmodule