module tb_nibbleswapper;

    // DUT signals
    reg clk;
    reg reset;
    reg [7:0] in;
    reg swap_en;
    wire [7:0] out;

    // Instantiate DUT
    nibbleswapper dut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .swap_en(swap_en),
        .out(out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Helper: expected swap
    function [7:0] expected_swap(input [7:0] x);
        expected_swap = {x[3:0], x[7:4]};
    endfunction

    // Apply stimulus
    task apply_swap(input [7:0] val, input enable, input [7:0] expected);
        begin
            in = val;
            swap_en = enable;
            @(posedge clk); #1;

            if (out !== expected)
                $display(" FAIL: in=%h swap_en=%b → out=%h (Expected: %h)", val, enable, out, expected);
            else
                $display("PASS: in=%h swap_en=%b → out=%h", val, enable, out);
        end
    endtask

    initial begin
        $dumpfile("nibbleswapper.vcd");
        $dumpvars(0, tb_nibbleswapper);

        $display("=== Starting NibbleSwapper Test ===");

        clk = 0; reset = 1; in = 8'h00; swap_en = 0;
        #12; reset = 0;

        // === Critical Testcases ===
        $display("--- Critical Testcases ---");

        // 1. Reset behavior
        if (out !== 8'h00) $display(" FAIL: Reset output not 0");

        // 2. Normal swap: 0x71 → 0x17
        apply_swap(8'h71, 1, 8'h17);

        // 3. Hold output when swap_en = 0
        apply_swap(8'hA5, 0, 8'h17); // No change expected

        // 4. Swap again: 0xB4 → 0x4B
        apply_swap(8'hB4, 1, 8'h4B);

        // 5. swap_en toggling
        apply_swap(8'hC3, 1, 8'h3C);
        apply_swap(8'hF0, 0, 8'h3C); // Should hold
        apply_swap(8'hF0, 1, 8'h0F); // Swap now

        // 6. Back-to-back swaps
        apply_swap(8'h11, 1, 8'h11);
        apply_swap(8'h22, 1, 8'h22);

        // 7. Same input twice, validate repeated swap
        apply_swap(8'h3C, 1, 8'hC3);
        apply_swap(8'h3C, 1, 8'hC3);

        // 8. Edge: 0x00 → should stay 0
        apply_swap(8'h00, 1, 8'h00);

        // 9. Edge: 0xFF → swap remains 0xFF
        apply_swap(8'hFF, 1, 8'hFF);

        // 10. Glitch check: swap_en = 0 on active clock → output should hold
        in = 8'h9A;
        swap_en = 0;
        @(posedge clk); #1;
        if (out !== 8'hFF) // last was FF
            $display("FAIL: Output changed unexpectedly on swap_en=0");
        else
            $display(" PASS: Output held on swap_en=0");

        // ===  Generic Testcases ===
        $display("--- Generic Testcases ---");

        apply_swap(8'hA5, 1, expected_swap(8'hA5));
        apply_swap(8'h5A, 1, expected_swap(8'h5A));
        apply_swap(8'h0F, 1, expected_swap(8'h0F));
        apply_swap(8'hF0, 1, expected_swap(8'hF0));
        apply_swap(8'hAA, 1, expected_swap(8'hAA));
        apply_swap(8'h55, 1, expected_swap(8'h55));
        apply_swap(8'hC0, 1, expected_swap(8'hC0));
        apply_swap(8'h03, 1, expected_swap(8'h03));
        apply_swap(8'h10, 1, expected_swap(8'h10));
        apply_swap(8'h01, 1, expected_swap(8'h01));

        $display("=== NibbleSwapper Test Completed ===");
        $finish;
    end

endmodule