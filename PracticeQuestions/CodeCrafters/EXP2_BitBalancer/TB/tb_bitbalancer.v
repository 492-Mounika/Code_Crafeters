`timescale 1ns/1ps
module tb_bitbalancer;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] in;

    // Output
    wire [3:0] count;

    // Instantiate the DUT
    bitbalancer uut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .count(count)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Task to apply test vectors
    task apply_test(input [7:0] val, input [3:0] expected);
        begin
            in = val;
            @(posedge clk);
            #1;
            if (count !== expected)
                $display("Test failed for input %b: Expected = %0d, Got = %0d", val, expected, count);
            else
                $display("Test passed for input %b: Count = %0d", val, count);
        end
    endtask

    initial begin
        // VCD dump for waveform viewing
        $dumpfile("bitbalancer.vcd");
        $dumpvars(0, tb_bitbalancer);

        // Live monitor
        $monitor("Time=%0t | reset=%b | in=%b | count=%0d", $time, reset, in, count);

        // Initialization
        clk = 0;
        reset = 1;
        in = 8'd0;

        // Reset the DUT
        @(posedge clk);
        #1;
        reset = 0;

        // Apply test vectors (17 cases)
        apply_test(8'b0000_0000, 4'd0);  // All 0s
        apply_test(8'b1111_1111, 4'd8);  // All 1s
        apply_test(8'b0000_0001, 4'd1);  // LSB only
        apply_test(8'b1000_0000, 4'd1);  // MSB only
        apply_test(8'b1010_1010, 4'd4);  // Alternating 1s
        apply_test(8'b0101_0101, 4'd4);  // Reverse alternating
        apply_test(8'b0011_1100, 4'd4);  // Middle cluster
        apply_test(8'b0001_1000, 4'd2);  // Sparse middle
        apply_test(8'b0000_1111, 4'd4);  // Lower nibble
        apply_test(8'b1111_0000, 4'd4);  // Upper nibble
        apply_test(8'b1100_0011, 4'd4);  // Symmetric ends
        apply_test(8'b1001_0110, 4'd4);  // Mixed pattern
        apply_test(8'b0111_1110, 4'd6);  // Dense middle
        apply_test(8'b0000_0010, 4'd1);  // Middle bit
        apply_test(8'b0100_0001, 4'd2);  // Edge bits
        apply_test(8'b0010_0100, 4'd2);  // Center bits
        apply_test(8'b0110_0110, 4'd4);  // Balanced pattern

        // Test reset behavior
        reset = 1;
        @(posedge clk);
        #1;
        if (count !== 4'd0)
            $display("Reset test failed: Expected = 0, Got = %0d", count);
        else
            $display("Reset test passed: Count = %0d", count);

        $display("All tests completed.");
        $finish;
    end
endmodule