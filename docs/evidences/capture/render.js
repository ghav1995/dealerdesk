// Draws each saved screen as a terminal image, with a headless browser.
//
//   node docs/evidences/capture/render.js
//
// The text comes straight from transcripts/, so nothing in an image is typed by hand.
// The only addition is a highlight on the lines named in transcripts/index.tsv.
// Set BROWSER to use Chrome or Chromium instead of Edge.
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

const folder = path.join(__dirname, "..");
const transcripts = path.join(folder, "transcripts");
const images = path.join(folder, "images");
const browser = process.env.BROWSER ||
    "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe";

const COLUMNS = 92;
const CHAR_WIDTH = 8.25;
const LINE_HEIGHT = 19;
const PADDING = 16;

const escape = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function page(text, mark) {
    const lines = text.replace(/\s+$/, "").split("\n");
    const body = lines
        .map((line) => {
            const marked = mark.test(line);
            return `<div class="${marked ? "line mark" : "line"}">${escape(line) || " "}</div>`;
        })
        .join("");
    return {
        rows: lines.length,
        html: `<!doctype html><html><head><meta charset="utf-8"><style>
html, body { margin: 0; background: #16181d; }
body { padding: ${PADDING}px; }
.line { font: 15px/${LINE_HEIGHT}px Consolas, "Cascadia Mono", "DejaVu Sans Mono", monospace;
        color: #d7dae0; white-space: pre; height: ${LINE_HEIGHT}px; }
.mark { background: #3b3413; color: #ffe27a; font-weight: 700; }
</style></head><body>${body}</body></html>`,
    };
}

fs.mkdirSync(images, { recursive: true });
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "evidence-"));
const entries = fs.readFileSync(path.join(transcripts, "index.tsv"), "utf8").trim().split("\n");

for (const entry of entries) {
    const [name, mark] = entry.split("\t");
    const text = fs.readFileSync(path.join(transcripts, name + ".txt"), "utf8");
    const { rows, html } = page(text, new RegExp(mark));
    const htmlFile = path.join(scratch, name + ".html");
    fs.writeFileSync(htmlFile, html);

    const width = Math.ceil(COLUMNS * CHAR_WIDTH) + PADDING * 2;
    const height = rows * LINE_HEIGHT + PADDING * 2;
    execFileSync(browser, [
        "--headless=new",
        "--disable-gpu",
        "--hide-scrollbars",
        "--force-device-scale-factor=2",
        `--window-size=${width},${height}`,
        `--user-data-dir=${path.join(scratch, "profile")}`,
        `--screenshot=${path.join(images, name + ".png")}`,
        "file:///" + htmlFile.replace(/\\/g, "/"),
    ], { stdio: "ignore", timeout: 60000 });
    console.log("drawn", name);
}
fs.rmSync(scratch, { recursive: true, force: true });
