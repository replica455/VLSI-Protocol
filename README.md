# VLSI-Protocol 
```
communication Protocol covered are

1. ✔️ SPI
2. ✔️ UART
3. [] I2C

Bus Protocol Covered are

1. APB
2. AXI
3. AHB 
4. WISH BONE

```
## COMMUNICATION PROTOCOL 📫 <===📧===💌===📧===> 📫
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

## SPI Protocol Verilog Implementation 
### Design Code
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

### Testbench Code

```
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
```

### Simulated Waveform 

![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/47093702-0f60-4eb7-a2e0-ed5184707c5e)


***THE CODES AND RESULT MIGHT BE OVERWHELMING TO UNDERSTAND SO PLEASE ALLOW ME TO BREAK THEM DOWN TO SIMPLIFIED DOCUMENTATION***

### Understanding The Design 

* First let us understand the simplified block diagram ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/55c11e57-22c3-4a3a-a685-6ca6b69d8298)
* Now previously we had discussed the major pin functions but other than those 4 pins some extra pins are require for the interface to work
* clock "clk" is the signal which we are providing to the FPGA Board say it is 100 MHz. the SPI interface devides the clock to 1 MHz signal which then drives all the functions of the interface and sends/receive data to/from the slaves.
* Please note dyou can make a clock devider logic for this purpose and the 100 MHz and 1 MHz are taken because for my example I am taking Digilent PMOD DAC which is known to work at maximum frequency of 1.8 MHz reliably.
* If we look at the coded I've used an always block for the clock devider circuit logic
```
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
```
* As you can see the reset signal is active low means all the action will start when ```rst == 0``` else the machine will be in default ideal state i.e. no action will be performed.
* noe to understand the above logic look at the waveform below ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/be415f74-9994-4a04-852a-758dd9c6af0d)
* our target is to reduce 100MHz signal --------> 1 MHz signal i.e. 1MHz multiplied by 100 makes 100MHz.So 1 full cycle of 1 MHz signal is equivalent to 100 full cycle of 100MHz signal which has been clearly shown in the picture above. So logically speaking flo 50 clk cycle if sclk signal is at logic 0 then for next 50 clk cycle it should toggle to logic 1. again after that for 50 clk cycle it should again toggle to logic 0 and so on. So we can say to produce 1MHz signal from the 100MHz signal the sclk signal must toggle its state after every 50 cycle count of clk signal. With this consept we can write logic like
```
if(countc < 50 )
          countc <= countc + 1;
      else
          begin
          countc <= 0;
          sclk <= ~sclk;
          end
```
where countc is used as a counter which counts 50 state or 50 cycle of clk signal. whenever it exceeds count 50 state the else block will execute which will toggle the sclk state and reset the countc signal to 0 then again counting will start from 0 to 50 and so on.
* now with thin understanding please read the always block as I have mentioned previously which is responsible for clock devider and generate the sclk signal which will trigger further state machine of transfering the data serially.
* Now follow this rough drawn waveform ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/f372ea89-e6cf-4725-ba86-8f5957564783)
* So as we have discussed all the operation occurs when the produced sclk triggers the  state machine. So in the waveform I've shown the the signal changes with respect to sclk only.
* machine will start the operation when the reset signal rst is low
* now din is a 12 bit pin where we put out data.
* now newd is a signal which when get high logic the machine will read the din value. In the above waveform I made newd signal high and its corrosponding din value is 100101011100. when the newd signal is low whatever value or garbage value present in the din pin will not be read by machine. In a way you can say the newd signal indicates whether newdata is present or not.
* Now when the din value is read, from the next clk cycle the chip select signal is triggered. as you can see from the waveform the chipselect is a active low signal. As soon as the cs signal is low it marks the start of transaction (SoT) and it will remain low till data transmition occur to slave. As soon as the cs will be high it marks end of transaction (EoT), i.e. transmission has ended.
* The cs signal will remain low till for 12 cycle of sclk because out data has 12 bit.
* after 12 bit has been transmitted the cs signal will be pulled high.
* with this knowledge let us again visit the statemachine part of the design, for help i've added the comments.
```
//state machine//
    reg [11:0] temp;
    
  always@(posedge sclk)
  begin
    if(rst == 1'b1) begin   // <-- rst is active low signal
      cs <= 1'b1;           // <-- initializing to default value      
      mosi <= 1'b0;         // <-- initializing to default value 
    end
    else begin                    
     case(state)
         idle:
             begin
               if(newd == 1'b1) begin // newdata is present 
                 state <= send;       // change the state
                 temp <= din;        //  temp is an internal 12 bit register 
                 cs <= 1'b0;         // chip select is made 0 i.e. start of transaction
               end
               else begin
                 state <= idle;      // else state dont change
                 temp <= 8'h00;      // temp receives default value
               end
             end
       
       
       send : begin
         if(count <= 11) begin     // count is used to count 12 cycle of sclk. i.re. it count 0 to 11
           mosi <= temp[count];    //sending lsb first --> data transmission occur
           count <= count + 1;     // incrementing the count
         end
         else
             begin
               count <= 0;        // count exceeds 11 then it again initialized to 0 
               state <= idle;     //state is main ideal
               cs <= 1'b1;        // cs is pilled logic high i.e. end of transaction
               mosi <= 1'b0;      // making it default value
             end 
       end
       
                
      default : state <= idle; 
       
   endcase
  end 
 end
  
endmodule
  ```
