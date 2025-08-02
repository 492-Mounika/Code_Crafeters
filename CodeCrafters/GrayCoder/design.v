module GrayCoder(
    input wire valid,
    input wire [7:0] data,
    output reg [7:0] gcode
);
integer i;
always @(*) begin
    if (valid) begin
        gcode[7] = data[7];
        for(i = 6;i>=0;i--) begin
            gcode[i] = data[i]^data[i+1];
        end
    end
    else begin
        gcode = 8'b00000000;
    end
end
endmodule

