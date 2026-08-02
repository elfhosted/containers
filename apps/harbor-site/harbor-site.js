/*
 * harbor-site: AWS SigV4 request signing for the Backblaze B2 origin.
 *
 * The bucket `elfhosted-harbor` is allPrivate (confirmed against
 * b2_list_buckets, not assumed), and it is shared with harbor-themes' image
 * blobs, so making it public to avoid signing would change the exposure of
 * another service's data. Every request to the origin is therefore signed here.
 *
 * SCOPE, deliberately small: GET and HEAD, no query string, no request body, one
 * fixed bucket. That is the whole surface a read-only static origin needs, and
 * it is why this is ~140 lines rather than the ~1600 of nginx-s3-gateway. The
 * canonical-request construction follows the same algorithm; see
 * https://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html
 *
 * VARIABLE EVALUATION ORDER IS LOAD-BEARING. nginx evaluates the proxy_pass URL
 * (ngx_http_proxy_eval) BEFORE it builds the proxied request headers, so a
 * design where the URI variable is a by-product of computing the Authorization
 * header would read the URI before it was set. Instead each exported function is
 * independently computable from the request, and the only value that is not a
 * pure function of the request -- the timestamp -- is memoised into the
 * $harbor_ts js_var so that `date` and `auth` cannot straddle a second boundary
 * and produce a signature over a timestamp different from the one sent.
 *
 * `nocache` on the js_set directives is REQUIRED, not tidiness: the SPA fallback
 * re-enters a second location with a different $harbor_key within the same
 * request, and a cached js_set would sign the first key and fetch the second.
 */

const crypto = require("crypto");

// sha256 of the empty string. Every request here is bodiless, so the payload
// hash is this constant and never needs computing.
const EMPTY_SHA256 =
  "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";

const SIGNED_HEADERS = "host;x-amz-content-sha256;x-amz-date";

// The signing key changes only once a day, and deriving it is four HMACs. Cache
// it per worker, keyed by the date it was derived for.
let signingKeyCache = { date: null, key: null };

function env(name, fallback) {
  const v = process.env[name];
  if (v === undefined || v === "") {
    if (fallback !== undefined) return fallback;
    throw new Error("harbor-site: required environment variable " + name + " is unset");
  }
  return v;
}

