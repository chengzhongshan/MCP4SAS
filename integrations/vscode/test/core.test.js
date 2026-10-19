'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const c = require('../src/core');
const launch = c.launcher('C:\\A folder\\runtime.json', 'C:\\A folder\\relay.js', 'C:\\Code\\Code.exe');
test('platform installers select the actual repository entry points', () => {
  for (const p of ['win32', 'linux', 'darwin']) assert.ok(fs.existsSync(path.join(__dirname, '../../..', 'install', c.platformInstaller(p))));
  assert.throws(() => c.platformInstaller('freebsd'));
});
test('Codex paths, Unicode and backslashes survive TOML', () => {
  const l = { ...launch, args: [...launch.args, '/tmp/张/π'] };
  const parsed = require('@iarna/toml').parse(c.mergeCodex('', l));
  assert.deepEqual(parsed.mcp_servers.mcp4sas_vscode.args, l.args);
  assert.equal(parsed.mcp_servers.mcp4sas_vscode.command, l.command);
});
test('unrelated comments, tables and server configuration are retained byte for byte', () => {
  const original = '# my preferences\nmodel = "something"\n[mcp_servers.existing]\ncommand="other"\n[projects."/x"]\ntrust_level="trusted"\n';
  assert.ok(c.mergeCodex(original, launch).startsWith(original));
});
test('Connect is idempotent and can update only its managed launcher', () => {
  const once = c.mergeCodex('', launch);
  assert.equal(c.mergeCodex(once, launch), once);
  const changed = c.mergeCodex(once + '\n[tools]\nweb_search=true\n', { ...launch, command: '/new/node' });
  assert.equal(require('@iarna/toml').parse(changed).tools.web_search, true);
});
test('unmanaged plain, quoted, dotted, inline or duplicate entries are refused', () => {
  for (const text of ['[mcp_servers.mcp4sas_vscode]\ncommand="mine"', '[mcp_servers."mcp4sas_vscode"]\ncommand="mine"', '[mcp_servers]\nmcp4sas_vscode.command="mine"', 'mcp_servers={mcp4sas_vscode={command="mine"}}', '[mcp_servers.x]\ncommand="x"\ncommand="y"']) assert.throws(() => c.mergeCodex(text, launch));
});
test('invalid TOML and incomplete managed blocks never get repaired silently', () => {
  for (const text of ['model="unterminated', c.BEGIN + '\n', c.END, c.BEGIN + '\n' + c.BEGIN + '\n' + c.END]) assert.throws(() => c.mergeCodex(text, launch));
});
test('comments and settings added inside managed block are not lost', () => {
  const modified = c.mergeCodex('', launch).replace('tool_timeout_sec = 180', 'tool_timeout_sec = 180\ncustom = "mine"');
  assert.throws(() => c.mergeCodex(modified, launch));
});
test('atomic Codex write backs up changed originals, leaves idempotent files alone', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-config-'));
  try {
    const file = path.join(dir, 'config.toml'); fs.writeFileSync(file, '# preserve\n');
    c.writeCodex(file, launch); const files = fs.readdirSync(dir);
    assert.equal(files.filter(n => n.endsWith('.bak')).length, 1);
    assert.equal(fs.readFileSync(path.join(dir, files.find(n => n.endsWith('.bak'))), 'utf8'), '# preserve\n');
    c.writeCodex(file, launch); assert.deepEqual(fs.readdirSync(dir), files);
  } finally { fs.rmSync(dir, { recursive: true, force: true }); }
});
test('invalid installations fail before configuration', () => {
  assert.throws(() => c.assertRepo(os.tmpdir()));
  c.assertRepo(path.join(__dirname, '../../..'));
});
test('shell quoting treats spaces, apostrophes and shell expansions literally', () => {
  assert.equal(c.shellQuote("a'b $(test)"), "'a'\\''b $(test)'");
});
