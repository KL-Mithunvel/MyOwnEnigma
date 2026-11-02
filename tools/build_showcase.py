"""Build the shareable showcase page (showcase/index.html) from showcase/template.html.

    python tools/build_showcase.py

Nothing on the page is typed in by hand: this script runs the real tools and reads their output
(testbench check counts, mutation result, synthesis resources, pytest count), generates the in-page
self-check vectors from the Python golden model, takes the machine presets from config.yaml, and embeds
the hardware photos, schematics and CAD views. Takes about a minute because it runs the whole verification flow.
The finished file is what gets published as an Artifact.
"""

from __future__ import annotations

import base64
import io
import json
import re
import subprocess
import sys
from pathlib import Path

import yaml
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import enigma_ref as ref  # noqa: E402
import mutation_check  # noqa: E402

DEVICE_LUTS = 32600           # XC7S50
FIRST_SYNTH_LUTS = 7190       # first Yosys run before optimisation, recorded in Claude_log.md (Phase 4)
CAD_IMAGES = {"cad_iso": "isometric view.png", "cad_side": "side view.png",
              "cad_section": "side cross section assembly.png"}
HARDWARE_PHOTOS = {"hw_bench": "13-setup-overview-bench-wide.jpeg", "hw_keyboard": "21-keyboard-angle-1.jpeg",
                   "hw_lamps": "19-lampboard-top-down.jpeg", "hw_mux": "18-lampboard-mux-modules.jpeg",
                   "hw_keycaps": "01-keycaps-morse-closeup-1.jpeg", "hw_case": "03-arty-case-top-view-1.jpeg"}
SCHEMATICS = {"sch_keyboard": "keyboard_schematic.png", "sch_lamps": "lampboard_schematic.png"}  # from the 2024 slides


def run(cmd: list[str]) -> str:
    result = subprocess.run([sys.executable, *cmd], cwd=ROOT, capture_output=True, text=True)
    if result.returncode != 0:
        raise SystemExit(f"{' '.join(cmd)} failed:\n{result.stdout}\n{result.stderr}")
    return result.stdout + result.stderr


def gather_stats() -> dict:
    sim = run(["tools/run_sim.py", "--all", "-v"])
    checks = {name: int(n) for name, n, errors in re.findall(r"(tb_\w+): (\d+) checks, (\d+) errors", sim)
              if int(errors) == 0}
    if len(checks) != 4:
        raise SystemExit("not every testbench reported zero errors:\n" + sim)
    vectors_core = int(re.search(r"(\d+) vectors from file", sim).group(1))
    mut = run(["tools/mutation_check.py"])
    killed, total = map(int, re.search(r"(\d+)/(\d+) mutations killed", mut).groups())
    synth = run(["tools/synth_check.py"])
    luts, ffs = map(int, re.search(r"(\d+) LUTs .*?, (\d+) FFs", synth).groups())
    if "SYNTH OK" not in synth:
        raise SystemExit("synthesis check failed:\n" + synth)
    tests = run(["-m", "pytest", "tests", "-q"])
    passed = int(re.search(r"(\d+) passed", tests).group(1))
    if "failed" in tests:
        raise SystemExit("pytest failures:\n" + tests)
    return {
        "checks_core": checks["tb_enigma_core"], "checks_keys": checks["tb_key_scanner"],
        "checks_lamps": checks["tb_lamp_driver"], "checks_top": checks["tb_enigma_top"],
        "checks_total": sum(checks.values()), "vectors_core": vectors_core,
        "mut_killed": killed, "mut_total": total, "luts": luts, "ffs": ffs, "pytest_passed": passed,
    }


def make_vectors(presets: list[dict]) -> list[dict]:
    def vec(name, rotors, rings, start, reflector, plugs, plain):
        cipher = ref.make_machine(rotors, rings, start, reflector, plugs).encrypt(plain)
        return {"name": name, "rotors": rotors, "rings": rings, "start": start, "reflector": reflector,
                "plugs": plugs, "plain": plain, "cipher": cipher}

    vectors = [
        vec("Published, rotors I-II-III", ["I", "II", "III"], "AAA", "AAA", "B", "", "AAAAA"),
        vec("Published, 26 letters", ["I", "II", "III"], "AAA", "AAA", "B", "", "A" * 26),
        vec("Double-step from ADU", ["I", "II", "III"], "AAA", "ADU", "B", "", "A" * 12),
    ]
    starts = ["AAA", "QWE", "ZDU", "MCK"]
    for i, p in enumerate(presets):
        vectors.append(vec(f"FPGA preset {i}", p["rotors"], p["rings"], starts[i % 4], p["reflector"], p["plugs"],
                           "HELLOWORLDENIGMA"))
    assert vectors[0]["cipher"] == "BDZGO", "reference model no longer matches the published vector"
    return vectors


def embed_images() -> dict:
    out = {}
    for name, file in CAD_IMAGES.items():
        img = Image.open(ROOT / "cad" / "enigma-keyboard" / file).convert("RGB")
        img.thumbnail((900, 900))
        buffer = io.BytesIO()
        img.save(buffer, "JPEG", quality=85, optimize=True)
        out[f"img_{name}"] = "data:image/jpeg;base64," + base64.b64encode(buffer.getvalue()).decode("ascii")
    for name, file in HARDWARE_PHOTOS.items():
        img = Image.open(ROOT / "images" / file).convert("RGB")
        img.thumbnail((900, 900))
        buffer = io.BytesIO()
        img.save(buffer, "JPEG", quality=80, optimize=True)
        out[f"img_{name}"] = "data:image/jpeg;base64," + base64.b64encode(buffer.getvalue()).decode("ascii")
    for name, file in SCHEMATICS.items():
        data = (ROOT / "docs" / "images" / file).read_bytes()
        out[f"img_{name}"] = "data:image/png;base64," + base64.b64encode(data).decode("ascii")
    return out


def main() -> None:
    cfg = yaml.safe_load((ROOT / "config.yaml").read_text(encoding="utf-8"))
    stats = gather_stats()
    assert stats["mut_total"] == len(mutation_check.MUTATIONS)
    values = dict(stats)
    values["lut_pct"] = f"{100 * stats['luts'] / DEVICE_LUTS:.1f}"
    values["luts_first"] = f"{FIRST_SYNTH_LUTS:,}"
    values["lut_first_pct"] = f"{100 * FIRST_SYNTH_LUTS / DEVICE_LUTS:.0f}"
    values["checks_total"] = f"{stats['checks_total']:,}"
    for key in ("checks_core", "checks_keys", "checks_lamps", "checks_top"):
        values[key] = f"{stats[key]:,}"
    values["presets_json"] = json.dumps([{k: p[k] for k in ("name", "rotors", "rings", "reflector", "plugs")}
                                         for p in cfg["presets"]])
    values["vectors_json"] = json.dumps(make_vectors(cfg["presets"]))
    values.update(embed_images())

    html = (ROOT / "showcase" / "template.html").read_text(encoding="utf-8")
    for key, value in values.items():
        html = html.replace("{{" + key + "}}", str(value))
    leftover = re.findall(r"\{\{(\w+)\}\}", html)
    if leftover:
        raise SystemExit(f"template placeholders not filled: {sorted(set(leftover))}")
    out = ROOT / "showcase" / "index.html"
    out.write_text(html, encoding="utf-8", newline="\n")
    print(f"wrote {out.relative_to(ROOT)} ({len(html) / 1024:.0f} KB)")
    print({k: v for k, v in values.items() if not k.startswith(("img_", "presets_", "vectors_"))})


if __name__ == "__main__":
    main()
