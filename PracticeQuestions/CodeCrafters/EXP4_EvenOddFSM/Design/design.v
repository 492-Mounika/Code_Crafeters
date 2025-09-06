module evenoddfsm(
    input wire clk,
    input wire reset,
    input wire in_valid,
    input wire [7:0] data_in,
    output reg even,
    output reg odd
);
    parameter EVEN_STATE = 1'b0;
    parameter ODD_STATE = 1'b1;
reg state,next_state;
always @(posedge clk or posedge reset) begin
    if(reset) begin
        state <= EVEN_STATE;
    end
    else begin
        state <= next_state;
    end
end
always @(*) begin
    next_state = state;
    if(in_valid) begin
        if(data_in[0] == 1'b0) begin
            next_state = EVEN_STATE;
        end
        else begin
            next_state = ODD_STATE;
        end
    end
end
always @(*) begin
    even = (state == EVEN_STATE);
    odd = (state == ODD_STATE);
end
endmodule