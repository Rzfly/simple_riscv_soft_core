`timescale 1ns / 1ns

`include "include.v"

`define TEST_PROG  1

module axi_riscv_core_sim();

    reg clk;
    reg rst_n;
    reg TCK;
    reg TMS;
    reg TDI;
    wire TDO;
    reg uart_tx;    
    reg [7:0] mem_a [3:0];    
    initial begin
        $readmemh("/home/rzfly/gitspace/riscv_core/tb/uart_tx.txt",mem_a);
    end
    always #10 clk = ~clk;     // 50MHz

    wire [`DATA_WIDTH - 1: 0] x3;
    wire [`DATA_WIDTH - 1: 0] x26;
    wire [`DATA_WIDTH - 1: 0] x27;
    
    assign x3 = axi_soc_top_inst.riscv_core_inst.regfile_inst.rf[3];
    assign x26 = axi_soc_top_inst.riscv_core_inst.regfile_inst.rf[26];
    assign x27 = axi_soc_top_inst.riscv_core_inst.regfile_inst.rf[27];
    
    integer r;  
    integer time_ms;
    wire [7:0]uart_data = axi_soc_top_inst.uart_inst.tx_data;
    wire jump_req = axi_soc_top_inst.riscv_core_inst.jump_req;
    wire [31:0]jump_addr = axi_soc_top_inst.riscv_core_inst.jump_addr;
    wire bp_taken = axi_soc_top_inst.riscv_core_inst.bp_taken_ex;
    wire branch_cal = axi_soc_top_inst.riscv_core_inst.branch_cal;
    wire branch_ex = axi_soc_top_inst.riscv_core_inst.branch_ex;
    wire branch_res = axi_soc_top_inst.riscv_core_inst.branch_res;
    
    wire [31:0]pc_if = axi_soc_top_inst.riscv_core_inst.pc_if;
    reg jump_req_d;
    reg branch_ex_d;
    reg branch_cal_d;
    reg branch_res_d;
    
    wire branch_ex_pedge = branch_ex & ~branch_ex_d;
    wire branch_cal_pedge = branch_cal & ~branch_cal_d;
    wire branch_res_pedge = branch_res & ~branch_res_d;
    wire jump_req_pedge = jump_req & ~jump_req_d;
 
    initial begin
        clk = 0;
        TCK = 1;
        TMS = 1;
        TDI = 1;
        uart_tx = 1;
        rst_n = `RstEnable;
        r = 0;
        #1000
        rst_n = `RstDisable;
        $display("test running...");
//        #10000
//        rst_n = `RstEnable;
//        #10000
//        rst_n = `RstDisable;

`ifdef TEST_PROG
        wait(x26 == 32'b1)   // wait sim end, when x26 == 1
        #500
        if (x27 == 32'b1) begin
            $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            for (r = 0; r < 32; r = r + 1)
                $display("x%2d = 0x%x", r, axi_soc_top_inst.riscv_core_inst.regfile_inst.rf[r]);
        end else begin
            $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("fail testnum = %2d", x3);
            for (r = 0; r < 32; r = r + 1)
                $display("x%2d = 0x%x", r, axi_soc_top_inst.riscv_core_inst.regfile_inst.rf[r]);
        end
        
        $finish;
`endif
    end
    
        // sim timeout
    initial begin
        #1000000
//        $finish;
        $display("Test time out.");
    end
    
    // sim timeout
    initial begin
        #2000000000
        $display("Time Out.");
        $finish;
    end
    
    
        
    // sim timeout
    initial begin
        time_ms = 0;
        forever
        begin
             #10000000
             time_ms = time_ms + 10;
             $display("simulated time is %dms. cost time is %t", time_ms, $time);
        end
    end
    
    always@(uart_data)begin
        $write("%c" , uart_data);
    end
    

    // read mem data
    initial begin    
//    #20  $readmemh ("/home/rzfly/gitspace/riscv_core/sim/instdata3.txt", axi_soc_top_inst.axi_duelport_bram_inst.sirv_duelport_ram_inst.mem_r);
    #20  $readmemh ("/home/rzfly/gitspace/riscv_core/sim/inst.data",  axi_soc_top_inst.axi_duelport_bram_inst.sirv_duelport_ram_inst.mem_r);
//    #20  $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\inst.data",  axi_soc_top_inst.axi_duelport_bram_inst.sirv_duelport_ram_inst.mem_r);
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\tinyriscv\\sim\\inst.data", soc_top_inst.srambus_inst.sirv_sim_ram_inst.mem_r);
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\inst.data", soc_top_inst.sirv_duelport_ram_inst.mem_r);
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\instdata3.txt", axi_soc_top_inst.AXI_DUELPORTSRAM_inst.sirv_duelport_ram_inst.mem_r);
    end

    // generate wave file, used by gtkwave
