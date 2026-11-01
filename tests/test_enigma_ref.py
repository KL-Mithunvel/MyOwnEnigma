"""Tests for the Python reference model (tools/enigma_ref.py).

These pin the model to published Enigma behaviour, so that when the Verilog is
later compared against the model, the model itself is trustworthy.
"""

import random
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import enigma_ref as ref  # noqa: E402


def machine(rotors=("I", "II", "III"), rings="AAA", pos="AAA", reflector="B", plugs=""):
    return ref.make_machine(rotors, rings, pos, reflector, plugs)


def test_published_vector_aaaaa():
    # Enigma I, rotors I-II-III, UKW-B, rings AAA, start AAA, no plugs.
    assert machine().encrypt("AAAAA") == "BDZGO"


def test_published_vector_helloworld_decrypts():
    cipher = machine().encrypt("HELLOWORLD")
    assert machine().encrypt(cipher) == "HELLOWORLD"


def test_known_long_vector():
    # 26 x 'A' at AAA, rotors I-II-III, UKW-B (widely published).
    assert machine().encrypt("A" * 26) == "BDZGOWCXLTKSBTMCDLPBMUQOFX"


@pytest.mark.parametrize("seed", range(20))
def test_reciprocal_and_no_self_encryption(seed):
    rng = random.Random(seed)
    rotors = tuple(rng.sample(ref.ROTOR_NAMES, 3))
    rings = "".join(rng.choice(ref.ALPHABET) for _ in range(3))
    pos = "".join(rng.choice(ref.ALPHABET) for _ in range(3))
    letters = list(ref.ALPHABET)
    rng.shuffle(letters)
    plugs = " ".join(letters[2 * i] + letters[2 * i + 1] for i in range(rng.randint(0, 10)))
    text = "".join(rng.choice(ref.ALPHABET) for _ in range(200))
    refl = rng.choice(ref.REFLECTOR_NAMES)
    cipher = machine(rotors, rings, pos, refl, plugs).encrypt(text)
    assert all(p != c for p, c in zip(text, cipher)), "a letter encrypted to itself"
    # Identical settings decrypt (reciprocity).
    assert machine(rotors, rings, pos, refl, plugs).encrypt(cipher) == text


def test_double_stepping_sequence():
    # Textbook double-step: ADU -> ADV -> AEW -> BFX -> BFY (rotors I-II-III).
    m = machine(pos="ADU")
    seen = []
    for _ in range(4):
        m.step()
        seen.append("".join(ref.to_letter(p) for p in m.pos))
    assert seen == ["ADV", "AEW", "BFX", "BFY"]


def test_ring_setting_changes_output():
    assert machine(rings="AAA").encrypt("AAAAA") != machine(rings="BBB").encrypt("AAAAA")


def test_plugboard_swaps_letters():
    text = "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG"
    assert machine().encrypt(text) != machine(plugs="AB CD EF").encrypt(text)
    # Plugged machine is still reciprocal.
    cipher = machine(plugs="AB CD EF").encrypt(text)
    assert machine(plugs="AB CD EF").encrypt(cipher) == text


def test_bad_plugboards_rejected():
    for bad in ("AA", "AB BC", "A", "ABC"):
        with pytest.raises(ValueError):
            ref.parse_plugs(bad)
    too_many = " ".join(a + b for a, b in zip("ABCDEFGHIJK", "LMNOPQRSTUV"))
    with pytest.raises(ValueError):
        ref.parse_plugs(too_many)


def test_reflectors_are_involutions_without_fixed_points():
    for name, wiring in ref.REFLECTORS.items():
        for i, ch in enumerate(wiring):
            j = ref.to_int(ch)
            assert j != i, f"reflector {name} maps {ref.to_letter(i)} to itself"
            assert wiring[j] == ref.to_letter(i), f"reflector {name} is not an involution"


def test_rotors_are_permutations():
    for name, (wiring, notch) in ref.ROTORS.items():
        assert sorted(wiring) == list(ref.ALPHABET), name
        assert notch in ref.ALPHABET
