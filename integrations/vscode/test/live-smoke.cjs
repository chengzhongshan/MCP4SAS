// Optional real-server/SAS check. Keeps raw records at the caller's chosen path.
// Usage: node test/live-smoke.cjs /private/runtime.json /private/capture.json [--sas]
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const cp = require('node:child_process');
const rl = require('node:readline');
const records = [], waiters = new Map();
const child = cp.spawn(process.env.MCP4SAS_NODE || process.execPath, [path.resolve(__dirname, '../src/relay.js'), '--config', path.resolve(process.argv[2])], { env: { ...process.env, ELECTRON_RUN_AS_NODE: '1' }, windowsHide: true });
let diagnostics = '', id = 0;
child.stderr.on('data', b => { diagnostics += b; });
child.on('error', e => { for (const p of waiters.values()) p.reject(e); });
child.on('exit', code => { for (const p of waiters.values()) p.reject(new Error(`Relay exited ${code}: ${diagnostics}`)); });
const lines = rl.createInterface({ input: child.stdout });
lines.on('line', line => {
  let message;
  try { message = JSON.parse(line); } catch { throw new Error('Non-JSON emitted on MCP stdout'); }
  records.push({ received: message });
  const p = waiters.get(message.id); assert.ok(p, 'No unsolicited notification response');
  waiters.delete(message.id); clearTimeout(p.timer);
  if (message.error) p.reject(new Error(message.error.message)); else p.resolve(message.result);
});
function request(method, params) {
  const message = { jsonrpc: '2.0', id: ++id, method, params };
  records.push({ sent: message });
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`Timeout ${method}`)), 210000);
    waiters.set(id, { resolve, reject, timer }); child.stdin.write(JSON.stringify(message) + '\n');
  });
}
const text = r => (r.content || []).map(c => c.text || '').join('\n');
async function sas(code, finalPattern, expectedState) {
  let result = await request('tools/call', { name: 'run_sas_codes_or_files_in_ODA', arguments: { sas_codes_or_file: code, saspy_cfgname: 'oda', persistent: 'false' } });
  const pid = text(result).match(/^PID:\s*(\d+)/m);
  const until = Date.now() + 240000;
  while (!/^STATUS: (?:COMPLETE|FAILED)/m.test(text(result)) && Date.now() < until) {
    assert.ok(pid, 'started result has the actual schema PID');
    await new Promise(r => setTimeout(r, 30000));
    result = await request('tools/call', { name: 'run_sas_codes_or_files_in_ODA', arguments: { pid: Number(pid[1]) } });
  }
  assert.match(text(result), new RegExp(`STATUS: ${expectedState}`)); assert.match(text(result), finalPattern);
  return result;
}
(async () => {
  const init = await request('initialize', { protocolVersion: '2024-11-05', capabilities: {}, clientInfo: { name: 'mcp4sas-extension-live-check', version: '0.1.0' } });
  assert.equal(init.serverInfo.name, 'MCP4SAS');
  const notify = { jsonrpc: '2.0', method: 'notifications/initialized' }; records.push({ sent: notify }); child.stdin.write(JSON.stringify(notify) + '\n');
  const tools = await request('tools/list'); assert.ok(tools.tools.some(t => t.name === 'run_sas_codes_or_files_in_ODA'));
  if (process.argv.includes('--sas')) {
    await sas('proc means data=sashelp.class noprint; var Age; output out=work.editor_check n=known nmiss=absent min=youngest max=oldest; run; data _null_; set work.editor_check; put "EDITOR_CHECK: " known= absent= youngest= oldest=; run;', /EDITOR_CHECK: known=19 absent=0 youngest=11 oldest=16/, 'COMPLETE');
    await sas('proc print data=work.editor_intentionally_absent; run;', /ERROR: File WORK\.EDITOR_INTENTIONALLY_ABSENT\.DATA does not exist\./, 'FAILED');
  }
  const closed = new Promise(resolve => child.once('exit', resolve));
  child.stdin.end(); assert.equal(await closed, 0);
  fs.writeFileSync(process.argv[3], JSON.stringify({ records, diagnostics, scope: 'Real stdio relay, original MCP4SAS HTTP server; SAS positive/negative only if --sas was supplied. Not an interactive AI model turn.' }, null, 2));
  console.log(`PASS: initialize, notification suppression, tools/list, clean relay EOF${process.argv.includes('--sas') ? ', actual SAS positive and negative' : ''}`);
})().catch(e => { fs.writeFileSync(process.argv[3], JSON.stringify({ error: e.message, records, diagnostics }, null, 2)); child.kill(); console.error(e); process.exitCode = 1; }).finally(() => { for (const p of waiters.values()) clearTimeout(p.timer); });
