# Hardware Reference

Sources: project README, team slides (`ppts/team 2 enigma ppt.pdf`), poster, `Arty-S7-50-Master.xdc`,
Arty S7 schematic (`ARTY_S7/arty_s7_sch-rev_e.pdf`), KiCad schematics, and the working parts of the
legacy `test.v`.

## Bill of materials (from the poster)

- Arty S7 (Spartan-7 XC7S50) development board
- Keyboard: 29 switches, 29 diodes, keycaps, 3D-printed case, **CD74HC4067** 16-channel analog mux
- Lamp board: 26 LEDs, **2 × CD74HC4067**
- Tools: Vivado, Onshape (CAD), KiCad (schematics)

> Correction: the original README names the multiplexer **74HC4051** (8-channel). The poster and the
> 4-bit select (`ck_io0..3`, 10 states) both indicate **CD74HC4067** (16-channel). The README was fixed.

## Keyboard (input side)

- Diode matrix, 9 columns × 4 rows, 29 switches (26 letters + 3 other keys not used by the logic).
- The FPGA drives a 4-bit column select on `ck_io0..ck_io3` to the 4067 and reads 4 row lines on
  `ck_io5..ck_io8` (`ck_io5` is the MSB of the row nibble).
- A pressed key puts its row line high while its column is selected. Legacy code scanned columns 0–9
  every 10 ms. Only columns 0–8 carry keys. Full key table: `config.yaml → keyboard.keys`.
- Row line `ck_io8` (LSB) is never used by any letter in the legacy mapping.

## Lamp board (output side)

- 26 LEDs on two 4067 muxes. The FPGA drives a 5-bit code on `o_lb0..o_lb4`; `o_lb4N` is its
  inverse and enables the second mux. Code 0–12 → A–M (mux 1), 16–28 → N–Z (mux 2).
  Code 31 selects an unused channel = all lamps off. Table: `config.yaml → lamp.codes`.

## Pin map (from `Arty-S7-50-Master.xdc`, only pins this design uses)

| Signal | Pin | Standard | Note |
|--------|-----|----------|------|
| CLK100MHZ | R2 | SSTL135 | 100 MHz oscillator |
| sw[0] sw[1] sw[2] | H14 H18 G18 | LVCMOS33 | slide switches |
| sw[3] | M5 | **SSTL135** | bank 34 (DDR3 bank, 1.35 V) — **avoid as a user input** |
| btn[0..3] | G15 K16 J16 H13 | LVCMOS33 | push buttons |
| led[0..3] | E18 F13 E13 H15 | LVCMOS33 | green LEDs |
| led0_r/g/b | J15 G17 F15 | LVCMOS33 | RGB LED 0 |
| led1_r/g/b | E15 F18 E14 | LVCMOS33 | RGB LED 1 |
| ck_io0..3 | L13 N13 L16 R14 | LVCMOS33 | keyboard column select (out) |
| ck_io5..8 | R16 R17 V17 R15 | LVCMOS33 | keyboard rows (in) |
| o_lb0..4 | U11 T11 R11 T13 T12 | LVCMOS33 | lamp mux code (Pmod JD / ck_io26-30) |
| o_lb4N | V13 | LVCMOS33 | inverse of o_lb4 (Pmod JD / ck_io31) |

Other config lines in the master XDC (kept in the new constraints file): `CONFIG_VOLTAGE 3.3`,
`CFGBVS VCCO`, SPI x4 config at 50 MHz, `INTERNAL_VREF 0.675` for bank 34.

## User interface of `enigma_top` (only keyboard + lamp board + Arty needed)

| Control | Function |
|---------|----------|
| `sw[1:0]` | Machine preset 0–3 (`config.yaml → presets`): rotors, rings, reflector, plugboard. Change between letters. |
| `sw[2]` | **Setup mode.** Typed letters shift into the start window (last 3 typed = left, middle, right) and echo on the lamps; nothing is encrypted. Switch off to load the window into the rotors. |
| `btn[0]` | Reload the typed start window into the rotors (start a new message). |
| `btn[1]` `btn[2]` `btn[3]` | Hold to show the left / middle / right rotor window letter on the lamp board (no display needed). |
| Keyboard | Each press steps the rotors, encrypts, and lights the lamp while the key is held (minimum on-time applies). |
| `led[0]` key held · `led[1]` setup · `led[2]` plug error · `led[3]` heartbeat (bitstream alive) | |
| RGB0 | Preset colour: red / green / blue / white = preset 0 / 1 / 2 / 3 |
| RGB1 | Green = ready, blue = setup, red = plug error |

## Keyboard / lamp wiring checks to do on the bench (Phase 7)

1. Each key produces exactly one row line high in exactly one column.
2. Lamp codes light the expected LED (A→A…Z→Z) with the keyboard disconnected.
3. 3.3 V levels only: the board header is 3.3 V; do not feed 5 V into `ck_io` inputs.

## CAD

Keyboard case (5 STEP parts, M2×5 ×8 + M2.5×15 ×4) and Arty S7 case (2 parts, M2×10 ×4). Onshape links
are in `cad/README.md`.
