module counter(
    input wire clk,             //Input for clock(positive/negative)
    input wire rst,             //Input for reset(count resets to zero if rst = 1)
    input wire valid,           //Input for valid - counts only when new input is given
    input wire [7:0] data,      //Input for data vector of size 8-bits
    output reg [3:0] cntOf1    //Output register to store the count of ones in the given data
);
//function to count the ones of a 8-bit data - Combinational
function [3:0] count_ones;
    input [7:0] data_in;
    integer i;
    begin
        count_ones = 4'd0;
        for(i = 0;i<8;i++) begin
            count_ones = count_ones+data_in[i];
        end
    end
endfunction
//main to count the number of ones for every new data
always @(posedge clk) begin
    if (rst) begin
        cntOf1 <= 4'd0;
    end
    else if (valid) begin
        cntOf1 <= count_ones(data);
    end
end
endmodule