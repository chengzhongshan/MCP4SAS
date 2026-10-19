#!/usr/bin/env node
'use strict';
// Standard MCP newline JSON transport, with an owned loopback-only Perl backend.
// Does not generate SAS, alter SAS results, or open/read authentication files.
const fs = require('node:fs');
const path = require('node:path');
const net = require('node:net');
const http = require('node:http');
const readline = require('node:readline');
const cp = require('node:child_process');
const core = require('./core');
let child;
function cleanup() { if (child && child.exitCode === null) child.kill(); }
process.on('exit', cleanup);
process.on('SIGTERM', () => process.exit(0));
process.on('SIGINT', () => process.exit(0));
function post(port, message, timeout = 180000) {
  return new Promise((resolve, reject) => {
    const req = http.request({ hostname: '127.0.0.1', port, path: '/mcp', method: 'POST', headers: { 'Content-Type': 'application/json' } }, res => {
      let body = '';
      res.setEncoding('utf8');
      res.on('data', b => { body += b; if (body.length > 64 * 1024 * 1024) req.destroy(new Error('MCP response exceeds 64 MiB')); });
      res.on('end', () => {
        if (res.statusCode !== 200) return reject(new Error(`Backend HTTP ${res.statusCode}`));
        try { resolve(JSON.parse(body)); } catch { reject(new Error('Backend returned invalid JSON')); }
      });
    });
    req.setTimeout(timeout, () => req.destroy(new Error('MCP request timed out; a SAS job may still be running.')));
    req.on('error', reject); req.end(JSON.stringify(message));
  });
}
async function freePort() {
  return new Promise((resolve, reject) => {
    const socket = net.createServer(); socket.once('error', reject);
    socket.listen(0, '127.0.0.1', () => { const port = socket.address().port; socket.close(() => resolve(port)); });
  });
}
async function start(config) {
  core.assertRepo(config.repo);
  if (!fs.statSync(config.cwd).isDirectory()) throw new Error('Project folder is not a directory.');
  const env = await core.runtimeEnvironment(config);
  const script = await core.toPosix(path.join(config.repo, 'server.pl'), config.perl);
  const port = await freePort();
  child = cp.spawn(config.perl, [script, 'daemon', '-m', 'production', '-l', `http://127.0.0.1:${port}`], { cwd: config.cwd, env, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
  // All diagnostics go to stderr. stdout is reserved exclusively for MCP JSON.
  child.stdout.pipe(process.stderr, { end: false }); child.stderr.pipe(process.stderr, { end: false });
  let failure; child.on('error', e => { failure = e; });
  const until = Date.now() + 45000;
  while (Date.now() < until) {
    if (failure) throw failure;
    if (child.exitCode !== null) throw new Error('MCP4SAS exited during startup. Run Quick Setup or inspect the MCP output.');
    try {
      const response = await post(port, { jsonrpc: '2.0', id: 'readiness', method: 'tools/list' }, 1500);
      if (Array.isArray(response.result?.tools) && child.exitCode === null) return port;
    } catch { /* Wait for our own server; never attach to an existing fixed port. */ }
    await new Promise(r => setTimeout(r, 150));
  }
  throw new Error('MCP4SAS did not become ready within 45 seconds.');
}
async function main() {
  const i = process.argv.indexOf('--config');
  if (i < 0 || !process.argv[i + 1]) throw new Error('Usage: relay.js --config /absolute/runtime.json');
  const config = JSON.parse(fs.readFileSync(process.argv[i + 1], 'utf8'));
  // Subscribe before startup so a client's EOF cannot leave a stray backend.
  const lines = readline.createInterface({ input: process.stdin, crlfDelay: Infinity });
  const iterator = lines[Symbol.asyncIterator]();
  const port = await start(config);
  // Processing is serialized because the original HTTP server owns ordered sessions.
  for await (const line of { [Symbol.asyncIterator]: () => iterator }) {
    let request;
    try { request = JSON.parse(line); if (!request || Array.isArray(request) || request.jsonrpc !== '2.0' || typeof request.method !== 'string') throw new Error(); }
    catch { process.stdout.write(JSON.stringify({ jsonrpc: '2.0', id: null, error: { code: -32700, message: 'Invalid JSON-RPC request' } }) + '\n'); continue; }
    const hasId = Object.hasOwn(request, 'id');
    try {
      const response = await post(port, request);
      if (!hasId) continue; // Pinned server returns bodies for notifications; never emit those.
      if (response.id !== request.id) throw new Error('MCP response ID mismatch');
      process.stdout.write(JSON.stringify(response) + '\n');
    } catch (e) {
      if (hasId) process.stdout.write(JSON.stringify({ jsonrpc: '2.0', id: request.id, error: { code: -32603, message: e.message } }) + '\n');
      else process.stderr.write('MCP4SAS notification failed.\n');
    }
  }
}
if (require.main === module) main().then(() => process.exit(0)).catch(e => { process.stderr.write(`MCP4SAS: ${e.message}\n`); process.exit(1); });
module.exports = { post, freePort };
