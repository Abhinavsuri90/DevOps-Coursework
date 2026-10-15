#!/usr/bin/env node
// Capture a single-page app that keeps a request open (e.g. Argo CD's event stream).
//
// Student: Abhinav
//
// capture-webpage.py uses Chrome's --virtual-time-budget, which never finishes while a
// streaming request is open. This script drives headless Chrome over the DevTools protocol
// instead: load the page, wait in real time, then save a screenshot of what is rendered.
//
// Usage: node scripts/capture-spa.mjs <url> <out.png> [WIDTHxHEIGHT] [wait-ms]
//   node scripts/capture-spa.mjs http://localhost:8081/applications/argocd/gitops-demo shot.png 1440x860 9000

import { spawn } from "node:child_process";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";

const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const [url, out, size = "1440x900", waitArg = "8000"] = process.argv.slice(2);
if (!url || !out) {
  console.error("usage: node scripts/capture-spa.mjs <url> <out.png> [WIDTHxHEIGHT] [wait-ms]");
  process.exit(2);
}
const [width, height] = size.toLowerCase().split("x").map(Number);
const waitMs = Number(waitArg);
const port = 9300 + Math.floor(Math.random() * 600);
const profile = mkdtempSync(join(tmpdir(), "capture-spa-"));
const sleep = (ms) => new Promise((done) => setTimeout(done, ms));

const chrome = spawn(CHROME, [
  "--headless=old", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
  `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`,
  `--window-size=${width},${height}`, "about:blank",
], { stdio: "ignore" });

async function pageSocketUrl() {
  for (let attempt = 0; attempt < 50; attempt += 1) {
    try {
      const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
      const page = targets.find((t) => t.type === "page");
      if (page) return page.webSocketDebuggerUrl;
    } catch {
      // Chrome is still starting.
    }
    await sleep(200);
  }
  throw new Error("Chrome DevTools endpoint did not come up");
}

try {
  const socket = new WebSocket(await pageSocketUrl());
  await new Promise((ready, fail) => { socket.onopen = ready; socket.onerror = fail; });
  let nextId = 0;
  const pending = new Map();
  socket.onmessage = (event) => {
    const message = JSON.parse(event.data);
    if (message.id && pending.has(message.id)) {
      pending.get(message.id)(message);
      pending.delete(message.id);
    }
  };
  const send = (method, params = {}) => new Promise((done) => {
    nextId += 1;
    pending.set(nextId, done);
    socket.send(JSON.stringify({ id: nextId, method, params }));
  });

  await send("Emulation.setDeviceMetricsOverride", { width, height, deviceScaleFactor: 1, mobile: false });
  await send("Page.enable");
  await send("Page.navigate", { url });
  await sleep(waitMs);
  const shot = await send("Page.captureScreenshot", { format: "png" });
  if (!shot.result?.data) throw new Error(`screenshot failed: ${JSON.stringify(shot.error ?? shot)}`);
  const outPath = resolve(out);
  mkdirSync(dirname(outPath), { recursive: true });
  writeFileSync(outPath, Buffer.from(shot.result.data, "base64"));
  console.log(`${out} <- ${url}`);
  socket.close();
} finally {
  chrome.kill();
  await sleep(300);
  rmSync(profile, { recursive: true, force: true });
}
