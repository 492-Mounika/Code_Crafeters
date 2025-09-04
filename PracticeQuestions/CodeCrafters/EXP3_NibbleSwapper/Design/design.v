module nibbleswapper(
    input clk,
    input reset,
    input [7:0]in,
    input swap_en,
    output reg [7:0]out
);
always @(posedge clk) begin
    if (reset) begin
        out <= 8'h00;                //when reset is given the output is set to zero
    end
    else if (swap_en) begin
        out <= {in[3:0],in[7:4]};    //when swap is enable the swapping of four bits takes place
    end
end
endmodule