* The testbench is straight forward and if you understood the design code and the rough drawn waveform you can also understand the simulated waveform.

### SPI Protocol Refference 

* https://www.circuitbasics.com/basics-of-the-spi-communication-protocol/

* https://www.analog.com/en/analog-dialogue/articles/introduction-to-spi-interface.html

* https://hackaday.com/2016/07/01/what-could-go-wrong-spi/

# UART Protocol
* Again an UART’s main purpose is to transmit and receive serial data.
* You’ll find UARTs being used in many electronics projects to connect GPS modules, Bluetooth modules, and RFID card reader modules to your Raspberry Pi, Arduino, or other microcontrollers.
* Now when should you use UART ? Use UART for device to device serial communication at ***low bandwidth***
* Only 2 pin facilitates the communication between the devices. See the picture below ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/fd918243-0830-40c6-bbb4-80e0fe8e69da)
* For an UART pin the rx pin receives serial data while the tx pin sends serial data and the gnd pin of the communicationg UART interface should be matched so that there exist a common level for data signal to make sense.
* Only two wires are needed to transmit data between two UARTs. Data flows from the tx pin of the transmitting UART to the rx pin of the receiving UART.
### Difference from the working of SPI protocol 
* UARTs transmit data asynchronously, which means there is no clock signal to synchronize the output of bits from the transmitting UART to the sampling of bits by the receiving UART. That is why later on when we will see the verilog design code you will find that we donot produce any other clock signal as output of UART module like we had produced sclk signal in case of SPI design which was feed to slave devices for synchronization purpose. 
* Instead of a clock signal, the transmitting UART adds start and stop bits to the data packet being transferred. These bits define the beginning and end of the data packet so the receiving UART knows when to start reading the bits i,e, they mark the start of transaction and end of transaction.
* Let me demonstrate -  Suppose a master wishes to communicate to slave device through UART protocol. both the master and slave has its own UART interface. As master wants to send data to slave what master needs to do is transmit data through the tx pin of UART module. Now let us say the ideal value or default value of tx pin is logoc 1. the master will pull it down to logic 0 , now this first logic 0 bit in tx pin will mart the start of transaction, then followed by the serial data , thd alter all the bits of data is transmitted the master will pull the tx pin back to logic 1 which will mark the end of transaction. Something looks like this picture when serial transmission occurs ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/47e48745-608d-4a9b-b2b5-1822f63e1087)
* In the above picture I have considered 8 bit data communication with data value 10100101. Since the snipet is from starting of simulation you will find ideal or default value of the tx pin before transmission was not logic 1 instead it was 'X'. So to mark the start of transaction the tx bit was first pulled to logic 0  then followed by 8 bit data transmitting serially then after 8 bit transmission is over the tx bit is pulled high again for end of transmission bit. Also in my design there is again a dignal donetx to validate the end of transaction bit has been received let us ignore that pin for now.
* Now same scenario is when slave wants to talk with master - ***< SoT bit >-< 8 bit data bits >-< EoT bit >***
* But now question arrise If we dont have any master clock signal they how the speed of data transfer is taken care of ?
* When the receiving UART detects a start bit, it starts to read the incoming bits at a specific frequency known as the baud rate.
* Baud rate is a measure of the speed of data transfer, expressed in bits per second (bps).
* Both UARTs must operate at about the same baud rate. The baud rate between the transmitting and receiving UARTs can only differ by about 10% before the timing of bits gets too far off.
* Now if you look at any general datasheet of UART you will get the baud rate information ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/26269428-f539-4c25-b31c-1188acbc60da)
* In my case I'll choose 9600 as baud rate
* If you get data sheet of UART IP you will find there are aoso some optional parity bit for error correction and detection. In my design I'm not considering any such bits.

  ***Again I am saying the protocols data frames can be more complex like it may have few number of start and stop bit, 0 or 1 parity bit and depending upon the designer the architecture can be complex***

