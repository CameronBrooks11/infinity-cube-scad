"""Render the infinity cube at several sizes and check that its hinges work.

usage: python3 tests/test_cube.py [OPENSCAD]

At each size it checks the whole cube's pieces and size, then, through
tests/probe.scad, that every link is free in its channel (no contact with the
cubes or pins), that no two links touch, and that all 32 pins reach into
their links, and that a hinge folds freely to 90 degrees and no further,
with its two cubes face to face and not overlapping.
Renders use --hardwarnings and $fn = 48 to stay quick.
"""

import os
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CUBE = os.path.join(ROOT, "infinity-cube.scad")
PROBE = os.path.join(ROOT, "tests", "probe.scad")
SIZES = (12, 14, 20, 30)


def solids_and_size(path):
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    parent = {}

    def find(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    for i in range(n):
        a = struct.unpack_from("<9f", data, 84 + i * 50 + 12)
        corners = [a[0:3], a[3:6], a[6:9]]
        for c in corners:
            parent.setdefault(c, c)
        root = find(corners[0])
        for c in corners[1:]:
            parent[find(c)] = root
    size = [max(p[i] for p in parent) - min(p[i] for p in parent) for i in range(3)]
    return len({find(v) for v in parent}), size


def render(openscad, scad, out, defines):
    cmd = [openscad, "--hardwarnings", "--export-format", "binstl", "-o", out, "-D", "$fn=48"]
    for name, value in defines.items():
        cmd += ["-D", f"{name}={value}"]
    return subprocess.run(cmd + [scad], capture_output=True, text=True)


def main():
    openscad = sys.argv[1] if len(sys.argv) > 1 else "openscad"
    failures = []

    def report(label, ok, got):
        print(f"{'ok  ' if ok else 'FAIL'} {label}: {got}")
        if not ok:
            failures.append(label)

    with tempfile.TemporaryDirectory() as tmp:
        stl = os.path.join(tmp, "case.stl")
        for s in SIZES:
            # The whole cube: the 4 bottom links float free on their pins, and
            # the supports join each other pair of cubes through its link.
            result = render(openscad, CUBE, stl, {"size": s})
            n, got = solids_and_size(stl) if result.returncode == 0 else (0, [0, 0, 0])
            want = [4 * s + 3, 2 * s + 1, s]
            report(f"size {s}: 8 pieces, {want[0]} x {want[1]} x {want[2]} mm",
                   n == 8 and all(abs(a - b) <= 0.01 for a, b in zip(got, want)),
                   f"{n} pieces, " + " x ".join(f"{v:.2f}" for v in got) + " mm")

            result = render(openscad, PROBE, stl, {"size": s, "CHECK": '"links_vs_body"'})
            free = "empty" in result.stderr.lower()
            report(f"size {s}: every link clears its channel and pins", free,
                   "no contact" if free else "a link touches the cubes or pins")

            result = render(openscad, PROBE, stl, {"size": s, "CHECK": '"links"'})
            n, _ = solids_and_size(stl) if result.returncode == 0 else (0, None)
            report(f"size {s}: no two links touch", n == 8, f"{n} separate links")

            result = render(openscad, PROBE, stl, {"size": s, "CHECK": '"pins_in_links"'})
            n, _ = solids_and_size(stl) if result.returncode == 0 and "empty" not in result.stderr.lower() else (0, None)
            report(f"size {s}: all 32 pins reach into their links", n == 32, f"{n} pins")

            # A hinge folds its two cubes 90 degrees each, bottom face to
            # bottom face, and stops there.
            turns = {}
            for a in (30, 60, 90, 120):
                result = render(openscad, PROBE, stl, {"size": s, "CHECK": '"fold"', "ANGLE": a})
                turns[a] = "empty" in result.stderr.lower()
            result = render(openscad, PROBE, stl, {"size": s, "CHECK": '"folded"', "ANGLE": 90})
            apart = "empty" in result.stderr.lower()
            report(f"size {s}: folded, a hinge's two cubes meet face to face without overlapping", apart,
                   "apart" if apart else "they overlap")
            report(f"size {s}: a hinge folds freely to 90 degrees and stops past it",
                   turns[30] and turns[60] and turns[90] and not turns[120],
                   "free to " + ", ".join(f"{a}: {'free' if f else 'blocked'}" for a, f in turns.items()))

        # Without supports nothing joins the cubes: 8 cubes and 8 links.
        result = render(openscad, CUBE, stl, {"supports": "false"})
        n, _ = solids_and_size(stl)
        report("without supports, cubes and links are all separate", n == 16, f"{n} pieces")

    print("all checks passed" if not failures else f"{len(failures)} failed")
    sys.exit(1 if failures else 0)


main()
