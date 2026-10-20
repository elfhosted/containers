// Holds connections on one port until a target port accepts, then joins them.
// Usage: node hold.js HOLD_PORT TARGET_PORT READY_FILE
'use strict';
const net = require('net');
const fs = require('fs');

const [holdPort, targetPort] = [Number(process.argv[2]), Number(process.argv[3])];
const readyFile = process.argv[4];
const GIVE_UP_MS = 30000;
const RETRY_MS = 50;
const DRAIN_MAX_MS = 10 * 60 * 1000;

const server = net.createServer({ allowHalfOpen: true }, client => {
  client.pause();
  client.on('error', () => {});
  const started = Date.now();
  const attempt = () => {
    if (client.destroyed) return;
    const upstream = net.connect({ port: targetPort, host: '127.0.0.1', allowHalfOpen: true });
    upstream.once('error', () => {
      upstream.destroy();
      if (Date.now() - started > GIVE_UP_MS) return client.destroy();
      setTimeout(attempt, RETRY_MS);
    });
    upstream.once('connect', () => {
      upstream.removeAllListeners('error');
      upstream.on('error', () => client.destroy());
      client.on('error', () => upstream.destroy());
      client.pipe(upstream);
      upstream.pipe(client);
      client.resume();
    });
  };
  attempt();
});

server.listen(holdPort, '127.0.0.1', () => fs.writeFileSync(readyFile, 'ready'));

process.on('SIGTERM', () => {
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(0), DRAIN_MAX_MS).unref();
});