### Advantage
* Only uses two wires
* No clock signal is necessary
* Has a parity bit to allow for error checking
* The structure of the data packet can be changed as long as both sides are set up for it
### Disadvantage
* The size of the data frame is limited to a maximum of 9 bits
* Doesn’t support multiple slave or multiple master systems
* The baud rates of each UART must be within 10% of each other

  ### Verilog design code
```
`timescale 1ns / 1ps
 
module uart_top
#(
parameter clk_freq = 1000000,
parameter baud_rate = 9600
)
(
  input clk,rst, 
  input rx,
  input [7:0] dintx,
  input send,
  output tx, 
  output [7:0] doutrx,
  output donetx,
  output donerx
  
    );
    
uarttx 
#(clk_freq, baud_rate) 
utx   
(clk, rst, send, dintx, tx, donetx);   
 
uartrx 
#(clk_freq, baud_rate)
rtx
(clk, rst, rx, donerx, doutrx);    
    
    
endmodule
 

module uarttx
#(
parameter clk_freq = 1000000,
parameter baud_rate = 9600
)
(
input clk,rst,
input send,
input [7:0] tx_data,
output reg tx,
output reg donetx
);
 
 localparam clkcount = (clk_freq/baud_rate); ///x
  
integer count = 0;
integer counts = 0;
 
reg uclk = 0;
  
parameter idle = 2'b00;
parameter transfer = 2'b01;

reg [1:0] state;
 
  always@(posedge clk)
    begin
      if(count < clkcount/2)
        count <= count + 1;
      else begin
        count <= 0;
        uclk <= ~uclk;
      end 
    end
  
  
  reg [7:0] din;
   
  always@(posedge uclk)
    begin
      if(rst) 
      begin
        state <= idle;
      end
     else
     begin
     case(state)
       idle:
         begin
           counts <= 0;
           tx <= 1'b1;    
           donetx <= 1'b0;
           
           if(send)             
           begin
             state <= transfer;
             din <= tx_data;
             tx <= 1'b0;       
           end                 
           else
             state <= idle;       
         end
       
 
      
      transfer: begin
        if(counts <= 7) begin
           counts <= counts + 1; 
           tx <= din[counts];
           state <= transfer;
        end
        else 
        begin
           counts <= 0;
           tx <= 1'b1;
           state <= idle;
          donetx <= 1'b1;
        end
      end     
      default : state <= idle;
    endcase
  end
