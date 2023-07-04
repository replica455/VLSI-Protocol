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

## SPI Protocol

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
* 



