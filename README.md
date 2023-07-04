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
* 



