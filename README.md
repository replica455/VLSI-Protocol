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

## SPT Protocol

* Used for the communication mainly between the 1 master and multiple slaves where the master can be a microcontroller or an FPGA and slaved can be DAC or ADC.
* The main operation is governed by 4 pins. So it is called 4 wire interface. This is illustrated in the diagram ![image](https://github.com/replica455/VLSI-Protocol/assets/55652905/98d2424a-47c0-474e-aac4-cbf911f9bf51)




