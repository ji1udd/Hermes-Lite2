# Hermes-Lite Ver2 Beta5 Compact Transceiver firmware
[_VU2ZAZ's HL2 Companion board_](https://github.com/bnamnaidu/HL2-Companion-board-codec-and-Filter-) ,
[_Errata_](CTRX_HL2b5/docs/ComboBoardErrata_180406.pdf) ,
[_HL2b5 Modification_](CTRX_HL2b5/docs/HL2b5_modification_for_ComboBoard.pdf)

## Based on the official 20180106 firmware.

## Iambic keyer and audio codec (sidetone)
- [_Keyer function_](https://github.com/ji1udd/Hermes-Lite/blob/6M/audiocodec/docs/Keyer_Sequece_and_setting.pdf)
- Mic gain (AK4951) : Normal 18dB, Boost 30dB
- Enable SPEAKER : [_Re-use "Random"_](https://github.com/ji1udd/Hermes-Lite2/blob/CompactTRX/compact-trx/Keyer_AK4951/docs/Speaker_Setting.jpg) on OpenHPSDR protocol.

## N2ADR filter (1 HPF, 6 LPFs) control
- Support [_Alex / Apollo auto filter mode_](https://github.com/ji1udd/Hermes-Lite2/blob/CompactTRX/compact-trx/TX_RX_Filter/docs/Filter_Setting.jpg) ; HPF and LPFs are switched according to TX and multi RXs frequencies.
- Support Alex manual filter mode ; This mode is not supported by piHPSDR, but supported by [_PowerSDR_](CTRX_HL2b5/docs/PowerSDR_ALEX_ManualFilter_setting_for_Jims_Filter.jpg).
- Short switch latency for CW keyer operation.
- HPF is bypassed during TX.

## External amplifier band control
- Send TX frequency with Elecraft serial command "FA(VFO A frequency)" to ExtAMP.
- UART 9600bps
- Tested with HARDROCK-50
- UART RxD is not used.

## External ATU control
- Enable ATU : Use [_"Apollo auto tune"_](https://github.com/ji1udd/Hermes-Lite2/blob/CompactTRX/compact-trx/powercontrol/docs/ATU_Setting.jpg) on OpenHPSDR protocol.
- Send START trigger to ATU (like Start SW), Receive STATUS from ATU (like Tuning LED).
- [_Control sequence_](https://github.com/ji1udd/Hermes-Lite2/blob/CompactTRX/compact-trx/powercontrol/docs/ATU_timing_chart.jpg)
- Tested with ICOM AH-4

## Cooling Fan control
- controlled by temperature sensor
- [_4 operation modes_](https://github.com/ji1udd/Hermes-Lite2/blob/CompactTRX/compact-trx/powercontrol/docs/Fan_Control_setting.jpg)

## LED Ports
- The function is automatically selected by ExtAMP/ExtATU interface circuit installation on board.
<img src="CTRX_HL2b5/docs/LEDs_function.jpg" width="640px">

## Others
- Embedded PA is always enabled for a stand alone transceiver.

## Use AK4951 audio codec board for HL2 Beta3 instead of VU2ZAZ's Companion board.
<img src="https://github.com/ji1udd/Hermes-Lite2/blob/CompactTRX/compact-trx/Keyer_AK4951/docs/KeyerIF_AK4951_board.JPG" width="240px">

- For more detail of AK4951 audio codec board, refer to [_CompactTRX branch_](https://github.com/ji1udd/Hermes-Lite2/tree/CompactTRX) on my git. 
- [_Installation guide_](CTRX_HL2b5/docs/Installation_Guide_codec_HL2b5_or_later.pdf)
- [_Assemble option_](CTRX_HL2b5/docs/AudioCodecBoard_AssembleOption.pdf) of AK4951 audio codec board.
- [_Assemble option between audio codec board_](CTRX_HL2b5/docs/IF_board_assemble_option.pdf) and [_I/F board_](https://github.com/ji1udd/Hermes-Lite2/blob/CompactTRX/compact-trx/IF_board/docs/IF_board.JPG).
- If another jack pin assignment is prefferd, it's possible to make another I/F board that has the jack pin assignment that you like and connect it to audio codec board using P2 and P3 ( or P4). CN4 on HL2 is currently not used.
- [_Interface circuit for HARDROCK-50_](CTRX_HL2b5/docs/interface_HR50.pdf)
