// Runs the actual built nginx/njs image against a throwaway HTTPS origin.
// No production network destination, image push, signing key or release build.
const assert = require("node:assert/strict");
const test = require("node:test");
const http = require("node:http");
const https = require("node:https");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const { execFile } = require("node:child_process");
const { promisify } = require("node:util");
const run = promisify(execFile);
const prefix = "/experimental-edge-tests/fixture/site/";
const conditional = [
  "if-range",
  "if-none-match",
  "if-modified-since",
  "if-match",
  "if-unmodified-since",
];

function manifest() {
  const base = "https://example.test/updates/experimental/0.9.123/none/Harbor_0.9.123_";
  return {
    channel: "experimental",
    version: "0.9.123",
    buildId: "none",
    notes: "fixture only",
    platforms: { "windows-x86_64": { url: base + "x64-setup.exe", signature: "fixture" } },
    installer: {
      "windows-x86_64": {
        url: base + "x64-installer.exe",
        signature: "fixture",
        size: 10,
        payloadVersion: 9123,
      },
    },
  };
}
function fixture() {
  const state = { candidate: { status: 404, body: "<Error>fixture missing</Error>" }, seen: [] };
  const normal = new Map([
    ["updates/latest.json", '{"version":"0.9.22","channel":"stable"}'],
    ["updates/latest-beta.json", '{"version":"0.9.122","channel":"beta"}'],
    ["updates/latest-legacy.json", '{"version":"0.9.20","channel":"legacy"}'],
    ["updates/Harbor_0.9.122_x64-setup.exe", "0123456789"],
    ["updates/experimental/0.9.123/none/Harbor_0.9.123_x64-setup.exe", "0123456789"],
  ]);
  function handler(req, res) {
    state.seen.push({ method: req.method, url: req.url, headers: req.headers });
    const key = req.url.startsWith(prefix) ? req.url.slice(prefix.length) : "";
    const entry =
      key === "updates/latest-experimental.json"
        ? state.candidate
        : normal.has(key)
          ? { status: 200, body: normal.get(key) }
          : { status: 404, body: "<Error>fixture missing</Error>" };
    let status = entry.status;
    let body = Buffer.from(entry.body);
    const headers = {
      "Content-Type": key.endsWith(".json") ? "application/json" : "application/octet-stream",
      ETag: '"fixture-etag"',
      "Last-Modified": "Wed, 02 Sep 2026 00:00:00 GMT",
    };
    // Any leaked conditional is observable, even one the real origin might
    // ignore. Range returns a partial body rather than JSON.
    if (status === 200 && conditional.some((key) => req.headers[key] !== undefined)) {
      status = req.headers["if-none-match"] || req.headers["if-modified-since"] ? 304 : 412;
      body = Buffer.alloc(0);
    } else if (status === 200 && req.headers.range) {
      status = 206;
      headers["Content-Range"] = "bytes 0-3/" + body.length;
      body = body.subarray(0, 4);
    }
    headers["Content-Length"] = body.length;
    res.writeHead(status, headers);
    res.end(req.method === "HEAD" ? undefined : body);
  }
  return { state, normal, handler };
}
const listen = (server) =>
  new Promise((resolve) => server.listen(0, "127.0.0.1", () => resolve(server.address().port)));
const close = async (server) => {
  server.closeAllConnections();
  await new Promise((resolve) => server.close(resolve));
};

test("fixture origin exposes range/conditional leaks and changing feed states", async () => {
  const { state, handler } = fixture();
  const server = http.createServer(handler);
  const port = await listen(server);
  const url = "http://127.0.0.1:" + port + prefix + "updates/latest-experimental.json";
  try {
    assert.equal((await fetch(url)).status, 404);
    state.candidate = { status: 200, body: JSON.stringify(manifest()) };
    assert.deepEqual(await (await fetch(url)).json(), manifest());
    assert.equal((await fetch(url, { headers: { Range: "bytes=0-3" } })).status, 206);
    for (const key of conditional) {
      const response = await fetch(url, { headers: { [key]: "fixture" } });
      assert.ok([304, 412].includes(response.status), key);
    }
  } finally {
    await close(server);
  }
});

