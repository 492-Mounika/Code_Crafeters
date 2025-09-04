module nibbleswapper(
    input clk,
    input reset,
    input [7:0]in,
    input swap_en,
    output reg [7:0]out
);
always @(posedge clk) begin
    if (reset) begin
        out <= 8'h00;
    end
    else if (swap_en) begin
        out <= {in[3:0],in[7:4]};
    end
end
endmodule