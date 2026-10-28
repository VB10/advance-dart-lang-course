"""Turns every <article class="card"> of a chapter page into a one-open-at-a-time accordion."""
import re, sys

CSS = """details.card { display: block; padding: 0; }
details.card > summary { list-style: none; cursor: pointer; padding: 20px 24px; }
details.card > summary::-webkit-details-marker { display: none; }
details.card > summary::after { content: "▸"; color: var(--muted); font-size: 18px; justify-self: end; transition: transform .15s; }
details.card[open] > summary::after { transform: rotate(90deg); }
details.card[open] > summary { border-bottom: 1px solid var(--line); }
details.card > .card-b { display: grid; gap: 16px; padding: 20px 24px 24px; }
details.card > summary.card-h { grid-template-columns: auto minmax(0, 1fr) auto auto; }
@media (max-width: 720px) { details.card > summary.card-h { grid-template-columns: auto minmax(0, 1fr) auto; } details.card > summary .ref { grid-column: 2; } }
.acc-tools { margin-top: 20px; display: flex; gap: 8px; }
"""

JS = """<script>
(() => {
  const cards = [...document.querySelectorAll('details.card')];
  const openHash = () => {
    const el = location.hash && document.querySelector(location.hash);
    if (el && el.matches('details.card')) { el.open = true; el.scrollIntoView({ block: 'start' }); }
  };
  window.addEventListener('hashchange', openHash);
  openHash();
  document.querySelectorAll('.card-h .ref').forEach(a => a.addEventListener('click', e => e.stopPropagation()));
})();
</script>
"""

def convert(html: str) -> str:
    if 'details class="card"' in html:
        return html
    def card(m):
        cid, head, body = m.group(1), m.group(2), m.group(3)
        head = head.replace('<div class="card-h">', '<summary class="card-h">', 1)[:-len('</div>')] + '</summary>'
        return f'  <details class="card" id="{cid}" name="kart">\n    {head}\n    <div class="card-b">{body}</div>\n  </details>\n'
    html = re.sub(r'  <article class="card" id="([^"]+)">\n    (<div class="card-h">.*?</div>)\n(.*?)  </article>\n', card, html, flags=re.S)
    html = html.replace('</style>', CSS + '</style>', 1)
    html = html.replace('</body>', JS + '</body>') if '</body>' in html else html + JS
    return html

if __name__ == '__main__':
    for path in sys.argv[1:]:
        src = open(path).read()
        out = convert(src)
        open(path, 'w').write(out)
        print(path, out.count('<details class="card"'), 'cards')
