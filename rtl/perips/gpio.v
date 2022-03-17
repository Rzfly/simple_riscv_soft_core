 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */


// GPIO模块
module gpio(

    input wire clk,
	input wire rst_n,

    input req_i,
    input wire we_i,
    input wire[31:0] addr_i,
    input wire[31:0] data_i,

    output reg[31:0] data_o,
    output addr_ok,
    output data_ok,
    input [`RAM_MASK_WIDTH - 1: 0]wem,

    input wire[1:0] io_pin_i,
    output wire[31:0] reg_ctrl,
    output wire[31:0] reg_data

    );


    // GPIO控制寄存�?
    localparam GPIO_CTRL = 4'h0;
    // GPIO数据寄存�?
    localparam GPIO_DATA = 4'h4;
    reg read_data_ok;
    reg write_data_ok;
    wire ren;
    wire wen;
    assign wen  = addr_ok && we_i && req_i;
    assign ren  = addr_ok && !we_i &&  req_i;
    assign addr_ok = rst_n;
    assign data_ok = read_data_ok | write_data_ok;
    // �?2位控�?1个IO的模式，�?多支�?16个IO
    // 0: 高阻�?1：输出，2：输�?
    reg[31:0] gpio_ctrl;
    // 输入输出数据
    reg[31:0] gpio_data;


    assign reg_ctrl = gpio_ctrl;
    assign reg_data = gpio_data;


    // 写寄存器
	always@(posedge clk)begin
        if (!rst_n) begin
            gpio_data <= 32'h0;
            gpio_ctrl <= 32'h0;
            write_data_ok <= 1'b0;
        end else if(req_i == 1'b1) begin
            if (wen) begin
                write_data_ok <= 1'b1;
                case (addr_i[3:0])
                    GPIO_CTRL: begin
                        gpio_ctrl <= data_i;
                    end
                    GPIO_DATA: begin
                        gpio_data <= data_i;
                    end
                endcase
            end else begin
                write_data_ok <= 1'b0;
                if (gpio_ctrl[1:0] == 2'b10) begin
                    gpio_data[0] <= io_pin_i[0];
                end
                if (gpio_ctrl[3:2] == 2'b10) begin
                    gpio_data[1] <= io_pin_i[1];
                end
            end
        end
        else begin
            write_data_ok <= 1'b0;
        end
    end

    // 读寄存器
	always@(posedge clk)begin
        if (!rst_n) begin
            data_o <= 32'h0;
            read_data_ok <= 1'b0;
        end else if(ren) begin
            read_data_ok <= 1'b1;
            case (addr_i[3:0])
                GPIO_CTRL: begin
                    data_o <= gpio_ctrl;
                end
                GPIO_DATA: begin
                    data_o <= gpio_data;
                end
                default: begin
                    data_o <= 32'h0;
                end
            endcase
        end
        else begin
            data_o <= 32'h0;
            read_data_ok <= 1'b0;
        end
    end

endmodule
