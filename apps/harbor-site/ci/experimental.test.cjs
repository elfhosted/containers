const assert = require('node:assert/strict');
const test = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const root = path.join(__dirname, '..');
const source = fs.readFileSync(path.join(root, 'harbor-experimental.js'), 'utf8');
const handler = new Function(source.replace('export default', 'return'))();
function manifest() {
  const base = 'https://example.test/updates/experimental/0.9.123/abc/Harbor_0.9.123_';
  return {
    channel: 'experimental', version: '0.9.123', buildId: 'abc',
    platforms: { 'windows-x86_64': { url: base + 'x64-setup.exe', signature: 'test' } },
    installer: { 'windows-x86_64': { url: base + 'x64-installer.exe', signature: 'test', size: 10, payloadVersion: 9123 } },
  };
}
async function request(reply, method = 'GET') {
  const calls = [];
  const r = {
    method, headersOut: {},
    subrequest: async (uri, options) => { calls.push([uri, options]); return reply; },
    return(status, body) { this.status = status; this.body = body; },
  };
  await handler.latest(r);
  assert.equal(r.headersOut['Cache-Control'], 'no-store');
  assert.equal(r.headersOut.Vary, 'X-Harbor-Channel');
  assert.equal(r.headersOut['Access-Control-Allow-Origin'], '*');
  return { r, calls };
}
test('verified candidate is served unchanged for GET and HEAD', async () => {
  const body = JSON.stringify(manifest());
  for (const method of ['GET', 'HEAD']) {
    const { r, calls } = await request({ status: 200, responseText: body }, method);
    assert.equal(r.status, 200);
    assert.equal(r.body, body);
    assert.deepEqual(calls, [['/_harbor_experimental_manifest', { method: 'GET' }]]);
  }
});
test('missing and withdrawn feeds return 204, never stable or beta', async () => {
  for (const status of [204, 403, 404]) assert.equal((await request({ status })).r.status, 204);
  assert.equal((await request({ status: 200, responseText: JSON.stringify({ ...manifest(), withdrawn: true }) })).r.status, 204);
});
test('malformed data, wrong channels, platforms, namespace, signatures and origin errors fail closed', async () => {
  const bad = [
    { ...manifest(), channel: 'stable' }, { ...manifest(), channel: 'beta' },
    { ...manifest(), version: '0.9.123-preview' }, { ...manifest(), buildId: '../abc' },
    { ...manifest(), platforms: {} }, { ...manifest(), installer: undefined },
    { ...manifest(), url: 'https://example.test/wrong.exe' },
  ];
  const cross = manifest();
  cross.platforms['windows-x86_64'].url = 'https://example.test/updates/Harbor_0.9.123_x64-setup.exe';
  bad.push(cross);
  const unsigned = manifest();
  unsigned.platforms['windows-x86_64'].signature = '';
  bad.push(unsigned);
  for (const m of bad) assert.equal((await request({ status: 200, responseText: JSON.stringify(m) })).r.status, 503);
  for (const responseText of ['<Error>storage details</Error>', 'null', '', 'x'.repeat(131073)]) {
    const { r } = await request({ status: 200, responseText });
    assert.equal(r.status, 503);
    assert.equal(r.body, undefined);
  }
  assert.equal((await request({ status: 500 })).r.status, 503);
});
test('state is not shared between warm requests or after withdrawal', async () => {
  for (let i = 0; i < 3; i++) {
    assert.equal((await request({ status: 200, responseText: JSON.stringify(manifest()) })).r.status, 200);
    assert.equal((await request({ status: 404 })).r.status, 204);
    assert.equal((await request({ status: 200, responseText: '{"channel":"stable"}' })).r.status, 503);
  }
});
test('write methods never contact storage', async () => {
  const { r, calls } = await request({ status: 200 }, 'POST');
  assert.equal(r.status, 405);
  assert.deepEqual(calls, []);
});
test('nginx preserves the original channel map, native URL and artifact proxy; experimental is isolated', () => {
  const config = fs.readFileSync(path.join(root, 'harbor-site.conf'), 'utf8');
  const updates = fs.readFileSync(path.join(root, 'harbor-updates.conf'), 'utf8');
  const map = config.match(/map \$http_x_harbor_channel \$harbor_chan \{[^}]+}/)[0];
  assert.deepEqual(map.match(/^\s+(?:default|"[^"]+")\s+"[^"]*";/gm).map(s => s.trim().replace(/\s+/g, ' ')),
    ['default "";', '"beta" "-beta";', '"legacy" "-legacy";']);
  assert.match(config, /"~\^experimental\$"\s+1;/);
  assert.match(updates, /if \(\$harbor_is_experimental\) \{ return 418; }/);
  assert.ok(updates.includes('set $harbor_key "updates/latest${harbor_chan}.json";'));
  assert.match(updates, /location = \/updates\/latest-experimental.json \{\s+subrequest_output_buffer_size 128k;\s+js_content experimental.latest;/);
  assert.match(updates, /location \^~ \/updates\/experimental\/uploads\//);
  assert.match(updates, /location \^~ \/updates\/ \{\s+set \$harbor_key "updates\/\$harbor_updates_path";/);
  assert.equal((config.match(/include \/etc\/nginx\/snippets\/harbor-updates.conf;/g) || []).length, 2);
});

test('only the internal experimental manifest fetch strips client range and conditional headers', () => {
  const updates = fs.readFileSync(path.join(root, 'harbor-updates.conf'), 'utf8');
  const internal = updates.match(/location = \/_harbor_experimental_manifest \{[^}]+}/)[0];
  assert.match(internal, /proxy_pass_request_headers off;/);
  assert.equal((updates.match(/proxy_pass_request_headers off;/g) || []).length, 1);
  assert.ok(internal.includes('include /etc/nginx/snippets/harbor-origin.conf;'), 'explicit origin signing headers remain');
});
