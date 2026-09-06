// Only the experimental request reaches this handler. Normal update channels
// continue through their original nginx proxy, without parsing or rewriting.
function record(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function validManifest(m) {
  if (!record(m) || m.channel !== "experimental" || m.withdrawn === true ||
      "url" in m || "signature" in m || typeof m.version !== "string" ||
      !/^(0|[1-9]\d*)\.(0|[1-9]\d{0,2})\.(0|[1-9]\d{0,2})$/.test(m.version) ||
      typeof m.buildId !== "string" || !/^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$/.test(m.buildId) ||
      m.buildId.indexOf("..") !== -1 || !record(m.platforms)) return false;
  const parts = m.version.split(".").map(Number);
  const payload = parts[0] * 1000000 + parts[1] * 1000 + parts[2];
  if (!Number.isSafeInteger(payload)) return false;
  const root = "/updates/experimental/" + m.version + "/" + m.buildId + "/Harbor_" + m.version + "_";
  function artifact(entry, tail) {
    if (!record(entry) || typeof entry.signature !== "string" ||
        !entry.signature.trim() || entry.signature.length > 8192 || typeof entry.url !== "string") return false;
    const match = /^https:\/\/[A-Za-z0-9.-]+(?::[0-9]{1,5})?(\/.*)$/.exec(entry.url);
    return !!match && match[1] === root + tail;
  }
  const names = Object.keys(m.platforms);
  if (!names.length || names.length > 2) return false;
  // Indexed loop, not for...of: njs rejects `of` outright ("Token \"of\" not
  // supported in this version"), so the module would not load and nginx would
  // refuse to start. The existing harbor-site.js uses no for...of either.
  for (var i = 0; i < names.length; i++) {
    var name = names[i];
    if (name === "windows-x86_64") {
      if (!artifact(m.platforms[name], "x64-setup.exe") || !record(m.installer)) return false;
      const setup = m.installer[name];
      if (!artifact(setup, "x64-installer.exe") || setup.payloadVersion !== payload ||
          !Number.isSafeInteger(setup.size) || setup.size <= 0) return false;
    } else if (name === "darwin-aarch64") {
      if (!artifact(m.platforms[name], "aarch64.app.tar.gz")) return false;
    } else return false;
  }
  if (m.installer !== undefined &&
      (!record(m.installer) || Object.keys(m.installer).some(function (k) { return k !== "windows-x86_64"; }) ||
       !m.platforms["windows-x86_64"])) return false;
  return true;
}

async function latest(r) {
  r.headersOut["Cache-Control"] = "no-store";
  r.headersOut["Vary"] = "X-Harbor-Channel";
  r.headersOut["Access-Control-Allow-Origin"] = "*";
  r.headersOut["X-Content-Type-Options"] = "nosniff";
  r.headersOut["X-Frame-Options"] = "DENY";
  if (r.method !== "GET" && r.method !== "HEAD") { r.return(405); return; }
  try {
    // Fixed internal URI and key. No request input can select an object or host.
    // GET even for a client HEAD: validation needs the actual manifest body.
    const reply = await r.subrequest("/_harbor_experimental_manifest", { method: "GET" });
    if (reply.status === 204 || reply.status === 403 || reply.status === 404) { r.return(204); return; }
    if (reply.status !== 200 || !reply.responseText || reply.responseText.length > 131072) { r.return(503); return; }
    const manifest = JSON.parse(reply.responseText);
    if (record(manifest) && manifest.channel === "experimental" && manifest.withdrawn === true) { r.return(204); return; }
    if (!validManifest(manifest)) { r.return(503); return; }
    r.headersOut["Content-Type"] = "application/json; charset=utf-8";
    r.return(200, reply.responseText);
  } catch (e) {
    // Named binding, not optional catch: njs rejects `catch {` ("Token \"{\"
    // not supported in this version") and the module then fails to load.
    // No origin XML, storage identifiers, or stable fallback on a failed read.
    r.return(503);
  }
}

export default { latest, validManifest };
