// The Meowbox mark: a television with ears. Drawn on a small grid so it stays
// crisp at any whole-number scale, the same way the channels' logos are.
//
// Letters: m marmalade, h highlight, d shade, k ink, s screen glow,
//          c cream, p pink, "." see-through.
const W = 30, H = 25;
const COLORS = { m: '#FFA630', h: '#FFC56E', d: '#D9781A', k: '#120E1F', s: '#2B2147', c: '#F6EEDD', p: '#FF7A9C' };

function grid() {
  const g = Array.from({ length: H }, () => Array(W).fill('.'));
  const put = (x, y, t) => { if (x >= 0 && x < W && y >= 0 && y < H) g[y][x] = t; };
  const box = (x0, y0, x1, y1, t) => { for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) put(x, y, t); };

  // ears: stepped triangles, pink inside
  for (const [ax, dir] of [[4, 1], [25, -1]]) {
    const span = (a, b, y, t) => { for (let i = a; i <= b; i++) put(ax + dir * i, y, t); };
    span(0, 1, 1, 'm'); span(-1, 2, 2, 'm'); span(-2, 3, 3, 'm'); span(-2, 4, 4, 'm'); span(-2, 5, 5, 'm');
    put(ax, 1, 'h');
    span(0, 1, 3, 'p'); span(0, 2, 4, 'p');
  }
  // the set
  box(2, 6, 27, 21, 'm');
  box(3, 5, 26, 5, 'm'); box(3, 22, 26, 22, 'd');
  box(1, 7, 1, 20, 'm'); box(28, 7, 28, 20, 'd');
  box(2, 21, 27, 21, 'd'); box(27, 8, 27, 21, 'd');
  box(7, 5, 22, 5, 'h');
  // tabby stripes between the ears
  for (const x of [12, 15, 18]) { put(x, 5, 'd'); put(x, 6, 'd'); }
  put(15, 7, 'd');
  // screen
  box(4, 9, 20, 19, 'k'); box(5, 8, 19, 8, 'k'); box(5, 20, 19, 20, 'k');
  box(5, 9, 6, 9, 's'); put(5, 10, 's');
  // :3
  box(8, 11, 9, 13, 'c'); box(15, 11, 16, 13, 'c');
  put(12, 14, 'p');
  for (const [x, y] of [[9, 16], [10, 17], [11, 17], [12, 16], [13, 17], [14, 17], [15, 16]]) put(x, y, 'c');
  put(12, 15, 'c');
  // knobs and speaker
  box(23, 9, 25, 11, 'k'); put(24, 10, 'c');
  box(23, 13, 25, 15, 'k'); put(24, 14, 'c');
  box(23, 17, 25, 17, 'd'); box(23, 19, 25, 19, 'd');
  // feet
  box(5, 23, 8, 23, 'd'); box(21, 23, 24, 23, 'd');
  return g.map(r => r.join(''));
}

function svg(scale = 1, x = 0, y = 0) {
  const rows = grid();
  let out = '';
  rows.forEach((row, ry) => {
    for (let i = 0; i < row.length;) {
      const t = row[i]; let j = i + 1;
      while (j < row.length && row[j] === t) j++;
      if (t !== '.') out += `<rect x="${x + i * scale}" y="${y + ry * scale}" width="${(j - i) * scale}" height="${scale}" fill="${COLORS[t]}"/>`;
      i = j;
    }
  });
  return out;
}

module.exports = { W, H, COLORS, grid, svg };
if (require.main === module) {
  const s = 16;
  require('fs').writeFileSync(process.argv[2] || 'mark-preview.html',
    `<body style="margin:0;background:#120E1F"><svg width="${W * s + 64}" height="${H * s + 64}" shape-rendering="crispEdges">${svg(s, 32, 32)}</svg>
     <svg width="200" height="140" shape-rendering="crispEdges" style="background:#F6EEDD">${svg(3, 30, 30)}</svg><svg width="200" height="140" shape-rendering="crispEdges">${svg(2, 30, 30)}</svg></body>`);
}
