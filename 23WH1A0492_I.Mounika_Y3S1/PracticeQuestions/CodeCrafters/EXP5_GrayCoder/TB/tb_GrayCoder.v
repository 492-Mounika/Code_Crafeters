`timescale 1ns/1ps

module tb_graycoder;

    reg clk;
    reg [3:0] bin_in;
    wire [3:0] gray_out;

    // Instantiate DUT
    graycoder dut (
        .clk(clk),
        .bin_in(bin_in),
        .gray_out(gray_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock period

    // VCD generation
    initial begin
        $dumpfile("graycoder.vcd");
        $dumpvars(0, tb_graycoder);
    end

    // Task to check output
    task check_gray(input [3:0] binary, input [3:0] expected);
        begin
            @(negedge clk);
            bin_in = binary;
            @(posedge clk);
            #1;
            if (gray_out !== expected)
                $display("[FAIL] Time: %0t | Input = %b | Expected = %b | Got = %b", $time, binary, expected, gray_out);
            else
                $display("[PASS] Time: %0t | Input = %b | Output = %b", $time, binary, gray_out);
        end
    endtask

    initial begin
        $display("----- Starting GrayCoder Testbench -----");

        // Generic Cases
        check_gray(4'b0000, 4'b0000);
        check_gray(4'b0001, 4'b0001);
        check_gray(4'b0010, 4'b0011);
        check_gray(4'b0011, 4'b0010);
        check_gray(4'b0100, 4'b0110);
        check_gray(4'b0101, 4'b0111);
        check_gray(4'b0110, 4'b0101);
        check_gray(4'b0111, 4'b0100);
        check_gray(4'b1000, 4'b1100);
        check_gray(4'b1001, 4'b1101);

        // Critical Cases
        check_gray(4'b1010, 4'b1111);
        check_gray(4'b1011, 4'b1110);
        check_gray(4'b1100, 4'b1010);
        check_gray(4'b1101, 4'b1011);
        check_gray(4'b1110, 4'b1001);
        check_gray(4'b1111, 4'b1000);
        check_gray(4'b1111, 4'b1000); // Repeat
        check_gray(4'b0000, 4'b0000);
        check_gray(4'b1111, 4'b1000);
        check_gray(4'b0101, 4'b0111);

        $display("----- Testbench Completed -----");
        $finish;
    end

endmodule