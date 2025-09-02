module bitbalancer(
    input wire clk,             //Input for clock(positive/negative)
    input wire reset,             //Input for reset(count resets to zero if rst = 1)
    input wire [7:0] in,      //Input for data vector of size 8-bits
    output reg [3:0] count    //Output register to store the count of ones in the given data
);
//function to count the ones of a 8-bit data - Combinational
function [3:0] count_ones;
    input [7:0] val;
    integer i;
    begin
        count_ones = 4'd0;
        for (i = 0; i < 8; i = i + 1) begin
            count_ones = count_ones + val[i];
        end
    end
endfunction
//main to count the number of ones for every new data
always @(posedge clk) begin
    if (reset) begin
        count <= 4'd0;
    end
    else begin
        count <= count_ones(in);
    end
end
endmodule