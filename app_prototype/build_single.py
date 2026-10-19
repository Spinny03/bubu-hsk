#!/usr/bin/env python3
"""Crea Bubu_prototipo.html: il prototipo in un solo file (CSS, dati, script e tratti inclusi)."""
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
read = lambda p: open(os.path.join(HERE, p), encoding='utf-8').read()
html = read('index.html')
strokes = {os.path.basename(f)[:-5]: json.load(open(f, encoding='utf-8'))
           for f in glob.glob(os.path.join(HERE, 'vendor', 'hanzi', '*.json'))}
html = html.replace('<link rel="stylesheet" href="styles.css">', '<style>\n' + read('styles.css') + '\n</style>')
html = html.replace('<script src="data.js"></script>', '<script>\n' + read('data.js') + '\nwindow.HANZI_DATA = '
                    + json.dumps(strokes, ensure_ascii=False, separators=(',', ':')) + ';\n</script>')
html = html.replace('<script src="vendor/hanzi-writer.min.js"></script>',
                    '<script>\n' + read('vendor/hanzi-writer.min.js') + '\n</script>')
html = html.replace('<script src="app.js"></script>', '<script>\n' + read('app.js') + '\n</script>')
out = os.path.join(os.path.dirname(HERE), 'Bubu_prototipo.html')
open(out, 'w', encoding='utf-8').write(html)
print(out, f'{os.path.getsize(out) / 1e6:.1f} MB')
