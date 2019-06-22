# ICOM ATU support fanction for Hermes-Lite Ver2

## Based on the official 20190616 gateware.

## Interface curcuit
<img src="docs/ATU-Interface.jpg" width="480px">

## PowerSDR setting
- Hardware_Config TAB
<img src="docs/PowerSDR_Hardware_Config.jpg" width="480px">
- Apollo TAB (ATU ON)
<img src="docs/PowerSDR_Apollo_ATU_ON.jpg" width="480px">
- Apollo TAB (ATU OFF/Hold)
<img src="docs/PowerSDR_Apollo_ATU_OFF.jpg" width="480px">
- Start ATU tuning
<img src="docs/PowerSDR_ATU_TUNE.jpg" width="480px">
 Step1: Push TUNE buttun to start tuning. When tuning is completed, transmission is automatically stopped.
 Step2: Push TUNE button again to return to receiving.

## Others
- Embedded 5W PA is always enabled.
- Tested with ICOM AH-4
- [_Control sequence_](https://github.com/ji1udd/Hermes-Lite2/blob/CompactTRX/compact-trx/powercontrol/docs/ATU_timing_chart.jpg)
