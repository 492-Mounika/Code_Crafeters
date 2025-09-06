`timescale 1ns / 1ps

module tb_evenoddfsm;

    // Inputs
    reg clk;
    reg reset;
    reg in_valid;
    reg [7:0] data_in;

    // Outputs
    wire even;
    wire odd;

    // Instantiate the DUT
    evenoddfsm dut (
        .clk(clk),
        .reset(reset),
        .in_valid(in_valid),
        .data_in(data_in),
        .even(even),
        .odd(odd)
    );

    // Clock Generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to apply a single input vector
    task apply_input(
        input [7:0] din, 
        input valid, 
        input [1:0] expected  // 2'b01 for even, 2'b10 for odd
    );
        begin
            @(negedge clk);
            in_valid = valid;
            data_in = din;
            @(posedge clk);
            #1;

            $display("[Time %0t] Input: %3d | in_valid: %b | EVEN: %b | ODD: %b | Expected: %s",
                $time, din, valid, even, odd,
                (expected == 2'b01) ? "EVEN" :
                (expected == 2'b10) ? "ODD" : "NO CHANGE");

            if (valid) begin
                if ((expected == 2'b01 && even !== 1'b1) || 
                    (expected == 2'b10 && odd !== 1'b1)) begin
                    $display("FAILED: Input %d | Expected: %b | Got EVEN: %b, ODD: %b", 
                        din, expected, even, odd);
                end else begin
                    $display("PASSED");
                end
            end
        end
    endtask

    // Test Procedure
    initial begin
        // VCD dump
        $dumpfile("evenoddfsm.vcd");
        $dumpvars(0, tb_evenoddfsm);

        // Initial values
        clk = 0;
        reset = 1;
        in_valid = 0;
        data_in = 0;

        // Apply Reset
        #12 reset = 0;

        // -------------------------------
        //  Critical Test Cases
        // -------------------------------
        apply_input(8'd0,    1, 2'b01); // even
        apply_input(8'd1,    1, 2'b10); // odd
        apply_input(8'd2,    1, 2'b01); // even
        apply_input(8'd255,  1, 2'b10); // odd (max value)
        apply_input(8'd128,  1, 2'b01); // even (MSB = 1)
        apply_input(8'd127,  1, 2'b10); // odd
        apply_input(8'd254,  1, 2'b01); // even
        apply_input(8'd3,    0, 2'b00); // in_valid = 0 → hold state
        apply_input(8'd4,    1, 2'b01); // even
        apply_input(8'd5,    1, 2'b10); // odd

        // -------------------------------
        // Generic Test Cases
        // -------------------------------
        apply_input(8'd10,   1, 2'b01);
        apply_input(8'd11,   1, 2'b10);
        apply_input(8'd6,    0, 2'b00); // in_valid = 0 → no change
        apply_input(8'd6,    1, 2'b01);
        apply_input(8'd9,    1, 2'b10);
        apply_input(8'd12,   1, 2'b01);
        apply_input(8'd13,   1, 2'b10);
        apply_input(8'd14,   1, 2'b01);
        apply_input(8'd15,   1, 2'b10);
        apply_input(8'd16,   1, 2'b01);

        $display("All test cases executed.");
        #20 $finish;
    end

endmodule