end
 
endmodule
 

module uartrx
#(
parameter clk_freq = 1000000, //MHz
parameter baud_rate = 9600
    )
 (
input clk,
input rst,
input rx,
output reg done,
output reg [7:0] rxdata
);
    
localparam clkcount = (clk_freq/baud_rate);
  
integer count = 0;
integer counts = 0;
  
reg uclk = 0;
  
parameter idle = 2'b00; 
parameter start = 2'b01;

reg [1:0] state;
 
 ///////////uart_clock_gen
  always@(posedge clk)
    begin
      if(count < clkcount/2)
        count <= count + 1;
      else begin
        count <= 0;
        uclk <= ~uclk;
      end 
    end

  always@(posedge uclk)
    begin
      if(rst) 
      begin
     rxdata <= 8'h00;
     counts <= 0;
     done <= 1'b0;
      end
     else
     begin
     case(state)
       
     idle : 
     begin
     rxdata <= 8'h00;
     counts <= 0;
     done <= 1'b0;
     
     if(rx == 1'b0)
       state <= start;
     else
       state <= idle;
     end
     
     start: 
     begin
       if(counts <= 7)
      begin
     counts <= counts + 1;
     rxdata <= {rx, rxdata[7:1]};
     end
     else
     begin
     counts <= 0;
     done <= 1'b1;
     state <= idle;
     end
     end
   
   
   default : state <= idle;
   
   endcase
 
end
 
end
 
endmodule
```
### Verilog Testbench

```
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

```

### Simulated Waveform 



![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/20434b88-b30f-4bd0-aeee-5da85a63c700)

***I know at this point everything looks complex. Allow me to simplify the design, TB and waveform***

### Design Description

So from the verilog top module if I try to draw a block diagram then it will look like this. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/d66172c1-e432-4409-95d5-908b15e62efe) 

let us now describe the purpose od each pin.

* ***clk and rst*** are the global signal. clk is the pin at which the FPGA is operationg 100MHz. Through this clock pin we will derive the device operating rate using the mentioned baud rate. The rst is the reset pin of the device.

  
* ***rx*** pin to receive data from other device serially.
* ***donerx*** whenever we complete receiving the 8 bit serial data from other devices the donerx pin will be pulled high logic.
* ***doutrx[7:0]*** in case of reception as soon as all the 8 bits have been received in "rx" pin we merge all the single bit serially received data in a single 8 bit packet and show the final output at the 8 bit doutrx[7:0] pin.

The above 3 pin deals with the reception mechanism of the peripheral. So simultaniously let us also look at the waveform also. I'm considering an arbitary 8 bit input ```10100101``` coming serially in rx pin. So the packet received at rx pin will look like 
```< 0 >--< 10100101 >--< 1 >``` i.e. 
```< start bit > -- < data bits > -- < stop bit >``` . After receiving the stop bit the datas received will be merged to 8 bit data and finally shown at doutrx[7:0] data pin and to tell the user the answer is available we observe the donerx pin goes high logic. Same thing is explained in the below picture ![251634918-0c425c35-6a6c-45e9-b76c-c64a3001d285](https://github.com/replica455/VLSI-Protocol/assets/55652905/06a8e77d-9f60-47f5-916d-5fa283410d5a)


Let us now discuss with the transmission mechanism. 
* ***send and dintx[7:0] pin*** whenever user has a new data which he wants to communicate with other device the first it will make 'send' pin high which will imply the there is a data to communicate and simultaniously we put the 8 bit data in the dintx[7:0] pin. I'm not annotating the picture like previous one but you can understand the meaning just by observing below picture. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/020e07a8-92c3-41c8-9d43-2dc210f31334)
* ***tx pin*** The data which we mentioned in the dintx[7:0] pin is the send bit by bit serially through 'tx' pin and obviously the same format will be used ```< 0 >--< 10100101 >--< 1 >``` i.e. ```< start bit >--< data bit >--< stop bit >```. The same thing you can understand from the picture. Hope you understand even without annotations. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/b3abac42-6083-48b4-8f98-e0975618bf47)
* As soon as the stop bit is received the donetx pin will be made high.

***Now i think you can understand the reception and transmission mechanism in an abstract level using the simulated waveform, Please review the waveform again to grasp the overall operation***

***Let us move deep into the design and see how the design is made***
* If we dig deep into the design implementation you will see the structure like this ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/55315e6b-c3fe-409e-bf3f-2419de40f562)
* See there are 2 operation transmission and reception so I've created 2 separate module for these 2 operation and named them as ***uarttx module for transmission*** and ***uartrx module for reception***.
* So you can see in the above picture that the ***uarttx*** module all the pins which are required for transmission purpose along with the global pin i.e. clk, rst, send, dintx[7:0], donetx, tx.
* Similarly in ***uartrx*** module we have all the pins which are required for reception purpose along with the global pin i.e. clk, rst, rx, doutrx[7:0], donerx.
* ***What I'll do now is to describe a single module and toher module you can understand easily. Let us take the transmission module "uarttx"***
*
``` 
module uarttx
#(
parameter clk_freq = 1000000,
parameter baud_rate = 9600
)
(
input clk,rst,
input send,
input [7:0] tx_data,
output reg tx,
output reg donetx
);
 
 localparam clkcount = (clk_freq/baud_rate); ///x
  
