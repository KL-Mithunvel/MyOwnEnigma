"""Static checks on the RTL sources, plus a wrapper that runs every Verilog testbench.

Static rules keep the RTL synthesizable for Vivado and simulation-safe (see .CLAUDE/CLAUDE.md).
The simulation wrapper skips itself if Icarus Verilog is not installed.
"""

import re
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import run_sim  # noqa: E402

RTL_FILES = sorted((ROOT / "rtl").glob("*.v"))
HAND_WRITTEN = [p for p in RTL_FILES] + [ROOT / "rtl" / "enigma_math.vh", ROOT / "rtl" / "enigma_util.vh"]


def code_only(text: str) -> str:
    """Strip // comments so rules do not trip on documentation."""
    return re.sub(r"//.*", "", text)


@pytest.mark.parametrize("path", HAND_WRITTEN, ids=lambda p: p.name)
def test_no_simulation_only_constructs_in_rtl(path):
    text = code_only(path.read_text(encoding="utf-8"))
    assert "$" not in text, "system tasks ($display, $finish...) are testbench-only"
    assert not re.search(r"#\s*\d", text), "delays are not synthesizable"
    assert not re.search(r"\binitial\b", text), "use declaration initial values instead of initial blocks"
    assert not re.search(r"always\s*@\s*\*", text), "always @* is not evaluated at time 0 in simulation; use assign + function"
    assert not re.search(r"\bforce\b|\brelease\b|\bdeassign\b", text)


@pytest.mark.parametrize("path", RTL_FILES, ids=lambda p: p.name)
def test_each_module_is_documented_and_timescaled(path):
    text = path.read_text(encoding="utf-8")
    assert "`timescale" in text.splitlines()[0], "first line must be the timescale"
    assert text.splitlines()[1].startswith("//") or text.splitlines()[1].startswith("`include"), "module needs a header comment"
    assert len(re.findall(r"^\s*module\s", text, flags=re.M)) == len(re.findall(r"^\s*endmodule\b", text, flags=re.M)) == 1


def test_one_module_per_file_and_name_matches():
    for path in RTL_FILES:
        modules = re.findall(r"^\s*module\s+(\w+)", path.read_text(encoding="utf-8"), flags=re.M)
        assert modules == [path.stem], f"{path.name}: expected module {path.stem}, found {modules}"


def test_no_hardcoded_clock_rates_in_rtl():
    """Timing numbers belong in config.yaml (-> generated macros), not inline in RTL."""
    for path in RTL_FILES:
        text = code_only(path.read_text(encoding="utf-8"))
        assert not re.search(r"\b100_?000_?000\b|\b1_?000_?000\b", text), path.name


def test_generated_headers_carry_banner():
    for name in ("enigma_params.vh", "enigma_tables.vh", "enigma_presets.vh"):
        assert "DO NOT EDIT BY HAND" in (ROOT / "rtl" / name).read_text(encoding="utf-8").splitlines()[0]


@pytest.mark.skipif(not (shutil.which("iverilog") or Path("C:/iverilog/bin/iverilog.exe").exists()),
                    reason="Icarus Verilog not installed")
def test_all_verilog_testbenches_pass():
    result = subprocess.run([sys.executable, str(ROOT / "tools" / "run_sim.py"), "--all"], cwd=ROOT,
                            capture_output=True, text=True, timeout=900)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "[warn]" not in result.stdout, "the RTL must compile warning-free at -Wall:\n" + result.stdout


def _yosys_available():
    try:
        import synth_check
        synth_check.find_yosys()
        return True
    except SystemExit:
        return False


@pytest.mark.skipif(not _yosys_available(), reason="Yosys not installed (pip install yowasp-yosys)")
def test_synthesis_is_clean_and_small():
    """No latches/warnings, and the whole design stays a small fraction of the XC7S50."""
    result = subprocess.run([sys.executable, str(ROOT / "tools" / "synth_check.py")], cwd=ROOT,
                            capture_output=True, text=True, timeout=900)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "SYNTH OK" in result.stdout
