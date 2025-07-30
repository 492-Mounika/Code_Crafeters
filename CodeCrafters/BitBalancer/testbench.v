`timescale 1ns / 1ps

module counter_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg valid;
    reg [7:0] data;
    wire [3:0] cntOf1;

    // Instantiate the DUT (Design Under Test)
    counter uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .data(data),
        .cntOf1(cntOf1)
    );

    // Clock generator: toggles every 5 ns => 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to apply one data input
    task apply_data(input [7:0] din);
        begin
            @(negedge clk);
            data = din;
            valid = 1;
            @(negedge clk);
            valid = 0;
        end
    endtask

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        valid = 0;
        data = 8'b00000000;

        // Wait and deassert reset
        #20;
        @(negedge clk);
        rst = 0;

        // Apply various test inputs
        apply_data(8'b00000000);  // Expected cntOf1 = 0
        apply_data(8'b00110111);  // Expected cntOf1 = 4
        apply_data(8'b10101010);  // Expected cntOf1 = 4
        apply_data(8'b11111111);  // Expected cntOf1 = 8
        apply_data(8'b10000000);  // Expected cntOf1 = 1
        apply_data(8'b01010101);  // Expected cntOf1 = 4

        // Wait and end simulation
        #20;
        $finish;
    end

    // Display results
    always @(posedge clk) begin
        if (valid)
           #1 $display("Time: %0t | Data: %b | Count of 1s: %d", $time, data, cntOf1);
    end

endmodule