integer count = 0;
integer counts = 0;
 
reg uclk = 0;
  
parameter idle = 2'b00;
parameter transfer = 2'b01;

reg [1:0] state;
 
 ///////////uart_clock_gen
  always@(posedge clk)
    begin
      if(count < clkcount/2)
        count <= count + 1;
      else begin
        count <= 0;
        uclk <= ~uclk;
      end 
    end
  
  
  reg [7:0] din;
  ////////////////////Reset decoder
 
  always@(posedge uclk)
    begin
      if(rst) 
      begin
        state <= idle;
      end
     else
     begin
     case(state)
       idle:
         begin
           counts <= 0;
           tx <= 1'b1;    //////////////////default value of tx is 1;
           donetx <= 1'b0;
           
           if(send)             ////////////////////////////// send is active high signal 
           begin
             state <= transfer;
             din <= tx_data;
             tx <= 1'b0;       ///////////////////////////// after initiating the process through send signal the tx bit is pulled down(SoT)
           end                 ///////////////////////////// So first tx = 0 indicates SoT;
           else
             state <= idle;       
         end
         
      transfer: begin
        if(counts <= 7) begin
           counts <= counts + 1; 
           tx <= din[counts];
           state <= transfer;
        end
        else 
        begin
           counts <= 0;
           tx <= 1'b1;
           state <= idle;
          donetx <= 1'b1;
        end
      end
          
      default : state <= idle;
    endcase
  end
end
 
endmodule
```
* IF i discuss from top to bottom first there are 2 parameter declared. One is for clock frequency which is 1MHz (say) and other is the UART interface baud rate 9600. These 2 parameter will determine the working frequency of the device.
```
module uarttx
#(
parameter clk_freq = 1000000,
parameter baud_rate = 9600
)
```
* Next comes the input and output pins
```
(
input clk,rst,          <-- Global pin
input send,             <-- Transmission input pin
input [7:0] tx_data,    <-- Transmission input pin
output reg tx,          <-- Transmission output pin
output reg donetx       <-- Transmission output pin
);
```
* The next step is to generate the frequency at which the UART peripheral will work. We want the device to work at the baud rate. But we only have the FPGA clock frequency 100MHz. So out next task is to convert the Clk frequency to approximate baud rate. We use the same logic as we discussed in the SPI protocol. i.e. clock devider. [1MHz / 9600 = 104 approx number of cycle]
```
localparam clkcount = (clk_freq/baud_rate); <- It gives us number of cycle of 1MHz clk signal which is equivalent to 1 cycle of baud rate signal 
reg uclk = 0;                               <- This is the signal which will mantain the operation frequency of the device
integer count = 0                           <- counter to count 0 to (clkcount / 2) i.e. 104 / 2 = 52 cycle
///////////uart_clock_gen
  always@(posedge clk)
    begin
      if(count < clkcount/2)       <- for count is less than 52 cycle, just increment the counter
        count <= count + 1;
      else begin
        count <= 0;                <- for count value more than 52 cycle toogle the state of uclk and reset the count value and keep on repeating
        uclk <= ~uclk;
      end 
    end
