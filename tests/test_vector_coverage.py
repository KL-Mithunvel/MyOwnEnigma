"""Coverage of the generated Verilog test vectors.

Passing simulation only means something if the vectors exercise the interesting cases. This replays the
generated vector file through the golden model and counts what it actually covered.
"""

import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import enigma_ref as ref  # noqa: E402
import gen_vectors  # noqa: E402


@pytest.fixture(scope="module")
def vectors():
    gen_vectors.main()
    parsed = []
    for line in gen_vectors.OUT.read_text(encoding="utf-8").splitlines():
        v = list(map(int, line.split()))
        rotors, rings, pos, refl, npairs = v[0:3], v[3:6], v[6:9], v[9], v[10]
        pairs = [(v[11 + 2 * i], v[12 + 2 * i]) for i in range(npairs)]
        length = v[31]
        plain = v[32:32 + length]
        parsed.append(dict(rotors=rotors, rings=rings, pos=pos, refl=refl, pairs=pairs, plain=plain))
    return parsed


def test_every_rotor_in_every_slot(vectors):
    for slot in range(3):
        assert {v["rotors"][slot] for v in vectors} == set(range(5)), f"slot {slot}"


def test_both_reflectors(vectors):
    assert {v["refl"] for v in vectors} == {0, 1}


def test_all_plug_counts_zero_to_ten(vectors):
    assert {len(v["pairs"]) for v in vectors} == set(range(11))


def test_all_ring_start_and_plaintext_letters(vectors):
    for slot in range(3):
        assert {v["rings"][slot] for v in vectors} == set(range(26)), f"ring slot {slot}"
        assert {v["pos"][slot] for v in vectors} == set(range(26)), f"start slot {slot}"
    assert {c for v in vectors for c in v["plain"]} == set(range(26))


def test_stepping_events_are_exercised(vectors):
    """Replay with the model and count carries and double-steps; each must occur many times."""
    carries_mid = carries_left = double_steps = 0
    for v in vectors:
        m = ref.Enigma(rotors=tuple(ref.ROTOR_NAMES[r] for r in v["rotors"]), rings=tuple(v["rings"]),
                       pos=list(v["pos"]), reflector=ref.REFLECTOR_NAMES[v["refl"]], plugs=list(v["pairs"]))
        for letter in v["plain"]:
            mid_notch = m.pos[1] == m._notch(1)
            right_notch = m.pos[2] == m._notch(2)
            carries_left += mid_notch
            carries_mid += right_notch
            double_steps += mid_notch and not right_notch
            m.encrypt_letter(letter)
    assert carries_mid >= 50
    assert carries_left >= 50
    assert double_steps >= 20, "the double-step anomaly must be well covered"


def test_long_run_wraps_the_fast_rotor(vectors):
    assert max(len(v["plain"]) for v in vectors) >= 2 * ref.N
