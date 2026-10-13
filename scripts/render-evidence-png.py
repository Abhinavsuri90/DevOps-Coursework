#!/usr/bin/env python3
"""Render lines of a recorded transcript as a terminal-style PNG.

Student: Abhinav

The PNGs in the screenshots/ folders are made with this script from the real
command output saved in evidence/*.txt. Each image names its source file and
line range in the footer, so it can be checked against the transcript.

Example:
  python3 scripts/render-evidence-png.py \
    --source session-13-storage-hpa-probes/evidence/hpa.txt --lines 1-40 \
    --title "Session 13 · HPA scale-out" \
    --out session-13-storage-hpa-probes/screenshots/04-hpa-scale-out.png
"""

import argparse
import html
import math
import os
import subprocess
import sys
import tempfile
import time

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
FONT_PX = 18
LINE_PX = 29
CHAR_PX = 10.84  # Menlo advance width at 18px
PAD_X = 26
HEADER_PX = 60
TOP_PX = 18
FOOTER_PX = 56
MIN_W, MAX_W = 1000, 2400


def parse_ranges(spec, total):
    if not spec:
        return [(1, total)]
    ranges = []
    for part in spec.split(","):
        start, _, end = part.partition("-")
        start = int(start)
        end = int(end) if end else start
        if start < 1 or end > total or start > end:
            sys.exit(f"line range {part} is outside 1-{total}")
        ranges.append((start, end))
    return ranges


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, help="transcript path relative to the repo root")
    parser.add_argument("--lines", help="ranges such as 1-20 or 1-10,30-42 (default: whole file)")
    parser.add_argument("--title", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    source = os.path.join(repo_root, args.source)
    with open(source, encoding="utf-8") as handle:
        all_lines = handle.read().splitlines()

    ranges = parse_ranges(args.lines, len(all_lines))
    rows = []
    for index, (start, end) in enumerate(ranges):
        if index:
            rows.append(("gap", "⋮"))
        for line in all_lines[start - 1:end]:
            kind = "cmd" if line.startswith("$ ") else "note" if line.startswith("# ") else "out"
            rows.append((kind, line.expandtabs(8)))

    longest = max((len(text) for _, text in rows), default=40)
    width = int(min(MAX_W, max(MIN_W, longest * CHAR_PX + 2 * PAD_X + 20)))
    chars_per_row = max(1, int((width - 2 * PAD_X - 20) / CHAR_PX))
    visual_rows = sum(max(1, math.ceil(len(text) / chars_per_row)) for _, text in rows)
    height = HEADER_PX + TOP_PX + visual_rows * LINE_PX + FOOTER_PX

    range_text = ", ".join(f"{s}–{e}" if s != e else f"{s}" for s, e in ranges)
    footer = f"Rendered from recorded command output · {args.source} lines {range_text}"
    body = "\n".join(
        f'<div class="{kind}">{html.escape(text) or "&nbsp;"}</div>' for kind, text in rows
    )
    page = f"""<!doctype html><html><head><meta charset="utf-8"><style>
html,body{{margin:0;background:#0d1117;}}
.win{{width:{width}px;height:{height}px;background:#0d1117;font-family:Menlo,"SF Mono",monospace;}}
.bar{{height:{HEADER_PX}px;background:#1f242c;display:flex;align-items:center;padding-left:26px;gap:10px;}}
.dot{{width:15px;height:15px;border-radius:50%;display:inline-block;}}
.title{{color:#e6edf3;font-size:21px;margin-left:16px;letter-spacing:.5px;}}
.body{{padding:{TOP_PX}px {PAD_X}px 0 {PAD_X}px;font-size:{FONT_PX}px;line-height:{LINE_PX}px;}}
.body div{{white-space:pre-wrap;word-break:break-all;}}
.out{{color:#e6edf3;}} .cmd{{color:#7ee787;}} .note{{color:#8b949e;font-style:italic;}} .gap{{color:#6e7681;}}
.foot{{position:absolute;top:{height - 40}px;left:{PAD_X}px;color:#8b949e;font-size:14px;font-family:Menlo,monospace;}}
</style></head><body><div class="win"><div class="bar">
<span class="dot" style="background:#ff5f57"></span><span class="dot" style="background:#febc2e"></span>
<span class="dot" style="background:#28c840"></span><span class="title">{html.escape(args.title)}</span></div>
<div class="body">{body}</div><div class="foot">{html.escape(footer)}</div></div></body></html>"""

    out_path = os.path.abspath(args.out)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    if os.path.exists(out_path):
        os.remove(out_path)
    with tempfile.TemporaryDirectory() as tmp:
        page_path = os.path.join(tmp, "page.html")
        with open(page_path, "w", encoding="utf-8") as handle:
            handle.write(page)
        # Headless Chrome can stay alive after writing the screenshot, so stop
        # it once the PNG exists and its size has settled.
        chrome = subprocess.Popen(
            [
                CHROME, "--headless=old", "--disable-gpu", "--hide-scrollbars",
                "--force-device-scale-factor=1", f"--user-data-dir={tmp}/profile",
                f"--window-size={width},{height}", f"--screenshot={out_path}",
                f"file://{page_path}",
            ],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        last_size, deadline = -1, time.time() + 60
        while time.time() < deadline:
            if chrome.poll() is not None:
                break
            size = os.path.getsize(out_path) if os.path.exists(out_path) else -1
            if size > 0 and size == last_size:
                break
            last_size = size
            time.sleep(0.5)
        chrome.terminate()
        try:
            chrome.wait(timeout=10)
        except subprocess.TimeoutExpired:
            chrome.kill()
    if not os.path.exists(out_path):
        sys.exit(f"Chrome did not write {args.out}")
    print(f"{args.out} ({width}x{height}) <- {args.source} lines {range_text}")


if __name__ == "__main__":
    main()