```
This will produce a "uclk" signal which will produce signal approximately to required baud rate. This signal will control the required state machine. Even Though we have produced the uclk signal it is used just to mantain the required frequency of operation and is not responsible for synchronizing the operation between 2 communicationg UART module.
* Next Let us observe the actual state machine for transreceiver operation. There are 2 states of the machine "idle" and "transfer" . Follow the code and comments you will understand.
```
always@(posedge uclk)
    begin
      if(rst) 
      begin
        state <= idle;
      end
     else
     begin
     case(state)
       idle:
         begin
           counts <= 0;         <-- default value
           tx <= 1'b1;          <--default value of tx is 1;
           donetx <= 1'b0;      <--default value 
           
           if(send)             <-- send is active high signal 
           begin
             state <= transfer; <-- change the state
             din <= tx_data;    <-- save the din value to a temporary register
             tx <= 1'b0;        <-- after initiating the process through send signal the tx bit is pulled down(SoT)
           end                  ///////////////////////////// So first tx = 0 indicates SoT;
           else
             state <= idle;       
         end
         
      transfer: begin
        if(counts <= 7) begin   <-- Since we are dealing with 8 bit data (next line)
           counts <= counts + 1;<-- we count till 8 (next line)
           tx <= din[counts];   <-- and simultaniously serially transmit the data din bit by bit
           state <= transfer;   <-- donot change the state
        end
        else 
        begin
           counts <= 0;         <-- reset the counts
           tx <= 1'b1;          <-- make the last bit 1 for EoT
           state <= idle;       <-- change the state
          donetx <= 1'b1;       <-- spull donetx state high for completion
        end
      end
          
      default : state <= idle;
    endcase
  end
end
```
* In the ***uartrx module*** the only different mechanism is to accumulate the data received in the rx pin. The logis is simple, we use a shift register.
```
 start: 
     begin
       if(counts <= 7)
      begin
     counts <= counts + 1;
     rxdata <= {rx, rxdata[7:1]}; <-- Shift register logic 
```
* Else every thing is same in usrtrx module
* Let us see the top module
```
module uart_top
#(
parameter clk_freq = 1000000,
parameter baud_rate = 9600
)
(
  input clk,rst,                           <---- include all the pins from the block diagram we I've shown previously
  input rx,
  input [7:0] dintx,
  input send,
  output tx, 
  output [7:0] doutrx,
  output donetx,
  output donerx
  
    );
    
uarttx                                   <-- Instantiate the transmission module
#(clk_freq, baud_rate)                   <-- pass the parameter values, If you want to cange the value you can mention in the top directly
utx                                      <-- Instantiation name
(clk, rst, send, dintx, tx, donetx);     <-- Line up the connecting wire
 
