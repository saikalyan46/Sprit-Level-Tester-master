# Sprit-Level-Tester
System to be designed: Spirit Level Tester System Description:
Used for testing the sobriety of a person. This system tests the sobriety of the user by
giving a sequence of hexadecimal characters of varying length(6 to 12 characters) by
showing it on the LCD. It records the reaction time of the user in ms and displays the
same on the LCD on a successful patch. The sequence should disappear after 2
seconds. The user is given a new pattern if he/she enters a wrong pattern. The user is
given a total of three chances. After three mismatches of patterns an alarm is sounded.
The pattern is generated randomly by the systems.

## ASSUMPTIONS
- Pseudo random numbers are generated with a cycle of 19683 and hence, in this
condition, supposed to be fairly random
- Software delays are producing the same amount of delay as hardware delay.
- Simulation time is not very slow as compared to real time.
- All the port driven i/o devices are working with any voltage output from the 8255A
pins
- Reaction time is being shown in microseconds irrespective of the sobriety of the
person.

## LIST OF COMPONENTS USED
| CHIP NUMBER | QTY. | CHIP | PURPOSE |
| --- | --- | --- | --- |
| 8086 | 1 | Microprocessor | Central Processing Unit |
| 74HC373 | 4 | 8 bit Octal Latches | Latching the Address Bus and the buzzer |
| 74HC245 | 4 | 8 bit Octal Latches | Latching the Data Bus and the LCD Panel |
| 74LS138 | 1 | 3:8 Decoder | Chip Select for ROM and Ram in memory interfacing |
| 74154 | 1 | 4:16 Decoder | Chip Select for 8255A to connect the I/O devices |
| 2732 | 2 | ROM (4KB each) | Read Only Memory To store the code |
| 6116 | 2 | ROM (2KB each) | Random Access Memory To store and retrieve temporary memory |
| 8255A | 2 | Programmable Peripheral Interface | Connects I/O devices to the memory |
| 555 | 1 | 555 Timer | Generates Clock pulse to measure reaction time |
| LM020L | 1 | Liquid Crystal Display | Displays the random patterns |
| BUZZER | 1 | Buzzer | Beeps as affirmative |


## OTHER HARDWARE USED
- Logic Gates – Used for building decoding logic for memory interfacing
- A Hex Keypad – Used for entering patterns

## MEMORY MAPPING
The System uses 4KB RAM (2KB banks of each odd and even) and 8KB ROM (4KB
banks for each odd and even) thus enabling copy of 16-bit of data in one cycle.<br/>
ROM : 8KB<br/>
Even bank starting Address — 00000h<br/>
Even bank ending Address — 01FFEh<br/>
Odd bank starting address — 00001h<br/>
Odd bank ending address — 01FFFh<br/>
RAM : 4KB<br/>
Even bank starting address — 02000h<br/>
Even bank ending address — 02FFEh<br/>
Odd bank starting address — 02001h<br/>
Odd bank ending address — 02FFFh<br/>
## MEMORY AND ADDRESS MAP TABLE
A0 and BHE’ signal is used for separating even and odd banks.
![image](https://user-images.githubusercontent.com/54111714/140653438-edba41df-fa0c-402e-ada0-a2d31de7544f.png)

## I/O INTERFACING
![image](https://user-images.githubusercontent.com/54111714/140653466-8627a97f-ef88-4d4a-9511-5f10972b448b.png)

## FLOW CHART
![image](https://user-images.githubusercontent.com/54111714/140653478-616ee6cf-d6a6-4ed2-9261-b2b29ea5ac2f.png)
