`timescale 1ns / 1ns

`include "include.v"

`define TEST_PROG  1

module riscv_core_sim();

    reg clk;
    reg rst_n;
    reg TCK;
    reg TMS;
    reg TDI;
    reg uart_tx;  
    reg [7:0] mem_a [3:0];    
    initial begin
        $readmemh("F:/vivadoworkspace/Arty/tx.txt",mem_a);
    end
    
    wire TDO;
    always #5 clk = ~clk;     // 50MHz

    wire [`DATA_WIDTH - 1: 0] x3;
    wire [`DATA_WIDTH - 1: 0] x26;
    wire [`DATA_WIDTH - 1: 0] x27;
    
    assign x3 = soc_top_inst.riscv_core_inst.regfile_inst.rf[3];
    assign x26 = soc_top_inst.riscv_core_inst.regfile_inst.rf[26];
    assign x27 = soc_top_inst.riscv_core_inst.regfile_inst.rf[27];
    
    integer r;

    initial begin
        clk = 0;
        TCK = 1;
        TMS = 1;
        TDI = 1;
        uart_tx = 1;
        rst_n = `RstEnable;
        r = 0;
        $display("test running...");
        #100
        rst_n = `RstDisable;
//        #10000
//        rst_n = `RstEnable;
//        #10000
//        rst_n = `RstDisable;

`ifdef TEST_PROG
        wait(x26 == 32'b1)   // wait sim end, when x26 == 1
        #100
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
                $display("x%2d = 0x%x", r, soc_top_inst.riscv_core_inst.regfile_inst.rf[r]);
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
                $display("x%2d = 0x%x", r, soc_top_inst.riscv_core_inst.regfile_inst.rf[r]);
        end
`endif
        $finish;
    end
    
        // sim timeout
    initial begin
        #5000000
        $display("Time Out.");
        $finish;
    end

    // read mem data
    initial begin
        #20
        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\inst.data", soc_top_inst.srambus_inst.sirv_sim_ram_inst.mem_r);
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\tinyriscv\\sim\\inst.data", soc_top_inst.srambus_inst.sirv_sim_ram_inst.mem_r);
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\inst.data", soc_top_inst.sirv_duelport_ram_inst.mem_r);
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\instdata3.txt", soc_top_inst.srambus_inst.sirv_sim_ram_inst.mem_r);
    end

    // generate wave file, used by gtkwave
    initial begin
        $dumpfile("riscv_core_sim.vcd");
        $dumpvars(0, riscv_core_sim);
    end
    
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
    soc_top soc_top_inst(
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


    initial begin
        #100000
        tx_byte();
        #250000
        tx_byte();
    end
endmodule