`timescale 1s / 1ps


module test();

reg clk,rst,rx;
reg [7:0] dintx;
reg send;
wire tx;
wire [7:0] doutrx;
wire donetx;
wire donerx;


uart_top DUT (clk,rst,rx,dintx,send,tx,doutrx,donetx,donerx);

initial clk = 0;
always #5 clk = ~clk;



initial begin

///////////////////////////////////////////////// for transmission
    @(posedge DUT.utx.uclk);
    rst = 1; rx = 1; send = 0; dintx = 8'b10100101;
    @(posedge DUT.utx.uclk);
    rst = 0; send = 1;
    #3000;
///////////////////////////////////////////////// for reception
    @(posedge DUT.rtx.uclk); 
     rx = 0;                   // -----------> SoT
    @(posedge DUT.rtx.uclk);
    rx = 1;
     @(posedge DUT.rtx.uclk);
    rx = 0;
     @(posedge DUT.rtx.uclk);
    rx = 1;
     @(posedge DUT.rtx.uclk);
    rx = 0;
     @(posedge DUT.rtx.uclk);
    rx = 0;
     @(posedge DUT.rtx.uclk);
    rx = 1;
     @(posedge DUT.rtx.uclk);
    rx = 0;
     @(posedge DUT.rtx.uclk);
    rx = 1;
     @(posedge DUT.rtx.uclk);
    rx = 1;                //----------------> EoT
    
     @(posedge DUT.rtx.uclk);
     @(posedge DUT.rtx.uclk);
     $finish;
    
      
end

endmodule
