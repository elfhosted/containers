// Equivalent of upstream's /app/bootstrap.cjs. Upstream require()s the ESM
// server.js, which needs Node >= 20.19; Alpine's nodejs package is older, so we
// use a dynamic import instead.
//
// 1. Regenerate public/__ENV.js with the runtime NEXT_PUBLIC_* variables
//    (next-runtime-env). The file is symlinked to /tmp for read-only rootfs.
// 2. Start the Next.js standalone server.
import { writeFileSync } from "node:fs";

const envVars = {};
for (const [key, value] of Object.entries(process.env)) {
  if (key.startsWith("NEXT_PUBLIC_")) envVars[key] = value;
}
writeFileSync("/tmp/__ENV.js", `self.__ENV = ${JSON.stringify(envVars)};`);

await import("/app/apps/web/server.js");