test(
  "running nginx/njs: both hosts and URLs, state transitions, headers and unchanged normal channels",
  {
    skip:
      process.env.HARBOR_EXPERIMENTAL_EDGE_INTEGRATION !== "1" &&
      "requires Linux Docker and the built test image",
    timeout: 180000,
  },
  async () => {
    assert.equal(
      process.platform,
      "linux",
      "this isolated runner uses Linux Docker host networking",
    );
    const temp = await fs.mkdtemp(path.join(os.tmpdir(), "harbor-experimental-edge-"));
    let container;
    let origin;
    try {
      // Ephemeral local TLS certificate only, unrelated to Harbor code signing.
      const cert = path.join(temp, "origin.crt");
      const key = path.join(temp, "origin.key");
      await run(
        "openssl",
        [
          "req",
          "-x509",
          "-newkey",
          "rsa:2048",
          "-nodes",
          "-days",
          "1",
          "-subj",
          "/CN=localhost",
          "-addext",
          "subjectAltName=DNS:localhost,DNS:127.0.0.1,IP:127.0.0.1",
          "-keyout",
          key,
          "-out",
          cert,
        ],
        { timeout: 15000 },
      );
      await fs.chmod(cert, 0o644);
      const { state, normal, handler } = fixture();
      origin = https.createServer(
        { key: await fs.readFile(key), cert: await fs.readFile(cert) },
        handler,
      );
      const port = await listen(origin);
      const launched = await run(
        "docker",
        [
          "run",
          "--detach",
          "--network",
          "host",
          "--mount",
          "type=bind,src=" + cert + ",dst=/etc/ssl/certs/ca-certificates.crt,readonly",
          "-e",
          "HARBOR_S3_ENDPOINT=https://127.0.0.1:" + port,
          "-e",
          "HARBOR_S3_BUCKET=experimental-edge-tests",
          "-e",
          "HARBOR_S3_PREFIX=fixture/",
          "-e",
          "HARBOR_SITE_S3_SUBPREFIX=site",
          "-e",
          "AWS_REGION=us-east-1",
          "-e",
          "AWS_ACCESS_KEY_ID=fixture-only",
          "-e",
          "AWS_SECRET_ACCESS_KEY=fixture-only-secret",
          "harbor-site-experimental-test",
        ],
        { timeout: 30000 },
      );
      container = launched.stdout.trim();
      assert.match(container, /^[a-f0-9]{64}$/);
      let ready = false;
      for (let attempt = 0; attempt < 40; attempt++) {
        const response = await fetch("http://127.0.0.1:8080/healthz", {
          signal: AbortSignal.timeout(1000),
        }).catch(() => null);
        if (response?.status === 200 && (await response.text()) === "ok\n") {
          ready = true;
          break;
        }
        await new Promise((resolve) => setTimeout(resolve, 250));
      }
      assert.equal(ready, true, "built image never became ready");
      assert.equal(
        (
          await run("docker", ["inspect", "--format", "{{.State.Running}}", container])
        ).stdout.trim(),
        "true",
      );
      const request = (host, url, method = "GET", headers = {}) =>
        fetch("http://127.0.0.1:8080" + url, {
          method,
          headers: { Host: host, ...headers },
          redirect: "manual",
          signal: AbortSignal.timeout(10000),
        });
      const hosts = ["harbor.site", "harbor.elfhosted.com"];
      const routes = [
        ["/updates/latest-experimental.json", {}],
        ["/updates/latest.json", { "X-Harbor-Channel": "experimental" }],
      ];
      async function checkNormal() {
        for (const host of hosts) {
          for (const [channel, filename] of [
            [null, "latest.json"],
            ["stable", "latest.json"],
            ["beta", "latest-beta.json"],
            ["legacy", "latest-legacy.json"],
            ["Experimental", "latest.json"],
          ]) {
            const headers = channel ? { "X-Harbor-Channel": channel } : {};
            const response = await request(host, "/updates/latest.json", "GET", headers);
            assert.equal(response.status, 200, host + " " + channel);
            assert.equal(await response.text(), normal.get("updates/" + filename));
            assert.equal(response.headers.get("cache-control"), "no-store");
            assert.ok(
              response.headers.get("vary").toLowerCase().split(/,\s*/).includes("x-harbor-channel"),
            );
          }
        }
      }
      await checkNormal();
      const valid = JSON.stringify(manifest());
      // Alternate good/bad/absent data through warm workers; no fallback/cache.
      for (const [status, body, expected] of [
        [404, "<Error>missing</Error>", 204],
        [200, valid, 200],
        [403, "<Error>private origin detail</Error>", 204],
        [200, JSON.stringify({ ...manifest(), withdrawn: true }), 204],
        [200, valid, 200],
        [200, '{"channel":"stable"}', 503],
        [200, "<invalid>", 503],
        [200, "x".repeat(131073), 503],
        [500, "origin failure", 503],
        [200, JSON.stringify({ ...manifest(), notes: "a".repeat(100000) }), 200],
        [404, "<Error>missing again</Error>", 204],
        [200, valid, 200],
      ]) {
        state.candidate = { status, body };
        for (const host of hosts)
          for (const [url, headers] of routes)
            for (const method of ["GET", "HEAD"]) {
              const response = await request(host, url, method, headers);
              assert.equal(
                response.status,
                expected,
                [host, url, method, status, body.length].join(" "),
              );
              assert.equal(response.headers.get("cache-control"), "no-store");
              assert.ok(
                response.headers
                  .get("vary")
                  .toLowerCase()
                  .split(/,\s*/)
                  .includes("x-harbor-channel"),
              );
              assert.equal(response.headers.get("access-control-allow-origin"), "*");
              assert.equal(await response.text(), method === "GET" && expected === 200 ? body : "");
            }
      }
      state.candidate = { status: 200, body: valid };
      for (const host of hosts)
        for (const [url, routeHeaders] of routes)
          for (const method of ["GET", "HEAD"]) {
            for (const input of [
              { Range: "bytes=0-3" },
              ...conditional.map((key) => ({ [key]: "fixture" })),
            ]) {
              const response = await request(host, url, method, {
                ...routeHeaders,
                ...input,
                Cookie: "fixture-session",
                Authorization: "Bearer client-fixture",
              });
              assert.equal(response.status, 200, JSON.stringify(input));
              assert.equal(await response.text(), method === "GET" ? valid : "");
              const fetched = state.seen.at(-1);
              assert.equal(fetched.method, "GET", "HEAD must still validate a full origin body");
              assert.equal(fetched.url, prefix + "updates/latest-experimental.json");
              for (const header of ["range", ...conditional, "cookie"])
                assert.equal(fetched.headers[header], undefined, header);
              assert.match(
                fetched.headers.authorization,
                /^AWS4-HMAC-SHA256 Credential=fixture-only\//,
              );
              assert.ok(fetched.headers["x-amz-date"]);
              assert.ok(fetched.headers["x-amz-content-sha256"]);
            }
          }
      for (const host of hosts) {
        for (const filename of [
          "updates/Harbor_0.9.122_x64-setup.exe",
          "updates/experimental/0.9.123/none/Harbor_0.9.123_x64-setup.exe",
        ]) {
          const response = await request(host, "/" + filename, "GET", { Range: "bytes=0-3" });
          assert.equal(response.status, 206, "installer range requests must still reach storage");
          assert.equal(await response.text(), "0123");
          assert.equal(response.headers.get("content-range"), "bytes 0-3/10");
        }
        const normalConditional = await request(host, "/updates/latest.json", "GET", {
          "If-None-Match": '"fixture-etag"',
        });
        assert.equal(
          normalConditional.status,
          304,
          "normal manifest conditional behavior is unchanged",
        );
        for (const url of [
          "/_harbor_experimental_manifest",
          "/updates/experimental/uploads/fixture.json",
        ]) {
          const before = state.seen.length;
          assert.equal((await request(host, url)).status, 404);
          assert.equal(state.seen.length, before, "internal/upload records must not reach storage");
        }
        for (const [url, headers] of routes)
          assert.equal((await request(host, url, "POST", headers)).status, 405);
      }
      await checkNormal();
    } catch (err) {
      if (container && /^[a-f0-9]{64}$/.test(container)) {
        const logs = await run("docker", ["logs", "--tail", "50", container], {
          timeout: 10000,
        }).catch(() => null);
        if (logs) console.error(logs.stdout + logs.stderr); // fixture-only container
      }
      throw err;
    } finally {
      try {
        if (container && /^[a-f0-9]{64}$/.test(container))
          await run("docker", ["rm", "--force", container], { timeout: 15000 });
      } finally {
        if (origin) await close(origin);
        const actual = await fs.realpath(temp);
        assert.ok(
          actual.startsWith(path.join(await fs.realpath(os.tmpdir()), "harbor-experimental-edge-")),
        );
        await fs.rm(actual, { recursive: true });
      }
    }
  },
);
