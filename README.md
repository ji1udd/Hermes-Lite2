# HL Ver2 Beta5 or later Companion Board V3.0 gateware
## Hardware : [_WA2T 's Companion Board V3.0_](https://github.com/WA2T/Hermes-Lite2) 

## Changes from  [_CTRX_HL2b5 gateware_](https://github.com/ji1udd/Hermes-Lite2/tree/CTRX_HL2b5) 

### I/O port assignment
- DB1-3 :  ExtAMP TxD (output)
- DB1-5 :  EXTTR (output ; FPGA pin 28 clone)
- CN4-2 :  Dot  (input)
- CN4-3 :  Dash (input)

### LED Ports
- D2,D3,D4 and D5 functions are basically same as official gateware 20190907.
- If additional ExtATU interface circuit is installed, D4 and D5 ports are used as ATU controll ports.

### Improvement of "Low RX sensitivity after CW Tx" (22 Sep. 2019)
- If PureSignal is set off, AD9866 RxPGA is powered down while CW Tx.
- If on, AD9866 RxPGA is always powered up. (same as previous version)

## Software setting
- [_PowerSDR_](V3_Companion/V3_PowerSDR_Setting.pdf)
- [_piHPSDR_](V3_Companion/V3_piHPSDR_Setting.pdf)
