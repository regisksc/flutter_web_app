#!/usr/bin/env python3
# Tiny redirect server: serves build/web statics AND is the real Bitly-like backend.
# stdlib only. State lives in .redirect_state.json. 302 redirects count a click.
import json, threading, time, random, string, os, re
from urllib.parse import urlparse, parse_qs
import http.server, socketserver

PORT = int(os.environ.get('REDIRECT_PORT', '8877'))
HERE = os.path.dirname(os.path.abspath(__file__))
WEB = os.path.join(HERE, '..', 'build', 'web')
STATE = os.path.join(HERE, '..', '.redirect_state.json')
RESERVED = {'api', 'admin', 'links', 'health', 'go', 'assets', 'icons', 'canvaskit'}
CODE_PATH = re.compile(r'^/([A-Za-z0-9_-]{3,20})$')
LOCK = threading.Lock()
state = {'links': []}  # each: {code, long_url, short_url, alias, created_at, clicks}

def load():
    global state
    if os.path.isfile(STATE):
        state = json.load(open(STATE))

def save():
    with open(STATE, 'w') as f:
        json.dump(state, f)

def base62_7():
    alphabet = string.ascii_letters + string.digits
    return ''.join(random.choice(alphabet) for _ in range(7))

def pinned_base():
    # Optional: .public_base_url (gitignored) or PUBLIC_BASE_URL pins the shared host so a link
    # made through localhost is never a localhost link.
    env = os.environ.get('PUBLIC_BASE_URL')
    if env:
        return env.rstrip('/')
    path = os.path.join(HERE, '..', '.public_base_url')
    if os.path.isfile(path):
        return open(path).read().strip().rstrip('/')
    return None

def public_base(handler):
    # Pinned host if configured, else built per request from the host the caller used; never stored.
    pinned = pinned_base()
    if pinned:
        return pinned
    host = handler.headers.get('X-Forwarded-Host') or handler.headers.get('Host', 'localhost:' + str(PORT))
    local = host.startswith(('127.', 'localhost', '[::1]'))
    scheme = handler.headers.get('X-Forwarded-Proto') or ('http' if local else 'https')
    return '{}://{}'.format(scheme, host)

def view(link, base):
    out = {k: v for k, v in link.items() if k != 'short_url'}
    out['short_url'] = '{}/{}'.format(base, link['code'])
    return out

def find(pred):
    return next((l for l in state['links'] if pred(l)), None)

def page(items, cursor, limit):
    ordered = sorted(items, key=lambda l: l['created_at'], reverse=True)
    chunk = ordered[cursor:cursor + limit]
    nxt = cursor + limit if cursor + limit < len(ordered) else None
    return chunk, nxt

class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def _send(self, code, body, ctype='application/json'):
        data = body if isinstance(body, bytes) else json.dumps(body).encode()
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        u = urlparse(self.path)
        p = u.path
        m = CODE_PATH.match(p)
        if p.startswith('/go/') or (m and find(lambda l: l['code'] == m.group(1))):
            code = p[len('/go/'):] if p.startswith('/go/') else m.group(1)
            with LOCK:
                link = find(lambda l: l['code'] == code)
                if link is None:
                    return self._send(404, {'error': 'not_found'})
                link['clicks'] += 1
                save()
            self.send_response(302)
            self.send_header('Location', link['long_url'])
            self.send_header('Cache-Control', 'no-store')
            self.send_header('Content-Length', '0')
            self.end_headers()
        elif p == '/api/links':
            q = parse_qs(u.query)
            cursor = int(q.get('cursor', ['0'])[0])
            limit = int(q.get('limit', ['10'])[0])
            with LOCK:
                page_items, nxt = page(state['links'], cursor, limit)
            base = public_base(self)
            return self._send(200, {'items': [view(i, base) for i in page_items], 'next_cursor': nxt})
        elif p.startswith('/api/links/'):
            code = p[len('/api/links/'):]
            with LOCK:
                link = find(lambda l: l['code'] == code)
            return self._send(200, view(link, public_base(self))) if link else self._send(404, {'error': 'not_found'})
        else:
            self._static(p)

    def _static(self, p):
        base = os.path.abspath(WEB)
        rel = 'index.html' if p == '/' else p.lstrip('/')
        full = os.path.normpath(os.path.join(base, rel))
        if not full.startswith(base) or not os.path.isfile(full):
            return self._send(404, {'error': 'no_file'})
        ctype = 'text/html' if rel.endswith('.html') else 'application/javascript' if rel.endswith('.js') else 'text/plain'
        with open(full, 'rb') as f:
            data = f.read()
        self._send(200, data, ctype)

    def do_POST(self):
        if self.path != '/api/shorten':
            return self._send(404, {'error': 'not_found'})
        n = int(self.headers.get('Content-Length', '0'))
        try:
            req = json.loads(self.rfile.read(n) or b'{}')
        except ValueError:
            return self._send(400, {'error': 'invalid_json'})
        long_url = str(req.get('long_url') or '').strip()
        alias = (req.get('alias') or '').strip() or None
        if not long_url.startswith(('http://', 'https://')) or len(long_url) > 2048 or not urlparse(long_url).netloc:
            return self._send(400, {'error': 'URL must start with http:// or https://'})
        if alias and (len(alias) < 3 or len(alias) > 20 or not set(alias) <= set(string.ascii_letters + string.digits + '_-') or alias.lower() in RESERVED):
            return self._send(400, {'error': 'Alias must be 3-20 letters, digits, - or _, and not reserved'})
        with LOCK:
            if alias and find(lambda l: l['code'] == alias):
                return self._send(409, {'error': 'Alias already taken'})
            code = None
            for _ in range(5):
                candidate = alias or base62_7()
                if not find(lambda l: l['code'] == candidate):
                    code = candidate
                    break
            if code is None:
                return self._send(500, {'error': 'no_code'})
            link = {'code': code, 'long_url': long_url, 'alias': alias, 'created_at': time.time(), 'clicks': 0}
            state['links'].append(link)
            save()
        return self._send(200, view(link, public_base(self)))

load()
socketserver.ThreadingTCPServer.allow_reuse_address = True
socketserver.ThreadingTCPServer(('127.0.0.1', PORT), H).serve_forever()