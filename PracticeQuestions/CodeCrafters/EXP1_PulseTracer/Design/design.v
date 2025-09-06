`timescale 1ns / 1ps

module PulseTracer #(
    parameter FILTER_LEN = 3
)(
    input  wire clk,
    input  wire rst_n,
    input  wire noisy_in,
    output reg  pulse_out
);

    reg [3:0] counter;   // counts stable highs

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            counter   <= 0;
            pulse_out <= 0;
        end
        else begin
            if(noisy_in) begin
                // increment counter until FILTER_LEN
                if(counter < FILTER_LEN)
                    counter <= counter + 1;

                // generate pulse exactly once when threshold is hit
                if(counter == FILTER_LEN - 1)
                    pulse_out <= 1;
                else
                    pulse_out <= 0;
            end
            else begin
                // reset when input goes low
                counter   <= 0;
                pulse_out <= 0;
            end
        end
    end

endmodule
