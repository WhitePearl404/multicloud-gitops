'use strict';

// Minimal placeholder backend for the multicloud-gitops demo.
// Reads REDIS_HOST / REDIS_PORT / REDIS_PASSWORD exactly as
// k8s-manifests/backend/deployment.yaml sets them, so it works
// unmodified once deployed.

const http = require('http');
const os = require('os');
const { createClient } = require('redis');

const PORT = process.env.PORT || 8080;
const REDIS_HOST = process.env.REDIS_HOST || 'redis.workloads.svc.cluster.local';
const REDIS_PORT = Number(process.env.REDIS_PORT || 6379);
const REDIS_PASSWORD = process.env.REDIS_PASSWORD || undefined;
const HOSTNAME = os.hostname();

const redisClient = createClient({
  socket: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    // Gentle, unbounded backoff -- never gives up trying to reconnect,
    // since Redis or the backend pod may simply start in either order.
    reconnectStrategy: (retries) => Math.min(retries * 200, 5000),
  },
  password: REDIS_PASSWORD,
});

// A Redis outage must never crash this process -- log it and keep
// serving /healthz so Kubernetes doesn't restart an otherwise-fine pod.
redisClient.on('error', (err) => {
  console.error('[redis] connection error:', err.message);
});

redisClient.connect().catch((err) => {
  console.error('[redis] initial connect failed, will keep retrying in background:', err.message);
});

function sendJson(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(body));
}

const server = http.createServer(async (req, res) => {
  if (req.url === '/healthz') {
    // Liveness/readiness: "is this process alive and able to respond?"
    // Deliberately does NOT depend on Redis -- a Redis blip should not
    // take otherwise-healthy backend pods out of the load balancer.
    sendJson(res, 200, { status: 'ok', hostname: HOSTNAME });
    return;
  }

  if (req.url === '/api/count') {
    if (!redisClient.isReady) {
      sendJson(res, 503, { error: 'redis unavailable', hostname: HOSTNAME });
      return;
    }
    try {
      const count = await redisClient.incr('multicloud-gitops:visits');
      sendJson(res, 200, { count, hostname: HOSTNAME, redisHost: REDIS_HOST });
    } catch (err) {
      sendJson(res, 503, { error: err.message, hostname: HOSTNAME });
    }
    return;
  }

  if (req.url === '/') {
    sendJson(res, 200, {
      service: 'multicloud-gitops-backend',
      hostname: HOSTNAME,
      endpoints: ['/healthz', '/api/count'],
    });
    return;
  }

  sendJson(res, 404, { error: 'not found' });
});

server.listen(PORT, () => {
  console.log(`backend listening on :${PORT}, redis=${REDIS_HOST}:${REDIS_PORT}`);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server');
  server.close(async () => {
    await redisClient.quit().catch(() => {});
    process.exit(0);
  });
});
