"""Consistency checks between config.yaml, the legacy test.v, the XDC files and the RTL.

These catch the kind of silent drift that wastes bench time: a key mapped differently in two places,
a constraint for a port that no longer exists, or a generated header that was edited by hand.
"""

import re
import sys
from pathlib import Path

import pytest
import yaml

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import enigma_ref as ref  # noqa: E402
import gen_tables  # noqa: E402

CFG = yaml.safe_load((ROOT / "config.yaml").read_text(encoding="utf-8"))


def test_keymap_matches_legacy_working_code():
    """config.yaml keys == the table in the legacy test.v that was demonstrated on the real keyboard."""
    legacy = (ROOT / "test.v").read_text(encoding="utf-8", errors="replace")
    legacy_keys = dict(re.findall(r"^\s*8'b([01]{8}): input_([A-Z]) <= 1;", legacy, flags=re.M))
    legacy_keys = {letter: pattern for pattern, letter in legacy_keys.items()}
    assert len(legacy_keys) == 26
    assert CFG["keyboard"]["keys"] == legacy_keys


def test_lamp_codes_match_legacy_working_code():
    legacy = (ROOT / "test.v").read_text(encoding="utf-8", errors="replace")
    found = re.findall(r"^\s*output_([A-Z]): \{o_lb4, o_lb3, o_lb2, o_lb1, o_lb0\} <= 5'b([01]{5});", legacy, flags=re.M)
    legacy_codes = {letter: int(bits, 2) for letter, bits in found}
    assert len(legacy_codes) == 26
    assert CFG["lamp"]["codes"] == legacy_codes


def test_keyboard_table_is_sane():
    keys = CFG["keyboard"]["keys"]
    assert sorted(keys) == list(ref.ALPHABET)
    assert len(set(keys.values())) == 26, "two keys share a matrix position"
    for letter, pattern in keys.items():
        assert re.fullmatch(r"[01]{8}", pattern), letter
        assert pattern[4:] != "0000", f"{letter} has no row bit"
        assert int(pattern[:4], 2) < CFG["keyboard"]["columns"], f"{letter} column out of scan range"
        assert bin(int(pattern[4:], 2)).count("1") == 1, f"{letter} rows must be one-hot"


def test_lamp_table_is_sane():
    codes = CFG["lamp"]["codes"]
    assert len(set(codes.values())) == 26
    assert CFG["lamp"]["idle_code"] not in codes.values()
    assert all(0 <= c < 32 for c in codes.values())


def test_presets_are_valid_machines():
    assert 1 <= len(CFG["presets"]) <= gen_tables.MAX_PRESETS
    for preset in CFG["presets"]:
        ref.make_machine(preset["rotors"], preset["rings"], "AAA", preset["reflector"], preset["plugs"])
        assert len(set(preset["rotors"])) == 3, "a rotor cannot be fitted twice"


@pytest.mark.parametrize("name,builder", [
    ("rtl/enigma_params.vh", gen_tables.build_params),
    ("rtl/enigma_tables.vh", gen_tables.build_tables),
    ("rtl/enigma_presets.vh", gen_tables.build_presets),
])
def test_generated_headers_are_in_sync(name, builder):
    """Generated Verilog must equal what the generator produces now (nobody hand-edited it)."""
    on_disk = (ROOT / name).read_text(encoding="utf-8").replace("\r\n", "\n")
    assert on_disk == builder(CFG), f"{name} is stale: run python tools/gen_tables.py"


def _xdc_pins(path: Path) -> dict:
    pattern = re.compile(r"^\s*set_property -dict \{ PACKAGE_PIN (\w+)\s+IOSTANDARD (\w+) \} \[get_ports \{ ([\w\[\]]+) \}\]")
    return {m.group(3): (m.group(1), m.group(2)) for line in path.read_text(encoding="utf-8").splitlines()
            if (m := pattern.match(line))}


def test_xdc_matches_digilent_master():
    ours = _xdc_pins(ROOT / "constraints" / "arty_s7_enigma.xdc")
    master = _xdc_pins(ROOT / "Arty-S7-50-Master.xdc")
    assert ours
    for port, spec in ours.items():
        assert master.get(port) == spec, f"{port}: {spec} differs from master {master.get(port)}"


def test_xdc_ports_match_top_level_ports():
    top = (ROOT / "rtl" / "enigma_top.v").read_text(encoding="utf-8")
    block = top[top.index(") (") : top.index(");")]
    block = re.sub(r"//.*", "", block)
    declared = set(re.findall(r"\b[A-Za-z_]\w*\b", block)) - {"input", "output", "wire", "reg"}
    constrained = {re.sub(r"\[\d+\]", "", p) for p in _xdc_pins(ROOT / "constraints" / "arty_s7_enigma.xdc")}
    assert declared == constrained, f"unconstrained: {declared - constrained}, unknown: {constrained - declared}"


def test_sw3_is_not_used_as_input():
    """sw[3] sits in the 1.35 V SSTL135 DDR bank; the design must not depend on it."""
    xdc = (ROOT / "constraints" / "arty_s7_enigma.xdc").read_text(encoding="utf-8")
    assert not re.search(r"get_ports \{ sw\[3\] \}", xdc)
