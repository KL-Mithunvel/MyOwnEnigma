## arty_s7_enigma.xdc - constraints for rtl/enigma_top.v on the Digilent Arty S7-50.
## Derived from Digilent's Arty-S7-50-Master.xdc; only the pins the design uses are enabled
## (pin map documented in docs/HARDWARE.md). Port names match enigma_top.v.
## sw[3] (M5) is intentionally NOT used: it is in bank 34 (DDR3, 1.35 V, SSTL135).

## Clock - 100 MHz
set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000} [get_ports { CLK100MHZ }];

## Slide switches: sw[1:0] = preset, sw[2] = setup mode
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }];
set_property -dict { PACKAGE_PIN H18   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }];
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }];

## Push buttons: btn[0] = reload start window, btn[1..3] = show left/middle/right window letter
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }];
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }];
set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { btn[2] }];
set_property -dict { PACKAGE_PIN H13   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }];

## Status LEDs: led[0] key held, led[1] setup, led[2] plug error, led[3] heartbeat
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { led[3] }];

## RGB LEDs: RGB0 = preset colour, RGB1 = green ready / blue setup / red plug error
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { led0_r }];
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { led0_g }];
set_property -dict { PACKAGE_PIN F15   IOSTANDARD LVCMOS33 } [get_ports { led0_b }];
set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { led1_r }];
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { led1_g }];
set_property -dict { PACKAGE_PIN E14   IOSTANDARD LVCMOS33 } [get_ports { led1_b }];

## Keyboard: column select to the CD74HC4067 (outputs), key rows back (inputs)
set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports { ck_io0 }];
set_property -dict { PACKAGE_PIN N13   IOSTANDARD LVCMOS33 } [get_ports { ck_io1 }];
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { ck_io2 }];
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { ck_io3 }];
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { ck_io5 }];
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { ck_io6 }];
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { ck_io7 }];
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { ck_io8 }];

## Lamp board: 5-bit code to the two CD74HC4067 muxes (Pmod JD / ck_io26-31)
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { o_lb0 }];
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { o_lb1 }];
set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { o_lb2 }];
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { o_lb3 }];
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { o_lb4 }];
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { o_lb4N }];

## Asynchronous human/mux inputs are synchronised in RTL (2-flop); slow outputs are not timing-critical.
set_false_path -from [get_ports { sw[*] btn[*] ck_io5 ck_io6 ck_io7 ck_io8 }]
set_false_path -to   [get_ports { led[*] led0_* led1_* ck_io0 ck_io1 ck_io2 ck_io3 o_lb* }]

## Configuration (unchanged from the Digilent master file)
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property INTERNAL_VREF 0.675 [get_iobanks 34]