uartrx                                   <-- Same as the previous one
#(clk_freq, baud_rate)
rtx
(clk, rst, rx, donerx, doutrx);    
    
    
endmodule
```
***After understanding the design operation, design simulated waveform and design code I'm expecting you can write the testbench by your own. Now this concludes the UART Protocol.***

So we have covered




✔️ SPI




✔️ UART






Now let us see I2C Protocol


### UART Protocol Refference

* https://www.circuitbasics.com/basics-uart-communication/

# I2C protocol
‼️ ***Updating soon, Will reqire time because it is lengthy and I'm traveling to new city. I hope I can complete the Communication protocol by 16 JULY*** ‼️

Like UART communication, I2C only uses two wires to transmit data between devices 1. SDA 2. SCL 



![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/a4de5eca-c0f4-479f-81fe-2abc67be1fc9)

Like SPI, I2C is synchronous, so the output of bits is synchronized to the sampling of bits by a clock signal shared between the master and the slave. The clock signal is always controlled by the master. This protocol might be bit complicated so I'm taking the example such that the I2C interface is communicating with a memory. So our process can be summed up like the I2C peripheral may write a data to the memory or can read the data from the memory. 
To make it easy just remember that the message frame can be abstracted up like the figure below.


![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/57965433-ea83-466f-bac3-763f9bfff1ec)


all the communication process will be acieved by using only those 2 line. 

* ***Start Condition*** Every message frame will have a START condition, else the communication will not occur. To have the start condition the SCL will be logic 1 for 2 clk cycle while at those same clock cycle the SDA line will switch from logic 1 to logic 0. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/dc9c90e4-79d0-4e5f-8bf0-f861719a6800)
* ***address*** Now after the start condition the actual transcation starts. Now when the transaction will occur the SCL line will follow reference clock only which helps to synchronize transaction between the master and slave. Till the transaction occurs the SCL and Reference clock will be same. The transaction occurs vis SDA line. Since we are using a memory to communicate, irrespective of operation (read or write ) we need to mention the address mentioned by master. The address frame is of 8 bit, of which the 7 bit addr[7:1] is used for mentioning the address, i.e. 7 bit address. So maximum depth of memory can be of 2^7 = 128 location. Now the last LSB bit of address addr[0] is use to mention the type of operation. Say if it is 1 then write operation and when it is 0 Read operation. So overall these 8 bits need to be communicated to slave serially in 8 clock cycle. But in the diagram I've minimized the transaction. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/99faa579-35ff-41be-b409-770fc4236581)
* ***Acknowledgement*** Now after 8 clock cycle the complete addredd bit are been sent to slave the slave has to send an acknowledgement signal to the master. So innidiately next clock cycle the SDA signal will be made logic 0 to signify the acknowledgement. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/853311c6-ac4d-48e0-afed-afb8b11aca05)
* ***Data*** Now after master receive the acknowledgement say it wants to send a data to the memory. So for next 8 clock cycle the 8 bit data from the master will be send serially through the SDA line. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/0dcf2a37-6d6c-408e-9e11-8da9522e5a1e)
* ***Ackmowledgement*** Now after sending the 8 bit data serially again the slave has to send the acknowledgement signal to master i.e. SDA is pulled/retained to logic 0. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/fa180407-06d3-4554-8d54-63ec292d2cd8)
* ***Stop Condition*** After receiving the aclnowledgement the message frame needs to be terminated using a stop condition. To do so the SDA bit should change from the logic 0 to logic 1 and the SCL bit needs to be retained to logic 1. ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/50ec6b09-722c-48b4-981a-6451e198d3c3)
* So the overall working waveform looks like this ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/a4e9994c-3da4-44a5-84e2-780739cc439d)



***NOTE- IN OUR DESIGN WHEN THE MASTER WILL NOT RECEIVE AN ACKNOWLEDGEMENT THEN THE STATE MACHINE WILL REMAIN TO ITS CURRENT STATE ONLY UNTILL IT DISNT RECEIVE AN ACK. SIGNAL. IN OTHER DESIGN WHEN THE ACK. SIGNAL IS NOT RECEIVED THEN THE STATEMACJ=HINE WILL AGAIN WAIT FOR START CONDITION AND THE PROCESS WILL START AGAIN. IT IS NOT VERY FREQUENT THAT THE DEVICE WILL MISS THE ACKNOWLEDGEMENT SIGNAL***



***My campus placement is going on . Please give me some time***












