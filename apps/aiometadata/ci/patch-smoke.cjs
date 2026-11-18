#!/usr/bin/env node
/*
 * Patch smoke test for the aiometadata image.
 *
 * Runs in the builder stage after `npm run build` and `npm run build:backend`
 * and asserts that each patch reached the compiled output (dist/server and
 * dist/client), not merely that `git apply` exited 0. Each check names the
 * patch it covers by its number.
 *
 * Usage: node patch-smoke.cjs [APP_ROOT]   (APP_ROOT defaults to cwd)
 */
'use strict';

const fs = require('fs');
const path = require('path');

const APP_ROOT = path.resolve(process.argv[2] || process.cwd());
const DIST = path.join(APP_ROOT, 'dist', 'server');
const CLIENT = path.join(APP_ROOT, 'dist', 'client');

const failures = [];

function read(relPath) {
  const full = path.join(DIST, relPath);
  if (!fs.existsSync(full)) {
    failures.push(`missing compiled file: dist/server/${relPath}`);
    return null;
  }
  return fs.readFileSync(full, 'utf8');
}

// Assert `needle` (string or RegExp) appears in dist/server/<relPath>.
function expect(patch, relPath, needle, note) {
  const content = read(relPath);
  if (content === null) return;
  const found = needle instanceof RegExp ? needle.test(content) : content.includes(needle);
  if (!found) {
    const shown = needle instanceof RegExp ? needle.toString() : JSON.stringify(needle);
    failures.push(`[${patch}] dist/server/${relPath} is missing ${shown}${note ? ` (${note})` : ''}`);
  }
}

function expectAll(patch, relPath, needles, note) {
  for (const needle of needles) expect(patch, relPath, needle, note);
}

const walkJs = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
  e.isDirectory() ? walkJs(path.join(dir, e.name)) : e.name.endsWith('.js') ? [path.join(dir, e.name)] : []);

// 04: env-tunable TMDB timeout and retries.
expectAll('04', 'lib/getTmdb.js', ['TMDB_REQUEST_TIMEOUT_MS', 'TMDB_MAX_RETRIES']);

// 05: each client consumes its parsed value. Number.isInteger guards against a
// NaN timeout from a non-numeric value.
const timeoutWiring = [
  ['lib/anilist.js', ['Number.isInteger', "providerEnvInt('ANILIST_REQUEST_TIMEOUT_MS', 5000, 1000)", "providerEnvInt('ANILIST_MAX_RETRIES', 2, 1)", 'timeout: ANILIST_REQUEST_TIMEOUT_MS', 'retries = ANILIST_MAX_RETRIES']],
  ['lib/anilistTracker.js', ['Number.isInteger', "providerEnvInt('ANILIST_TRACKER_REQUEST_TIMEOUT_MS', 5000, 1000)", "providerEnvInt('ANILIST_TRACKER_MAX_RETRIES', 2, 1)", 'timeout: REQUEST_TIMEOUT_MS', 'maxRetries = MAX_RETRIES']],
  ['lib/imdb.js', ['Number.isInteger', "providerEnvInt('IMDB_REQUEST_TIMEOUT_MS', 5000, 1000)", 'timeout: IMDB_REQUEST_TIMEOUT_MS']],
  ['lib/mal.js', ['Number.isInteger', "providerEnvInt('JIKAN_REQUEST_TIMEOUT_MS', 5000, 1000)", 'timeout: JIKAN_REQUEST_TIMEOUT_MS']],
  ['lib/tvdb.js', ['Number.isInteger', "providerEnvInt('TVDB_MAX_RETRIES', 2, 1)", 'maxRetries = TVDB_MAX_RETRIES']],
  ['lib/tvmaze.js', ['Number.isInteger', "providerEnvInt('TVMAZE_REQUEST_TIMEOUT_MS', 5000, 1000)", "providerEnvInt('TVMAZE_MAX_RETRIES', 2, 1)", 'timeout: DEFAULT_TIMEOUT', 'retries = MAX_RETRIES']],
  ['utils/letterboxdUtils.js', ['Number.isInteger', "providerEnvInt('LETTERBOXD_REQUEST_TIMEOUT_MS', 5000, 1000)", "providerEnvInt('LETTERBOXD_MAX_RETRIES', 2, 1)", 'timeout: LETTERBOXD_REQUEST_TIMEOUT_MS', 'maxRetries: LETTERBOXD_MAX_RETRIES']],
  ['utils/mdbList.js', ['Number.isInteger', "providerEnvInt('MDBLIST_REQUEST_TIMEOUT_MS', 5000, 1000)", "providerEnvInt('MDBLIST_MAX_RETRIES', 2, 1)", 'timeout: MDBLIST_REQUEST_TIMEOUT_MS', 'maxRetries: MDBLIST_MAX_RETRIES']],
  ['utils/traktUtils.js', ['Number.isInteger', "providerEnvInt('TRAKT_REQUEST_TIMEOUT_MS', 5000, 1000)", "providerEnvInt('TRAKT_MAX_RETRIES', 2, 1)", 'timeout: TRAKT_REQUEST_TIMEOUT_MS', 'retries = TRAKT_MAX_RETRIES']],
];
for (const [relPath, needles] of timeoutWiring) {
  expectAll('05', relPath, needles, 'parsed value must be wired into the compiled client');
}
{
  const src = read('lib/anilist.js');
  if (src !== null && /timeout:\s*\d{4,}/.test(src)) {
    failures.push('[05] lib/anilist.js still has a hardcoded request timeout');
  }
}

