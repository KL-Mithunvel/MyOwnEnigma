"""Generate test vectors for the Verilog testbenches from the Python golden model.

    python tools/gen_vectors.py            # writes sim/build/vectors.txt

One vector per line, all decimal integers separated by spaces:

    rot_l rot_m rot_r  ring_l ring_m ring_r  pos_l pos_m pos_r  reflector
    npairs  a0 b0 a1 b1 ... a9 b9          (unused pairs are 0 0)
    length  plain[0..length-1]  cipher[0..length-1]

Rotor codes: I=0 .. V=4. Letters: A=0 .. Z=25. Seed and counts come from config.yaml (sim:).
The set is built to hit: every rotor, both reflectors, 0..10 plug pairs, ring settings, and the
stepping edge cases (rotors parked one step before their notches).
"""

from __future__ import annotations

import random
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import enigma_ref as ref  # noqa: E402

OUT = ROOT / "sim" / "build" / "vectors.txt"


def random_plugs(rng: random.Random, count: int) -> list[tuple[int, int]]:
    letters = list(range(ref.N))
    rng.shuffle(letters)
    return [(letters[2 * i], letters[2 * i + 1]) for i in range(count)]


def make_vector(rotors, rings, pos, refl, plugs, plain) -> str:
    machine = ref.Enigma(
        rotors=tuple(ref.ROTOR_NAMES[r] for r in rotors),
        rings=tuple(rings),
        pos=list(pos),
        reflector=ref.REFLECTOR_NAMES[refl],
        plugs=list(plugs),
    )
    cipher = [machine.encrypt_letter(c) for c in plain]
    padded = list(plugs) + [(0, 0)] * (ref.MAX_PLUGS - len(plugs))
    fields = [*rotors, *rings, *pos, refl, len(plugs)]
    for a, b in padded:
        fields += [a, b]
    fields += [len(plain), *plain, *cipher]
    return " ".join(str(f) for f in fields)


def main() -> None:
    cfg = yaml.safe_load((ROOT / "config.yaml").read_text(encoding="utf-8"))["sim"]
    rng = random.Random(cfg["seed"])
    max_len = cfg["max_message_len"]
    lines = []

    def msg(n):
        return [rng.randrange(ref.N) for _ in range(n)]

    # Published reference: I-II-III, rings AAA, start AAA, no plugs, 'AAAAA' -> 'BDZGO'
    lines.append(make_vector([0, 1, 2], [0, 0, 0], [0, 0, 0], 0, [], [0] * 26))

    # Random machines
    for _ in range(cfg["random_vectors"]):
        rotors = rng.sample(range(5), 3)
        rings = [rng.randrange(ref.N) for _ in range(3)]
        pos = [rng.randrange(ref.N) for _ in range(3)]
        plugs = random_plugs(rng, rng.randint(0, ref.MAX_PLUGS))
        lines.append(make_vector(rotors, rings, pos, rng.randrange(2), plugs, msg(rng.randint(1, max_len))))

    # Stepping edge cases: park rotors 0-2 steps before their notches, then run long enough to carry
    for _ in range(60):
        rotors = rng.sample(range(5), 3)
        notch = [ref.to_int(ref.ROTORS[ref.ROTOR_NAMES[r]][1]) for r in rotors]
        pos = [rng.randrange(ref.N), (notch[1] - rng.randint(0, 2)) % ref.N, (notch[2] - rng.randint(0, 2)) % ref.N]
        rings = [rng.randrange(ref.N) for _ in range(3)]
        lines.append(make_vector(rotors, rings, pos, rng.randrange(2), random_plugs(rng, rng.randint(0, 10)),
                                 msg(max_len)))

    # Full-cycle run: 700 letters crosses the fast-rotor wrap and a middle-rotor carry, with all 10 plugs
    lines.append(make_vector([2, 1, 0], [1, 2, 3], [0, 0, 0], 0, random_plugs(rng, 10), msg(700)))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"wrote {OUT.relative_to(ROOT)} ({len(lines)} vectors)")


if __name__ == "__main__":
    main()
