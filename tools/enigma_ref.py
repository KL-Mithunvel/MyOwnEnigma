"""Reference (golden) model of the Wehrmacht Enigma I / M3 (3 rotors + plugboard).

This is the software truth the Verilog in rtl/ is checked against. It is written
for clarity, not speed. Letters are integers 0..25 (A=0 ... Z=25) internally.

Historical data (rotor wirings, notches, reflectors) lives in WIRING below and is
the single source for tools/gen_tables.py, which generates rtl/enigma_tables.vh.
See docs/ENIGMA_SPEC.md for the full description of the algorithm.

Usage:
    python tools/enigma_ref.py --rotors I II III --rings AAA --pos AAA \\
        --reflector B --plugs "AB CD" --text HELLOWORLD
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field

ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
N = 26

# Rotor wiring (entry contact A..Z -> exit contact) and turnover notch letter.
# The notch is the window letter at which the rotor, when it next steps,
# also carries the rotor to its left.
ROTORS = {
    "I": ("EKMFLGDQVZNTOWYHXUSPAIBRCJ", "Q"),
    "II": ("AJDKSIRUXBLHWTMCQGZNPYFVOE", "E"),
    "III": ("BDFHJLCPRTXVZNYEIWGAKMUSQO", "V"),
    "IV": ("ESOVPZJAYQUIRHXLNFTGKDCMWB", "J"),
    "V": ("VZBRGITYUPSDNHLXAWMJQOFECK", "Z"),
}
ROTOR_NAMES = list(ROTORS)  # order defines the hardware rotor_sel code 0..4

REFLECTORS = {
    "B": "YRUHQSLDPXNGOKMIEBFZCWVJAT",
    "C": "FVPJIAOYEDRZXWGCTKUQSBNMHL",
}
REFLECTOR_NAMES = list(REFLECTORS)  # order defines the hardware reflector_sel code

MAX_PLUGS = 10


def to_int(letter: str) -> int:
    return ALPHABET.index(letter.upper())


def to_letter(value: int) -> str:
    return ALPHABET[value % N]


def parse_plugs(spec: str) -> list[tuple[int, int]]:
    """'AB CD' -> [(0, 1), (2, 3)]. Raises ValueError on an invalid plugboard."""
    pairs = []
    used = set()
    for token in spec.split():
        if len(token) != 2 or not token.isalpha():
            raise ValueError(f"bad plug pair {token!r}")
        a, b = to_int(token[0]), to_int(token[1])
        if a == b:
            raise ValueError(f"plug pair {token!r} connects a letter to itself")
        if a in used or b in used:
            raise ValueError(f"letter reused in plug pair {token!r}")
        used.update((a, b))
        pairs.append((a, b))
    if len(pairs) > MAX_PLUGS:
        raise ValueError(f"at most {MAX_PLUGS} plug pairs, got {len(pairs)}")
    return pairs


@dataclass
class Enigma:
    """Three-rotor Enigma. rotors/rings/pos are given left-to-right."""

    rotors: tuple[str, str, str] = ("I", "II", "III")
    rings: tuple[int, int, int] = (0, 0, 0)  # Ringstellung, A=0
    pos: list[int] = field(default_factory=lambda: [0, 0, 0])  # window letters
    reflector: str = "B"
    plugs: list[tuple[int, int]] = field(default_factory=list)

    def __post_init__(self) -> None:
        self.pos = list(self.pos)
        self._plug_map = list(range(N))
        for a, b in self.plugs:
            self._plug_map[a], self._plug_map[b] = b, a

    # ---- stepping -------------------------------------------------------
    def _notch(self, slot: int) -> int:
        return to_int(ROTORS[self.rotors[slot]][1])

    def step(self) -> None:
        """Advance the rotors for one key press (includes double-stepping)."""
        left, mid, right = 0, 1, 2
        mid_at_notch = self.pos[mid] == self._notch(mid)
        right_at_notch = self.pos[right] == self._notch(right)
        if mid_at_notch:
            self.pos[left] = (self.pos[left] + 1) % N
        if mid_at_notch or right_at_notch:
            self.pos[mid] = (self.pos[mid] + 1) % N
        self.pos[right] = (self.pos[right] + 1) % N

    # ---- signal path ----------------------------------------------------
    def _rotor_pass(self, slot: int, c: int, forward: bool) -> int:
        wiring = ROTORS[self.rotors[slot]][0]
        shift = (self.pos[slot] - self.rings[slot]) % N
        entry = (c + shift) % N
        if forward:
            out = to_int(wiring[entry])
        else:
            out = wiring.index(ALPHABET[entry])
        return (out - shift) % N

    def encrypt_letter(self, c: int) -> int:
        """Step, then pass one letter (0..25) through the machine."""
        self.step()
        c = self._plug_map[c]
        for slot in (2, 1, 0):  # right -> left
            c = self._rotor_pass(slot, c, forward=True)
        c = to_int(REFLECTORS[self.reflector][c])
        for slot in (0, 1, 2):  # left -> right
            c = self._rotor_pass(slot, c, forward=False)
        return self._plug_map[c]

    def encrypt(self, text: str) -> str:
        """Encrypt/decrypt text. Non-letters are dropped; case is ignored."""
        return "".join(
            to_letter(self.encrypt_letter(to_int(ch))) for ch in text if ch.isalpha()
        )


def make_machine(rotors, rings, pos, reflector="B", plugs="") -> Enigma:
    """Convenience constructor taking letters ('AAA') and a plug string ('AB CD')."""
    return Enigma(
        rotors=tuple(rotors),
        rings=tuple(to_int(ch) for ch in rings),
        pos=[to_int(ch) for ch in pos],
        reflector=reflector,
        plugs=parse_plugs(plugs),
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--rotors", nargs=3, default=["I", "II", "III"], choices=ROTOR_NAMES,
                        help="left middle right")
    parser.add_argument("--rings", default="AAA", help="ring settings, left to right, e.g. AAA")
    parser.add_argument("--pos", default="AAA", help="start window letters, left to right")
    parser.add_argument("--reflector", default="B", choices=REFLECTOR_NAMES)
    parser.add_argument("--plugs", default="", help='plug pairs, e.g. "AB CD"')
    parser.add_argument("--text", required=True)
    args = parser.parse_args()
    machine = make_machine(args.rotors, args.rings, args.pos, args.reflector, args.plugs)
    print(machine.encrypt(args.text))


if __name__ == "__main__":
    main()
