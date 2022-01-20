`timescale 1ns / 1ns

`include "include.v"

`define TEST_PROG  1

module riscv_core_sim();

    reg clk;
    reg rst_n;
    
    always #10 clk = ~clk;     // 50MHz

    wire [`RegBus - 1: 0] x3;
    wire [`RegBus - 1: 0] x26;
    wire [`RegBus - 1: 0] x27;
    
    assign x3 = soc_top_inst.riscv_core_inst.regfile_inst.rf[3];
    assign x26 = soc_top_inst.riscv_core_inst.regfile_inst.rf[26];
    assign x27 = soc_top_inst.riscv_core_inst.regfile_inst.rf[27];
    
    integer r;

    initial begin
        clk = 0;
        rst_n = `RstEnable;
        r = 0;
        $display("test running...");
        #40
        rst_n = `RstDisable;
        #200

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
        #500000
        $display("Time Out.");
        $finish;
    end

    // read mem data
    initial begin
        #20
//        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\inst.data", soc_top_inst.rom_inst._rom);
        $readmemh ("C:\\Users\\newrz\\Desktop\\riscv\\simple_riscv_soft_core\\sim\\instdata3.txt", soc_top_inst.rom_inst._rom);
    end

    // generate wave file, used by gtkwave
    initial begin
        $dumpfile("riscv_core_sim.vcd");
        $dumpvars(0, riscv_core_sim);
    end
    
    
    soc_top soc_top_inst(
        .clk(clk),
        .rst_n(rst_n)
    );
    
endmodule