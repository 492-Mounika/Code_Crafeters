`timescale 1ns / 1ps

module tb_PulseTracer;

    // Parameters
    parameter FILTER_LEN = 3;
    parameter CLK_PERIOD = 10;

    // Signals
    reg clk;
    reg rst_n;
    reg noisy_in;
    wire pulse_out;

    // Instantiate DUT
    PulseTracer #(.FILTER_LEN(FILTER_LEN)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .noisy_in(noisy_in),
        .pulse_out(pulse_out)
    );

    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Monitor
    always @(posedge clk)
        $display("Time %0t | noisy_in=%b | pulse_out=%b", $time, noisy_in, pulse_out);

    // Stimulus
    initial begin
        $dumpfile("pulse_tracer_full.vcd");
        $dumpvars(0, tb_PulseTracer);

        // Reset
        rst_n = 0;
        noisy_in = 0;
        #(2*CLK_PERIOD);
        rst_n = 1;

        // -------------------------------
        // TESTCASE 1: Glitch < FILTER_LEN
        // -------------------------------
        $display("\n[TC1] Short Glitch (Should NOT trigger pulse)");
        noisy_in = 1; #(1*CLK_PERIOD);
        noisy_in = 0; #(5*CLK_PERIOD);

        // -------------------------------
        // TESTCASE 2: Valid pulse
        // -------------------------------
        $display("\n[TC2] Stable high for FILTER_LEN (Should trigger 1 pulse)");
        noisy_in = 1; #(FILTER_LEN * CLK_PERIOD);
        noisy_in = 1; #(CLK_PERIOD);  // Pulse expected here
        noisy_in = 0; #(3 * CLK_PERIOD);

        // -------------------------------
        // TESTCASE 3: Noise — alternating glitches
        // -------------------------------
        $display("\n[TC3] Alternating glitches (Should NOT trigger pulse)");
        repeat (10) begin
            noisy_in = $random % 2;
            #(CLK_PERIOD);
        end

        // -------------------------------
        // TESTCASE 4: Back-to-back valid pulses
        // -------------------------------
        $display("\n[TC4] Two valid pulses with low separation");
        noisy_in = 1; #(FILTER_LEN * CLK_PERIOD);
        noisy_in = 1; #(CLK_PERIOD);  // Pulse 1
        noisy_in = 0; #(3 * CLK_PERIOD);
        noisy_in = 1; #(FILTER_LEN * CLK_PERIOD);
        noisy_in = 1; #(CLK_PERIOD);  // Pulse 2
        noisy_in = 0; #(3 * CLK_PERIOD);

        // -------------------------------
        // TESTCASE 5: Long hold high (No multiple pulses)
        // -------------------------------
        $display("\n[TC5] Long held high (Only one pulse)");
        noisy_in = 1; #(FILTER_LEN * CLK_PERIOD);
        noisy_in = 1; #(10 * CLK_PERIOD); // Should only see 1 pulse
        noisy_in = 0; #(3 * CLK_PERIOD);

        // -------------------------------
        // TESTCASE 6: Glitch during rising period
        // -------------------------------
        $display("\n[TC6] Glitch during FILTER_LEN build-up");
        noisy_in = 1; #(1 * CLK_PERIOD);
        noisy_in = 0; #(1 * CLK_PERIOD);  // breaks the streak
        noisy_in = 1; #(FILTER_LEN * CLK_PERIOD);
        noisy_in = 1; #(CLK_PERIOD);      // Pulse expected here
        noisy_in = 0; #(3 * CLK_PERIOD);

        // -------------------------------
        // TESTCASE 7: Random noise + controlled pulses
        // -------------------------------
        $display("\n[TC7] Random noise, then forced valid pulse");
        repeat (20) begin
            noisy_in = $random % 2;
            #(CLK_PERIOD);
        end
        noisy_in = 0; #(3 * CLK_PERIOD);  // reset
        noisy_in = 1; #(FILTER_LEN * CLK_PERIOD);
        noisy_in = 1; #(CLK_PERIOD);      // Pulse expected here
        noisy_in = 0; #(3 * CLK_PERIOD);

        // Done
        $display("\nAll tests complete.");
        $finish;
    end

endmodule