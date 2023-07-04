`timescale 1ns / 1ps

module test();

reg clk, newd,rst;
reg [11:0] din; 
wire sclk,cs,mosi;

spi DUT (.clk(clk),.newd(newd),.rst(rst),.din(din),.sclk(sclk),.cs(cs),.mosi(mosi));


always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    newd = 0;
    din = 12'b100101011100;
    #1000;
    rst = 0;
    #1000;
    newd = 1;   
    #1000;
    newd=0;
    #1600;
    $finish;
end

endmodule
