module LightChaser(
    input wire clk,
    input wire rst,         //input for reset wire to take input for every cycle
    input wire enable,      //input for enable to switch on the circuit
    output reg [7:0]light   //output register to display the light

);
    reg [2:0] count;
    //main block
    always @(posedge clk) begin
        if (rst  && enable) begin
            light <= 8'b00000001;   //on reset the light is intialized to the led on LSB
        end
        else if(enable) begin
            if (count == 3'd4) begin
                light <= (light == 8'b10000000) ? 8'b00000001 : light << 1;
                count <= 0;  // Reset the counter after shifting
            end 
            else begin
                count <= count + 1;  // Increment counter for few clocks
            end
        end
    end
endmodule
