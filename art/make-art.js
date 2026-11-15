// Draws the channel's pictures into roku/images/ : the home-screen tile, the
// splash screen and the in-app logo. Needs Node, Playwright (for a browser to
// rasterise with) and, optionally, Python with Pillow to shrink the files.
//
//   node art/make-art.js
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');
const { chromium } = require('playwright');
const mark = require('./mark.js');

const root = path.resolve(__dirname, '..');
const out = path.join(root, 'roku', 'images');
const font = 'data:font/ttf;base64,' + fs.readFileSync(path.join(root, 'roku', 'fonts', 'Jersey15.ttf')).toString('base64');
const INK = '#120E1F', CREAM = '#F6EEDD', LILAC = '#A99FBF';
// one chip per colour bar on a test card
const BARS = ['#FFA630', '#FF7A9C', '#B388FF', '#64B5F6', '#00BFA5', '#B6D52A', '#F6EEDD'];

const page = (w, h, body, bg = INK) => `<!doctype html><style>
  @font-face { font-family: J; src: url(${font}); }
  html, body { margin: 0; width: ${w}px; height: ${h}px; background: ${bg}; overflow: hidden; }
  text { font-family: J; }
</style><svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" shape-rendering="crispEdges">${body}</svg>`;

const chips = (cx, y, size, gap) => BARS.map((c, i) =>
  `<rect x="${cx - (BARS.length * (size + gap) - gap) / 2 + i * (size + gap)}" y="${y}" width="${size}" height="${size}" fill="${c}"/>`).join('');

const word = (cx, baseline, size, fill = CREAM, text = 'MEOWBOX', spacing = 0.04) =>
  `<text x="${cx}" y="${baseline}" font-size="${size}" fill="${fill}" text-anchor="middle" letter-spacing="${size * spacing}">${text}</text>`;

// home-screen tile: the mark, the name, a row of colour chips
function tile(w, h, s) {
  const mw = mark.W * s, mh = mark.H * s;
  const top = Math.round(h * 0.11);
  return page(w, h,
    mark.svg(s, Math.round((w - mw) / 2), top) +
    word(w / 2, top + mh + Math.round(h * 0.215), Math.round(h * 0.21)) +
    chips(w / 2, h - Math.round(h * 0.085), Math.round(h * 0.03), Math.round(h * 0.022)));
}

// splash: laid out to sit exactly where the app's first card puts the same
// things (see showMessage in MainScene.brs), so start-up does not jump. u is
// screen pixels per layout unit: 1 at 1280x720, 1.5 at 1920x1080.
function splash(u) {
  const w = 1280 * u, h = 720 * u;
  return page(w, h,
    `<rect width="${w}" height="${8 * u}" fill="#FFA630"/>` +
    mark.svg(8 * u, 520 * u, 170 * u) +
    word(w / 2, 452 * u, 60 * u, CREAM, 'MEOWBOX', 0) +
    chips(w / 2, 500 * u, 10 * u, 8 * u));
}

const logo = () => `<!doctype html><style>html,body{margin:0;background:transparent}</style>
  <svg width="${mark.W * 16}" height="${mark.H * 16}" shape-rendering="crispEdges">${mark.svg(16)}</svg>`;

(async () => {
  const browser = await chromium.launch();
  const shots = [
    ['icon_focus_hd.png', 290, 218, tile(290, 218, 5), false],
    ['icon_focus_fhd.png', 540, 405, tile(540, 405, 9), false],
    ['splash_hd.png', 1280, 720, splash(1), false],
    ['splash_fhd.png', 1920, 1080, splash(1.5), false],
    ['logo.png', mark.W * 16, mark.H * 16, logo(), true],
  ];
  for (const [name, w, h, html, clear] of shots) {
    const p = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
    await p.setContent(html);
    await p.evaluate(() => document.fonts.ready);
    await p.screenshot({ path: path.join(out, name), omitBackground: clear });
    await p.close();
  }
  await browser.close();
  // smooth the lettering's edges down to a few shades, so the files pack small
  try {
    execFileSync('python3', ['-c', `
import sys
from PIL import Image
for f in sys.argv[1:]:
    im = Image.open(f)
    # fewer distinct colours pack smaller; saved as plain RGB(A), the kind every Roku reads
    if im.mode == 'RGBA' and im.getextrema()[3][0] < 255:
        pass
    else:
        im = im.convert('RGB').quantize(colors=48, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert('RGB')
    im.save(f, optimize=True)
`, ...shots.map(s => path.join(out, s[0]))]);
  } catch (e) { console.warn('left unshrunk (Pillow not found)'); }
  for (const s of shots) console.log(s[0], fs.statSync(path.join(out, s[0])).size, 'bytes');
})();