//    initial begin
//        $dumpfile("axi_riscv_core_sim.vcd");
//        $dumpvars(0, axi_riscv_core_sim);
//    end
    
    wire over;
    wire succ;
    wire halted_ind;
    wire uart_tx_pin;
    wire uart_rx_pin;
    wire [1:0]gpio;
    reg gpio_input;
    wire gpio_output;
    initial begin
        gpio_input = 0;
    end
    always #10000 gpio_input = ~gpio_input;
    assign gpio[1] = gpio_input;
    assign gpio_output = gpio[0];
//    wire jtag_TCK;
//    wire jtag_TMS;
//    wire jtag_TDI;
//    wire jtag_TDO;
    wire spi_miso;
    wire spi_mosi;
    wire spi_ss;
    wire spi_clk;
    assign spi_miso = 1'b0;
    assign uart_rx_pin = uart_tx;
    axi_soc_top axi_soc_top_inst(
        .sys_clk(clk),
        .rst_ext_i(rst_n),
        .uart_debug_pin(1'b0),
        .over(over),
        .succ(succ),
        .halted_ind(halted_ind),
        .uart_tx_pin(uart_tx_pin),
        .uart_rx_pin(uart_rx_pin),
        .gpio(gpio),
        .spi_miso(spi_miso),
        .spi_mosi(spi_mosi),
        .spi_ss(spi_ss),
        .spi_clk(spi_clk)
`ifdef TEST_JTAG
        ,
        .jtag_TCK(TCK),
        .jtag_TMS(TMS),
        .jtag_TDI(TDI),
        .jtag_TDO(TDO)
`endif
    );
    
        task tx_bit(
    input [7:0]data
);
    integer i;
    for (i = 0 ; i <10 ; i = i + 1) begin
        case (i)
            0: uart_tx <=  1'b0;
            1: uart_tx <=  data[0];
            2: uart_tx <=  data[1];
            3: uart_tx <=  data[2];
            4: uart_tx <=  data[3];
            5: uart_tx <=  data[4];
            6: uart_tx <=  data[5];
            7: uart_tx <=  data[6];
            8: uart_tx <=  data[7];
            9: uart_tx <=   1'b1;
            default:uart_tx <= 1'b1;
        endcase
        #8601;
    end
endtask

task tx_byte();
    integer i;
      for (i = 0 ; i <4 ; i = i + 1) begin
            tx_bit(mem_a[i]);
      end
endtask 

//    initial begin
//        #100000
//        tx_byte();
//        #250000
//        tx_byte();
//    end


    integer handle;
    integer count;
//    integer wrong_bp;
    integer jump_req_count;
    integer branch_count;
    integer branch_res_count;
    integer branch_cal_count;
    initial begin
         count = 0;
//         wrong_bp = 0;
         jump_req_count = 0;
         branch_count = 0;
         branch_res_count = 0;
         branch_cal_count = 0;
         handle = $fopen("/home/rzfly/gitspace/riscv_core/tb/jump_trace.txt");//打开文件
    end
       
    initial begin
        #15000000
        $display("jump: %d", count);
        $display("jump req count: %d", jump_req_count);
        $display("branch_count: %d", branch_count);
        $display("branch_cal_count: %d", branch_cal_count);
        $display("branch_res_count: %d", branch_res_count);
    end
    always@(posedge clk)begin
        jump_req_d <= jump_req;
        branch_ex_d <= branch_ex;
        branch_cal_d <= branch_cal;
        branch_res_d <= branch_res;
    end
    
    always@(posedge clk)begin
        if(branch_ex_pedge)
        branch_count <= branch_count + 1;
    end
    always@(posedge clk)begin
        if(branch_cal_pedge)
        branch_cal_count <= branch_cal_count + 1;
    end
    always@(posedge clk)begin
        if(branch_res_pedge)
        branch_res_count <= branch_res_count + 1;
    end
    
    always@(posedge clk)begin
        if(jump_req_pedge)begin
        count = count + 1;
//        $fdisplay(handle,"pc_if: 0x%x     jump_addr: 0x%x",pc_if,jump_addr);
        $fdisplay(handle,"%d pc_if: %d jump_addr: %d time: %t",count,pc_if,jump_addr,$time);
        end
    end    
    
endmodule