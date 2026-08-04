'use strict';

// Minimal placeholder frontend for the multicloud-gitops demo.
// Zero external dependencies on purpose -- uses Node's built-in http
// server and global fetch (Node 18+) to call the backend.
//
// Swap this out for your real frontend app whenever you have one; the
// Dockerfile, port, and env vars it reads are all the contract the rest
// of the repo (k8s-manifests/frontend/*, app-ci.yml) expects.

const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 8080;
const BACKEND_API_URL = process.env.BACKEND_API_URL || 'http://backend.workloads.svc.cluster.local:8080';
const HOSTNAME = os.hostname();

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[c]));
}

function renderPage({ backendReachable, backendBody, error }) {
  const backendSection = backendReachable
    ? `<p>Backend says: <strong>${escapeHtml(JSON.stringify(backendBody))}</strong></p>`
    : `<p style="color:#b00020">Backend unreachable right now (${escapeHtml(error || 'unknown error')}). ` +
      `The frontend itself is still healthy -- this page is intentionally resilient to a downstream outage.</p>`;

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>multicloud-gitops demo</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
           max-width: 640px; margin: 3rem auto; padding: 0 1rem; color: #1a1a1a; }
    code { background: #f0f0f0; padding: 0.15rem 0.35rem; border-radius: 3px; }
    small { color: #666; }
  </style>
</head>
<body>
  <h1>multicloud-gitops demo</h1>
  <p>Served by frontend pod <code>${escapeHtml(HOSTNAME)}</code>.</p>
  ${backendSection}
  <p><small>This is a minimal placeholder app -- swap it for the real frontend when you have one.</small></p>
</body>
</html>`;
}

const server = http.createServer(async (req, res) => {
  if (req.url === '/') {
    try {
      const backendRes = await fetch(`${BACKEND_API_URL}/api/count`, {
        signal: AbortSignal.timeout(3000),
      });
      if (!backendRes.ok) {
        throw new Error(`backend responded ${backendRes.status}`);
      }
      const backendBody = await backendRes.json();
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(renderPage({ backendReachable: true, backendBody }));
    } catch (err) {
      // Deliberate: the readiness/liveness probe hits "/", so a backend
      // outage must never make the frontend itself report unhealthy.
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(renderPage({ backendReachable: false, error: err.message }));
    }
    return;
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('not found');
});

server.listen(PORT, () => {
  console.log(`frontend listening on :${PORT}, backend=${BACKEND_API_URL}`);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server');
  server.close(() => process.exit(0));
});
