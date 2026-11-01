# Enigma Specification (what this project implements)

Machine: **Wehrmacht Enigma I / M3** — three rotors chosen from I–V, reflector B (UKW-B) or C
(UKW-C), ring settings (Ringstellung), start positions (Grundstellung), plugboard (Steckerbrett)
with up to 10 pairs. Letters are numbered A=0 … Z=25. The golden implementation is
`tools/enigma_ref.py`; the Verilog (`rtl/enigma_core.v`) must match it exactly.

## Signal path for one key press

1. **Step** the rotors (before the letter is encrypted).
2. Plugboard swap.
3. Rotor right → middle → left (forward).
4. Reflector.
5. Rotor left → middle → right (inverse wiring).
6. Plugboard swap again → lamp.

Because the reflector is an involution with no fixed point, the machine is **reciprocal** (the same
settings decrypt) and **a letter never encrypts to itself**.

## Rotor offset formula

For a rotor with wiring `W`, window position `p` and ring setting `r`:

```
shift   = (p - r) mod 26
forward : out = (W[(c + shift) mod 26] - shift) mod 26
inverse : out = (W^-1[(c + shift) mod 26] - shift) mod 26
```

## Stepping (including the double-step anomaly)

Each rotor has a notch letter. On every key press, before encryption:

```
left_steps   = middle is at its notch
middle_steps = middle is at its notch  OR  right is at its notch   (double-step)
right_steps  = always
```

Example, rotors I-II-III: `ADU → ADV → AEW → BFX → BFY` (the middle rotor steps twice in a row).

## Wiring tables (historical)

| Rotor | Wiring (A→Z) | Notch |
|-------|--------------|-------|
| I | EKMFLGDQVZNTOWYHXUSPAIBRCJ | Q |
| II | AJDKSIRUXBLHWTMCQGZNPYFVOE | E |
| III | BDFHJLCPRTXVZNYEIWGAKMUSQO | V |
| IV | ESOVPZJAYQUIRHXLNFTGKDCMWB | J |
| V | VZBRGITYUPSDNHLXAWMJQOFECK | Z |
| UKW-B | YRUHQSLDPXNGOKMIEBFZCWVJAT | — |
| UKW-C | FVPJIAOYEDRZXWGCTKUQSBNMHL | — |

The hardware rotor code is the index in the order I, II, III, IV, V (0–4); reflector code 0 = B, 1 = C.

## Published test vectors (used in tests)

| Setup | Input | Output |
|-------|-------|--------|
| Rotors I-II-III, UKW-B, rings AAA, start AAA, no plugs | `AAAAA` | `BDZGO` |
| same | 26 × `A` | `BDZGOWCXLTKSBTMCDLPBMUQOFX` |
| same, start `ADU` | 4 key presses | window `ADV, AEW, BFX, BFY` |

## Plugboard rules

At most 10 pairs; a letter may be in only one pair; a letter cannot be paired with itself. The
hardware flags an invalid configuration on `plug_error` and ignores the bad pair.

## Why the original `test.v` was not a working Enigma

It chained one-direction substitutions with no stepping, used a pass-through/shifted "reflector" (not an
involution), had no ring settings, no notches and no plugboard, and selected "rotors" with switches.
It was a useful interface experiment (keyboard → lamp mapping worked) but not the cipher. Details in
`.CLAUDE/CLAUDE.md` → Known Technical Debt.

## References

- Crypto Museum Enigma technical details; Cipher Machines & Cryptology (enigmatech)
- Cryptography Stack Exchange: how ring settings change wiring tables
- Wikipedia: Enigma machine — mathematical analysis
