// ElfHosted shim, appended to node_modules/pg/lib/index.js at build time.
//
// Kan (packages/api/src/trpc.ts, packages/db/src/client.ts) constructs a new
// pg.Pool for every HTTP request and never ends it. Each of those pools keeps
// its connection open for pg's default 10s idle timeout, so the number of
// PostgreSQL backends tracks the request rate: a scripted session of ~2 req/s
// held ~40 connections, exhausted max_connections=20 ("sorry, too many clients
// already") and pushed the postgres sidecar past 200 MiB.
//
// This makes pg.Pool return one shared pool per distinct configuration, so the
// whole app uses a small, bounded set of connections. Pool size defaults to 5
// and can be changed with KAN_PG_POOL_MAX. Kan never calls pool.end(), so
// sharing is safe. An error listener is attached so a backend dropped by the
// server (restart, idle_session_timeout) does not surface as an
// uncaughtException.
module.exports = function sharePools(pg) {
  const BasePool = pg.Pool;
  const pools = new Map();
  const max = Number(process.env.KAN_PG_POOL_MAX) || 5;

  class SharedPool extends BasePool {
    constructor(options) {
      const key = JSON.stringify(options || {});
      const existing = pools.get(key);
      if (existing) return existing;
      super({ max, ...options });
      this.on("error", (err) => {
        console.error("pg pool: idle client error:", err && err.message);
      });
      pools.set(key, this);
    }
  }

  pg.Pool = SharedPool;
};