// `https://s3.us-west-000.backblazeb2.com` -> `s3.us-west-000.backblazeb2.com`.
// Scheme and any explicit port are kept, because proxy_pass needs the authority
// verbatim and the Host header we sign must equal the one nginx sends.
function endpointHost() {
  const ep = env("HARBOR_S3_ENDPOINT");
  return ep.replace(/^https?:\/\//, "").replace(/\/.*$/, "");
}

// HARBOR_S3_PREFIX separates environments inside one shared bucket
// (`elfhosted.com/` in production, `ci-elfhosted.com/` on CI) and
// HARBOR_SITE_S3_SUBPREFIX separates this service's objects from
// harbor-themes' `images/` tree beneath it. An empty HARBOR_S3_PREFIX is a hard
// error for the same reason it is in harbor-themes' backend-s3.js: Flux
// substitutes an undefined variable as an empty string, so an unset variable
// would silently address the bucket root shared with production.
function keyPrefix() {
  const p = env("HARBOR_S3_PREFIX").replace(/^\/+/, "").replace(/\/+$/, "");
  const sub = env("HARBOR_SITE_S3_SUBPREFIX", "site").replace(/^\/+/, "").replace(/\/+$/, "");
  return p + "/" + sub + "/";
}

function two(n) {
  return n < 10 ? "0" + n : "" + n;
}

// YYYYMMDD'T'HHMMSS'Z', UTC.
function amzDatetime(d) {
  return (
    d.getUTCFullYear() +
    two(d.getUTCMonth() + 1) +
    two(d.getUTCDate()) +
    "T" +
    two(d.getUTCHours()) +
    two(d.getUTCMinutes()) +
    two(d.getUTCSeconds()) +
    "Z"
  );
}

// One timestamp per request, memoised in the $harbor_ts js_var. Both `date` and
// `auth` come through here, so the value signed is always the value sent.
function requestDatetime(r) {
  const memo = r.variables.harbor_ts;
  if (memo) return memo;
  const now = amzDatetime(new Date());
  r.variables.harbor_ts = now;
  return now;
}

// S3 canonical URI encoding: unreserved characters are A-Za-z0-9-_.~ and
// everything else is percent-encoded with UPPERCASE hex, path separators
// excepted. encodeURIComponent leaves !'()* alone, which S3 does not, so they
// are escaped explicitly -- getting this wrong only shows up on the handful of
// objects whose names contain them.
function encodeSegment(s) {
  return encodeURIComponent(s).replace(/[!'()*]/g, function (c) {
    return "%" + c.charCodeAt(0).toString(16).toUpperCase();
  });
}

function encodePath(p) {
  return p.split("/").map(encodeSegment).join("/");
}

// The object key for this request. $harbor_key is set per location and is the
// path BENEATH the service sub-prefix, e.g. `apex/index.html`.
function objectKey(r) {
  const k = r.variables.harbor_key || "";
  return keyPrefix() + k.replace(/^\/+/, "");
}

function signingKey(secret, date, region, service) {
  if (signingKeyCache.date === date && signingKeyCache.key) {
    return signingKeyCache.key;
  }
  const kDate = crypto.createHmac("sha256", "AWS4" + secret).update(date).digest();
  const kRegion = crypto.createHmac("sha256", kDate).update(region).digest();
  const kService = crypto.createHmac("sha256", kRegion).update(service).digest();
  const kSigning = crypto.createHmac("sha256", kService).update("aws4_request").digest();
  signingKeyCache = { date: date, key: kSigning };
  return kSigning;
}

/* ---- exported nginx variables ---- */

// Authority for proxy_pass and for proxy_ssl_name.
function host(r) {
  return endpointHost();
}

// Path-style S3 URI: /<bucket>/<encoded key>. Path style rather than
// virtual-host style because B2's S3 endpoint serves both and path style needs
// no per-bucket DNS name, so the endpoint in the ConfigMap is the only host
// anything has to reach.
function uri(r) {
  return "/" + encodeSegment(env("HARBOR_S3_BUCKET")) + "/" + encodePath(objectKey(r));
}

function date(r) {
  return requestDatetime(r);
}

function payloadHash(r) {
  return EMPTY_SHA256;
}

function auth(r) {
  const method = r.method === "HEAD" ? "HEAD" : "GET";
  const amzDate = requestDatetime(r);
  const shortDate = amzDate.substring(0, 8);
  const region = env("AWS_REGION");
  const service = "s3";
  const accessKey = env("AWS_ACCESS_KEY_ID");
  const secretKey = env("AWS_SECRET_ACCESS_KEY");
  const h = endpointHost();

  const canonicalRequest =
    method + "\n" +
    uri(r) + "\n" +
    "\n" +
    "host:" + h + "\n" +
    "x-amz-content-sha256:" + EMPTY_SHA256 + "\n" +
    "x-amz-date:" + amzDate + "\n" +
    "\n" +
    SIGNED_HEADERS + "\n" +
    EMPTY_SHA256;

  const scope = shortDate + "/" + region + "/" + service + "/aws4_request";
  const stringToSign =
    "AWS4-HMAC-SHA256\n" +
    amzDate + "\n" +
    scope + "\n" +
    crypto.createHash("sha256").update(canonicalRequest).digest("hex");

  const signature = crypto
    .createHmac("sha256", signingKey(secretKey, shortDate, region, service))
    .update(stringToSign)
    .digest("hex");

  return (
    "AWS4-HMAC-SHA256 Credential=" + accessKey + "/" + scope +
    ",SignedHeaders=" + SIGNED_HEADERS +
    ",Signature=" + signature
  );
}

export default { host, uri, date, payloadHash, auth };
