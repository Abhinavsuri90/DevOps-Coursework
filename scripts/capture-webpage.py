#!/usr/bin/env python3
"""Capture a real browser screenshot of a web page with headless Chrome.

Student: Abhinav

Unlike render-evidence-png.py (which draws a recorded terminal transcript),
this loads the live URL in Chrome and saves exactly what the browser renders.

Example:
  python3 scripts/capture-webpage.py http://localhost:3001 \
    docker-fundamentals/screenshots/01-nodejs-browser.png --size 1000x420
"""

import argparse
import html
import os
import subprocess
import sys
import tempfile
import time

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("url")
    parser.add_argument("out")
    parser.add_argument("--size", default="1280x800", help="WIDTHxHEIGHT of the viewport")
    parser.add_argument("--wait-ms", type=int, default=4000, help="virtual time for JavaScript to run")
    parser.add_argument("--address-bar", action="store_true",
                        help="show the URL above the page (the live page is loaded in an iframe)")
    args = parser.parse_args()

    width, height = args.size.lower().split("x")
    out_path = os.path.abspath(args.out)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    if os.path.exists(out_path):
        os.remove(out_path)

    with tempfile.TemporaryDirectory() as tmp:
        target = args.url
        if args.address_bar:
            frame = os.path.join(tmp, "frame.html")
            with open(frame, "w", encoding="utf-8") as handle:
                handle.write(
                    "<!doctype html><html><body style='margin:0;font-family:-apple-system,Helvetica,sans-serif'>"
                    "<div style='height:44px;background:#e8eaed;display:flex;align-items:center;padding:0 14px;gap:8px'>"
                    "<span style='width:12px;height:12px;border-radius:50%;background:#ff5f57'></span>"
                    "<span style='width:12px;height:12px;border-radius:50%;background:#febc2e'></span>"
                    "<span style='width:12px;height:12px;border-radius:50%;background:#28c840'></span>"
                    "<div style='margin-left:14px;flex:1;background:#fff;border-radius:16px;padding:6px 14px;"
                    f"font-size:14px;color:#202124'>{html.escape(args.url)}</div></div>"
                    f"<iframe src='{html.escape(args.url)}' style='border:0;width:100%;"
                    f"height:{int(height) - 44}px'></iframe></body></html>"
                )
            target = f"file://{frame}"
        chrome = subprocess.Popen(
            [
                CHROME, "--headless=old", "--disable-gpu", "--hide-scrollbars",
                "--force-device-scale-factor=1", f"--user-data-dir={tmp}/profile",
                f"--window-size={width},{height}", f"--virtual-time-budget={args.wait_ms}",
                f"--screenshot={out_path}", target,
            ],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        last_size, deadline = -1, time.time() + 90
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
    print(f"{args.out} <- {args.url}")


if __name__ == "__main__":
    main()
