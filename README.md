# VLSI-Protocol
```
communication Protocol covered are 
1. SPI
2. UART
3. I2C
Bus Protocol Covered are
1. APB
2. AXI
3. AHB 
4. WISH BONE

```
## INTRODUCTION ON COMMUNICATION PROTOCOL
* SPI, I2C, and UART are ideal for communication between microcontrollers and between microcontrollers and sensors where large amounts of high speed data don’t need to be transferred.
* SPI, I2C, and UART are quite a bit slower than protocols like USB, ethernet, Bluetooth, and WiFi, but they’re a lot more simple and use less hardware and system resources
* The bits of data can be transmitted either in parallel or serial form. In parallel communication, the bits of data are sent all at the same time, each through a separate wire.
* In serial communication, the bits are sent one by one through a single wire.

# SPI Protocol
### PIN FUNCTIONALITY
* Used for the communication mainly between the 1 master and multiple slaves where the master can be a microcontroller or an FPGA and slaves can be DAC or ADC.
* The main operation is governed by 4 pins. So it is called 4 wire interface. This is illustrated in the diagram ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/98d2424a-47c0-474e-aac4-cbf911f9bf51)
* The pin functionality are
```
MOSI --> master output slave input => This pin is use to send data serially from master to slave device
MISO --> master input slave output => This pin is use to receive data serially from slave to master device
SCLK --> clock signal produced by master which use to drive the slave device 
CS   --> Chip select => In case of multiple slave the width of CS line will increase
```
* Just to clarify the FPGA (master) board will run in "clk" clock freaquency which is usually high. The slaves like DAC and ADC Runs in low frequency clock signal. So we feed the Master with "clk" signal, then master device devides the clock using clock devider logic and produce a new clock signal called "sclk" or slave clock signal which will drive the slaves.
* For simplicity we are using 1 slave so "CS". Infact the pins discussed above are all 1 bit.
### BASIC WORKING IDEA
* The core idea of SPI is that each device has a shift-register that it can use to send or receive a byte of data. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/fb6a31d7-0e2e-43f7-9bed-53319faa3db9)
*  Thanks to HACKDAY.COM for the documentation. I'll give reference at the end.
*  These two shift registers are connected together in a ring, the output of one going to the input of the other and vice-versa. One device, the master, controls the common clock signal that makes sure that each register shifts one bit in just exactly as the other is shifting one bit out (and vice-versa).
*  As you might expect, this means a master/slave pair must use the same clocking scheme to communicate.
### MODES OF WORKING
* Every Master device should have a pair of registers, clock polarity (CPOL) and clock phase (CPHA), which determine the sampling and shifting action of the datas. Thanks to <ANALOG DEVICES> for the below documentation which will help to understand the functionality of the modes.
* The clock signal in SPI can be modified using the properties of clock polarity and clock phase. These two properties work together to define when the bits are output and when they are sampled.
* Clock polarity (CPOL) can be set by the master to allow for bits to be output and sampled on either the rising or falling edge of the clock cycle.
* Clock phase (CPHA) can be set for output and sampling to occur on either the first edge or second edge of the clock cycle, regardless of whether it is rising or falling.
* The below table summarises all the modes and their significance. Again all the credit goes to ANALOG DEVICES. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/e491a900-6ba7-46f2-87f5-6e0fc33226e6)
* The below figure will help to demonstrate different modes as mentioned. Note that in these examples, the data is shown on the MOSI and MISO line. The start and end of transmission is indicated by the dotted green line, the sampling edge is indicated in orange, and the shifting edge is indicated in blue. Please note these figures are for illustration purpose only.
* SPI Mode 0, CPOL = 0, CPHA = 0: CLK idle state = low, data sampled on rising edge and shifted on falling edge. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/416f7412-3dc6-45e3-a43f-4c303f3b997e)
* SPI Mode 1, CPOL = 0, CPHA = 1: CLK idle state = low, data sampled on the falling edge and shifted on the rising edge. In this mode, clock polarity is 0, which indicates that the idle state of the clock signal is low. The clock phase in this mode is 1, which indicates that the data is sampled on the falling edge (shown by the orange dotted line) and the data is shifted on the rising edge (shown by the dotted blue line) of the clock signal. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/0e829ff0-24c3-4f2d-bdfe-dc3291e4fdff)
* SPI Mode 2, CPOL = 1, CPHA = 0: CLK idle state = high, data sampled on the rising edge and shifted on the falling edge. In this mode, the clock polarity is 1, which indicates that the idle state of the clock signal is high. The clock phase in this mode is 0, which indicates that the data is sampled on the rising edge (shown by the orange dotted line) and the data is shifted on the falling edge (shown by the dotted blue line) of the clock signal. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/928b8494-9a42-445b-aabe-af1d31105c38)
* SPI Mode 3, CPOL = 1, CPHA = 1: CLK idle state = high, data sampled on the falling edge and shifted on the rising edge. In this mode, the clock polarity is 1, which indicates that the idle state of the clock signal is high. The clock phase in this mode is 1, which indicates that the data is sampled on the falling edge (shown by the orange dotted line) and the data is shifted on the rising edge (shown by the dotted blue line) of the clock signal. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/9b43cfe9-5fe1-4a69-a070-2c98b78aedfb)

### Advantage of SPI Communication
* No start and stop bits, so the data can be streamed continuously without interruption
* No complicated slave addressing system like I2C
* Higher data transfer rate than I2C (almost twice as fast)
* Separate MISO and MOSI lines, so data can be sent and received at the same time

### Disadvantage of SPI Communication 
* Uses four wires (I2C and UARTs use two)
* No acknowledgement that the data has been successfully received (I2C has this)
* No form of error checking like the parity bit in UART
* Only allows for a single master

Now this conclude the theory of the SPI communication. Now let us proceed to implement the SPI Communication through Verilog.

### SPI Protocol Verilog Implementation 

```
 module spi(
input clk, newd,rst,
input [11:0] din, 
output reg sclk,cs,mosi
    );
  
  parameter idle = 2'b00;
  parameter send = 2'b01;
  
  reg [5:0] countc = 0;
  reg [3:0] count = 0;
  
  reg [1:0] state;
 
 //generation of sclk//
 always@(posedge clk)
  begin
    if(rst == 1'b1) begin
      countc <= 0;
      sclk <= 1'b0;
    end
    else begin 
      if(countc < 50 )
          countc <= countc + 1;
      else
          begin
          countc <= 0;
          sclk <= ~sclk;
          end
    end
  end
  
  //state machine//
    reg [11:0] temp;
    
  always@(posedge sclk)
  begin
    if(rst == 1'b1) begin
      cs <= 1'b1; 
      mosi <= 1'b0;
    end
    else begin
     case(state)
         idle:
             begin
               if(newd == 1'b1) begin
                 state <= send;
                 temp <= din; 
                 cs <= 1'b0;
               end
               else begin
                 state <= idle;
                 temp <= 8'h00;
               end
             end
       
       
       send : begin
         if(count <= 11) begin
           mosi <= temp[count]; /////sending lsb first
           count <= count + 1;
         end
         else
             begin
               count <= 0;
               state <= idle;
               cs <= 1'b1;
               mosi <= 1'b0;
             end
       end
       
                
      default : state <= idle; 
       
   endcase
  end 
 end
  
endmodule
```

### Refference 

* https://www.circuitbasics.com/basics-of-the-spi-communication-protocol/

* https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html

* https://hackaday.com/2016/07/01/what-could-go-wrong-spi/








