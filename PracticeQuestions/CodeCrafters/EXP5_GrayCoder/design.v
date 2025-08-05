module GrayCoder(
    input wire valid,                 //New Input  
    input wire [7:0] data,            //Data input
    output reg [7:0] gcode            //Gray code output
);
integer i;
//main block
always @(*) begin
    if (valid) begin                  //Starts executing when new input is given
        gcode[7] = data[7];
        for(i = 6;i>=0;i--) begin
            gcode[i] = data[i]^data[i+1];   //Graycode logic
        end
    end
    else begin
        gcode = 8'b00000000;    //gray code sets to zero when no input is given
    end
end
endmodule