// 06: trending and TVDB remote-id lookups are cached.
expect('06', 'lib/getTmdb.js', 'tmdb:trending:');
expect('06', 'lib/tvdb.js', 'remoteid:imdb:');

// 08: resolveAllIds is called with the normalised type.
expect('08', 'lib/getMeta.js', /resolveAllIds\(stremioId,\s*finalType,/);

// 09: the cleanup lock is held under the process's hostname.
expect('09', 'cache-cleanup.js', 'HOSTNAME');

// 11: every provider base URL is read from the environment and used. A
// declaration alone is one occurrence; two prove it feeds a request URL (or,
// for FANART_API_BASE, the client options). TVmaze assigns its base to the
// TVMAZE_API_URL alias, so that is asserted directly.
const API_BASE_VARS = [
  'TRAKT_API_BASE', 'MDBLIST_API_BASE', 'ANILIST_API_BASE', 'TMDB_API_BASE', 'TVDB_API_BASE',
  'TVMAZE_API_BASE', 'CINEMETA_API_BASE', 'CINEMETA_LIVE_API_BASE', 'FANART_API_BASE',
  'KITSU_API_BASE', 'SIMKL_API_BASE', 'SIMKL_DATA_BASE', 'PUBLICMETADB_API_BASE',
];
if (fs.existsSync(DIST)) {
  const occurrences = new Map(API_BASE_VARS.map((v) => [v, 0]));
  for (const file of walkJs(DIST)) {
    const text = fs.readFileSync(file, 'utf8');
    for (const v of API_BASE_VARS) occurrences.set(v, occurrences.get(v) + text.split(v).length - 1);
  }
  expectAll('11', 'lib/tvmaze.js', [
    'TVMAZE_API_URL = process.env.TVMAZE_API_BASE',
    '${TVMAZE_API_URL}/',
  ], 'TVMAZE_API_BASE must feed constructed request URLs');
  const unwired = API_BASE_VARS.filter((v) => occurrences.get(v) < (v === 'TVMAZE_API_BASE' ? 1 : 2));
  if (unwired.length) {
    failures.push(`[11] base URL wiring absent from compiled backend: ${unwired.map((v) => `${v} (${occurrences.get(v)})`).join(', ')}`);
  }
} else {
  failures.push(`missing dist/server - did build:backend run? (looked in ${DIST})`);
}

// 11, negative and repo-wide: no compiled string literal names these hosts
// except as the default on the right of `process.env.X || '...'`. Parsed with
// TypeScript, so comments cannot hide or fake a hit. Trakt is absent on
// purpose: authenticated Trakt calls go to Trakt directly (patch 20).
// publicmetadb.com (a user's own key) is out of scope, so only its api. host.
{
  const HOSTS = [
    [/https:\/\/api\.(mdblist|simkl)\.com/, '11'],
    [/https:\/\/data\.simkl\.in/, '11'],
    [/https:\/\/api\.publicmetadb\.com/, '11'],
    [/https:\/\/v3\.sg\.media-imdb\.com/, '28'],
  ];
  let ts = null;
  try { ts = require(path.join(APP_ROOT, 'node_modules', 'typescript')); } catch (_) { /* reported below */ }
  const isEnvDefault = (node) => {
    let child = node;
    while (child.parent && ts.isParenthesizedExpression(child.parent)) child = child.parent;
    const p = child.parent;
    return !!p && ts.isBinaryExpression(p) && p.operatorToken.kind === ts.SyntaxKind.BarBarToken &&
      p.right === child && ts.isPropertyAccessExpression(p.left) &&
      ts.isPropertyAccessExpression(p.left.expression) && p.left.expression.getText() === 'process.env';
  };
  if (!ts) {
    failures.push('[11] typescript not found under node_modules - cannot scan for hardcoded provider hosts');
  } else if (fs.existsSync(DIST)) {
    for (const file of walkJs(DIST)) {
      const sf = ts.createSourceFile(file, fs.readFileSync(file, 'utf8'), ts.ScriptTarget.Latest, true, ts.ScriptKind.JS);
      const visit = (node) => {
        const isText = ts.isStringLiteral(node) || ts.isNoSubstitutionTemplateLiteral(node) ||
          node.kind === ts.SyntaxKind.TemplateHead || node.kind === ts.SyntaxKind.TemplateMiddle || node.kind === ts.SyntaxKind.TemplateTail;
        for (const [HOST, patch] of HOSTS) {
          if (isText && HOST.test(node.text) && !isEnvDefault(node)) {
            const line = sf.getLineAndCharacterOfPosition(node.getStart(sf)).line + 1;
            failures.push(`[${patch}] ${path.relative(APP_ROOT, file)}:${line} calls ${node.text.match(HOST)[0]} directly - route it through its base URL setting`);
          }
        }
        ts.forEachChild(node, visit);
      };
      visit(sf);
    }
  }
}

// 13: rotating file log.
expect('13', 'lib/logBuffer.js', 'AIOMETADATA_LOG_FILE');

// 14: TTL for TMDB detail responses.
expect('14', 'lib/getTmdb.js', 'TMDB_DETAIL_TTL');

// 15: wildcard and whole-keyspace cache clears are guarded.
expect('15', 'index.js', 'ALLOW_UNSCOPED_CACHE_CLEAR');
expect('15', 'lib/dashboardApi.js', 'unscopedClearRefusal');

// 17: list and catalog fetches carry the caller's freshness.
expectAll('17', 'utils/mdbList.js', ['function freshnessHeaders(', 'freshnessHeaders(opts.ttl)']);

// 18: the settings API withholds a sensitive value that came from the
// environment, and the placeholder cannot be written back.
expectAll('18', 'lib/settingsService.js', [
  /value:\s*envBackedSecret\s*\?\s*exports\.WITHHELD_SECRET\s*:\s*currentValue/,
  /def\.sensitive\s*&&\s*value === exports\.WITHHELD_SECRET/,
], 'sensitive env-backed settings must be withheld, and the placeholder unwritable');

// 19: Trakt device flow, its auth host, and the single-exchange claim.
expectAll('19', 'lib/trakt.js', ['auth.trakt.tv', 'urn:ietf:wg:oauth:2.0:oob', '/oauth/device/code', '/oauth/device/token']);
expectAll('19', 'index.js', ['/api/auth/trakt/device', 'resolveTraktAuthMode', 'claimDeviceAuthExchange', 'completeDeviceAuthSession', 'renewDeviceAuthClaim']);
expectAll('19', 'lib/deviceAuth.js', ['claim:', 'redis.call', 'deviceAuthCallerRateLimit', 'redeemed']);

// 20: a request carrying an Authorization header goes to Trakt itself.
expectAll('20', 'utils/traktTransport.js', ['TRAKT_DIRECT_BASE_URL', 'carriesCredentials', "=== 'authorization'", 'TRAKT_CONFIGURED_BASE_URL']);
expect('20', 'utils/traktUtils.js', 'traktTransport', 'traktUtils must use the Trakt transport');
expect('20', 'lib/trakt.js', 'traktTransport', 'TraktClient must use the Trakt transport');

// 21: /api/config reports whether Trakt and Simkl are configured, not their ids.
expectAll('21', 'index.js', [
  "hasTrakt: !!getSetting('TRAKT_CLIENT_ID')",
  "hasSimkl: !!(getSetting('SIMKL_CLIENT_ID') || getSetting('SIMKL_V2_CLIENT_ID'))",
]);
{
  const src = read('index.js');
  if (src !== null && /\btrakt:\s*getSetting\('TRAKT_CLIENT_ID'\)/.test(src)) {
    failures.push('[21] /api/config still serves TRAKT_CLIENT_ID');
  }
}

// 22: built-in-key calls can go to the operator's endpoint, directly, and no
// grounded prompt or web-search pass is sent there.
expectAll('22', 'utils/gemini-client.js', ['BUILT_IN_AI_BASE_URL', 'BUILT_IN_AI_MODEL', 'isBuiltInAiCall']);
expect('22', 'utils/openrouter-client.js', 'getDirectDispatcher', 'endpoint calls must bypass any configured proxy');
expect('22', 'utils/openrouter-client.js', /baseUrl\s*\|\|\s*\(0, ai_endpoint_1\.aiEndpointBase\)\(\)/, 'an explicit endpoint must take precedence over OPENROUTER_BASE_URL');
expect('22', 'utils/gemini-service.js', 'isBuiltInAiCall(apiKey)');
expect('22', 'utils/recommendations/provider.js', 'builtInGateway');
expect('22', 'lib/getSearch.js', 'isBuiltInAiCall(process.env.BUILT_IN_GEMINI_API_KEY');

// 24: the configure page hides the model pickers when the endpoint chooses the
// model. Each dialog is found by its datalist id and checked for its own label.
expect('24', 'index.js', 'hasBuiltInAiGateway');
if (!fs.existsSync(CLIENT)) {
  failures.push(`[24] ${CLIENT} missing - the configure UI was not built`);
} else {
  const bundle = walkJs(CLIENT).map((f) => fs.readFileSync(f, 'utf8'));
  const dialogs = [
    ['AI catalog', 'ai-catalog-openrouter-models', 'AI catalog model chosen by this instance'],
    ['recommendations', 'recommendation-openrouter-models', 'Recommendation model chosen by this instance'],
  ];
  for (const [name, datalistId, needle] of dialogs) {
    const chunks = bundle.filter((src) => src.includes(datalistId));
    if (!chunks.length) {
      failures.push(`[24] no chunk holds the ${name} dialog (${datalistId}) - upstream renamed it, this check needs rewriting`);
    } else if (!chunks.some((src) => src.includes(needle))) {
      failures.push(`[24] the ${name} dialog has no built-in AI branch`);
    }
  }
  if (!bundle.some((src) => /\(!!\w+\.hasBuiltInAiGateway\)/.test(src))) {
    failures.push('[24] the configure page never reads hasBuiltInAiGateway from /api/config');
  }
}

// 26: saved MDBList list URLs are sent through MDBLIST_API_BASE, with freshness.
expectAll('26', 'utils/mdbList.js', ['function viaMdblistBase(', 'new URL(viaMdblistBase(baseUrl))']);
{
  const src = read('utils/mdbList.js');
  if (src !== null && !/headers: freshnessHeaders\(opts\.ttl\) \}\),\s*opts\.apiKey,\s*`MDBList fetchCursorBlock/.test(src)) {
    failures.push('[26] fetchCursorBlock sends no freshness headers');
  }
}

// 28: the IMDb suggestion host is read from the environment.
expect('28', 'utils/imdbSuggestions.js', 'IMDB_SUGGESTION_BASE');

// 29: calls through a configured base URL are recorded as the tracker's.
expectAll('29', 'utils/trackerCalls.js', ['PROXIED_TRACKER_BASES', 'SIMKL_API_BASE', 'MDBLIST_API_BASE']);

// 30: one MovieLens re-sync pass per interval across replicas.
expectAll('30', 'lib/movielensSync.js', ['movielens-sync:run-claim', 'claimSyncPass', 'releaseSyncPass']);

// 31: proxy trust and the client address header are read from the environment.
expectAll('31', 'index.js', ['process.env.TRUST_PROXY', 'process.env.CLIENT_IP_HEADER', "'trust proxy fn'"]);

if (failures.length) {
  console.error(`patch smoke FAILED (${failures.length} problem(s)):`);
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}

console.log('patch smoke passed: all patched features present in the compiled output');
